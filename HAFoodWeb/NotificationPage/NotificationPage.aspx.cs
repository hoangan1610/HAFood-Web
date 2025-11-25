using HAFoodWeb.Models;
using HAFoodWeb.Services;
using System;
using System.Text;
using System.Threading.Tasks;

namespace HAFoodWeb.NotificationPage
{
    public partial class NotificationPage : System.Web.UI.Page
    {
        private const int PageSize = 10; // số thông báo mỗi trang

        protected async void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                await BindNotificationsAsync();
            }
        }

        private async Task BindNotificationsAsync()
        {
            var token = Request?.Cookies["AuthToken"]?.Value;

            // Nếu chưa đăng nhập -> chuyển sang trang login
            if (string.IsNullOrEmpty(token))
            {
                var returnUrl = Server.UrlEncode(Request.RawUrl);
                Response.Redirect($"~/AuthPage/Login.aspx?returnUrl={returnUrl}", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            int page = 1;
            var pageQuery = Request.QueryString["page"];
            if (!string.IsNullOrEmpty(pageQuery) && !int.TryParse(pageQuery, out page))
            {
                page = 1;
            }
            if (page <= 0) page = 1;

            var service = new NotificationService();
            NotificationPagedResultDto result = null;

            try
            {
                // Gọi API phân trang bằng await (không block)
                result = await service.GetPagedAsync(token, page, PageSize, false, null);
            }
            catch
            {
                result = null;
            }

            if (result == null || result.items == null || result.items.Count == 0)
            {
                rptAllNotifications.DataSource = null;
                rptAllNotifications.DataBind();

                pnlNoData.Visible = true;
                pnlPager.Visible = false;

                lblSummary.Text = "Hiện bạn chưa có thông báo nào.";
                return;
            }

            // Đảm bảo mới nhất ở trên (nếu server chưa sort)
            result.items.Sort((a, b) => b.createdAt.CompareTo(a.createdAt));

            rptAllNotifications.DataSource = result.items;
            rptAllNotifications.DataBind();
            pnlNoData.Visible = false;

            // tóm tắt
            lblSummary.Text = $"Bạn có {result.totalRows} thông báo, trong đó {result.totalUnread} chưa đọc.";

            // tính phân trang
            int totalRows = result.totalRows;
            int pageSize = result.pageSize > 0 ? result.pageSize : PageSize;
            int totalPages = (int)Math.Ceiling(totalRows / (double)pageSize);
            int currentPage = result.page <= 0 ? 1 : result.page;

            if (totalPages > 1)
            {
                pnlPager.Visible = true;
                litPager.Text = BuildPagerHtml(currentPage, totalPages);
            }
            else
            {
                pnlPager.Visible = false;
            }
        }

        private string BuildPagerHtml(int currentPage, int totalPages)
        {
            var urlRoot = ResolveUrl("~/NotificationPage/NotificationPage");
            var sb = new StringBuilder();

            sb.Append("<nav aria-label='Phân trang thông báo'><ul class='hf-pagination'>");

            // Previous
            if (currentPage > 1)
            {
                var prevUrl = $"{urlRoot}?page={currentPage - 1}";
                sb.AppendFormat("<li class='page-item prev'><a href='{0}'>Trang trước</a></li>", prevUrl);
            }

            // Hiển thị vài trang xung quanh trang hiện tại
            int start = Math.Max(1, currentPage - 2);
            int end = Math.Min(totalPages, currentPage + 2);

            if (start > 1)
            {
                var firstUrl = $"{urlRoot}?page=1";
                sb.AppendFormat("<li class='page-item'><a href='{0}'>1</a></li>", firstUrl);
                if (start > 2)
                {
                    sb.Append("<li class='page-item'><a href='javascript:void(0)'>...</a></li>");
                }
            }

            for (int i = start; i <= end; i++)
            {
                var css = i == currentPage ? "active" : "";
                var pageUrl = $"{urlRoot}?page={i}";
                sb.AppendFormat("<li class='page-item {2}'><a href='{0}'>{1}</a></li>", pageUrl, i, css);
            }

            if (end < totalPages)
            {
                if (end < totalPages - 1)
                {
                    sb.Append("<li class='page-item'><a href='javascript:void(0)'>...</a></li>");
                }
                var lastUrl = $"{urlRoot}?page={totalPages}";
                sb.AppendFormat("<li class='page-item'><a href='{0}'>{1}</a></li>", lastUrl, totalPages);
            }

            // Next
            if (currentPage < totalPages)
            {
                var nextUrl = $"{urlRoot}?page={currentPage + 1}";
                sb.AppendFormat("<li class='page-item next'><a href='{0}'>Trang sau</a></li>", nextUrl);
            }

            sb.Append("</ul></nav>");

            return sb.ToString();
        }
    }
}
