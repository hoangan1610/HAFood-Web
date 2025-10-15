using System;
using System.Configuration;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using HAFoodWeb.Infrastructure;

namespace HAFoodWeb.Services
{
    public class DeviceTracker
    {
        private const string CookieName = "HADeviceUuid";
        private readonly HttpRequest _req;
        private readonly HttpResponse _res;

        private readonly string _apiBase = ConfigurationManager.AppSettings["ApiBaseUrl"]?.TrimEnd('/');

        public DeviceTracker(HttpRequest req, HttpResponse res)
        {
            _req = req;
            _res = res;
        }

        public string GetOrCreateDeviceUuid()
        {
            var cookie = _req.Cookies[CookieName];
            if (cookie != null && !string.IsNullOrWhiteSpace(cookie.Value)) return cookie.Value;

            var newUuid = Guid.NewGuid().ToString();
            var newCookie = new HttpCookie(CookieName, newUuid)
            {
                HttpOnly = true,
                Secure = _req.IsSecureConnection,
                Expires = DateTime.UtcNow.AddYears(10),
                SameSite = SameSiteMode.Lax
            };
            _res.Cookies.Add(newCookie);
            return newUuid;
        }

        public string GetClientIp()
        {
            string xff = _req.ServerVariables["HTTP_X_FORWARDED_FOR"];
            if (!string.IsNullOrEmpty(xff))
            {
                var ip = xff.Split(',').Select(p => p.Trim()).FirstOrDefault(s => !string.IsNullOrEmpty(s));
                if (!string.IsNullOrEmpty(ip)) return NormalizeLocalIp(ip);
            }
            var direct = _req.ServerVariables["REMOTE_ADDR"] ?? _req.UserHostAddress;
            return NormalizeLocalIp(direct ?? "unknown");
        }

        private static string NormalizeLocalIp(string ip)
        {
            if (ip == "::1" || ip == "0:0:0:0:0:0:0:1") return "127.0.0.1";
            return ip;
        }

        public string GetFriendlyDeviceModel()
        {
            var ua = _req.UserAgent ?? string.Empty;
            if (string.IsNullOrWhiteSpace(ua)) return "unknown";

            string os = ua.IndexOf("Android", StringComparison.OrdinalIgnoreCase) >= 0 ? "Android" :
                        ua.IndexOf("iPhone", StringComparison.OrdinalIgnoreCase) >= 0 ? "iPhone" :
                        ua.IndexOf("iPad", StringComparison.OrdinalIgnoreCase) >= 0 ? "iPad" :
                        ua.IndexOf("Macintosh", StringComparison.OrdinalIgnoreCase) >= 0 ? "macOS" :
                        ua.IndexOf("Windows", StringComparison.OrdinalIgnoreCase) >= 0 ? "Windows" :
                        ua.IndexOf("Linux", StringComparison.OrdinalIgnoreCase) >= 0 ? "Linux" : "Unknown OS";

            string browser = ua.IndexOf("Edg/", StringComparison.OrdinalIgnoreCase) >= 0 || ua.IndexOf("Edge/", StringComparison.OrdinalIgnoreCase) >= 0 ? "Edge" :
                             ua.IndexOf("OPR/", StringComparison.OrdinalIgnoreCase) >= 0 || ua.IndexOf("Opera", StringComparison.OrdinalIgnoreCase) >= 0 ? "Opera" :
                             (ua.IndexOf("Chrome/", StringComparison.OrdinalIgnoreCase) >= 0 && ua.IndexOf("Chromium", StringComparison.OrdinalIgnoreCase) < 0) ? "Chrome" :
                             (ua.IndexOf("Safari/", StringComparison.OrdinalIgnoreCase) >= 0 && ua.IndexOf("Chrome/", StringComparison.OrdinalIgnoreCase) < 0) ? "Safari" :
                             ua.IndexOf("Firefox/", StringComparison.OrdinalIgnoreCase) >= 0 ? "Firefox" : "Unknown Browser";

            return $"{browser} on {os}";
        }

        public async Task SendAsync(int? userInfoId)
        {
            var payload = new
            {
                userInfoId = userInfoId,
                deviceUuid = GetOrCreateDeviceUuid(),
                deviceModel = GetFriendlyDeviceModel(),
                ip = GetClientIp()
            };

            try
            {
                var url = $"{_apiBase}/api/Device/upsert";
                var resp = await HttpJson.PostJsonAsync(url, payload);
                if (!resp.IsSuccessStatusCode)
                {
                    var txt = await resp.Content.ReadAsStringAsync();
                    System.Diagnostics.Debug.WriteLine($"[DeviceTracker] API err {resp.StatusCode}: {txt}");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("[DeviceTracker] send fail: " + ex);
            }
        }
    }
}
