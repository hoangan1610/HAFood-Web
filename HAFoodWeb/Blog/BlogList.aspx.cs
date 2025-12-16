using HAFoodWeb.Services;
using System;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web;

namespace HAFoodWeb.Blog
{
    public partial class BlogList : System.Web.UI.Page
    {
        private readonly IArticleService _svc = new ArticleService();
        private const int PageSize = 9;

        private int PageNum
        {
            get
            {
                if (int.TryParse(Request.QueryString["page"], out var p) && p > 0) return p;
                return 1;
            }
        }

        private string Q => (Request.QueryString["q"] ?? "").Trim();

        protected async void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                txtQ.Text = Q;
                await BindAsync();
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            var q = (txtQ.Text ?? "").Trim();
            Response.Redirect(BuildUrl(page: 1, q: q), false);
            Context.ApplicationInstance.CompleteRequest();
        }

        private async Task BindAsync()
        {
            var res = await _svc.ListAsync(Q, PageNum, PageSize);

            var items = res?.items ?? new System.Collections.Generic.List<HAFoodWeb.Models.ArticleListItemDto>();

            string apiBase = (ConfigurationManager.AppSettings["ApiBaseUrl"] ?? "").Trim().TrimEnd('/');
            foreach (var it in items)
                it.cover_Image_Url = NormalizeUrl(it.cover_Image_Url, apiBase);

            rpArticles.DataSource = items;
            rpArticles.DataBind();

            var total = res?.total ?? 0;
            var totalPages = (int)Math.Ceiling(total / (double)PageSize);
            if (totalPages <= 0) totalPages = 1;

            // nếu url page vượt tổng trang → redirect về trang cuối
            if (PageNum > totalPages)
            {
                Response.Redirect(BuildUrl(totalPages, Q), false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            litEmpty.Text = items.Any() ? "" : "<div class='text-muted py-3'>Chưa có bài viết.</div>";

            // Bỏ "Trang 1/1"
            litInfo.Text = "";

            // Pagination kiểu: 1,2,3 … 6 … 9,10 (khi nhiều trang)
            litPager.Text = BuildPagerHtml(PageNum, totalPages, Q);
        }

        private string BuildUrl(int page, string q)
        {
            page = Math.Max(1, page);
            q = (q ?? "").Trim();

            var url = ResolveUrl("~/blog");
            var parts = new System.Collections.Generic.List<string> { "page=" + page };
            if (!string.IsNullOrWhiteSpace(q))
                parts.Add("q=" + HttpUtility.UrlEncode(q));

            return url + "?" + string.Join("&", parts);
        }

        private string BuildPagerHtml(int page, int totalPages, string q)
        {
            string U(int p) => BuildUrl(p, q);

            var sb = new StringBuilder();
            sb.Append("<nav class='ha-pager' aria-label='Blog pagination'><ul class='pagination pagination-sm mb-0'>");

            // Prev
            sb.Append(page > 1
                ? $"<li class='page-item'><a class='page-link' href='{U(page - 1)}' aria-label='Previous'>←</a></li>"
                : "<li class='page-item disabled'><span class='page-link' aria-label='Previous'>←</span></li>");

            // Nếu ít trang thì show hết cho dễ
            if (totalPages <= 10)
            {
                for (int p = 1; p <= totalPages; p++)
                {
                    if (p == page)
                        sb.Append($"<li class='page-item active'><span class='page-link'>{p}</span></li>");
                    else
                        sb.Append($"<li class='page-item'><a class='page-link' href='{U(p)}'>{p}</a></li>");
                }
            }
            else
            {
                // Nhiều trang: 1,2,3 … current … last-1,last
                var pages = new System.Collections.Generic.SortedSet<int>();

                // first 3
                for (int p = 1; p <= 3; p++) pages.Add(p);

                // last 2
                pages.Add(totalPages - 1);
                pages.Add(totalPages);

                // current (nếu không nằm trong nhóm đầu/đuôi)
                if (page > 3 && page < totalPages - 1) pages.Add(page);

                int prev = 0;
                foreach (var p in pages)
                {
                    if (prev != 0 && p - prev > 1)
                        sb.Append("<li class='page-item disabled'><span class='page-link'>…</span></li>");

                    if (p == page)
                        sb.Append($"<li class='page-item active'><span class='page-link'>{p}</span></li>");
                    else
                        sb.Append($"<li class='page-item'><a class='page-link' href='{U(p)}'>{p}</a></li>");

                    prev = p;
                }
            }

            // Next
            sb.Append(page < totalPages
                ? $"<li class='page-item'><a class='page-link' href='{U(page + 1)}' aria-label='Next'>→</a></li>"
                : "<li class='page-item disabled'><span class='page-link' aria-label='Next'>→</span></li>");

            sb.Append("</ul></nav>");
            return sb.ToString();
        }

        private static string NormalizeUrl(string url, string apiBase)
        {
            url = (url ?? "").Trim();
            if (url.Length == 0) return "";

            if (url.StartsWith("http://", StringComparison.OrdinalIgnoreCase) ||
                url.StartsWith("https://", StringComparison.OrdinalIgnoreCase))
                return url;

            if (url.StartsWith("/") && !string.IsNullOrWhiteSpace(apiBase))
                return apiBase + url;

            return url;
        }

        protected string SafeText(object v, int max)
        {
            var s = (v ?? "").ToString().Trim();
            s = s.Replace("\r", " ").Replace("\n", " ");
            if (max > 0 && s.Length > max) s = s.Substring(0, max) + "…";
            return Server.HtmlEncode(s);
        }
    }
}
