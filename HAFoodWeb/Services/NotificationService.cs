using HAFoodWeb.Models;
using Newtonsoft.Json;
using System;
using System.Configuration;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Threading.Tasks;

namespace HAFoodWeb.Services
{
    public class NotificationService : INotificationService
    {
        private readonly string _apiBase = ConfigurationManager.AppSettings["ApiBaseUrl"]?.TrimEnd('/');

        // ProblemDetails theo RFC7807 
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

        // ---- THÊM: wrapper sync dùng cho SSE ----
        public NotificationLatestResultDto GetLatest(string token, int take = 10)
        {
            // rất quan trọng: .ConfigureAwait(false) bên trong GetLatestAsync
            return GetLatestAsync(token, take)
                .ConfigureAwait(false)
                .GetAwaiter()
                .GetResult();
        }

        public async Task<NotificationLatestResultDto> GetLatestAsync(string token, int take = 10)
        {
            if (string.IsNullOrEmpty(_apiBase))
            {
                System.Diagnostics.Debug.WriteLine("[Notifications.Latest] ApiBaseUrl is null/empty");
                return null;
            }

            var url = $"{_apiBase}/api/notifications/latest?take={take}";

            try
            {
                using (var client = new HttpClient())
                {
                    client.Timeout = TimeSpan.FromSeconds(5);
                    client.DefaultRequestHeaders.Authorization =
                        new AuthenticationHeaderValue("Bearer", token);

                    var response = await client.GetAsync(url).ConfigureAwait(false);
                    var json = await response.Content.ReadAsStringAsync().ConfigureAwait(false);

                    if (!response.IsSuccessStatusCode)
                    {
                        System.Diagnostics.Debug.WriteLine($"[Notifications.Latest] {response.StatusCode}: {json}");
                        return null;
                    }

                    var envelope = SafeDeserialize<NotificationLatestResultDtoApiOkResponse>(json);
                    return envelope?.data;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("[Notifications.Latest] error: " + ex);
                return null;
            }
        }

        public async Task<NotificationPagedResultDto> GetPagedAsync(
            string token,
            int page = 1,
            int pageSize = 20,
            bool onlyUnread = false,
            int? type = null)
        {
            var sb = new StringBuilder($"{_apiBase}/api/notifications");
            sb.Append($"?page={page}");
            sb.Append($"&pageSize={pageSize}");
            sb.Append($"&onlyUnread={onlyUnread.ToString().ToLowerInvariant()}");
            if (type.HasValue)
            {
                sb.Append($"&type={type.Value}");
            }

            var url = sb.ToString();

            try
            {
                using (var client = new HttpClient())
                {
                    client.Timeout = TimeSpan.FromSeconds(10);
                    client.DefaultRequestHeaders.Authorization =
                        new AuthenticationHeaderValue("Bearer", token);

                    var response = await client.GetAsync(url).ConfigureAwait(false);
                    var json = await response.Content.ReadAsStringAsync().ConfigureAwait(false);

                    if (!response.IsSuccessStatusCode)
                    {
                        System.Diagnostics.Debug.WriteLine($"[Notifications.Paged] {response.StatusCode}: {json}");
                        return null;
                    }

                    var envelope = SafeDeserialize<NotificationPagedResultDtoApiOkResponse>(json);
                    return envelope?.data;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("[Notifications.Paged] error: " + ex);
                return null;
            }
        }

        public async Task<ApiBaseResponse> MarkAsReadAsync(string token, long id)
        {
            var url = $"{_apiBase}/api/notifications/{id}/read";

            try
            {
                using (var client = new HttpClient())
                {
                    client.Timeout = TimeSpan.FromSeconds(5);
                    client.DefaultRequestHeaders.Authorization =
                        new AuthenticationHeaderValue("Bearer", token);

                    var response = await client.PostAsync(url, null).ConfigureAwait(false);
                    var json = await response.Content.ReadAsStringAsync().ConfigureAwait(false);

                    if (!response.IsSuccessStatusCode)
                    {
                        System.Diagnostics.Debug.WriteLine($"[Notifications.Read] {response.StatusCode}: {json}");

                        var problem = SafeDeserialize<ProblemDetailsEnvelope>(json);
                        return new ApiBaseResponse
                        {
                            Success = false,
                            Message = problem?.detail ?? "Không thể đánh dấu thông báo đã đọc",
                            Code = problem?.code
                        };
                    }

                    var ok = SafeDeserialize<ApiBaseResponse>(json) ?? new ApiBaseResponse
                    {
                        Success = true,
                        Message = "OK"
                    };
                    return ok;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("[Notifications.Read] error: " + ex);
                return new ApiBaseResponse
                {
                    Success = false,
                    Message = "Không thể kết nối máy chủ"
                };
            }
        }

        public async Task<ApiBaseResponse> MarkAllAsReadAsync(string token)
        {
            var url = $"{_apiBase}/api/notifications/read-all";

            try
            {
                using (var client = new HttpClient())
                {
                    client.Timeout = TimeSpan.FromSeconds(5);
                    client.DefaultRequestHeaders.Authorization =
                        new AuthenticationHeaderValue("Bearer", token);

                    var response = await client.PostAsync(url, null).ConfigureAwait(false);
                    var json = await response.Content.ReadAsStringAsync().ConfigureAwait(false);

                    if (!response.IsSuccessStatusCode)
                    {
                        System.Diagnostics.Debug.WriteLine($"[Notifications.ReadAll] {response.StatusCode}: {json}");

                        var problem = SafeDeserialize<ProblemDetailsEnvelope>(json);
                        return new ApiBaseResponse
                        {
                            Success = false,
                            Message = problem?.detail ?? "Không thể đánh dấu tất cả thông báo đã đọc",
                            Code = problem?.code
                        };
                    }

                    var ok = SafeDeserialize<ApiBaseResponse>(json) ?? new ApiBaseResponse
                    {
                        Success = true,
                        Message = "OK"
                    };
                    return ok;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("[Notifications.ReadAll] error: " + ex);
                return new ApiBaseResponse
                {
                    Success = false,
                    Message = "Không thể kết nối máy chủ"
                };
            }
        }
    }
}
