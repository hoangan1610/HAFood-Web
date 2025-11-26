using HAFoodWeb.Models;
using HAFoodWeb.Services;
using System;
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

        // ===== Helpers =====

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

        // Link ưu tiên sang trang Product theo product_Id (bỏ review_Id)
        protected string BuildNotificationUrl(object dataItem)
        {
            try
            {
                long pid = GetLong(
                    dataItem,
                    "product_Id", "productId",
                    "payload.product_Id", "payload.productId",
                    "data.product_Id", "data.productId"
                );

                if (pid > 0)
                    return ResolveUrl($"~/Product/Product.aspx?id={pid}");

                // Legacy: nếu có mã đơn thì về tab orders
                string title = Convert.ToString(DataBinder.Eval(dataItem, "title"));
                string body = Convert.ToString(DataBinder.Eval(dataItem, "body"));

                string extraCode = null;
                try { extraCode = Convert.ToString(DataBinder.Eval(dataItem, "order_Code")); } catch { }
                if (string.IsNullOrWhiteSpace(extraCode))
                {
                    try { extraCode = Convert.ToString(DataBinder.Eval(dataItem, "orderCode")); } catch { }
                }

                var code = extraCode ?? ExtractOrderCode(title) ?? ExtractOrderCode(body);
                if (!string.IsNullOrWhiteSpace(code))
                {
                    return ResolveUrl("~/UserInfo/UserDetail.aspx?tab=orders&id=" + Server.UrlEncode(code));
                }
            }
            catch { }

            return "javascript:void(0)";
        }
    }
}
