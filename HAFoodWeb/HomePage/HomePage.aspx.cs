using System;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using System.Web.UI;
using Newtonsoft.Json;

namespace HAFoodWeb.HomePage
{
    public partial class HomePage : System.Web.UI.Page
    {
        private const string DeviceUuidCookieName = "HADeviceUuid";
        private const string DeviceApiUrl = "https://api.hafood.id.vn/api/Device/upsert";

        protected void Page_Load(object sender, EventArgs e)
        {
            var ip = GetClientIp();
            var deviceModel = GetFriendlyDeviceModelFromUserAgent();
            var deviceUuid = GetOrCreateDeviceUuid();
            var userInfoId = GetUserInfoId(); // null nếu chưa đăng nhập

            // Debug Output
            System.Diagnostics.Debug.WriteLine("Device UUID: " + deviceUuid);
            System.Diagnostics.Debug.WriteLine("Device Model: " + deviceModel);
            System.Diagnostics.Debug.WriteLine("IP: " + ip);
            System.Diagnostics.Debug.WriteLine("UserInfoId: " + (userInfoId.HasValue ? userInfoId.Value.ToString() : "null"));

            // Gửi async lên API mà không block UI
            PageAsyncTask task = new PageAsyncTask(async ct =>
            {
                await SendDeviceInfoToApi(deviceUuid, deviceModel, ip, userInfoId);
            });
            RegisterAsyncTask(task);
        }

        private int? GetUserInfoId()
        {
            // Giả sử userId lưu trong Session["UserId"]
            if (Session["UserId"] != null)
                return Convert.ToInt32(Session["UserId"]);
            return null;
        }

        private string GetOrCreateDeviceUuid()
        {
            var cookie = Request.Cookies[DeviceUuidCookieName];
            if (cookie != null && !string.IsNullOrWhiteSpace(cookie.Value))
                return cookie.Value;

            var newUuid = Guid.NewGuid().ToString();
            var newCookie = new HttpCookie(DeviceUuidCookieName, newUuid)
            {
                HttpOnly = true,
                Secure = Request.IsSecureConnection,
                Expires = DateTime.UtcNow.AddYears(10)
            };
            Response.Cookies.Add(newCookie);
            return newUuid;
        }

        private string GetClientIp()
        {
            string xff = Request.ServerVariables["HTTP_X_FORWARDED_FOR"];
            if (!string.IsNullOrEmpty(xff))
            {
                var ipList = xff.Split(',').Select(p => p.Trim()).ToArray();
                if (ipList.Length > 0 && !string.IsNullOrEmpty(ipList[0]))
                    return NormalizeLocalIp(ipList[0]);
            }

            string ip = Request.ServerVariables["REMOTE_ADDR"] ?? Request.UserHostAddress;
            return NormalizeLocalIp(ip ?? "unknown");
        }

        private string NormalizeLocalIp(string ip)
        {
            if (string.Equals(ip, "::1", StringComparison.OrdinalIgnoreCase) ||
                string.Equals(ip, "0:0:0:0:0:0:0:1", StringComparison.OrdinalIgnoreCase))
                return "127.0.0.1";

            return ip;
        }

        private string GetFriendlyDeviceModelFromUserAgent()
        {
            var ua = Request.UserAgent ?? string.Empty;
            if (string.IsNullOrWhiteSpace(ua))
                return "unknown";

            string os;
            if (ua.IndexOf("Android", StringComparison.OrdinalIgnoreCase) >= 0) os = "Android";
            else if (ua.IndexOf("iPhone", StringComparison.OrdinalIgnoreCase) >= 0) os = "iPhone";
            else if (ua.IndexOf("iPad", StringComparison.OrdinalIgnoreCase) >= 0) os = "iPad";
            else if (ua.IndexOf("Macintosh", StringComparison.OrdinalIgnoreCase) >= 0) os = "macOS";
            else if (ua.IndexOf("Windows", StringComparison.OrdinalIgnoreCase) >= 0) os = "Windows";
            else if (ua.IndexOf("Linux", StringComparison.OrdinalIgnoreCase) >= 0) os = "Linux";
            else os = "Unknown OS";

            string browser;
            if (ua.IndexOf("Edg/", StringComparison.OrdinalIgnoreCase) >= 0 || ua.IndexOf("Edge/", StringComparison.OrdinalIgnoreCase) >= 0)
                browser = "Edge";
            else if (ua.IndexOf("OPR/", StringComparison.OrdinalIgnoreCase) >= 0 || ua.IndexOf("Opera", StringComparison.OrdinalIgnoreCase) >= 0)
                browser = "Opera";
            else if (ua.IndexOf("Chrome/", StringComparison.OrdinalIgnoreCase) >= 0 &&
                     ua.IndexOf("Chromium", StringComparison.OrdinalIgnoreCase) < 0)
                browser = "Chrome";
            else if (ua.IndexOf("Safari/", StringComparison.OrdinalIgnoreCase) >= 0 &&
                     ua.IndexOf("Chrome/", StringComparison.OrdinalIgnoreCase) < 0)
                browser = "Safari";
            else if (ua.IndexOf("Firefox/", StringComparison.OrdinalIgnoreCase) >= 0)
                browser = "Firefox";
            else
                browser = "Unknown Browser";

            return $"{browser} on {os}";
        }

        private async Task SendDeviceInfoToApi(string deviceUuid, string deviceModel, string ip, int? userInfoId)
        {
            using (var client = new HttpClient())
            {
                var payload = new
                {
                    userInfoId = userInfoId, // null nếu chưa đăng nhập
                    deviceUuid = deviceUuid,
                    deviceModel = deviceModel,
                    ip = ip
                };

                var json = JsonConvert.SerializeObject(payload);
                var content = new StringContent(json, Encoding.UTF8, "application/json");

                try
                {
                    var response = await client.PostAsync(DeviceApiUrl, content);
                    if (!response.IsSuccessStatusCode)
                    {
                        var respText = await response.Content.ReadAsStringAsync();
                        System.Diagnostics.Debug.WriteLine($"API trả lỗi: {response.StatusCode} - {respText}");
                    }
                    else
                    {
                        System.Diagnostics.Debug.WriteLine("Gửi device info thành công.");
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine("Lỗi khi gửi device info: " + ex);
                }
            }
        }
    }
}