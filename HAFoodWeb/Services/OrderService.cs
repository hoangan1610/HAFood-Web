using HAFoodWeb.Infrastructure;
using Newtonsoft.Json;
using System;
using System.Configuration;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Threading.Tasks;
using System.Web;

namespace HAFoodWeb.Services
{
    public class OrderService
    {
        private readonly string _apiBase = ConfigurationManager.AppSettings["ApiBaseUrl"]?.TrimEnd('/');

        private void AttachAuthHeader(HttpRequestMessage req)
        {
            var token = HttpContext.Current?.Request?.Cookies["AuthToken"]?.Value;
            if (!string.IsNullOrEmpty(token))
                req.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token);
        }

        public async Task<OrderCheckoutResponse> CheckoutAsync(OrderCheckoutRequest body)
        {
            if (string.IsNullOrWhiteSpace(_apiBase))
                throw new InvalidOperationException("ApiBaseUrl is not configured.");

            var url = $"{_apiBase}/api/orders/checkout";

            var json = JsonConvert.SerializeObject(body, new JsonSerializerSettings
            {
                Culture = System.Globalization.CultureInfo.InvariantCulture,
                NullValueHandling = NullValueHandling.Ignore
            });

            var req = new HttpRequestMessage(HttpMethod.Post, url)
            {
                Content = new StringContent(json, Encoding.UTF8, "application/json")
            };

            // Backend ghi "text/plain", nên chấp nhận mọi kiểu để an toàn
            req.Headers.Accept.Clear();
            req.Headers.Accept.ParseAdd("*/*");

            AttachAuthHeader(req);

            var resp = await HttpJson.Client.SendAsync(req);
            var respText = await resp.Content.ReadAsStringAsync();

            System.Diagnostics.Debug.WriteLine($"POST {url}\nREQ: {json}\nRESP({(int)resp.StatusCode}): {respText}");

            if (!resp.IsSuccessStatusCode)
                throw new ApplicationException($"Checkout failed {(int)resp.StatusCode}: {respText}");

            // Thử parse JSON trước (kể cả khi server trả text/plain)
            try
            {
                var parsed = JsonConvert.DeserializeObject<OrderCheckoutResponse>(respText);
                if (parsed != null &&
                    (parsed.order_Id > 0 || !string.IsNullOrWhiteSpace(parsed.order_Code)))
                {
                    return parsed;
                }
            }
            catch { /* sẽ fallback */ }

            // Fallback: coi toàn bộ body là mã đơn (text)
            var trimmed = (respText ?? "").Trim().Trim('"');
            if (!string.IsNullOrEmpty(trimmed))
                return new OrderCheckoutResponse { order_Code = trimmed };

            return null;
        }
    }

    // ==== DTO theo schema bạn cung cấp ====
    public class OrderCheckoutRequest
    {
        public long cart_Id { get; set; }                 // nếu không có thì để 0
        public string ship_Name { get; set; }
        public string ship_Full_Address { get; set; }
        public string ship_Phone { get; set; }
        public int payment_Method { get; set; }           // 0: COD, 1: MoMo, 2: VNPAY...
        public string ip { get; set; }
        public string note { get; set; }
        public long address_Id { get; set; }              // nếu không có sổ địa chỉ → 0
        public long device_Id { get; set; }               // nếu backend yêu cầu id thiết bị riêng → map, chưa có → 0
        public string promo_Code { get; set; }
        public long[] selected_Line_Ids { get; set; }
        public OrderItem[] items { get; set; }
    }

    public class OrderItem
    {
        public long variant_Id { get; set; }
        public int quantity { get; set; }
    }

    public class OrderCheckoutResponse
    {
        public long order_Id { get; set; }
        public string order_Code { get; set; }

        public string payment_Url { get; set; }

        // Nếu backend sau này thêm payUrl / redirectUrl, bổ sung ở đây
        // public string payment_Url { get; set; }
    }
}
