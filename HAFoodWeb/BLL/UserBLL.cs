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

                    if (string.IsNullOrWhiteSpace(respContent))
                    {
                        System.Diagnostics.Debug.WriteLine("Response content is empty");
                        return null;
                    }

                    var jsonResult = JsonConvert.DeserializeObject<Newtonsoft.Json.Linq.JObject>(respContent);

                    bool isSuccess = false;
                    if (jsonResult["success"] != null)
                    {
                        isSuccess = jsonResult["success"].Value<bool>();
                        System.Diagnostics.Debug.WriteLine("Success value: " + isSuccess);
                    }

                    if (isSuccess)
                    {
                        System.Diagnostics.Debug.WriteLine("Login thành công, trả về toàn bộ response");
                        return JsonConvert.DeserializeObject<dynamic>(respContent);
                    }
                    else
                    {
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

        public async Task<(bool Verified, int OtpId, string Message)> VerifyRegisterOtpViaApi(string email, string code)
        {
            try
            {
                using (var client = new HttpClient())
                {
                    string apiUrl = $"{apiBaseUrl}/api/Auth/verify-otp";

                    var payload = new
                    {
                        email = email,
                        code = code
                    };

                    string json = JsonConvert.SerializeObject(payload);
                    Debug.WriteLine("VerifyRegisterOtpViaApi: Sending request = " + json);

                    var content = new StringContent(json, Encoding.UTF8, "application/json");
                    var response = await client.PostAsync(apiUrl, content);

                    string responseContent = await response.Content.ReadAsStringAsync();
                    Debug.WriteLine("VerifyRegisterOtpViaApi: Response = " + responseContent);

                    if (!response.IsSuccessStatusCode)
                    {
                        Debug.WriteLine($"VerifyRegisterOtpViaApi: HTTP ERROR {(int)response.StatusCode} - {response.ReasonPhrase}");
                        return (false, 0, $"HTTP Error {(int)response.StatusCode}");
                    }

                    var jsonResult = JsonConvert.DeserializeObject<JObject>(responseContent);

                    bool verified = jsonResult["verified"]?.Value<bool>() ?? false;
                    int otpId = jsonResult["otpId"]?.Value<int>() ?? 0;
                    string message = jsonResult["message"]?.Value<string>() ?? string.Empty;

                    return (verified, otpId, message);
                }
            }
            catch (Exception ex)
            {
                Debug.WriteLine("VerifyRegisterOtpViaApi Exception: " + ex.ToString());
                return (false, 0, ex.Message);
            }
        }

        public async Task<bool> ResendOtpViaApi(string email, string deviceUuid = null)
        {
            try
            {
                using (var client = new HttpClient())
                {
                    string uuid = deviceUuid ?? Guid.NewGuid().ToString();
                    int purpose = 1;

                    var payload = new
                    {
                        email = email,
                        purpose = purpose,
                        deviceUuid = uuid,
                        deviceModel = (string)null,
                        ip = (string)null
                    };

                    string json = JsonConvert.SerializeObject(payload);
                    Debug.WriteLine("ResendOtpViaApi: Sending request = " + json);

                    var content = new StringContent(json, Encoding.UTF8, "application/json");
                    var response = await client.PostAsync($"{apiBaseUrl}/api/Auth/otp/resend", content);

                    string responseContent = await response.Content.ReadAsStringAsync();
                    Debug.WriteLine("ResendOtpViaApi: Response = " + responseContent);

                    if (!response.IsSuccessStatusCode)
                    {
                        Debug.WriteLine($"HTTP Error: {(int)response.StatusCode} - {response.ReasonPhrase}");
                        return false;
                    }

                    var jsonResult = JsonConvert.DeserializeObject<Newtonsoft.Json.Linq.JObject>(responseContent);

                    // ✅ FIX: Kiểm tra field "accepted" thay vì "success"
                    bool accepted = jsonResult["accepted"]?.Value<bool>() ?? false;
                    Debug.WriteLine($"ResendOtpViaApi: accepted = {accepted}");

                    return accepted;
                }
            }
            catch (Exception ex)
            {
                Debug.WriteLine("ResendOtpViaApi Exception: " + ex.ToString());
                return false;
            }
        }

        public async Task<int?> ForgotPasswordViaApi(string email)
        {
            try
            {
                using (var client = new HttpClient())
                {
                    // Chỉ gửi email thôi
                    var payload = new { email = email };

                    string json = JsonConvert.SerializeObject(payload);
                    Debug.WriteLine("ForgotPasswordViaApi: Request payload = " + json);

                    var content = new StringContent(json, Encoding.UTF8, "application/json");
                    var response = await client.PostAsync($"{apiBaseUrl}/api/Auth/password/forgot", content);
                    string responseContent = await response.Content.ReadAsStringAsync();

                    Debug.WriteLine("ForgotPasswordViaApi: Response = " + responseContent);

                    if (!response.IsSuccessStatusCode)
                    {
                        Debug.WriteLine($"ForgotPasswordViaApi: HTTP error {(int)response.StatusCode} - {response.ReasonPhrase}");
                        return null;
                    }

                    var jsonResult = Newtonsoft.Json.Linq.JObject.Parse(responseContent);
                    bool accepted = jsonResult["accepted"]?.Value<bool>() ?? false;
                    int otpId = jsonResult["otpId"]?.Value<int>() ?? 0;

                    Debug.WriteLine($"ForgotPasswordViaApi: accepted = {accepted}, otpId = {otpId}");

                    if (accepted)
                        return otpId; // trả otpId khi thành công
                    else
                        return null;
                }
            }
            catch (Exception ex)
            {
                Debug.WriteLine("ForgotPasswordViaApi Exception: " + ex.ToString());
                return null;
            }
        }


        public async Task<bool> VerifyForgotPasswordOtpViaApi(string email, string otp)
        {
            try
            {
                using (var client = new HttpClient())
                {
                    string apiUrl = $"{apiBaseUrl}/api/Auth/password/reset/verify";

                    var payload = new
                    {
                        email = email,
                        otp = otp // ✅ Đúng theo request format
                    };

                    string json = JsonConvert.SerializeObject(payload);
                    Debug.WriteLine("VerifyForgotPasswordOtpViaApi: Sending request = " + json);

                    var content = new StringContent(json, Encoding.UTF8, "application/json");
                    var response = await client.PostAsync(apiUrl, content);

                    string responseContent = await response.Content.ReadAsStringAsync();
                    Debug.WriteLine("VerifyForgotPasswordOtpViaApi: Response = " + responseContent);

                    if (!response.IsSuccessStatusCode)
                    {
                        Debug.WriteLine($"HTTP ERROR: {(int)response.StatusCode} - {response.ReasonPhrase}");
                        return false;
                    }

                    var jsonResult = JsonConvert.DeserializeObject<JObject>(responseContent);
                    bool verified = jsonResult["verified"]?.Value<bool>() ?? false;

                    return verified;
                }
            }
            catch (Exception ex)
            {
                Debug.WriteLine("VerifyForgotPasswordOtpViaApi Exception: " + ex.ToString());
                return false;
            }
        }

        public async Task<bool> ResetPasswordConfirmViaApi(int otpId, string newPassword)
        {
            try
            {
                using (var client = new HttpClient())
                {
                    string apiUrl = $"{apiBaseUrl}/api/Auth/password/reset/confirm";

                    var payload = new
                    {
                        otpId = otpId,
                        newPassword = newPassword
                    };

                    string json = JsonConvert.SerializeObject(payload);
                    Debug.WriteLine("ResetPasswordConfirmViaApi: Sending request = " + json);

                    var content = new StringContent(json, Encoding.UTF8, "application/json");
                    var response = await client.PostAsync(apiUrl, content);

                    string responseContent = await response.Content.ReadAsStringAsync();
                    Debug.WriteLine("ResetPasswordConfirmViaApi: Response = " + responseContent);

                    if (!response.IsSuccessStatusCode)
                    {
                        Debug.WriteLine($"ResetPasswordConfirmViaApi: HTTP ERROR {(int)response.StatusCode} - {response.ReasonPhrase}");
                        return false;
                    }

                    // Response example: { "success": true, "code": "string", "message": "string" }
                    var jsonResult = JsonConvert.DeserializeObject<JObject>(responseContent);
                    bool success = jsonResult["success"]?.Value<bool>() ?? false;
                    Debug.WriteLine("ResetPasswordConfirmViaApi: success = " + success);

                    return success;
                }
            }
            catch (Exception ex)
            {
                Debug.WriteLine("ResetPasswordConfirmViaApi Exception: " + ex.ToString());
                return false;
            }
        }
    }
}