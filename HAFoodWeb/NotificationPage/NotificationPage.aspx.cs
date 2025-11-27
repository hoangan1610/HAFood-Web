using HAFoodWeb.Models;
using HAFoodWeb.Services;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Web;
using System.Web.UI;

namespace HAFoodWeb.NotificationPage
{
    public partial class NotificationPage : System.Web.UI.Page
    {
        private const int PageSize = 10;

        private static readonly Regex OrderCodeStrong =
            new Regex(@"(?:đơn\s*hàng|mã\s*đơn|order)\s*#?\s*[:\-]?\s*([A-Z0-9\-]{6,})",
                RegexOptions.Compiled | RegexOptions.IgnoreCase | RegexOptions.CultureInvariant);

        private static readonly Regex OrderCodeFallback =
            new Regex(@"(?<!\d)(\d{10,20})(?!\d)",
                RegexOptions.Compiled | RegexOptions.CultureInvariant);

        protected async void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack) await BindNotificationsAsync();
        }

        private async Task BindNotificationsAsync()
        {
            var token = Request?.Cookies["AuthToken"]?.Value;

            if (string.IsNullOrEmpty(token))
            {
                var returnUrl = Server.UrlEncode(Request.RawUrl);
                Response.Redirect($"~/AuthPage/Login.aspx?returnUrl={returnUrl}", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            int page = 1;
            var pageQuery = Request.QueryString["page"];
            if (!string.IsNullOrEmpty(pageQuery) && !int.TryParse(pageQuery, out page)) page = 1;
            if (page <= 0) page = 1;

            var service = new NotificationService();
            NotificationPagedResultDto result = null;

            try { result = await service.GetPagedAsync(token, page, PageSize, false, null); }
            catch { result = null; }

            if (result == null || result.items == null || result.items.Count == 0)
            {
                rptAllNotifications.DataSource = null; rptAllNotifications.DataBind();
                pnlNoData.Visible = true; pnlPager.Visible = false;
                lblSummary.Text = "Hiện bạn chưa có thông báo nào.";
                return;
            }

            result.items.Sort((a, b) => b.createdAt.CompareTo(a.createdAt));
            rptAllNotifications.DataSource = result.items;
            rptAllNotifications.DataBind();
            pnlNoData.Visible = false;

            lblSummary.Text = $"Bạn có {result.totalRows} thông báo, trong đó {result.totalUnread} chưa đọc.";

            int totalRows = result.totalRows;
            int pageSize = result.pageSize > 0 ? result.pageSize : PageSize;
            int totalPages = (int)Math.Ceiling(totalRows / (double)pageSize);
            int currentPage = result.page <= 0 ? 1 : result.page;

            if (totalPages > 1)
            {
                pnlPager.Visible = true;
                litPager.Text = BuildPagerHtml(currentPage, totalPages);
            }
            else pnlPager.Visible = false;
        }

        private string BuildPagerHtml(int currentPage, int totalPages)
        {
            var urlRoot = ResolveUrl("~/NotificationPage/NotificationPage");
            var sb = new StringBuilder();
            sb.Append("<nav aria-label='Phân trang thông báo'><ul class='hf-pagination'>");

            if (currentPage > 1)
            {
                var prevUrl = $"{urlRoot}?page={currentPage - 1}";
                sb.AppendFormat("<li class='page-item prev'><a href='{0}'>Trang trước</a></li>", prevUrl);
            }

            int start = Math.Max(1, currentPage - 2);
            int end = Math.Min(totalPages, currentPage + 2);

            if (start > 1)
            {
                var firstUrl = $"{urlRoot}?page=1";
                sb.AppendFormat("<li class='page-item'><a href='{0}'>1</a></li>", firstUrl);
                if (start > 2) sb.Append("<li class='page-item'><a href='javascript:void(0)'>...</a></li>");
            }

            for (int i = start; i <= end; i++)
            {
                var css = i == currentPage ? "active" : "";
                var pageUrl = $"{urlRoot}?page={i}";
                sb.AppendFormat("<li class='page-item {2}'><a href='{0}'>{1}</a></li>", pageUrl, i, css);
            }

            if (end < totalPages)
            {
                if (end < totalPages - 1) sb.Append("<li class='page-item'><a href='javascript:void(0)'>...</a></li>");
                var lastUrl = $"{urlRoot}?page={totalPages}";
                sb.AppendFormat("<li class='page-item'><a href='{0}'>{1}</a></li>", lastUrl, totalPages);
            }

            if (currentPage < totalPages)
            {
                var nextUrl = $"{urlRoot}?page={currentPage + 1}";
                sb.AppendFormat("<li class='page-item next'><a href='{0}'>Trang sau</a></li>", nextUrl);
            }

            sb.Append("</ul></nav>");
            return sb.ToString();
        }

        // ===== Helpers JSON data =====

        private static IDictionary<string, object> ParseDataJson(object dataItem)
        {
            try
            {
                var raw = Convert.ToString(DataBinder.Eval(dataItem, "data"));
                if (string.IsNullOrWhiteSpace(raw)) return null;

                var dict = JsonConvert.DeserializeObject<Dictionary<string, object>>(raw);
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

        private static long GetLong(object dataItem, params string[] paths)
        {
            if (dataItem == null || paths == null) return 0L;
            foreach (var p in paths)
            {
                try
                {
                    var v = DataBinder.Eval(dataItem, p);
                    if (v == null) continue;
                    if (v is long l) return l;
                    if (v is int i) return i;
                    if (long.TryParse(Convert.ToString(v), out var r)) return r;
                }
                catch { }
            }
            return 0L;
        }

        // Link ưu tiên sang Product theo product_Id; nếu có review_Id thì thêm ?review=
        // Link ưu tiên sang Product theo product_Id; nếu có review_Id thì thêm ?review=
        // ĐÃ ĐỔI: bọc qua Proxy/NotificationGo.ashx để click = đánh dấu đã đọc
        protected string BuildNotificationUrl(object dataItem)
        {
            try
            {
                // 0) Lấy notification_id
                long notifyId = 0;
                try
                {
                    var idObj = DataBinder.Eval(dataItem, "id");
                    if (idObj != null)
                    {
                        long.TryParse(Convert.ToString(idObj), out notifyId);
                    }
                }
                catch { }

                // 1) Ưu tiên đọc JSON data
                var dataDict = ParseDataJson(dataItem);

                long pid = GetLongFromDict(dataDict, "product_id", "productId");
                long reviewId = GetLongFromDict(dataDict, "review_id", "reviewId");

                // fallback nếu API sau này có thêm field riêng
                if (pid <= 0)
                {
                    pid = GetLong(dataItem, "product_Id", "productId");
                }
                if (reviewId <= 0)
                {
                    reviewId = GetLong(dataItem, "review_Id", "reviewId");
                }

                // === Bước 2: build URL ĐÍCH THẬT (chưa wrap NotificationGo) ===
                string target = null;

                if (pid > 0)
                {
                    target = $"~/Product/Product.aspx?id={pid}";
                    if (reviewId > 0)
                    {
                        target += "&review=" + reviewId;
                    }
                }
                else
                {
                    // Order – ưu tiên đọc order_code trong JSON
                    string code = GetStringFromDict(dataDict, "order_code", "orderCode");

                    string title = Convert.ToString(DataBinder.Eval(dataItem, "title"));
                    string body = Convert.ToString(DataBinder.Eval(dataItem, "body"));

                    if (string.IsNullOrWhiteSpace(code))
                    {
                        string extraCode = null;
                        try { extraCode = Convert.ToString(DataBinder.Eval(dataItem, "order_Code")); } catch { }
                        if (string.IsNullOrWhiteSpace(extraCode))
                        {
                            try { extraCode = Convert.ToString(DataBinder.Eval(dataItem, "orderCode")); } catch { }
                        }

                        code = extraCode ?? ExtractOrderCode(title) ?? ExtractOrderCode(body);
                    }

                    if (!string.IsNullOrWhiteSpace(code))
                    {
                        target = "~/UserInfo/UserDetail.aspx?tab=orders&id=" + Server.UrlEncode(code);
                    }
                }

                // Nếu vẫn không biết đi đâu thì khỏi wrap, tránh lỗi
                if (string.IsNullOrWhiteSpace(target))
                {
                    return "javascript:void(0)";
                }

                // Convert target sang absolute 1 lần
                var absTarget = ResolveUrl(target);

                // Nếu vì lý do gì đó không lấy được notifyId => đi thẳng
                if (notifyId <= 0)
                {
                    return absTarget;
                }

                // === Bước 3: bọc qua NotificationGo.ashx để mark-as-read rồi redirect ===
                var goUrl = $"~/Proxy/NotificationGo.ashx?id={notifyId}&u={Server.UrlEncode(absTarget)}";
                return ResolveUrl(goUrl);
            }
            catch
            {
                // fallback: không biết đi đâu
                return "javascript:void(0)";
            }
        }

    }
}
