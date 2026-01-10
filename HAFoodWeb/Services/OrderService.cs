using HAFoodWeb.Infrastructure;
using HAFoodWeb.Models;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Configuration;
using System.Diagnostics;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Web;

namespace HAFoodWeb.Services
{
    public class OrderService : IOrderService
    {
        private readonly string _apiBase = ConfigurationManager.AppSettings["ApiBaseUrl"]?.TrimEnd('/');

        private void AttachAuthHeader(HttpRequestMessage req)
        {
            string token = null;

            // 1) Cookie
            var ck = HttpContext.Current?.Request?.Cookies["AuthToken"]?.Value;
            if (!string.IsNullOrWhiteSpace(ck))
                token = HttpUtility.UrlDecode(ck);

            // 2) Fallback: Session
            if (string.IsNullOrWhiteSpace(token))
                token = HttpContext.Current?.Session?["JwtToken"] as string;

            // 3) Gắn header
            if (!string.IsNullOrWhiteSpace(token))
            {
                if (token.StartsWith("Bearer ", StringComparison.OrdinalIgnoreCase))
                    token = token.Substring(7).Trim();

                req.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token);
            }
        }

        // ========= Helpers =========
        private static string NormalizeCode(string s)
        {
            if (string.IsNullOrWhiteSpace(s)) return "";
            s = s.Trim().Replace(" ", "");
            return s.ToUpperInvariant();
        }

        private static bool CodeContains(string full, string needleNormalizedUpper)
        {
            if (string.IsNullOrWhiteSpace(needleNormalizedUpper)) return true;
            if (string.IsNullOrWhiteSpace(full)) return false;
            return full.IndexOf(needleNormalizedUpper, StringComparison.OrdinalIgnoreCase) >= 0;
        }

        private static int? TryReadInt(JObject body, string key)
        {
            if (body == null) return null;
            var tok = body.SelectToken(key);
            if (tok == null || tok.Type == JTokenType.Null) return null;
            if (tok.Type == JTokenType.Integer) return tok.Value<int>();
            if (tok.Type == JTokenType.String && int.TryParse(tok.Value<string>(), out var i)) return i;
            return null;
        }

        // =========================================================
        // ✅ NEW CORE: GetMyOrdersAsync (BE lấy uid từ JWT)
        // GET /api/orders?status=&order_code=&page=&page_size=
        // =========================================================
        public async Task<OrderPageDto> GetMyOrdersAsync(int? status = null, string orderCode = null, int page = 1, int pageSize = 20)
        {
            if (string.IsNullOrWhiteSpace(_apiBase))
                throw new InvalidOperationException("ApiBaseUrl is not configured.");

            var code = NormalizeCode(orderCode);

            var url = $"{_apiBase}/api/orders?page={page}&page_size={pageSize}";
            if (status.HasValue) url += $"&status={status.Value}";
            if (!string.IsNullOrWhiteSpace(code)) url += $"&order_code={Uri.EscapeDataString(code)}";

            var req = new HttpRequestMessage(HttpMethod.Get, url);
            req.Headers.Accept.Clear();
            req.Headers.Accept.ParseAdd("*/*");
            AttachAuthHeader(req);

            var resp = await HttpJson.Client.SendAsync(req);
            var json = await resp.Content.ReadAsStringAsync();

            Debug.WriteLine($"GET {url}\nRESP({(int)resp.StatusCode}): {json}");

            if (!resp.IsSuccessStatusCode)
                throw new ApplicationException($"Get orders failed {(int)resp.StatusCode}: {json}");

            return JsonConvert.DeserializeObject<OrderPageDto>(json);
        }

        // =========================================================
        // ✅ LEGACY wrappers (giữ để code cũ không vỡ)
        // =========================================================
        public Task<OrderPageDto> GetOrdersByUserAsync(long userId, int? status = null, int page = 1, int pageSize = 20)
            => GetMyOrdersAsync(status, orderCode: null, page: page, pageSize: pageSize);

