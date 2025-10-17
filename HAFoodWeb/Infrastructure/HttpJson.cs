using System;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;

namespace HAFoodWeb.Infrastructure
{
    public static class HttpJson
    {
        public static readonly HttpClient Client;

        static HttpJson()
        {
            // Bật TLS 1.2 cho .NET Framework
            ServicePointManager.SecurityProtocol |= SecurityProtocolType.Tls12;

            Client = new HttpClient
            {
                Timeout = TimeSpan.FromSeconds(15)
            };

            // Một số proxy/WAF cần Accept & User-Agent rõ ràng
            Client.DefaultRequestHeaders.Accept.Clear();
            Client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
            Client.DefaultRequestHeaders.UserAgent.ParseAdd("HAFoodWeb/1.0 (+https://hafood.id.vn)");
        }

        /// <summary>
        /// Strict: ném exception nếu HTTP status không thành công.
        /// </summary>
        public static async Task<T> GetJsonAsync<T>(string url)
        {
            var resp = await Client.GetAsync(url);
            resp.EnsureSuccessStatusCode();
            var text = await resp.Content.ReadAsStringAsync();
            return JsonConvert.DeserializeObject<T>(text);
        }

        /// <summary>
        /// Safe: không ném exception; trả fallback nếu lỗi HTTP/deserialize/network.
        /// </summary>
        public static async Task<T> TryGetJsonAsync<T>(string url, T fallback)
        {
            try
            {
                var resp = await Client.GetAsync(url);
                if (!resp.IsSuccessStatusCode) return fallback;

                var text = await resp.Content.ReadAsStringAsync();
                var data = JsonConvert.DeserializeObject<T>(text);
                return data == null ? fallback : data;
            }
            catch
            {
                return fallback;
            }
        }

        public static async Task<HttpResponseMessage> PostJsonAsync<T>(string url, T payload)
        {
            var json = JsonConvert.SerializeObject(payload);
            var content = new StringContent(json, Encoding.UTF8, "application/json");
            return await Client.PostAsync(url, content);
        }

        public static async Task<HttpResponseMessage> PutJsonAsync<T>(string url, T payload)
        {
            var json = JsonConvert.SerializeObject(payload);
            var content = new StringContent(json, Encoding.UTF8, "application/json");
            return await Client.PutAsync(url, content);
        }
    }
}
