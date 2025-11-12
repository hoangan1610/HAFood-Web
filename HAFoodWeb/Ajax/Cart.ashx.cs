using System;
using System.IO;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading.Tasks;
using System.Web;
using Newtonsoft.Json;
using HAFoodWeb.Services;       // DeviceTracker, CartService
using HAFoodWeb.Infrastructure;
using HAFoodWeb.Models;         // CartAddRequest, CartResponseDto

namespace HAFoodWeb.Ajax
{
    /// <summary>
    /// Stable badge counter for WebForms (.ashx)
    /// Rules:
    ///  - Authenticated -> ONLY user cart (/api/cart)
    ///  - Guest         -> ONLY device cart (/api/cart?device_uuid=...)
    ///  No cross-fallback to avoid flicker.
    /// </summary>
    public class Cart : HttpTaskAsyncHandler
    {
        private static readonly HttpClient http = CreateHttp();

        private static HttpClient CreateHttp()
        {
            var handler = new HttpClientHandler
            {
                // DEV: self-signed cert?
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
                            int channel = TryGetChannel(ctx);
                            var count = await GetCountStableAsync(ctx, channel).ConfigureAwait(false);
                            WriteJson(ctx, 200, new { ok = true, count });
                            return;
                        }

                    case "add":
                        {
                            var body = await ReadBodyAsync(ctx).ConfigureAwait(false);
                            var req = Deserialize<AddReq>(body) ?? new AddReq();
                            if (req.Qty <= 0) req.Qty = 1;

                            int channel = TryGetChannel(ctx);
                            var deviceUuid = GetUuid(ctx);

                            // Add item (guest flow is acceptable for both states; API will merge to user cart if needed)
                            var svc = new CartService();
                            var add = new CartAddRequest
                            {
                                variant_Id = req.VariantId,
                                quantity = req.Qty
                            };
                            var added = await svc.AddCartItemAsync(deviceUuid, add).ConfigureAwait(false);

                            // Return count from the SAME data source we will use for "count" (stable)
                            var count = await GetCountStableAsync(ctx, channel).ConfigureAwait(false);
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
            var token = ctx?.Request?.Cookies["AuthToken"]?.Value;
            var hasCookie = !string.IsNullOrWhiteSpace(token);
            var hasPrincipal = ctx?.User?.Identity?.IsAuthenticated ?? false;
            return hasCookie || hasPrincipal;
        }

        private static string GetUuid(HttpContext ctx)
        {
            var tracker = new DeviceTracker(ctx.Request, ctx.Response);
            return tracker.GetOrCreateDeviceUuid();
        }

        private static int TryGetChannel(HttpContext ctx)
        {
            // ưu tiên query ?channel=…, fallback header x-channel, default=1
            var q = ctx?.Request?["channel"];
            if (int.TryParse(q, out var c) && c > 0) return c;

            var hdr = ctx?.Request?.Headers["x-channel"];
            if (int.TryParse(hdr, out c) && c > 0) return c;

            return 1;
        }

        /// <summary>
        /// Stable strategy:
        ///  - If AUTH -> ONLY user cart (/api/cart)
        ///  - Else    -> ONLY device cart (/api/cart?device_uuid=...)
        /// </summary>
        private static async Task<int> GetCountStableAsync(HttpContext ctx, int channel)
        {
            var svc = new CartService();
            var uuid = GetUuid(ctx);

            if (IsAuthenticated(ctx))
            {
                // Use direct HTTP to ensure Authorization header present even on same-origin.
                var viaHttp = await GetUserCountViaHttpAsync(ctx, channel).ConfigureAwait(false);
                if (viaHttp >= 0) return viaHttp;

                // Fallback to service (kept in case of transient issues)
                var userCart = await svc.GetCartAsync().ConfigureAwait(false);
                var userCount = ExtractCount(userCart);
                return Math.Max(0, userCount);
            }
            else
            {
                var cart = await svc.GetCartAsync(uuid).ConfigureAwait(false);
                var count = ExtractCount(cart);
                return Math.Max(0, count);
            }
        }

        private static async Task<int> GetUserCountViaHttpAsync(HttpContext ctx, int channel)
        {
            try
            {
                var apiBase = (System.Configuration.ConfigurationManager.AppSettings["ApiBaseUrl"] ?? "").TrimEnd('/');
                if (string.IsNullOrEmpty(apiBase)) return -1;

                var token = ctx?.Request?.Cookies["AuthToken"]?.Value;
                if (string.IsNullOrWhiteSpace(token)) return -1;

                var url = apiBase + "/api/cart";
                if (channel > 0) url += (url.Contains("?") ? "&" : "?") + "channel=" + channel;

                using (var req = new HttpRequestMessage(HttpMethod.Get, url))
                {
                    req.Headers.Accept.ParseAdd("application/json");
                    req.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token);

                    using (var resp = await http.SendAsync(req, HttpCompletionOption.ResponseHeadersRead).ConfigureAwait(false))
                    {
                        if (!resp.IsSuccessStatusCode) return -1;

                        var json = await resp.Content.ReadAsStringAsync().ConfigureAwait(false);
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

        /// <summary>
        /// Ưu tiên header.item_Count; nếu không có, sum quantity; -1 nếu không đọc được
        /// </summary>
        private static int ExtractCount(CartResponseDto dto)
        {
            try
            {
                if (dto?.header?.item_Count >= 0)
                    return dto.header.item_Count;

                if (dto?.items != null)
                    return Math.Max(0, dto.items.Sum(it => it?.quantity ?? 0));
            }
            catch { }
            return -1;
        }

        private static async Task<string> ReadBodyAsync(HttpContext ctx)
        {
            if (ctx?.Request?.InputStream == null) return "";
            ctx.Request.InputStream.Position = 0;
            using (var sr = new StreamReader(ctx.Request.InputStream))
            {
                return await sr.ReadToEndAsync().ConfigureAwait(false);
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

        public override bool IsReusable => false;

        private class AddReq
        {
            public int ProductId { get; set; }   // chưa dùng
            public long VariantId { get; set; }
            public int Qty { get; set; }
        }
    }
}
