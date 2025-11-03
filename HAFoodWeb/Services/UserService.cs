using HAFoodWeb.Infrastructure;
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
    public class UserService : IUserService
    {
        private readonly string _apiBase = ConfigurationManager.AppSettings["ApiBaseUrl"]?.TrimEnd('/');

        // ProblemDetails theo RFC7807 (API của bạn đang trả dạng này)
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

        private static void TrySetOptional(object obj, string propName, object value)
        {
            if (obj == null || propName == null) return;
            var prop = obj.GetType().GetProperty(propName);
            if (prop != null && prop.CanWrite)
            {
                try { prop.SetValue(obj, value); } catch { /* ignore */ }
            }
        }

        public async Task<AuthMeResponse> GetProfileAsync(string token)
        {
            var url = $"{_apiBase}/api/Auth/me";

            using (var client = new HttpClient())
            {
                client.DefaultRequestHeaders.Authorization =
                    new AuthenticationHeaderValue("Bearer", token);

                var response = await client.GetAsync(url);
                response.EnsureSuccessStatusCode(); // có thể giữ vì trang load profile cần thành công

                var json = await response.Content.ReadAsStringAsync();
                return JsonConvert.DeserializeObject<AuthMeResponse>(json);
            }
        }

        public async Task<bool> LogoutAsync(string token)
        {
            var url = $"{_apiBase}/api/Auth/logout";
            var body = new { token = token };

            try
            {
                using (var client = new HttpClient())
                {
                    var json = JsonConvert.SerializeObject(body);
                    var content = new StringContent(json, Encoding.UTF8, "application/json");
                    var resp = await client.PostAsync(url, content);
                    // có thể đọc body để log
                    var respBody = await resp.Content.ReadAsStringAsync();
                    if (!resp.IsSuccessStatusCode)
                    {
                        System.Diagnostics.Debug.WriteLine($"[Logout] {resp.StatusCode}: {respBody}");
                        return false;
                    }
                    return true;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Logout failed: " + ex.Message);
                return false;
            }
        }

        public async Task<ApiBaseResponse> UpdateProfileAsync(string token, UserUpdateRequest request)
        {
            var url = $"{_apiBase}/api/users/me/profile";

            try
            {
                // Đảm bảo header Authorization cho HttpJson.Client
                HttpJson.Client.DefaultRequestHeaders.Authorization =
                    new AuthenticationHeaderValue("Bearer", token);

                // KHÔNG EnsureSuccessStatusCode – để còn đọc body lỗi (409, 500…)
                var response = await HttpJson.PutJsonAsync(url, request);
                var responseJson = await response.Content.ReadAsStringAsync();

                if (response.IsSuccessStatusCode)
                {
                    var ok = SafeDeserialize<ApiBaseResponse>(responseJson) ?? new ApiBaseResponse
                    {
                        Success = true,
                        Message = "OK"
                    };
                    TrySetOptional(ok, "StatusCode", (int)response.StatusCode);
                    TrySetOptional(ok, "RawBody", responseJson);
                    return ok;
                }
                else
                {
                    var problem = SafeDeserialize<ProblemDetailsEnvelope>(responseJson);
                    var fail = new ApiBaseResponse
                    {
                        Success = false,
                        Message = "Không thể cập nhật profile"
                    };

                    TrySetOptional(fail, "StatusCode", (int)response.StatusCode);
                    TrySetOptional(fail, "RawBody", responseJson);

                    if (problem != null)
                    {
                        TrySetOptional(fail, "Code", problem.code);
                        TrySetOptional(fail, "Title", problem.title);
                        TrySetOptional(fail, "Detail", problem.detail);

                        if (!string.IsNullOrWhiteSpace(problem.detail))
                            fail.Message = problem.detail;
                    }

                    return fail;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("UpdateProfile failed: " + ex);
                var err = new ApiBaseResponse
                {
                    Success = false,
                    Message = "Không thể cập nhật profile"
                };
                TrySetOptional(err, "Detail", ex.Message);
                return err;
            }
        }

        public async Task<ApiBaseResponse> UpdateAvatarAsync(string token, System.Web.UI.WebControls.FileUpload fileUpload)
        {
            var url = $"{_apiBase}/api/users/me/avatar";

            try
            {
                using (var httpClient = new HttpClient())
                {
                    httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);

                    using (var form = new MultipartFormDataContent())
                    {
                        var fileContent = new StreamContent(fileUpload.FileContent);
                        var contentType = fileUpload.PostedFile?.ContentType;
                        if (!string.IsNullOrWhiteSpace(contentType))
                            fileContent.Headers.ContentType = new MediaTypeHeaderValue(contentType);

                        form.Add(fileContent, "file", fileUpload.FileName);

                        var response = await httpClient.PostAsync(url, form);
                        var responseJson = await response.Content.ReadAsStringAsync();

                        if (!response.IsSuccessStatusCode)
                        {
                            System.Diagnostics.Debug.WriteLine($"[Avatar Upload] {response.StatusCode} - {responseJson}");

                            var problem = SafeDeserialize<ProblemDetailsEnvelope>(responseJson);
                            var fail = new ApiBaseResponse
                            {
                                Success = false,
                                Message = problem?.detail ?? "Upload avatar thất bại"
                            };
                            TrySetOptional(fail, "StatusCode", (int)response.StatusCode);
                            TrySetOptional(fail, "Code", problem?.code);
                            TrySetOptional(fail, "Title", problem?.title);
                            TrySetOptional(fail, "Detail", problem?.detail);
                            TrySetOptional(fail, "RawBody", responseJson);

                            return fail;
                        }

                        var ok = SafeDeserialize<ApiBaseResponse>(responseJson) ?? new ApiBaseResponse
                        {
                            Success = true,
                            Message = "OK"
                        };
                        TrySetOptional(ok, "StatusCode", (int)response.StatusCode);
                        TrySetOptional(ok, "RawBody", responseJson);
                        return ok;
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("UpdateAvatar failed: " + ex);
                var err = new ApiBaseResponse
                {
                    Success = false,
                    Message = "Không thể upload avatar"
                };
                TrySetOptional(err, "Detail", ex.Message);
                return err;
            }
        }

        public async Task<ApiBaseResponse> ChangePasswordAsync(string token, string oldPassword, string newPassword)
        {
            var url = $"{_apiBase}/api/Auth/password/change";

            try
            {
                using (var client = new HttpClient())
                {
                    client.DefaultRequestHeaders.Authorization =
                        new AuthenticationHeaderValue("Bearer", token);

                    var requestBody = new
                    {
                        oldPassword = oldPassword,
                        newPassword = newPassword
                    };

                    var json = JsonConvert.SerializeObject(requestBody);
                    var content = new StringContent(json, Encoding.UTF8, "application/json");

                    var response = await client.PostAsync(url, content);
                    var responseJson = await response.Content.ReadAsStringAsync();

                    if (!response.IsSuccessStatusCode)
                    {
                        System.Diagnostics.Debug.WriteLine($"[ChangePassword] {response.StatusCode}: {responseJson}");

                        // Ưu tiên parse ProblemDetails
                        var problem = SafeDeserialize<ProblemDetailsEnvelope>(responseJson);
                        if (problem != null)
                        {
                            var fail = new ApiBaseResponse
                            {
                                Success = false,
                                Message = problem.detail ?? "Đổi mật khẩu thất bại"
                            };
                            TrySetOptional(fail, "StatusCode", (int)response.StatusCode);
                            TrySetOptional(fail, "Code", problem.code);
                            TrySetOptional(fail, "Title", problem.title);
                            TrySetOptional(fail, "Detail", problem.detail);
                            TrySetOptional(fail, "RawBody", responseJson);
                            return fail;
                        }

                        // Nếu server trả ApiBaseResponse
                        var errorResponse = SafeDeserialize<ApiBaseResponse>(responseJson) ?? new ApiBaseResponse
                        {
                            Success = false,
                            Message = "Đổi mật khẩu thất bại"
                        };
                        TrySetOptional(errorResponse, "StatusCode", (int)response.StatusCode);
                        TrySetOptional(errorResponse, "RawBody", responseJson);
                        return errorResponse;
                    }

                    var ok = SafeDeserialize<ApiBaseResponse>(responseJson) ?? new ApiBaseResponse
                    {
                        Success = true,
                        Message = "OK"
                    };
                    TrySetOptional(ok, "StatusCode", (int)response.StatusCode);
                    TrySetOptional(ok, "RawBody", responseJson);
                    return ok;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("[ChangePassword] Lỗi: " + ex.Message);
                var err = new ApiBaseResponse
                {
                    Success = false,
                    Message = "Không thể kết nối máy chủ"
                };
                TrySetOptional(err, "Detail", ex.Message);
                return err;
            }
        }
    }
}
