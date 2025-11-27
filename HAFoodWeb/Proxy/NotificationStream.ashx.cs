using HAFoodWeb.Services;
using Newtonsoft.Json;
using System;
using System.Threading;
using System.Web;

namespace HAFoodWeb.Proxy
{
    public class NotificationStream : IHttpHandler
    {
        public bool IsReusable => false;

        public void ProcessRequest(HttpContext context)
        {
            var req = context.Request;
            var resp = context.Response;

            // === SSE headers ===
            resp.ContentType = "text/event-stream";
            resp.ContentEncoding = System.Text.Encoding.UTF8;
            resp.Charset = "utf-8";

            resp.BufferOutput = false;
            resp.Cache.SetCacheability(HttpCacheability.NoCache);
            resp.Cache.SetNoStore();
            resp.Cache.SetRevalidation(HttpCacheRevalidation.AllCaches);
            resp.Cache.SetExpires(DateTime.UtcNow.AddSeconds(-1));

            // Lấy token từ cookie (giống Header / Login)
            var token = req.Cookies["AuthToken"]?.Value;
            if (string.IsNullOrEmpty(token))
            {
                resp.StatusCode = 401;
                WriteEvent(resp, "error", "{\"code\":\"UNAUTHENTICATED\"}");
                resp.Flush();
                return;
            }

            var svc = new NotificationService(); // dùng wrapper sync GetLatest
            int? lastUnread = null;

            // Gợi ý client reconnect sau 10s nếu đứt
            resp.Write("retry: 10000\n\n");
            resp.Flush();

            System.Diagnostics.Debug.WriteLine("[NotificationStream] START loop for user token.");

            // Vòng lặp giữ kết nối, mỗi X giây hỏi API 1 lần
            while (resp.IsClientConnected)
            {
                try
                {
                    // Gọi API latest (wrapper sync, bên trong đã ConfigureAwait(false))
                    var latest = svc.GetLatest(token, take: 1);

                    if (latest == null)
                    {
                        System.Diagnostics.Debug.WriteLine("[NotificationStream] latest == null");
                    }
                    else
                    {
                        System.Diagnostics.Debug.WriteLine("[NotificationStream] latest.totalUnread = " + latest.totalUnread);
                    }

                    var totalUnread = latest?.totalUnread ?? 0;

                    System.Diagnostics.Debug.WriteLine("[NotificationStream] totalUnread = " + totalUnread);

                    if (lastUnread == null || totalUnread != lastUnread.Value)
                    {
                        lastUnread = totalUnread;

                        var payload = JsonConvert.SerializeObject(new
                        {
                            totalUnread
                        });

                        System.Diagnostics.Debug.WriteLine("[NotificationStream] push SSE: " + payload);

                        WriteEvent(resp, "notifications.badge", payload);
                        resp.Flush();
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine("[NotificationStream] error: " + ex);

                    WriteEvent(resp, "error", "{\"code\":\"SERVER_ERROR\"}");
                    resp.Flush();

                    // chờ 5s rồi thử lại (nếu client vẫn còn nối)
                    Thread.Sleep(5000);
                    continue;
                }

                // Khoảng giữa 2 lần check – 5s là đủ “realtime” với badge + toast
                Thread.Sleep(5000);
            }

            System.Diagnostics.Debug.WriteLine("[NotificationStream] client disconnected, END.");
        }

        private static void WriteEvent(HttpResponse resp, string evt, string data)
        {
            resp.Write("event: " + evt + "\n");
            resp.Write("data: " + data + "\n\n");
        }
    }
}
