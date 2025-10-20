using HAFoodWeb.Infrastructure;
using HAFoodWeb.Models;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
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

        public async Task<AuthMeResponse> GetProfileAsync(string token)
        {
            var url = $"{_apiBase}/api/Auth/me";

            using (var client = new HttpClient())
            {
                client.DefaultRequestHeaders.Authorization =
                    new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", token);

                var response = await client.GetAsync(url);
                response.EnsureSuccessStatusCode();

                var json = await response.Content.ReadAsStringAsync();
                return Newtonsoft.Json.JsonConvert.DeserializeObject<AuthMeResponse>(json);
            }
        }


        public async Task<bool> LogoutAsync(string token)
        {
            var url = $"{_apiBase}/api/Auth/logout";
            var body = new { token = token };

            try
            {
                using (var client = new System.Net.Http.HttpClient())
                {
                    var json = Newtonsoft.Json.JsonConvert.SerializeObject(body);
                    var content = new System.Net.Http.StringContent(json, System.Text.Encoding.UTF8, "application/json");
                    var resp = await client.PostAsync(url, content);
                    resp.EnsureSuccessStatusCode();
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
                // Gán header Authorization tạm thời
                HttpJson.Client.DefaultRequestHeaders.Authorization =
                    new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", token);

                var response = await HttpJson.PutJsonAsync(url, request);
                response.EnsureSuccessStatusCode();

                var responseJson = await response.Content.ReadAsStringAsync();
                return JsonConvert.DeserializeObject<ApiBaseResponse>(responseJson);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("UpdateProfile failed: " + ex.Message);
                return new ApiBaseResponse
                {
                    Success = false,
                    Message = "Không thể cập nhật profile"
                };
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
                        fileContent.Headers.ContentType = new MediaTypeHeaderValue(fileUpload.PostedFile.ContentType);

                        form.Add(fileContent, "file", fileUpload.FileName);

                        var response = await httpClient.PostAsync(url, form);
                        var responseJson = await response.Content.ReadAsStringAsync();

                        if (!response.IsSuccessStatusCode)
                        {
                            System.Diagnostics.Debug.WriteLine($"[Avatar Upload] {response.StatusCode} - {responseJson}");
                            return new ApiBaseResponse { Success = false, Message = "Upload avatar thất bại" };
                        }

                        return JsonConvert.DeserializeObject<ApiBaseResponse>(responseJson);
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("UpdateAvatar failed: " + ex);
                return new ApiBaseResponse { Success = false, Message = "Không thể upload avatar" };
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
                        // Thử parse để lấy message chi tiết từ server
                        var errorResponse = JsonConvert.DeserializeObject<ApiBaseResponse>(responseJson);
                        return errorResponse ?? new ApiBaseResponse
                        {
                            Success = false,
                            Message = "Đổi mật khẩu thất bại"
                        };
                    }

                    return JsonConvert.DeserializeObject<ApiBaseResponse>(responseJson);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("[ChangePassword] Lỗi: " + ex.Message);
                return new ApiBaseResponse
                {
                    Success = false,
                    Message = "Không thể kết nối máy chủ"
                };
            }
        }
    }
}
