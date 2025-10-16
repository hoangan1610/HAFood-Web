using HAFoodWeb.Infrastructure;
using HAFoodWeb.Models;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Net.Http;
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
    }
}
