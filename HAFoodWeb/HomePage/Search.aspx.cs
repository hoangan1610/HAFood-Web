using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using HAFoodWeb.Models;
using HAFoodWeb.Services;

namespace HAFoodWeb
{
    public partial class Search : Page
    {
        private readonly ISearchService _search = new SearchService();
        private readonly ICategoryService _cats = new CategoryService();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;

            RegisterAsyncTask(new PageAsyncTask(async ct =>
            {
                await BindCategoryTreeAsync();
                await BindAsync();
            }));
        }

        private static int? ParseNullableInt(string s)
        {
            int v;
            return int.TryParse(s, out v) ? v : (int?)null;
        }

        private ProductSearchRequest ReadRequest()
        {
            int page, pageSize; long catId;
            int.TryParse(Request["page"], out page);
            int.TryParse(Request["page_size"], out pageSize);
            long.TryParse(Request["category_id"], out catId);

            double? min = null, max = null;
            double tmp;
            if (double.TryParse(Request["min_price"], out tmp)) min = tmp;
            if (double.TryParse(Request["max_price"], out tmp)) max = tmp;

            // Map sort UI → DB column
            string sort = (Request["sort"] ?? "updated_at:desc").Trim().ToLowerInvariant();
            if (sort == "price:asc") sort = "min_retail_price:asc";
            else if (sort == "price:desc") sort = "min_retail_price:desc";
            else if (sort == "name:asc") sort = "product_name:asc";
            else if (sort == "name:desc") sort = "product_name:desc";

            // Weight ranges (w=from-to)
            var weightRanges = new List<WeightRange>();
            var wParams = Request.QueryString.GetValues("w");
            if (wParams != null && wParams.Length > 0)
            {
                foreach (var s in wParams)
                {
                    if (string.IsNullOrWhiteSpace(s)) continue;
                    var parts = s.Split(new[] { '-' }, 2, StringSplitOptions.None);
                    int from;
                    if (parts.Length >= 1 && int.TryParse(parts[0], out from))
                    {
                        int toParsed; int? to = null;
                        if (parts.Length == 2 && int.TryParse(parts[1], out toParsed)) to = toParsed;
                        weightRanges.Add(new WeightRange { From = from, To = to });
                    }
                }
            }

            // Checkbox fallback
            if (weightRanges.Count == 0)
            {
                if (Request["w_100_250"] == "on") weightRanges.Add(new WeightRange { From = 100, To = 250 });
                if (Request["w_250_500"] == "on") weightRanges.Add(new WeightRange { From = 250, To = 500 });
                if (Request["w_500_1000"] == "on") weightRanges.Add(new WeightRange { From = 500, To = 1000 });
                if (Request["w_1000_5000"] == "on") weightRanges.Add(new WeightRange { From = 1000, To = 5000 });
                if (Request["w_5000"] == "on") weightRanges.Add(new WeightRange { From = 5000, To = (int?)null });
            }

            // Clamp price
            if (min.HasValue)
            {
                var v = min.Value; if (v < 10000) v = 10000; if (v > 1000000) v = 1000000;
                min = Math.Round(v / 1000d) * 1000d;
            }
            if (max.HasValue)
            {
                var v = max.Value; if (v < 10000) v = 10000; if (v > 1000000) v = 1000000;
                max = Math.Round(v / 1000d) * 1000d;
            }
            if (min.HasValue && max.HasValue && min > max) { var t = min; min = max; max = t; }

            int? status = ParseNullableInt(Request["status"]);

            return new ProductSearchRequest
            {
                Query = (Request["q"] ?? "").Trim(),
                CategoryId = catId > 0 ? (long?)catId : null,
                Brand = (Request["brand"] ?? "").Trim(),
                MinPrice = min,
                MaxPrice = max,
                OnlyInStock = string.Equals(Request["only_in_stock"], "true", StringComparison.OrdinalIgnoreCase),
                Sort = string.IsNullOrWhiteSpace(sort) ? "updated_at:desc" : sort,
                Page = page > 0 ? page : 1,
                PageSize = pageSize > 0 ? pageSize : 20,
                Status = status,
                WeightRanges = weightRanges
            };
        }

        private string CurrentSearchPath() => ResolveUrl(Request.CurrentExecutionFilePath);