        public Task<OrderPageDto> GetOrdersByUserAsync(long userId, int? status, string orderCode, int page, int pageSize)
            => GetMyOrdersAsync(status, orderCode: orderCode, page: page, pageSize: pageSize);

        // =========================================================
        // Đổi phương thức thanh toán cho order đã tạo (safe)
        // =========================================================
        public async Task<SwitchPaymentResult> SwitchPaymentSafeAsync(
            string orderCode, int newMethod, string reason = null, CancellationToken ct = default)
        {
            if (string.IsNullOrWhiteSpace(_apiBase))
            {
                return new SwitchPaymentResult
                {
                    Outcome = SwitchPaymentOutcome.Error,
                    Status = 0,
                    Code = "CLIENT_CONFIG",
                    Message = "ApiBaseUrl is not configured."
                };
            }

            var url = $"{_apiBase}/api/orders/switch-payment/{Uri.EscapeDataString(orderCode)}";
            var payload = new { New_Method = newMethod, Reason = reason };
            var json = JsonConvert.SerializeObject(payload);

            var req = new HttpRequestMessage(HttpMethod.Post, url)
            {
                Content = new StringContent(json, Encoding.UTF8, "application/json")
            };
            req.Headers.Accept.Clear();
            req.Headers.Accept.ParseAdd("*/*");
            AttachAuthHeader(req);

            HttpResponseMessage resp;
            string text;

            try
            {
                resp = await HttpJson.Client.SendAsync(req);
                text = await resp.Content.ReadAsStringAsync();
            }
            catch (Exception ex)
            {
                return new SwitchPaymentResult
                {
                    Outcome = SwitchPaymentOutcome.Error,
                    Status = 0,
                    Code = "NETWORK_ERROR",
                    Message = ex.Message
                };
            }

            Debug.WriteLine($"POST {url}\nREQ: {json}\nRESP({(int)resp.StatusCode}): {text}");

            JObject body = null;
            try { if (!string.IsNullOrWhiteSpace(text)) body = JObject.Parse(text); } catch { }

            if (resp.IsSuccessStatusCode)
            {
                return new SwitchPaymentResult
                {
                    Outcome = SwitchPaymentOutcome.Switched,
                    Status = resp.StatusCode,
                    RawBody = text,
                    OrderCode = body?.Value<string>("order_code")
                                ?? body?.Value<string>("orderCode")
                                ?? body?.Value<string>("Order_Code"),
                    NewStatus = body?.Value<string>("new_status")
                                ?? body?.Value<string>("newStatus")
                                ?? body?.Value<string>("New_Status"),
                    NewMethod = TryReadInt(body, "new_method")
                                ?? TryReadInt(body, "newMethod")
                                ?? TryReadInt(body, "New_Method")
                };
            }

            switch (resp.StatusCode)
            {
                case HttpStatusCode.Unauthorized:
                    return new SwitchPaymentResult
                    {
                        Outcome = SwitchPaymentOutcome.Unauthorized,
                        Status = resp.StatusCode,
                        RawBody = text,
                        Code = body?.Value<string>("code"),
                        Message = body?.Value<string>("message")
                    };
                case HttpStatusCode.Forbidden:
                    return new SwitchPaymentResult
                    {
                        Outcome = SwitchPaymentOutcome.Forbidden,
                        Status = resp.StatusCode,
                        RawBody = text,
                        Code = body?.Value<string>("code"),
                        Message = body?.Value<string>("message")
                    };
                case HttpStatusCode.NotFound:
                    return new SwitchPaymentResult
                    {
                        Outcome = SwitchPaymentOutcome.NotFound,
                        Status = resp.StatusCode,
                        RawBody = text,
                        Code = body?.Value<string>("code") ?? "ORDER_NOT_FOUND",
                        Message = body?.Value<string>("message")
                    };
                case HttpStatusCode.BadRequest:
                    {
                        var code = (body?.Value<string>("code") ?? "").ToUpperInvariant();
                        if (code == "ORDER_ALREADY_PAID")
                        {
                            return new SwitchPaymentResult
                            {
                                Outcome = SwitchPaymentOutcome.AlreadyPaid,
                                Status = resp.StatusCode,
                                RawBody = text,
                                Code = code,
                                Message = body?.Value<string>("message") ?? "Order is already paid."
                            };
                        }
                        return new SwitchPaymentResult
                        {
                            Outcome = SwitchPaymentOutcome.Error,
                            Status = resp.StatusCode,
                            RawBody = text,
                            Code = string.IsNullOrWhiteSpace(code) ? "BAD_REQUEST" : code,
                            Message = body?.Value<string>("message") ?? "Bad request."
                        };
                    }
            }

            return new SwitchPaymentResult
            {
                Outcome = SwitchPaymentOutcome.Error,
                Status = resp.StatusCode,
                RawBody = text,
                Code = body?.Value<string>("code"),
                Message = body?.Value<string>("message") ?? $"HTTP {(int)resp.StatusCode}"
            };
        }

