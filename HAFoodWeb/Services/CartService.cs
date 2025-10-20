using HAFoodWeb.Infrastructure;
using HAFoodWeb.Models;
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
    public class CartService : ICartService
    {
        private readonly string _apiBase = ConfigurationManager.AppSettings["ApiBaseUrl"]?.TrimEnd('/');

        private void AttachAuthHeader(HttpClient client)
        {
            var token = HttpContext.Current.Request.Cookies["AuthToken"]?.Value;
            client.DefaultRequestHeaders.Authorization = null;

            if (!string.IsNullOrEmpty(token))
            {
                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);
            }
        }

        // 🛒 Lấy giỏ hàng
        public async Task<CartResponseDto> GetCartAsync(long deviceId)
        {
            var url = $"{_apiBase}/api/cart?device_id={deviceId}";
            try
            {
                AttachAuthHeader(HttpJson.Client);
                var resp = await HttpJson.Client.GetAsync(url);
                var json = await resp.Content.ReadAsStringAsync();

                if (!resp.IsSuccessStatusCode) return null;
                return JsonConvert.DeserializeObject<CartResponseDto>(json);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("GetCartAsync failed: " + ex.Message);
                return null;
            }
        }

        // ➕ Thêm sản phẩm vào giỏ
        public async Task<CartResponseDto> AddCartItemAsync(long deviceId, CartAddRequest item)
        {
            var url = $"{_apiBase}/api/cart/items?device_id={deviceId}";
            try
            {
                AttachAuthHeader(HttpJson.Client);

                var json = JsonConvert.SerializeObject(item);
                System.Diagnostics.Debug.WriteLine("📤 POST " + url);
                System.Diagnostics.Debug.WriteLine("📦 BODY " + json);

                var content = new StringContent(json, Encoding.UTF8, "application/json");
                var resp = await HttpJson.Client.PostAsync(url, content);
                var responseJson = await resp.Content.ReadAsStringAsync();

                System.Diagnostics.Debug.WriteLine("📥 RESPONSE STATUS: " + resp.StatusCode);
                System.Diagnostics.Debug.WriteLine("📥 RESPONSE BODY: " + responseJson);

                if (!resp.IsSuccessStatusCode) return null;
                return JsonConvert.DeserializeObject<CartResponseDto>(responseJson);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("AddCartItemAsync failed: " + ex.Message);
                return null;
            }
        }

        // ✏️ Cập nhật số lượng sản phẩm
        public async Task<CartResponseDto> UpdateQuantityAsync(long variantId, long deviceId, int quantity)
        {
            var url = $"{_apiBase}/api/cart/items/{variantId}?device_id={deviceId}";
            var body = new CartUpdateQtyRequest { quantity = quantity };

            try
            {
                AttachAuthHeader(HttpJson.Client);

                var json = JsonConvert.SerializeObject(body);
                var content = new StringContent(json, Encoding.UTF8, "application/json");
                var resp = await HttpJson.Client.PutAsync(url, content);
                var responseJson = await resp.Content.ReadAsStringAsync();

                if (!resp.IsSuccessStatusCode) return null;
                return JsonConvert.DeserializeObject<CartResponseDto>(responseJson);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("UpdateQuantityAsync failed: " + ex.Message);
                return null;
            }
        }

        // ❌ Xóa 1 sản phẩm khỏi giỏ
        public async Task<CartResponseDto> DeleteCartItemAsync(long variantId, long deviceId)
        {
            var url = $"{_apiBase}/api/cart/items/{variantId}?device_id={deviceId}";
            try
            {
                AttachAuthHeader(HttpJson.Client);
                var resp = await HttpJson.Client.DeleteAsync(url);
                var responseJson = await resp.Content.ReadAsStringAsync();

                if (!resp.IsSuccessStatusCode) return null;
                return JsonConvert.DeserializeObject<CartResponseDto>(responseJson);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("DeleteCartItemAsync failed: " + ex.Message);
                return null;
            }
        }

        // 🧹 Xóa toàn bộ sản phẩm trong giỏ
        public async Task<CartResponseDto> ClearCartAsync(long deviceId)
        {
            var url = $"{_apiBase}/api/cart/items?device_id={deviceId}";
            try
            {
                AttachAuthHeader(HttpJson.Client);
                var resp = await HttpJson.Client.DeleteAsync(url);
                var responseJson = await resp.Content.ReadAsStringAsync();

                if (!resp.IsSuccessStatusCode) return null;
                return JsonConvert.DeserializeObject<CartResponseDto>(responseJson);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("ClearCartAsync failed: " + ex.Message);
                return null;
            }
        }
    }
}