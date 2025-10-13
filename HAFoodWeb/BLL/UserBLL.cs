using HAFoodWeb.AuthPage;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Diagnostics;
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

        public async Task<dynamic> LoginViaApi(string email, string password, string deviceUuid = null, string ip = null)
        {
            string apiUrl = $"{apiBaseUrl}/api/Auth/login";
            using (HttpClient client = new HttpClient())
            {
                // Payload gửi lên API
                var payload = new
                {
                    email = email,
                    password = password,
                    deviceUuid = deviceUuid,
                    ip = ip
                };
                string jsonPayload = JsonConvert.SerializeObject(payload);
                System.Diagnostics.Debug.WriteLine("Payload gửi đi: " + jsonPayload);
                var content = new StringContent(jsonPayload, Encoding.UTF8, "application/json");

                try
                {
                    HttpResponseMessage response = await client.PostAsync(apiUrl, content);
                    string respContent = await response.Content.ReadAsStringAsync();
                    System.Diagnostics.Debug.WriteLine("Status code: " + response.StatusCode);
                    System.Diagnostics.Debug.WriteLine("Response từ API: " + respContent);

                    // Kiểm tra nếu response rỗng
                    if (string.IsNullOrWhiteSpace(respContent))
                    {
                        System.Diagnostics.Debug.WriteLine("Response content is empty");
                        return null;
                    }

                    // Deserialize thành JObject để kiểm tra chính xác hơn
                    var jsonResult = JsonConvert.DeserializeObject<Newtonsoft.Json.Linq.JObject>(respContent);

                    // Kiểm tra success
                    bool isSuccess = false;
                    if (jsonResult["success"] != null)
                    {
                        isSuccess = jsonResult["success"].Value<bool>();
                        System.Diagnostics.Debug.WriteLine("Success value: " + isSuccess);
                    }

                    if (isSuccess)
                    {
                        System.Diagnostics.Debug.WriteLine("Login thành công, trả về toàn bộ response");

                        // Trả về toàn bộ response vì API không có trường "data"
                        return JsonConvert.DeserializeObject<dynamic>(respContent);
                    }
                    else
                    {
                        // Log lỗi nếu có
                        if (jsonResult["message"] != null)
                        {
                            System.Diagnostics.Debug.WriteLine("Login thất bại: " + jsonResult["message"].ToString());
                        }
                        return null;
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine("LoginViaApi Exception: " + ex.ToString());
                    return null;
                }
            }
        }

        public async Task<bool> VerifyOtpViaApi(string email, string otp)
        {
            try
            {
                using (var client = new HttpClient())
                {
                    var payload = new { email = email, otp = otp };
                    string json = JsonConvert.SerializeObject(payload);
                    Debug.WriteLine("VerifyOtpViaApi: Sending request = " + json);

                    var content = new StringContent(json, Encoding.UTF8, "application/json");
                    var response = await client.PostAsync($"{apiBaseUrl}/api/Auth/verify-otp", content);

                    string responseContent = await response.Content.ReadAsStringAsync();
                    Debug.WriteLine("VerifyOtpViaApi: Response = " + responseContent);

                    return response.IsSuccessStatusCode;
                }
            }
            catch (Exception ex)
            {
                Debug.WriteLine("VerifyOtpViaApi Exception: " + ex.Message);
                return false;
            }
        }

        public async Task<bool> ResendOtpViaApi(string email)
        {
            try
            {
                using (var client = new HttpClient())
                {
                    var payload = new { email = email };
                    string json = JsonConvert.SerializeObject(payload);
                    Debug.WriteLine("ResendOtpViaApi: Sending request = " + json);

                    var content = new StringContent(json, Encoding.UTF8, "application/json");
                    var response = await client.PostAsync($"{apiBaseUrl}/api/Auth/otp/resend", content);

                    string responseContent = await response.Content.ReadAsStringAsync();
                    Debug.WriteLine("ResendOtpViaApi: Response = " + responseContent);

                    return response.IsSuccessStatusCode;
                }
            }
            catch (Exception ex)
            {
                Debug.WriteLine("ResendOtpViaApi Exception: " + ex.Message);
                return false;
            }
        }
    }
}