        // =========================================================
        // Xin link thanh toán mới cho order đã có
        // =========================================================
        public async Task<string> CreatePaymentLinkForOrderAsync(string orderCode, int method)
        {
            if (string.IsNullOrWhiteSpace(_apiBase))
                throw new InvalidOperationException("ApiBaseUrl is not configured.");

            var codeEsc = Uri.EscapeDataString(orderCode);
            var url = $"{_apiBase}/api/orders/{codeEsc}/payment-link";

            var bodyObj = new { Method = method };
            var json = JsonConvert.SerializeObject(bodyObj);

            var req = new HttpRequestMessage(HttpMethod.Post, url)
            {
                Content = new StringContent(json, Encoding.UTF8, "application/json")
            };
            req.Headers.Accept.ParseAdd("*/*");
            AttachAuthHeader(req);

            var resp = await HttpJson.Client.SendAsync(req);
            var text = await resp.Content.ReadAsStringAsync();

            Debug.WriteLine($"POST {url}\nREQ: {json}\nRESP({(int)resp.StatusCode}): {text}");

            if (!resp.IsSuccessStatusCode)
                throw new ApplicationException($"Create payment link failed {(int)resp.StatusCode}: {text}");

            JObject obj;
            try
            {
                obj = JsonConvert.DeserializeObject<JObject>(text);
            }
            catch
            {
                var trimmed = (text ?? "").Trim().Trim('"');
                if (!string.IsNullOrWhiteSpace(trimmed) &&
                    trimmed.StartsWith("http", StringComparison.OrdinalIgnoreCase))
                {
                    return trimmed;
                }
                throw new ApplicationException("Success but cannot parse payment url: " + text);
            }

            var payUrl = obj.Value<string>("payment_url")
                     ?? obj.Value<string>("payment_Url")
                     ?? obj.Value<string>("paymentUrl")
                     ?? obj.Value<string>("url");

            if (string.IsNullOrWhiteSpace(payUrl))
                throw new ApplicationException("Payment url not found in response: " + text);

            return payUrl;
        }

        // =========================================================
        // Checkout
        // =========================================================
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

            Debug.WriteLine($"POST {url}\nREQ: {json}\nRESP({(int)resp.StatusCode}): {respText}");

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
            catch { }

            var trimmed = (respText ?? "").Trim().Trim('"');
            if (!string.IsNullOrEmpty(trimmed))
                return new OrderCheckoutResponse { order_Code = trimmed };