        private string BuildCategoryLink(long id)
        {
            var rawQs = Request.QueryString == null ? "" : Request.QueryString.ToString();
            var nv = HttpUtility.ParseQueryString(rawQs ?? "");
            nv["category_id"] = id.ToString();
            nv["page"] = "1";

            var ub = new UriBuilder(Request.Url) { Path = CurrentSearchPath(), Query = nv.ToString() };
            return ub.Uri.PathAndQuery;
        }

        private async System.Threading.Tasks.Task BindCategoryTreeAsync()
        {
            var all = await _cats.GetAllAsync() ?? new List<CategoryTreeDto>();

            var byParent = all
                .Where(x => x.Parent_Id.HasValue)
                .GroupBy(x => x.Parent_Id.Value)
                .ToDictionary(
                    g => g.Key,
                    g => g.OrderBy(x => x.Sort_Order ?? int.MaxValue).ThenBy(x => x.Name).ToList()
                );

            var idSet = new HashSet<long>(all.Select(x => x.Id));
            var roots = all
                .Where(x => !x.Parent_Id.HasValue || !idSet.Contains(x.Parent_Id.Value))
                .OrderBy(x => x.Sort_Order ?? int.MaxValue).ThenBy(x => x.Name).ToList();

            var expandSet = new HashSet<long>();
            long selId;
            if (long.TryParse(Request["category_id"], out selId))
            {
                var parentMap = all.ToDictionary(x => x.Id, x => x.Parent_Id);
                long? cur = selId;
                while (cur.HasValue && parentMap.TryGetValue(cur.Value, out var p))
                {
                    if (p.HasValue) expandSet.Add(p.Value); else break;
                    cur = p;
                }
            }

            var sb = new StringBuilder();
            foreach (var r in roots)
                RenderNode(r, sb, byParent, expandSet, selId > 0 ? (long?)selId : null);

            ltCategoryTree.Text = sb.ToString();
        }

        private void RenderNode(
            CategoryTreeDto n,
            StringBuilder sb,
            Dictionary<long, List<CategoryTreeDto>> byParent,
            HashSet<long> expandSet,
            long? selectedId)
        {
            byParent.TryGetValue(n.Id, out var children);
            bool hasChild = children != null && children.Count > 0;

            bool isSelected = (selectedId.HasValue && n.Id == selectedId.Value);
            bool expanded = isSelected || (expandSet != null && expandSet.Contains(n.Id));

            sb.Append("<div class='cat-node'>");

            if (hasChild)
            {
                sb.Append("<div class='d-flex justify-content-between align-items-center'>");

                // ✅ thêm class active + data-cat-id để JS lookup tên category cho chip
                sb.AppendFormat(
                    "<a class='cat-link {2}' data-cat-id='{1}' {3} href='{0}'>{4}</a>",
                    BuildCategoryLink(n.Id),
                    n.Id,
                    isSelected ? "is-active" : "",
                    isSelected ? "aria-current='true'" : "",
                    Server.HtmlEncode(n.Name)
                );

                sb.AppendFormat(
                    "<span class='cat-toggle small text-muted' data-toggle-cat='{0}' aria-expanded='{1}'> {2} </span>",
                    n.Id, expanded ? "true" : "false", expanded ? "–" : "+"
                );

                sb.Append("</div>");

                sb.AppendFormat("<div id='cat-children-{0}' class='cat-children {1}'>", n.Id, expanded ? "" : "d-none");
                foreach (var c in children) RenderNode(c, sb, byParent, expandSet, selectedId);
                sb.Append("</div>");
            }
            else
            {
                sb.AppendFormat(
                    "<a class='cat-link {2}' data-cat-id='{1}' {3} href='{0}'>{4}</a>",
                    BuildCategoryLink(n.Id),
                    n.Id,
                    isSelected ? "is-active" : "",
                    isSelected ? "aria-current='true'" : "",
                    Server.HtmlEncode(n.Name)
                );
            }

            sb.Append("</div>");
        }

