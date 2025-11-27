using HAFoodWeb.Services;
using System;
using System.Web;

namespace HAFoodWeb.Proxy
{
    public class NotificationMarkRead : IHttpHandler
    {
        public bool IsReusable => false;

        public void ProcessRequest(HttpContext context)
        {
            var req = context.Request;
            var resp = context.Response;

            resp.ContentType = "application/json; charset=utf-8";
            resp.ContentEncoding = System.Text.Encoding.UTF8;

            // Lấy token giống mấy chỗ khác
            var token = req.Cookies["AuthToken"]?.Value;
            if (string.IsNullOrEmpty(token))
            {
                resp.StatusCode = 401;
                resp.Write("{\"success\":false,\"message\":\"Not authenticated\"}");
                return;
            }

            if (!long.TryParse(req["id"], out var id) || id <= 0)
            {
                resp.StatusCode = 400;
                resp.Write("{\"success\":false,\"message\":\"Invalid id\"}");
                return;
            }

            try
            {
                var svc = new NotificationService();
                var result = svc.MarkAsReadAsync(token, id)
                                .ConfigureAwait(false)
                                .GetAwaiter()
                                .GetResult();

                if (result?.Success == true)
                {
                    resp.Write("{\"success\":true}");
                }
                else
                {
                    var msg = (result?.Message ?? "Mark read failed").Replace("\"", "\\\"");
                    resp.StatusCode = 200;
                    resp.Write("{\"success\":false,\"message\":\"" + msg + "\"}");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("[NotificationMarkRead] error: " + ex);
                resp.StatusCode = 500;
                resp.Write("{\"success\":false,\"message\":\"Server error\"}");
            }
        }
    }
}
