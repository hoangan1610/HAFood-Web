using HAFoodWeb.Services;
using System;
using System.Web;

namespace HAFoodWeb.Proxy
{
    public class NotificationGo : IHttpHandler
    {
        public bool IsReusable => false;

        public void ProcessRequest(HttpContext context)
        {
            var req = context.Request;
            var resp = context.Response;

            string idStr = req.QueryString["id"];
            long notifyId = 0;
            long.TryParse(idStr, out notifyId);

            string targetEncoded = req.QueryString["u"];
            string targetUrl = null;

            if (!string.IsNullOrEmpty(targetEncoded))
            {
                targetUrl = HttpUtility.UrlDecode(targetEncoded);
            }

            if (string.IsNullOrWhiteSpace(targetUrl))
            {
                targetUrl = VirtualPathUtility.ToAbsolute("~/NotificationPage/NotificationPage.aspx",
                                                          req.ApplicationPath);
            }

            var token = req.Cookies["AuthToken"]?.Value;

            if (!string.IsNullOrEmpty(token) && notifyId > 0)
            {
                try
                {
                    var svc = new NotificationService();
                    // sync block ok trong handler
                    svc.MarkAsReadAsync(token, notifyId)
                       .GetAwaiter()
                       .GetResult();
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine("[NotificationGo] mark read error: " + ex);
                }
            }

            resp.Redirect(targetUrl, endResponse: false);
            context.ApplicationInstance.CompleteRequest();
        }
    }
}
