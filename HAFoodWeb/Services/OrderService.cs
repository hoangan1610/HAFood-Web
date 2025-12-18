using HAFoodWeb.Infrastructure;
using HAFoodWeb.Models;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Configuration;
using System.Diagnostics;
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

            // 2) Fallback: Session (đúng với code bạn đang dùng trong ASPX)
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


        // === NEW: Đổi phương thức thanh toán cho order đã tạo (an toàn, không throw) ===
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
                text = await resp.Content.ReadAsStringAsync(); // ❗ Không truyền ct trên .NET Framework
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
            try { if (!string.IsNullOrWhiteSpace(text)) body = JObject.Parse(text); } catch { /* ignore */ }

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

        private static int? TryReadInt(JObject body, string key)
        {
            if (body == null) return null;
            var tok = body.SelectToken(key);
            if (tok == null || tok.Type == JTokenType.Null) return null;
            if (tok.Type == JTokenType.Integer) return tok.Value<int>();
            if (tok.Type == JTokenType.String && int.TryParse(tok.Value<string>(), out var i)) return i;
            return null;
        }

        // === NEW: Xin link thanh toán mới cho order đã có ===
        public async Task<string> CreatePaymentLinkForOrderAsync(string orderCode, int method)
        {
            if (string.IsNullOrWhiteSpace(_apiBase))
                throw new InvalidOperationException("ApiBaseUrl is not configured.");

            var codeEsc = Uri.EscapeDataString(orderCode);
            var url = $"{_apiBase}/api/orders/{codeEsc}/payment-link";

            // Body khớp CreatePayLinkDto { Method }
            var bodyObj = new { Method = method }; // hoặc new { method = method }; model binding case-insensitive nên đều được
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
                // fallback: nếu BE sau này trả plain text URL
                var trimmed = (text ?? "").Trim().Trim('"');
                if (!string.IsNullOrWhiteSpace(trimmed) &&
                    trimmed.StartsWith("http", StringComparison.OrdinalIgnoreCase))
                {
                    return trimmed;
                }
                throw new ApplicationException("Success but cannot parse payment url: " + text);
            }

            // CHÚ Ý: đúng key là payment_url (chữ u thường)
            var payUrl = obj.Value<string>("payment_url")
                     ?? obj.Value<string>("payment_Url")
                     ?? obj.Value<string>("paymentUrl")
                     ?? obj.Value<string>("url");

            if (string.IsNullOrWhiteSpace(payUrl))
                throw new ApplicationException("Payment url not found in response: " + text);

            return payUrl;
        }




        // ====== CheckoutAsync giữ nguyên logic, chỉ bỏ ct trong ReadAsStringAsync ======
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
            catch { /* fallback */ }

            var trimmed = (respText ?? "").Trim().Trim('"');
            if (!string.IsNullOrEmpty(trimmed))
                return new OrderCheckoutResponse { order_Code = trimmed };

            return null;
        }

        // ====== Các hàm GetOrdersByUserAsync / GetOrderDetailAsync giữ nguyên, chỉ ReadAsStringAsync() không ct ======
        public async Task<OrderPageDto> GetOrdersByUserAsync(long userId, int? status = null, int page = 1, int pageSize = 20)
        {
            var url = $"{_apiBase}/api/orders?userId={userId}&page={page}&page_size={pageSize}";
            if (status.HasValue) url += $"&status={status.Value}";

            var req = new HttpRequestMessage(HttpMethod.Get, url);
            AttachAuthHeader(req);

            var resp = await HttpJson.Client.SendAsync(req);
            var json = await resp.Content.ReadAsStringAsync();

            if (!resp.IsSuccessStatusCode)
            {
                Debug.WriteLine($"GET {url} FAILED: {(int)resp.StatusCode}\n{json}");
                return null;
            }

            return JsonConvert.DeserializeObject<OrderPageDto>(json);
        }

        public async Task<OrderDetailDto> GetOrderDetailAsync(long orderId)
        {
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


        // ===================== DETAIL BY CODE (Dò trang /api/orders) =====================
        public async Task<OrderDetailDto> GetOrderDetailByCodeAsync(string orderCode)
        {
            if (string.IsNullOrWhiteSpace(_apiBase) || string.IsNullOrWhiteSpace(orderCode))
                return null;

            string code = orderCode.Trim();
            int page = 1;
            int pageSize = 50; // tăng nếu BE cho phép (100 càng tốt)

            while (true)
            {
                var url = $"{_apiBase}/api/orders?page={page}&page_size={pageSize}";
                var req = new HttpRequestMessage(HttpMethod.Get, url);
                AttachAuthHeader(req);

                HttpResponseMessage resp;
                string json;

                try
                {
                    resp = await HttpJson.Client.SendAsync(req);
                    json = await resp.Content.ReadAsStringAsync();
                }
                catch (Exception ex)
                {
                    Debug.WriteLine($"GET {url} ERROR: {ex}");
                    return null;
                }

                if (!resp.IsSuccessStatusCode)
                {
                    Debug.WriteLine($"GET {url} FAILED: {(int)resp.StatusCode}\n{json}");
                    return null;
                }

                OrderPageDto pageDto = null;
                try { pageDto = JsonConvert.DeserializeObject<OrderPageDto>(json); }
                catch (Exception ex)
                {
                    Debug.WriteLine("❌ Deserialize OrderPageDto: " + ex);
                    return null;
                }

                if (pageDto?.items != null && pageDto.items.Count > 0)
                {
                    var found = pageDto.items.Find(x => string.Equals(x.order_Code, code, StringComparison.OrdinalIgnoreCase));
                    if (found != null)
                    {
                        // lấy chi tiết theo id
                        return await GetOrderDetailAsync(found.id);
                    }
                }

                // tính trang tiếp
                if (pageDto == null || pageDto.pageSize <= 0) return null;

                int totalPages = (int)Math.Ceiling(pageDto.totalCount / (double)pageDto.pageSize);
                if (totalPages <= 0) totalPages = page; // phòng khi BE không set totalCount

                if (page >= totalPages) break;
                page++;
            }

            return null; // không tìm thấy
        }

        // ===================== SMART PICKER (ưu tiên code) =====================
        public async Task<OrderDetailDto> GetOrderDetailSmartAsync(string codeOrId)
        {
            if (string.IsNullOrWhiteSpace(codeOrId)) return null;

            // thử coi như CODE trước
            var byCode = await GetOrderDetailByCodeAsync(codeOrId);
            if (byCode != null) return byCode;

            // fallback: nếu là số -> thử id
            if (long.TryParse(codeOrId, out var id))
                return await GetOrderDetailAsync(id);

            return null;
        }
    }

    // ===== DTO / enum (để ngoài class, trong cùng namespace) =====
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
        public string RawBody { get; set; }   // bỏ ?
        public string Code { get; set; }      // bỏ ?
        public string Message { get; set; }   // bỏ ?
        public string OrderCode { get; set; } // bỏ ?
        public int? NewMethod { get; set; }
        public string NewStatus { get; set; } // bỏ ?
    }

    // ✅ Cho phép null ở value types: long?, byte?
    // ===== DTO gửi lên API /api/orders/checkout =====
    public class OrderCheckoutRequest
    {
        public long? cart_Id { get; set; }          // nullable để gửi null
        public long? device_Id { get; set; }        // nullable

        public string ship_Name { get; set; } = "";
        public string ship_Full_Address { get; set; } = "";
        public string ship_Phone { get; set; } = "";

        public byte payment_Method { get; set; }    // tinyint -> byte

        public string ip { get; set; }              // optional
        public string note { get; set; }            // optional

        public long? address_Id { get; set; }       // nullable

        public string promo_Code { get; set; }      // optional
        public long[] selected_Line_Ids { get; set; }  // optional
        public OrderItem[] items { get; set; }          // optional

        // ✅ NEW: để BE tính phí ship theo địa chỉ + khối lượng
        public string ship_City_Code { get; set; }      // mã tỉnh/thành
        public string ship_Ward_Code { get; set; }      // mã xã/phường
        public int? total_Weight_Gram { get; set; }     // tổng gram tất cả item
    }

    // Mảng items[]
    public class OrderItem
    {
        public long variant_Id { get; set; }
        public int quantity { get; set; }
    }



   

    public class OrderCheckoutResponse
    {
        public long order_Id { get; set; }
        public string order_Code { get; set; }   // bỏ ?
        public string payment_Url { get; set; }  // bỏ ?
    }
}


   