            return null;
        }

        // =========================================================
        // GET ORDER DETAIL BY ID
        // =========================================================
        public async Task<OrderDetailDto> GetOrderDetailAsync(long orderId)
        {
            if (string.IsNullOrWhiteSpace(_apiBase))
                throw new InvalidOperationException("ApiBaseUrl is not configured.");

            var url = $"{_apiBase}/api/orders/{orderId}";
            var req = new HttpRequestMessage(HttpMethod.Get, url);
            AttachAuthHeader(req);

            var resp = await HttpJson.Client.SendAsync(req);
            var json = await resp.Content.ReadAsStringAsync();

            Debug.WriteLine($"GET {url} => {(int)resp.StatusCode}");
            Debug.WriteLine(json);

            if (!resp.IsSuccessStatusCode)
            {
                Debug.WriteLine($"GET {url} FAILED: {(int)resp.StatusCode}\n{json}");
                return null;
            }

            try
            {
                return JsonConvert.DeserializeObject<OrderDetailDto>(json);
            }
            catch (Exception ex)
            {
                Debug.WriteLine("❌ Deserialize OrderDetailDto: " + ex);
                return null;
            }
        }

        // =========================================================
        // ✅ NEW: DETAIL BY CODE (không scan nữa)
        // dùng server filter order_code -> lấy id -> gọi detail
        // =========================================================
        public async Task<OrderDetailDto> GetOrderDetailByCodeAsync(string orderCode)
        {
            if (string.IsNullOrWhiteSpace(_apiBase) || string.IsNullOrWhiteSpace(orderCode))
                return null;

            var code = NormalizeCode(orderCode);
            if (string.IsNullOrWhiteSpace(code)) return null;

            // gọi list với order_code (SP dùng LIKE => có thể trả nhiều)
            var page = await GetMyOrdersAsync(status: null, orderCode: code, page: 1, pageSize: 20);
            var items = page?.items;
            if (items == null || items.Count == 0) return null;

            // ưu tiên exact match sau khi normalize, fallback contains
            var found = items.FirstOrDefault(x => string.Equals(NormalizeCode(x.order_Code), code, StringComparison.OrdinalIgnoreCase))
                       ?? items.FirstOrDefault(x => CodeContains(NormalizeCode(x.order_Code), code))
                       ?? items.FirstOrDefault();

            if (found == null) return null;

            return await GetOrderDetailAsync(found.id);
        }

        // =========================================================
        // SMART PICKER (code trước, fallback id)
        // =========================================================
        public async Task<OrderDetailDto> GetOrderDetailSmartAsync(string codeOrId)
        {
            if (string.IsNullOrWhiteSpace(codeOrId)) return null;

            var byCode = await GetOrderDetailByCodeAsync(codeOrId);
            if (byCode != null) return byCode;

            if (long.TryParse(codeOrId, out var id))
                return await GetOrderDetailAsync(id);

            return null;
        }
    }

    // ===== enum/DTO phụ trợ =====
    public enum SwitchPaymentOutcome
    {
        Switched,
        AlreadyPaid,
        NotFound,
        Unauthorized,
        Forbidden,
        Error
    }

    public sealed class SwitchPaymentResult
    {
        public SwitchPaymentOutcome Outcome { get; set; }
        public HttpStatusCode Status { get; set; }
        public string RawBody { get; set; }
        public string Code { get; set; }
        public string Message { get; set; }
        public string OrderCode { get; set; }
        public int? NewMethod { get; set; }
        public string NewStatus { get; set; }
    }

    public class OrderCheckoutRequest
    {
        public long? cart_Id { get; set; }
        public long? device_Id { get; set; }

        public string ship_Name { get; set; } = "";
        public string ship_Full_Address { get; set; } = "";
        public string ship_Phone { get; set; } = "";

        public byte payment_Method { get; set; }

        public string ip { get; set; }
        public string note { get; set; }

        public long? address_Id { get; set; }

        public string promo_Code { get; set; }
        public long[] selected_Line_Ids { get; set; }
        public OrderItem[] items { get; set; }

        public string ship_City_Code { get; set; }
        public string ship_Ward_Code { get; set; }
        public int? total_Weight_Gram { get; set; }
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
    }
}
