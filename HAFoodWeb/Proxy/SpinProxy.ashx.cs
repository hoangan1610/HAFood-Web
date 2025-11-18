using System;
using System.Configuration;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Web;

namespace HAFoodWeb.Proxy
{
    public class SpinProxy : IHttpHandler
    {
        private static readonly string ApiBase =
            (ConfigurationManager.AppSettings["ApiBaseUrl"] ?? "").TrimEnd('/');

        public bool IsReusable => false;

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json; charset=utf-8";

            var action = (context.Request["action"] ?? "").ToLowerInvariant();

            var token = GetUserToken(context);
            if (string.IsNullOrEmpty(token))
            {
                context.Response.StatusCode = 401;
                context.Response.Write("{\"success\":false,\"message\":\"NOT_AUTHENTICATED\"}");
                return;
            }

            try
            {
                switch (action)
                {
                    case "config":
                        ProxyConfig(context, token);
                        break;

                    case "turns":
                        ProxyTurns(context, token);
                        break;

                    case "roll":
                        ProxyRoll(context, token);
                        break;

                    case "checkin":     // 👈 THÊM DÒNG NÀY
                        ProxyCheckin(context, token);
                        break;

                    case "status":
                        ProxyStatus(context, token);
                        break;
                    default:
                        context.Response.StatusCode = 400;
                        context.Response.Write("{\"success\":false,\"message\":\"UNKNOWN_ACTION\"}");
                        break;
                }
            }
            catch (Exception ex)
            {
                context.Response.StatusCode = 500;
                var msg = ("SpinProxy error: " + ex.Message).Replace("\"", "'");
                context.Response.Write("{\"success\":false,\"message\":\"" + msg + "\"}");
            }
        }


        /// <summary>
        /// TODO: chỉnh lại cho khớp logic auth hiện tại (cookie, session, v.v.)
        /// </summary>
        private static string GetUserToken(HttpContext ctx)
        {
            // 1) Đọc từ cookie giống Login
            var c = ctx.Request.Cookies["AuthToken"];   // 👈 cùng tên với Login
            if (c != null && !string.IsNullOrWhiteSpace(c.Value))
                return c.Value;

            // 2) Fallback: đọc từ Session giống Login
            var s = ctx.Session?["JwtToken"] as string; // 👈 đúng key
            if (!string.IsNullOrWhiteSpace(s))
                return s;

            return null;
        }

        private static void ProxyConfig(HttpContext ctx, string token)
        {
            var apiUrl = $"{ApiBase}/api/gam/spin-config/active?channel=1";

            using (var client = CreateClient(token))
            using (var resp = client.GetAsync(apiUrl).Result)
            {
                var body = resp.Content.ReadAsStringAsync().Result;
                ctx.Response.StatusCode = (int)resp.StatusCode;
                ctx.Response.Write(body);
            }
        }

        private static void ProxyTurns(HttpContext ctx, string token)
        {
            var apiUrl = $"{ApiBase}/api/gam/spins";

            using (var client = CreateClient(token))
            using (var resp = client.GetAsync(apiUrl).Result)
            {
                var body = resp.Content.ReadAsStringAsync().Result;
                ctx.Response.StatusCode = (int)resp.StatusCode;
                ctx.Response.Write(body);
            }
        }

        private static void ProxyRoll(HttpContext ctx, string token)
        {
            // turnId gửi lên qua query hoặc form
            var turnStr = ctx.Request["turnId"] ?? ctx.Request["id"];
            if (!long.TryParse(turnStr, out var turnId))
            {
                ctx.Response.StatusCode = 400;
                ctx.Response.Write("{\"success\":false,\"message\":\"INVALID_TURN_ID\"}");
                return;
            }

            var apiUrl = $"{ApiBase}/api/gam/spins/{turnId}/roll";

            // Tùy bạn đang design API Body như nào – đây là ví dụ
            var payload = new
            {
                channel = 1,
                device_id = (long?)null,
                ip = ctx.Request.UserHostAddress
            };
            var json = Newtonsoft.Json.JsonConvert.SerializeObject(payload);
            var content = new StringContent(json, Encoding.UTF8, "application/json");

            using (var client = CreateClient(token))
            using (var resp = client.PostAsync(apiUrl, content).Result)
            {
                var body = resp.Content.ReadAsStringAsync().Result;
                ctx.Response.StatusCode = (int)resp.StatusCode;
                ctx.Response.Write(body);
            }
        }

        private static HttpClient CreateClient(string token)
        {
            var client = new HttpClient();
            client.DefaultRequestHeaders.Authorization =
                new AuthenticationHeaderValue("Bearer", token);
            return client;
        }

        private static void ProxyCheckin(HttpContext ctx, string token)
        {
            // API checkin: POST /api/gam/checkin?channel=1
            var apiUrl = $"{ApiBase}/api/gam/checkin?channel=1";

            using (var client = CreateClient(token))
            {
                // nếu API không yêu cầu body, có thể gửi {} cho chắc
                var content = new StringContent("{}", Encoding.UTF8, "application/json");

                using (var resp = client.PostAsync(apiUrl, content).Result)
                {
                    var body = resp.Content.ReadAsStringAsync().Result;
                    ctx.Response.StatusCode = (int)resp.StatusCode;
                    ctx.Response.Write(body);
                }
            }
        }

        private static void ProxyStatus(HttpContext ctx, string token)
        {
            // có thể cho channel là query ?channel=1, tạm hard-code 1
            var apiUrl = $"{ApiBase}/api/gam/status?channel=1";

            using (var client = CreateClient(token))
            using (var resp = client.GetAsync(apiUrl).Result)
            {
                var body = resp.Content.ReadAsStringAsync().Result;
                ctx.Response.StatusCode = (int)resp.StatusCode;
                ctx.Response.Write(body);
            }
        }

    }
}