        protected async System.Threading.Tasks.Task BindAsync()
        {
            var req = ReadRequest();

            var list = await _search.SearchListAsync(req);
            var cards = await _search.BuildCardsAsync(req, list);

            ltTotal.Text = string.Format("{0:n0} sản phẩm", list.TotalCount);

            // EMPTY STATE
            if (list.TotalCount == 0)
            {
                rpProducts.Visible = false;
                ltPager.Text = string.Empty;

                ltEmpty.Text = @"
<div class='text-center py-5'>
  <p class='mb-2 fw-semibold'>Không tìm thấy sản phẩm phù hợp</p>
  <p class='text-muted mb-3 small'>
    Bạn thử xoá bớt bộ lọc hoặc đổi từ khoá tìm kiếm nhé.
  </p>
  <button type='button' class='btn btn-outline-secondary btn-sm' onclick='clearAllFilters()'>
    Xoá tất cả bộ lọc
  </button>
</div>";

                // DEBUG URL API
                if (!string.IsNullOrEmpty(_search.LastListUrl))
                {
                    var debugUrl0 = _search.LastListUrl
                        .Replace("\\", "\\\\")
                        .Replace("'", "\\'")
                        .Replace(Environment.NewLine, "");

                    ClientScript.RegisterStartupScript(
                        this.GetType(),
                        "searchDebug",
                        $"console.log('SearchApiUrl = \"{debugUrl0}\"');",
                        true
                    );
                }

                return;
            }

            rpProducts.Visible = true;
            ltEmpty.Text = string.Empty;

            rpProducts.DataSource = cards;
            rpProducts.DataBind();

            ltPager.Text = BuildPager(req.Page, req.PageSize, list.TotalCount);

            // DEBUG URL API
            if (!string.IsNullOrEmpty(_search.LastListUrl))
            {
                var debugUrl = _search.LastListUrl
                    .Replace("\\", "\\\\")
                    .Replace("'", "\\'")
                    .Replace(Environment.NewLine, "");

                ClientScript.RegisterStartupScript(
                    this.GetType(),
                    "searchDebug",
                    $"console.log('SearchApiUrl = \"{debugUrl}\"');",
                    true
                );
            }
        }

        private string BuildPager(int page, int pageSize, int total)
        {
            if (total <= pageSize) return "";
            var totalPages = (int)Math.Ceiling((double)total / pageSize);
            if (page < 1) page = 1;
            if (page > totalPages) page = totalPages;

            string SetPage(int p)
            {
                var rawQs = Request.QueryString == null ? "" : Request.QueryString.ToString();
                var nv = HttpUtility.ParseQueryString(rawQs ?? "");
                nv["page"] = p.ToString();

                var ub = new UriBuilder(Request.Url) { Path = CurrentSearchPath(), Query = nv.ToString() };
                return ub.Uri.PathAndQuery;
            }

            string PageItem(string text, string href, bool disabled, bool active, string ariaLabel, bool isSpanWhenDisabled = false)
            {
                var cls = "page-item";
                if (disabled) cls += " disabled";
                if (active) cls += " active";

                if (disabled && isSpanWhenDisabled)
                {
                    return $"<li class='{cls}'><span class='page-link' aria-label='{HttpUtility.HtmlAttributeEncode(ariaLabel)}'>{HttpUtility.HtmlEncode(text)}</span></li>";
                }

                var ariaCurrent = active ? " aria-current='page'" : "";
                var safeHref = disabled ? "#" : href;
                return $"<li class='{cls}'><a class='page-link' href='{safeHref}' aria-label='{HttpUtility.HtmlAttributeEncode(ariaLabel)}'{ariaCurrent}>{HttpUtility.HtmlEncode(text)}</a></li>";
            }

            string Ellipsis()
            {
                return "<li class='page-item disabled'><span class='page-link'>…</span></li>";
            }

            var sb = new StringBuilder();

            // First / Prev
            sb.Append(PageItem("Đầu", SetPage(1), page <= 1, false, "Trang đầu"));
            sb.Append(PageItem("‹", SetPage(page - 1), page <= 1, false, "Trang trước"));

            // Pages with ellipsis
            const int window = 2;
            int start = Math.Max(1, page - window);
            int end = Math.Min(totalPages, page + window);

            if (start > 1)
            {
                sb.Append(PageItem("1", SetPage(1), false, page == 1, "Trang 1"));
                if (start > 2) sb.Append(Ellipsis());
            }

            for (int i = start; i <= end; i++)
            {
                sb.Append(PageItem(i.ToString(), SetPage(i), false, i == page, $"Trang {i}"));
            }

            if (end < totalPages)
            {
                if (end < totalPages - 1) sb.Append(Ellipsis());
                sb.Append(PageItem(totalPages.ToString(), SetPage(totalPages), false, page == totalPages, $"Trang {totalPages}"));
            }

            // Next / Last
            sb.Append(PageItem("›", SetPage(page + 1), page >= totalPages, false, "Trang sau"));
            sb.Append(PageItem("Cuối", SetPage(totalPages), page >= totalPages, false, "Trang cuối"));

            return sb.ToString();
        }
    }
}
