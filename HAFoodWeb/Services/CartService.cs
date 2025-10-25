using HAFoodWeb.Infrastructure;
using HAFoodWeb.Models;
using Newtonsoft.Json;
using System.Configuration;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Threading.Tasks;
using System.Web;

namespace HAFoodWeb.Services
{
    public class CartService : ICartService
    {
        private readonly string _apiBase = ConfigurationManager.AppSettings["ApiBaseUrl"]?.TrimEnd('/');

        private void AttachAuthHeader(HttpRequestMessage req)
        {
            var token = System.Web.HttpContext.Current?.Request?.Cookies["AuthToken"]?.Value;
            if (!string.IsNullOrEmpty(token))
                req.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token);
        }

        // === Lấy giỏ: ĐÃ ĐĂNG NHẬP (KHÔNG kèm device_uuid) ===
        public Task<CartResponseDto> GetCartAsync()
            => GetCartInternalAsync(null);

        // === Lấy giỏ: KHÁCH (CÓ kèm device_uuid) ===
        public Task<CartResponseDto> GetCartAsync(string deviceUuid)
            => GetCartInternalAsync(deviceUuid);

        private async Task<CartResponseDto> GetCartInternalAsync(string deviceUuidOrNull)
        {
            var url = string.IsNullOrWhiteSpace(deviceUuidOrNull)
                ? $"{_apiBase}/api/cart"
                : $"{_apiBase}/api/cart?device_uuid={HttpUtility.UrlEncode(deviceUuidOrNull)}";

            var req = new HttpRequestMessage(HttpMethod.Get, url);
            AttachAuthHeader(req);

            var resp = await HttpJson.Client.SendAsync(req);
            var json = await resp.Content.ReadAsStringAsync();
            if (!resp.IsSuccessStatusCode)
            {
                System.Diagnostics.Debug.WriteLine($"GET {url} FAILED: {(int)resp.StatusCode}\n{json}");
                return null;
            }
            return JsonConvert.DeserializeObject<CartResponseDto>(json);
        }

        public async Task<CartResponseDto> AddCartItemAsync(string deviceUuid, CartAddRequest item)
        {
            var url = $"{_apiBase}/api/cart/items?device_uuid={HttpUtility.UrlEncode(deviceUuid)}";
            var settings = new JsonSerializerSettings
            {
                Culture = System.Globalization.CultureInfo.InvariantCulture,
                NullValueHandling = NullValueHandling.Ignore
            };
            var content = new StringContent(JsonConvert.SerializeObject(item, settings), Encoding.UTF8, "application/json");
            var req = new HttpRequestMessage(HttpMethod.Post, url) { Content = content };
            AttachAuthHeader(req);

            var resp = await HttpJson.Client.SendAsync(req);
            var json = await resp.Content.ReadAsStringAsync();
            if (!resp.IsSuccessStatusCode)
            {
                System.Diagnostics.Debug.WriteLine($"POST {url} FAILED\nBody:{await content.ReadAsStringAsync()}\nResp:{json}");
                return null;
            }
            return JsonConvert.DeserializeObject<CartResponseDto>(json);
        }

        public async Task<CartResponseDto> UpdateQuantityAsync(long variantId, string deviceUuid, int quantity)
        {
            var url = $"{_apiBase}/api/cart/items/{variantId}?device_uuid={HttpUtility.UrlEncode(deviceUuid)}";
            var body = new { quantity };
            var content = new StringContent(JsonConvert.SerializeObject(body, new JsonSerializerSettings
            {
                Culture = System.Globalization.CultureInfo.InvariantCulture
            }), Encoding.UTF8, "application/json");
            var req = new HttpRequestMessage(HttpMethod.Put, url) { Content = content };
            AttachAuthHeader(req);

            var resp = await HttpJson.Client.SendAsync(req);
            var json = await resp.Content.ReadAsStringAsync();
            if (!resp.IsSuccessStatusCode)
            {
                System.Diagnostics.Debug.WriteLine($"PUT {url} FAILED\nBody:{await content.ReadAsStringAsync()}\nResp:{json}");
                return null;
            }
            return JsonConvert.DeserializeObject<CartResponseDto>(json);
        }

        public async Task<CartResponseDto> DeleteCartItemAsync(long variantId, string deviceUuid)
        {
            var url = $"{_apiBase}/api/cart/items/{variantId}?device_uuid={HttpUtility.UrlEncode(deviceUuid)}";
            var req = new HttpRequestMessage(HttpMethod.Delete, url);
            AttachAuthHeader(req);

            var resp = await HttpJson.Client.SendAsync(req);
            var json = await resp.Content.ReadAsStringAsync();
            if (!resp.IsSuccessStatusCode)
            {
                System.Diagnostics.Debug.WriteLine($"DELETE {url} FAILED\n{json}");
                return null;
            }
            return JsonConvert.DeserializeObject<CartResponseDto>(json);
        }

        public async Task<CartResponseDto> ClearCartAsync(string deviceUuid)
        {
            var url = $"{_apiBase}/api/cart/items?device_uuid={HttpUtility.UrlEncode(deviceUuid)}";
            var req = new HttpRequestMessage(HttpMethod.Delete, url);
            AttachAuthHeader(req);

            var resp = await HttpJson.Client.SendAsync(req);
            var json = await resp.Content.ReadAsStringAsync();
            if (!resp.IsSuccessStatusCode)
            {
                System.Diagnostics.Debug.WriteLine($"DELETE {url} FAILED\n{json}");
                return null;
            }
            return JsonConvert.DeserializeObject<CartResponseDto>(json);
        }
    }
}
