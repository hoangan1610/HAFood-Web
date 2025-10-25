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

        // === NEW: Đổi phương thức thanh toán cho order đã tạo ===
        public async Task SwitchPaymentAsync(string orderCode, int newMethod, string reason = null)
        {
            if (string.IsNullOrWhiteSpace(_apiBase))
                throw new InvalidOperationException("ApiBaseUrl is not configured.");

            var url = $"{_apiBase}/api/orders/switch-payment/{Uri.EscapeDataString(orderCode)}";

            var body = new { New_Method = newMethod, Reason = reason };
            var json = JsonConvert.SerializeObject(body);

            var req = new HttpRequestMessage(HttpMethod.Post, url)
            {
                Content = new StringContent(json, Encoding.UTF8, "application/json")
            };
            req.Headers.Accept.Clear();
            req.Headers.Accept.ParseAdd("*/*");
            AttachAuthHeader(req);

            var resp = await HttpJson.Client.SendAsync(req);
            var text = await resp.Content.ReadAsStringAsync();
            System.Diagnostics.Debug.WriteLine($"POST {url}\nREQ: {json}\nRESP({(int)resp.StatusCode}): {text}");

            if (!resp.IsSuccessStatusCode)
                throw new ApplicationException($"SwitchPayment failed {(int)resp.StatusCode}: {text}");
        }

        // === NEW: Xin link thanh toán mới cho order đã có ===
        // Ưu tiên endpoint: POST /api/orders/{code}/payment-link { method }
        // Nếu BE dùng endpoint khác, ta fallback thử /api/orders/checkout (sẽ thất bại nếu cart đóng).
        public async Task<string> CreatePaymentLinkForOrderAsync(string orderCode, int method)
        {
            if (string.IsNullOrWhiteSpace(_apiBase))
                throw new InvalidOperationException("ApiBaseUrl is not configured.");

            // 1) Thử endpoint chuyên dụng (khớp gợi ý BE)
            var url1 = $"{_apiBase}/api/orders/{Uri.EscapeDataString(orderCode)}/payment-link";
            var body = new { method };
            var json = JsonConvert.SerializeObject(body);

            var req1 = new HttpRequestMessage(HttpMethod.Post, url1)
            {
                Content = new StringContent(json, Encoding.UTF8, "application/json")
            };
            req1.Headers.Accept.Clear();
            req1.Headers.Accept.ParseAdd("*/*");
            AttachAuthHeader(req1);

            var resp1 = await HttpJson.Client.SendAsync(req1);
            var text1 = await resp1.Content.ReadAsStringAsync();
            System.Diagnostics.Debug.WriteLine($"POST {url1}\nREQ: {json}\nRESP({(int)resp1.StatusCode}): {text1}");

            if (resp1.IsSuccessStatusCode)
            {
                // Chuẩn: trả JSON { payment_Url: "..." } hoặc trả plain text
                try
                {
                    var obj = JsonConvert.DeserializeObject<dynamic>(text1);
                    string payUrl = obj?.payment_Url ?? obj?.payUrl ?? obj?.url;
                    if (!string.IsNullOrWhiteSpace(payUrl)) return (string)payUrl;
                }
                catch { /* ignore */ }

                var trimmed = (text1 ?? "").Trim('"', ' ', '\n', '\r', '\t');
                if (trimmed.StartsWith("http", StringComparison.OrdinalIgnoreCase))
                    return trimmed;
            }

            // 2) Nếu endpoint trên không tồn tại (404) hoặc không success → báo lỗi rõ
            throw new ApplicationException($"Create payment link failed {(int)resp1.StatusCode}: {text1}");
        }

        // ====== GIỮ NGUYÊN CheckoutAsync như bạn đã có ======
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
            req.Headers.Accept.Clear();
            req.Headers.Accept.ParseAdd("*/*");
            AttachAuthHeader(req);

            var resp = await HttpJson.Client.SendAsync(req);
            var respText = await resp.Content.ReadAsStringAsync();

            System.Diagnostics.Debug.WriteLine($"POST {url}\nREQ: {json}\nRESP({(int)resp.StatusCode}): {respText}");

            if (!resp.IsSuccessStatusCode)
                throw new ApplicationException($"Checkout failed {(int)resp.StatusCode}: {respText}");

            try
            {
                var parsed = JsonConvert.DeserializeObject<OrderCheckoutResponse>(respText);
                if (parsed != null &&
                    (parsed.order_Id > 0 || !string.IsNullOrWhiteSpace(parsed.order_Code)))
                {
                    return parsed;
                }
            }
            catch { /* fallback */ }

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
