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

            // Header mặc định
            Client.DefaultRequestHeaders.Accept.Clear();
            Client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
            Client.DefaultRequestHeaders.UserAgent.ParseAdd("HAFoodWeb/1.0 (+https://hafood.id.vn)");
        }

        /// <summary>
        /// Strict: ném exception nếu HTTP status không thành công (dùng khi cần thấy lỗi thật).
        /// </summary>
        public static async Task<T> GetJsonAsync<T>(string url)
        {
            var resp = await Client.GetAsync(url);
            var body = await resp.Content.ReadAsStringAsync();
            System.Diagnostics.Debug.WriteLine($"[HTTP RAW] {url}\r\nStatus={(int)resp.StatusCode} {resp.ReasonPhrase}\r\n{body}");
            resp.EnsureSuccessStatusCode();
            return JsonConvert.DeserializeObject<T>(body);
        }

        /// <summary>
        /// Safe: không ném exception; trả fallback nếu lỗi HTTP/deserialize/network (nhưng có log).
        /// </summary>
        public static async Task<T> TryGetJsonAsync<T>(string url, T fallback)
        {
            try
            {
                var resp = await Client.GetAsync(url);
                if (!resp.IsSuccessStatusCode)
                {
                    var errBody = await resp.Content.ReadAsStringAsync();
                    System.Diagnostics.Debug.WriteLine($"[HTTP {resp.StatusCode}] {url}\r\n{errBody}");
                    return fallback;
                }

                var text = await resp.Content.ReadAsStringAsync();
                var data = JsonConvert.DeserializeObject<T>(text);
                if (data == null)
                {
                    System.Diagnostics.Debug.WriteLine($"[DESERIALIZE NULL] {url}\r\n{text}");
                    return fallback;
                }
                return data;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("[HTTP EX] " + url + "\r\n" + ex);
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
