using HAFoodWeb.AuthPage;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;

namespace HAFoodWeb.BLL
{
    public class UserBLL
    {
        private readonly string apiBaseUrl;

        public UserBLL()
        {
            apiBaseUrl = ConfigurationManager.AppSettings["ApiBaseUrl"];
        }

        public async Task<bool> RegisterViaApi(string fullName, string email, string password, string phone)
        {
            string apiUrl = $"{apiBaseUrl}/api/Auth/register";

            using (HttpClient client = new HttpClient())
            {
                var payload = new
                {
                    FullName = fullName,
                    Phone = phone,
                    Email = email,
                    Password = password,
                    Avatar = ""
                };

                string jsonData = JsonConvert.SerializeObject(payload);
                var content = new StringContent(jsonData, Encoding.UTF8, "application/json");

                try
                {
                    HttpResponseMessage response = await client.PostAsync(apiUrl, content);

                    if (response.IsSuccessStatusCode)
                        return true;

                    string error = await response.Content.ReadAsStringAsync();
                    System.Diagnostics.Debug.WriteLine("Register API error: " + error);
                    return false;
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine("RegisterViaApi Exception: " + ex.Message);
                    return false;
                }
            }
        }

        public async Task<bool> LoginViaApi(string email, string password)
        {
            string apiUrl = $"{apiBaseUrl}/api/Auth/login";

            using (HttpClient client = new HttpClient())
            {
                var payload = new { Email = email, Password = password };
                var content = new StringContent(JsonConvert.SerializeObject(payload), Encoding.UTF8, "application/json");

                try
                {
                    HttpResponseMessage response = await client.PostAsync(apiUrl, content);

                    // true nếu status 200, false nếu login thất bại
                    return response.IsSuccessStatusCode;
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine("LoginViaApi Exception: " + ex.Message);
                    return false;
                }
            }
        }

        public async Task<bool> VerifyOtpViaApi(string email, string otp)
        {
            string apiUrl = $"{apiBaseUrl}/api/Auth/verify-otp";

            using (HttpClient client = new HttpClient())
            {
                var payload = new { email = email, otp = otp };
                string jsonData = JsonConvert.SerializeObject(payload);
                var content = new StringContent(jsonData, Encoding.UTF8, "application/json");

                try
                {
                    HttpResponseMessage response = await client.PostAsync(apiUrl, content);
                    string resText = await response.Content.ReadAsStringAsync();
                    System.Diagnostics.Debug.WriteLine("VerifyOtp: " + resText);
                    return response.IsSuccessStatusCode;
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine("VerifyOtp Exception: " + ex.Message);
                    return false;
                }
            }
        }

        public async Task<bool> ResendOtpViaApi(string email)
        {
            string apiUrl = $"{apiBaseUrl}/api/Auth/otp/resend";

            using (HttpClient client = new HttpClient())
            {
                var payload = new { email = email };
                var content = new StringContent(JsonConvert.SerializeObject(payload), Encoding.UTF8, "application/json");

                try
                {
                    HttpResponseMessage response = await client.PostAsync(apiUrl, content);
                    string resText = await response.Content.ReadAsStringAsync();
                    System.Diagnostics.Debug.WriteLine($"[ResendOtp] Status: {(int)response.StatusCode} | Body: {resText}");

                    return response.IsSuccessStatusCode;
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine("ResendOtp Exception: " + ex.Message);
                    return false;
                }
            }
        }
    }
}