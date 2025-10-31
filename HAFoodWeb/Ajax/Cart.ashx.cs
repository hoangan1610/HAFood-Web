using System;
using System.IO;
using System.Linq;
using System.Net.Http;
using System.Threading.Tasks;
using System.Web;
using Newtonsoft.Json;
using HAFoodWeb.Services;       // DeviceTracker, CartService
using HAFoodWeb.Infrastructure;
using HAFoodWeb.Models;         // CartAddRequest, CartResponseDto

namespace HAFoodWeb.Ajax
{
    // WebForms async handler cho .NET Framework
    public class Cart : HttpTaskAsyncHandler
    {
        private static readonly HttpClient http = CreateHttp();

        private static HttpClient CreateHttp()
        {
            var handler = new HttpClientHandler
            {
                // DEV self-signed cert? Bật dòng dưới trong môi trường DEV:
                // ServerCertificateCustomValidationCallback = (m, c, ch, e) => true
            };
            var h = new HttpClient(handler);
            h.Timeout = TimeSpan.FromSeconds(10);
            return h;
        }

        public override async Task ProcessRequestAsync(HttpContext ctx)
        {
            ctx.Response.ContentType = "application/json; charset=utf-8";
            ctx.Response.Cache.SetCacheability(HttpCacheability.NoCache);

            var action = (ctx.Request["action"] ?? "").Trim().ToLowerInvariant();
            if (string.IsNullOrEmpty(action))
            {
                WriteJson(ctx, 400, new { ok = false, message = "Missing action" });
                return;
            }

            try
            {
                switch (action)
                {
                    case "count":
                        {
                            var count = await GetCountSmartAsync(ctx);
                            WriteJson(ctx, 200, new { ok = true, count });
                            return;
                        }

                    case "add":
                        {
                            var body = await ReadBodyAsync(ctx);
                            var req = Deserialize<AddReq>(body) ?? new AddReq();
                            if (req.Qty <= 0) req.Qty = 1;

                            var deviceUuid = GetUuid(ctx);
                            var svc = new CartService();

                            var add = new CartAddRequest
                            {
                                variant_Id = req.VariantId,
                                quantity = req.Qty
                            };

                            var added = await svc.AddCartItemAsync(deviceUuid, add);
                            var count = ExtractCount(added);
                            if (count < 0) count = await GetCountSmartAsync(ctx);

                            WriteJson(ctx, 200, new { ok = true, count });
                            return;
                        }

                    default:
                        WriteJson(ctx, 404, new { ok = false, message = "Unknown action" });
                        return;
                }
            }
            catch (TaskCanceledException)
            {
                WriteJson(ctx, 504, new { ok = false, message = "Timeout" });
            }
            catch (Exception ex)
            {
                WriteJson(ctx, 500, new { ok = false, message = ex.Message });
            }
        }

        // ================= Helpers =================

        private static bool IsAuthenticated(HttpContext ctx)
        {
            var hasCookie = !string.IsNullOrWhiteSpace(ctx != null && ctx.Request != null && ctx.Request.Cookies["AuthToken"] != null ? ctx.Request.Cookies["AuthToken"].Value : null);
            var hasPrincipal = (ctx != null && ctx.User != null && ctx.User.Identity != null) ? ctx.User.Identity.IsAuthenticated : false;
            return hasCookie || hasPrincipal;
        }

        private static string GetUuid(HttpContext ctx)
        {
            var tracker = new DeviceTracker(ctx.Request, ctx.Response);
            return tracker.GetOrCreateDeviceUuid();
        }

        // Đếm “thông minh” (async, tránh deadlock)
        private static async Task<int> GetCountSmartAsync(HttpContext ctx)
        {
            var svc = new CartService();
            var uuid = GetUuid(ctx);

            if (IsAuthenticated(ctx))
            {
                // 1) Ưu tiên GIỎ USER
                var userCart = await svc.GetCartAsync();
                var userCount = ExtractCount(userCart);
                if (userCount > 0) return userCount;
                if (userCount == 0) return 0; // user có giỏ nhưng rỗng

                // 1b) Thử gọi HTTP trực tiếp (Authorization) không kèm device
                var direct = await GetUserCountViaHttpAsync(ctx);
                if (direct >= 0) return direct;

                // 2) Fallback DEVICE
                var guestCart = await svc.GetCartAsync(uuid);
                var guestCount = ExtractCount(guestCart);
                return Math.Max(0, guestCount);
            }
            else
            {
                var cart = await svc.GetCartAsync(uuid);
                var count = ExtractCount(cart);
                return Math.Max(0, count);
            }
        }

        private static async Task<int> GetUserCountViaHttpAsync(HttpContext ctx)
        {
            try
            {
                var apiBase = (System.Configuration.ConfigurationManager.AppSettings["ApiBaseUrl"] ?? "").TrimEnd('/');
                if (string.IsNullOrEmpty(apiBase)) return -1;

                var token = ctx.Request.Cookies["AuthToken"] != null ? ctx.Request.Cookies["AuthToken"].Value : null;
                if (string.IsNullOrWhiteSpace(token)) return -1;

                using (var req = new HttpRequestMessage(HttpMethod.Get, apiBase + "/api/cart"))
                {
                    req.Headers.Accept.ParseAdd("application/json");
                    req.Headers.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", token);

                    using (var resp = await http.SendAsync(req, HttpCompletionOption.ResponseHeadersRead))
                    {
                        if (!resp.IsSuccessStatusCode) return -1;

                        var json = await resp.Content.ReadAsStringAsync();
                        var dto = JsonConvert.DeserializeObject<CartResponseDto>(json);
                        return ExtractCount(dto);
                    }
                }
            }
            catch
            {
                return -1;
            }
        }

        // Ưu tiên header.item_Count; nếu không có, sum quantity; -1 nếu không đọc được
        private static int ExtractCount(CartResponseDto dto)
        {
            try
            {
                if (dto != null && dto.header != null && dto.header.item_Count >= 0)
                    return dto.header.item_Count;

                if (dto != null && dto.items != null)
                    return Math.Max(0, dto.items.Sum(it => it != null ? it.quantity : 0));
            }
            catch { }
            return -1;
        }

        private static async Task<string> ReadBodyAsync(HttpContext ctx)
        {
            if (ctx.Request.InputStream == null) return "";
            ctx.Request.InputStream.Position = 0;
            using (var sr = new StreamReader(ctx.Request.InputStream))
            {
                return await sr.ReadToEndAsync();
            }
        }

        private static T Deserialize<T>(string s)
        {
            if (string.IsNullOrWhiteSpace(s)) return default(T);
            return JsonConvert.DeserializeObject<T>(s);
        }

        private static void WriteJson(HttpContext ctx, int status, object obj)
        {
            ctx.Response.StatusCode = status;
            ctx.Response.Write(JsonConvert.SerializeObject(obj));
        }

        public override bool IsReusable { get { return false; } }

        private class AddReq
        {
            public int ProductId { get; set; }   // chưa dùng
            public long VariantId { get; set; }
            public int Qty { get; set; }
        }
    }
}
