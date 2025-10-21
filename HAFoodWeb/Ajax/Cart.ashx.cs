using System;
using System.IO;
using System.Web;
using Newtonsoft.Json;
using HAFoodWeb.Services;       // DeviceTracker
using HAFoodWeb.Infrastructure; // HttpJson
using HAFoodWeb.Models;         // CartAddRequest, CartResponseDto

namespace HAFoodWeb.Ajax
{
    public class Cart : IHttpHandler
    {
        public void ProcessRequest(HttpContext ctx)
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
                            var count = GetCountSync(ctx);
                            WriteJson(ctx, 200, new { ok = true, count });
                            return;
                        }

                    case "add":
                        {
                            var body = ReadBody(ctx);
                            var req = Deserialize<AddReq>(body) ?? new AddReq();
                            if (req.Qty <= 0) req.Qty = 1;

                            var deviceUuid = GetUuid(ctx);
                            var svc = new CartService();

                            // GÁN ĐÚNG THEO MODEL HIỆN TẠI
                            var add = new CartAddRequest
                            {
                                variant_Id = req.VariantId, // long
                                quantity = req.Qty        // int
                                                          // name_Variant / price_Variant / image_Variant: nếu cần có thể điền thêm
                            };

                            var added = svc.AddCartItemAsync(deviceUuid, add).GetAwaiter().GetResult();
                            var count = ExtractCount(added);
                            if (count < 0) count = GetCountSync(ctx); // fallback

                            WriteJson(ctx, 200, new { ok = true, count });
                            return;
                        }

                    default:
                        WriteJson(ctx, 404, new { ok = false, message = "Unknown action" });
                        return;
                }
            }
            catch (Exception ex)
            {
                WriteJson(ctx, 500, new { ok = false, message = ex.Message });
            }
        }

        // ===== Helpers =====
        private static string GetUuid(HttpContext ctx)
        {
            var tracker = new DeviceTracker(ctx.Request, ctx.Response);
            return tracker.GetOrCreateDeviceUuid();
        }

        private static int GetCountSync(HttpContext ctx)
        {
            var uuid = GetUuid(ctx);
            var svc = new CartService();
            var cart = svc.GetCartAsync(uuid).GetAwaiter().GetResult();
            var c = ExtractCount(cart);
            if (c >= 0) return c;

            int sum = 0;
            if (cart?.items != null)
            {
                foreach (var it in cart.items) sum += (it?.quantity ?? 0);
            }
            return sum;
        }

        private static int ExtractCount(CartResponseDto dto)
        {
            try { if (dto?.header != null) return dto.header.item_Count; }
            catch { }
            return -1;
        }

        private static string ReadBody(HttpContext ctx)
        {
            if (ctx.Request.InputStream == null) return "";
            ctx.Request.InputStream.Position = 0;
            using (var sr = new StreamReader(ctx.Request.InputStream))
                return sr.ReadToEnd();
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

        public bool IsReusable => false;

        // body từ JS: { productId, variantId, qty }
        private class AddReq
        {
            public int ProductId { get; set; }  // hiện không dùng
            public long VariantId { get; set; } // long để khớp variant_Id
            public int Qty { get; set; }
        }
    }
}
