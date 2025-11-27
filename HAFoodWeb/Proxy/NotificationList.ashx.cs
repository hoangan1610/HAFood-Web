using HAFoodWeb.Models;
using HAFoodWeb.Services;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;

namespace HAFoodWeb.Proxy
{
    public class NotificationList : IHttpHandler
    {
        public bool IsReusable => false;

        // Regex tìm mã đơn trong title/body (fallback)
        private static readonly Regex OrderCodeStrong =
            new Regex(@"(?:đơn\s*hàng|mã\s*đơn|order)\s*#?\s*[:\-]?\s*([A-Z0-9\-]{6,})",
                RegexOptions.Compiled | RegexOptions.IgnoreCase | RegexOptions.CultureInvariant);

        private static readonly Regex OrderCodeFallback =
            new Regex(@"(?<!\d)(\d{10,20})(?!\d)",
                RegexOptions.Compiled | RegexOptions.CultureInvariant);

        public void ProcessRequest(HttpContext context)
        {
            var req = context.Request;
            var resp = context.Response;

            resp.ContentType = "text/html; charset=utf-8";
            resp.ContentEncoding = Encoding.UTF8;

            // Lấy token giống NotificationStream / Header
            var token = req.Cookies["AuthToken"]?.Value;
            if (string.IsNullOrEmpty(token))
            {
                resp.StatusCode = 401;
                resp.Write("<div class=\"notify-empty\">Bạn chưa đăng nhập.</div>");
                return;
            }

            var svc = new NotificationService();
            NotificationLatestResultDto latest = null;

            try
            {
                latest = svc.GetLatestAsync(token, take: 10)
                            .GetAwaiter().GetResult();

                System.Diagnostics.Debug.WriteLine(
                    "[NotificationList] latest: " +
                    (latest == null
                         ? "null"
                         : $"items={latest.items?.Count ?? 0}, totalUnread={latest.totalUnread}")
                );
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("[NotificationList] error: " + ex);
                resp.StatusCode = 500;
                resp.Write("<div class=\"notify-empty\">Không tải được danh sách thông báo.</div>");
                return;
            }

            if (latest == null || latest.items == null || !latest.items.Any())
            {
                resp.Write("<div class=\"notify-empty\">Chưa có thông báo nào.</div>");
                return;
            }

            var sb = new StringBuilder();

            foreach (var n in latest.items)
            {
                var id = n.id;
                var title = HttpUtility.HtmlEncode(n.title ?? string.Empty);
                var body = HttpUtility.HtmlEncode(n.body ?? string.Empty);
                var timeText = (n.createdAt == default(DateTime))
                                   ? ""
                                   : n.createdAt.ToString("dd/MM/yyyy HH:mm");
                var unreadCls = !n.isRead ? " unread" : string.Empty;

                // URL đích thật (product / orders / notification page)
                var targetUrl = BuildTargetUrl(context, n);

                // Bao qua NotificationGo.ashx để đánh dấu đã đọc rồi mới redirect
                var goUrl = BuildGoUrl(context, n.id, targetUrl);
                var href = HttpUtility.HtmlAttributeEncode(goUrl);

                sb.Append("<a class=\"notify-item")
                  .Append(unreadCls)
                  .Append("\" data-id=\"").Append(id).Append("\" href=\"")
                  .Append(href).Append("\">");

                sb.Append("<div class=\"notify-item-title\">")
                  .Append(title)
                  .Append("</div>");

                sb.Append("<div class=\"notify-item-body\">")
                  .Append(body)
                  .Append("</div>");

                sb.Append("<div class=\"notify-item-time\">")
                  .Append(timeText)
                  .Append("</div>");

                sb.Append("</a>");
            }

            resp.Write(sb.ToString());
        }

        // ============ Helpers: parse data JSON ============

