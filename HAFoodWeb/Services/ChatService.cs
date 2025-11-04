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
using System.Threading.Tasks;

namespace HAFoodWeb.Services
{
    public class ChatService : IChatService
    {
        private readonly string _apiBase = ConfigurationManager.AppSettings["ApiBaseUrl"]?.TrimEnd('/');

        private class ProblemDetailsEnvelope
        {
            public string type { get; set; }
            public string title { get; set; }
            public int? status { get; set; }
            public string detail { get; set; }
            public string instance { get; set; }
            public string traceId { get; set; }
            public string code { get; set; }
        }

        private static T SafeDeserialize<T>(string json) where T : class
        {
            if (string.IsNullOrWhiteSpace(json)) return null;
            try { return JsonConvert.DeserializeObject<T>(json); }
            catch { return null; }
        }

        private static string Trunc(string s, int max = 600)
            => string.IsNullOrEmpty(s) ? s : (s.Length <= max ? s : s.Substring(0, max) + $" ...(+{s.Length - max} chars)");

        public async Task<ChatAskResponse> AskAsync(string token, string message)
        {
            // Bảo đảm TLS1.2 khi gọi Cloudflare/HTTPS
            ServicePointManager.SecurityProtocol |= SecurityProtocolType.Tls12;

            var url = $"{_apiBase}/api/chat/ask";
            var ask = new AskRequest { message = message ?? string.Empty };

            try
            {
                using (var client = new HttpClient())
                {
                    client.Timeout = TimeSpan.FromSeconds(15);
                    if (!string.IsNullOrWhiteSpace(token))
                        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);

                    var payload = JsonConvert.SerializeObject(ask);
                    var content = new StringContent(payload, Encoding.UTF8, "application/json");

                    var sw = Stopwatch.StartNew();
                    Debug.WriteLine($"[ChatService] POST {url} Payload={Trunc(payload, 400)}");
                    var resp = await client.PostAsync(url, content).ConfigureAwait(false);
                    var body = await resp.Content.ReadAsStringAsync().ConfigureAwait(false);
                    sw.Stop();
                    Debug.WriteLine($"[ChatService] <- {(int)resp.StatusCode} in {sw.ElapsedMilliseconds}ms Body={Trunc(body)}");

                    if (!resp.IsSuccessStatusCode)
                    {
                        var problem = SafeDeserialize<ProblemDetailsEnvelope>(body);
                        return new ChatAskResponse
                        {
                            Success = false,
                            Code = problem?.code,
                            Message = problem?.detail ?? problem?.title ?? $"HTTP {(int)resp.StatusCode}",
                            Reply = null,
                            RawBody = body
                        };
                    }

                    var result = new ChatAskResponse { Success = true, Message = "OK", RawBody = body };

                    try
                    {
                        var tokenized = JToken.Parse(body);
                        if (tokenized.Type == JTokenType.String)
                        {
                            result.Reply = tokenized.Value<string>();
                        }
                        else if (tokenized.Type == JTokenType.Object)
                        {
                            var obj = (JObject)tokenized;
                            result.Reply =
                                obj.Value<string>("answer") ??  
                                obj.Value<string>("reply") ??
                                obj.Value<string>("message") ??
                                obj.Value<string>("content") ??
                                obj.Value<string>("text") ??
                                body;

                            if (obj.TryGetValue("success", out var s) && s.Type == JTokenType.Boolean)
                                result.Success = s.Value<bool>();
                            if (obj.TryGetValue("code", out var c)) result.Code = c?.Value<string>() ?? result.Code;
                            if (obj.TryGetValue("message", out var m)) result.Message = m?.Value<string>() ?? result.Message;
                        }
                        else
                        {
                            result.Reply = body;
                        }
                    }
                    catch (Exception ex)
                    {
                        Debug.WriteLine($"[ChatService] JSON parse error: {ex}");
                        result.Reply = string.IsNullOrWhiteSpace(result.Reply) ? body : result.Reply;
                    }

                    return result;
                }
            }
            catch (TaskCanceledException tcex)
            {
                Debug.WriteLine($"[ChatService] TIMEOUT: {tcex}");
                return new ChatAskResponse
                {
                    Success = false,
                    Code = "TIMEOUT",
                    Message = "Hệ thống phản hồi chậm, vui lòng thử lại.",
                    RawBody = tcex.ToString()
                };
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"[ChatService] EX: {ex}");
                return new ChatAskResponse
                {
                    Success = false,
                    Code = "NETWORK_ERROR",
                    Message = "Không thể kết nối máy chủ",
                    RawBody = ex.ToString()
                };
            }
        }
    }
}
