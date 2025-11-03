using HAFoodWeb.Infrastructure;
using HAFoodWeb.Models;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Diagnostics;
using System.Globalization;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Threading.Tasks;

namespace HAFoodWeb.Services
{
    public class AddressService : IAddressService
    {
        private readonly string _apiBase = ConfigurationManager.AppSettings["ApiBaseUrl"]?.TrimEnd('/');

        private void AttachAuthHeader(HttpRequestMessage req)
        {
            var token = System.Web.HttpContext.Current?.Request?.Cookies["AuthToken"]?.Value;
            if (!string.IsNullOrEmpty(token))
                req.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token);
        }

        private static readonly JsonSerializerSettings _jsonSettings = new JsonSerializerSettings
        {
            Culture = CultureInfo.InvariantCulture,
            NullValueHandling = NullValueHandling.Ignore
        };

        public async Task<IReadOnlyList<AddressDto>> GetMyAddressesAsync(string token, bool onlyActive = true)
        {
            var url = $"{_apiBase}/api/addresses/me?onlyActive={(onlyActive ? "true" : "false")}";
            var req = new HttpRequestMessage(HttpMethod.Get, url);
            AttachAuthHeader(req);

            var resp = await HttpJson.Client.SendAsync(req);
            var json = await resp.Content.ReadAsStringAsync();

            if (!resp.IsSuccessStatusCode)
            {
                Debug.WriteLine($"GET {url} FAILED: {(int)resp.StatusCode}\n{json}");
                return Array.Empty<AddressDto>();
            }

            var env = JsonConvert.DeserializeObject<ApiEnvelope<List<AddressDto>>>(json);
            return env?.data ?? new List<AddressDto>();
        }

        public async Task<AddressDto> CreateAddressAsync(string token, AddressCreateRequest request)
        {
            var url = $"{_apiBase}/api/addresses";
            var content = new StringContent(JsonConvert.SerializeObject(request, _jsonSettings), Encoding.UTF8, "application/json");
            var req = new HttpRequestMessage(HttpMethod.Post, url) { Content = content };
            AttachAuthHeader(req);

            var resp = await HttpJson.Client.SendAsync(req);
            var json = await resp.Content.ReadAsStringAsync();

            if (!resp.IsSuccessStatusCode)
            {
                Debug.WriteLine($"POST {url} FAILED\nBody:{await content.ReadAsStringAsync()}\nResp:{json}");
                return null;
            }

            var env = JsonConvert.DeserializeObject<ApiEnvelope<AddressDto>>(json);
            return env?.data;
        }

        public async Task<AddressDto> UpdateAddressAsync(string token, long id, AddressUpdateRequest request)
        {
            var url = $"{_apiBase}/api/addresses/{id}";
            var content = new StringContent(JsonConvert.SerializeObject(request, _jsonSettings), Encoding.UTF8, "application/json");
            var req = new HttpRequestMessage(HttpMethod.Put, url) { Content = content };
            AttachAuthHeader(req);

            var resp = await HttpJson.Client.SendAsync(req);
            var json = await resp.Content.ReadAsStringAsync();

            if (!resp.IsSuccessStatusCode)
            {
                Debug.WriteLine($"PUT {url} FAILED\nBody:{await content.ReadAsStringAsync()}\nResp:{json}");
                return null;
            }

            var env = JsonConvert.DeserializeObject<ApiEnvelope<AddressDto>>(json);
            return env?.data;
        }

        public async Task<bool> DeleteAddressAsync(string token, long id)
        {
            var url = $"{_apiBase}/api/addresses/{id}";
            var req = new HttpRequestMessage(HttpMethod.Delete, url);
            AttachAuthHeader(req);

            var resp = await HttpJson.Client.SendAsync(req);
            var json = await resp.Content.ReadAsStringAsync();

            if (!resp.IsSuccessStatusCode)
            {
                Debug.WriteLine($"DELETE {url} FAILED\n{json}");
                return false;
            }

            return true;
        }

        public async Task<AddressDto> SetDefaultAsync(string token, long id)
        {
            var url = $"{_apiBase}/api/addresses/{id}/default";
            var req = new HttpRequestMessage(HttpMethod.Put, url);
            AttachAuthHeader(req);

            var resp = await HttpJson.Client.SendAsync(req);
            var json = await resp.Content.ReadAsStringAsync();

            if (!resp.IsSuccessStatusCode)
            {
                Debug.WriteLine($"PUT {url} FAILED\n{json}");
                return null;
            }

            var env = JsonConvert.DeserializeObject<ApiEnvelope<AddressDto>>(json);
            return env?.data;
        }

        public async Task<AddressDto> GetMyAddressByIdAsync(string token, long id)
        {
            var list = await GetMyAddressesAsync(token, onlyActive: false);
            return list?.FirstOrDefault(a => a.id == id);
        }
    }
}