        private static IDictionary<string, object> ParseData(string json)
        {
            if (string.IsNullOrWhiteSpace(json)) return null;
            try
            {
                var dict = JsonConvert.DeserializeObject<Dictionary<string, object>>(json);
                if (dict == null) return null;
                return new Dictionary<string, object>(dict, StringComparer.OrdinalIgnoreCase);
            }
            catch
            {
                return null;
            }
        }

        private static long GetLongFromDict(IDictionary<string, object> dict, params string[] keys)
        {
            if (dict == null || keys == null) return 0L;
            foreach (var k in keys)
            {
                if (!dict.TryGetValue(k, out var v) || v == null) continue;
                if (v is long l) return l;
                if (v is int i) return i;
                if (long.TryParse(Convert.ToString(v), out var r)) return r;
            }
            return 0L;
        }

        private static string GetStringFromDict(IDictionary<string, object> dict, params string[] keys)
        {
            if (dict == null || keys == null) return null;
            foreach (var k in keys)
            {
                if (!dict.TryGetValue(k, out var v) || v == null) continue;
                var s = Convert.ToString(v);
                if (!string.IsNullOrWhiteSpace(s)) return s;
            }
            return null;
        }

        private static string ExtractOrderCode(string text)
        {
            if (string.IsNullOrWhiteSpace(text)) return null;

            var m1 = OrderCodeStrong.Match(text);
            if (m1.Success) return TrimPunct(m1.Groups[1].Value);

            var m2 = OrderCodeFallback.Match(text);
            if (m2.Success) return TrimPunct(m2.Groups[1].Value);

            return null;
        }

        private static string TrimPunct(string s)
            => (s ?? "").Trim(' ', '.', ',', ';', ':', '#', ']', '[', ')', '(', '!', '?', '"', '\'');

        /// <summary>
        /// URL đích thật (Product / Orders / NotificationPage) – giống logic NotificationPage.BuildNotificationUrl
        /// </summary>
        private static string BuildTargetUrl(HttpContext ctx, NotificationDto n)
        {
            try
            {
                var dataDict = ParseData(n.data);

                long pid = GetLongFromDict(dataDict, "product_id", "productId");
                long reviewId = GetLongFromDict(dataDict, "review_id", "reviewId");

                if (pid > 0)
                {
                    var url = $"~/Product/Product.aspx?id={pid}";
                    if (reviewId > 0)
                    {
                        url += "&review=" + reviewId;
                    }
                    return VirtualPathUtility.ToAbsolute(url, ctx.Request.ApplicationPath);
                }

                string code = GetStringFromDict(dataDict, "order_code", "orderCode");
                if (string.IsNullOrWhiteSpace(code))
                {
                    var extracted = ExtractOrderCode(n.title) ?? ExtractOrderCode(n.body);
                    code = extracted;
                }

                if (!string.IsNullOrWhiteSpace(code))
                {
                    var encoded = HttpUtility.UrlEncode(code);
                    var url = "~/UserInfo/UserDetail.aspx?tab=orders&id=" + encoded;
                    return VirtualPathUtility.ToAbsolute(url, ctx.Request.ApplicationPath);
                }
            }
            catch { }

            // Fallback: về trang danh sách thông báo
            return VirtualPathUtility.ToAbsolute("~/NotificationPage/NotificationPage.aspx",
                                                 ctx.Request.ApplicationPath);
        }

        /// <summary>
        /// Bao URL đích qua NotificationGo.ashx để đánh dấu đã đọc.
        /// </summary>
        private static string BuildGoUrl(HttpContext ctx, long notifyId, string targetUrl)
        {
            if (string.IsNullOrWhiteSpace(targetUrl))
            {
                targetUrl = VirtualPathUtility.ToAbsolute("~/NotificationPage/NotificationPage.aspx",
                                                          ctx.Request.ApplicationPath);
            }

            var encodedTarget = HttpUtility.UrlEncode(targetUrl);
            var go = $"~/Proxy/NotificationGo.ashx?id={notifyId}&u={encodedTarget}";
            return VirtualPathUtility.ToAbsolute(go, ctx.Request.ApplicationPath);
        }
    }
}
