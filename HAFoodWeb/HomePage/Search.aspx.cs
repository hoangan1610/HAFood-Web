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
            double tmp; // non-nullable cho TryParse
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
            bool expanded = (selectedId.HasValue && n.Id == selectedId.Value) || (expandSet != null && expandSet.Contains(n.Id));

            sb.Append("<div class='cat-node'>");

            if (hasChild)
            {
                sb.Append("<div class='d-flex justify-content-between align-items-center'>");
                sb.AppendFormat("<a class='text-decoration-none' href='{0}'>{1}</a>",
                    BuildCategoryLink(n.Id), Server.HtmlEncode(n.Name));
                sb.AppendFormat("<span class='cat-toggle small text-muted' data-toggle-cat='{0}' aria-expanded='{1}'> {2} </span>",
                    n.Id, expanded ? "true" : "false", expanded ? "–" : "+");
                sb.Append("</div>");

                sb.AppendFormat("<div id='cat-children-{0}' class='cat-children {1}'>", n.Id, expanded ? "" : "d-none");
                foreach (var c in children) RenderNode(c, sb, byParent, expandSet, selectedId);
                sb.Append("</div>");
            }
            else
            {
                sb.AppendFormat("<a class='text-decoration-none' href='{0}'>{1}</a>",
                    BuildCategoryLink(n.Id), Server.HtmlEncode(n.Name));
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

            // Có dữ liệu thì bind bình thường
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

            string SetPage(int p)
            {
                var rawQs = Request.QueryString == null ? "" : Request.QueryString.ToString();
                var nv = HttpUtility.ParseQueryString(rawQs ?? "");
                nv["page"] = p.ToString();

                var ub = new UriBuilder(Request.Url) { Path = CurrentSearchPath(), Query = nv.ToString() };
                return ub.Uri.PathAndQuery;
            }

            var sbHtml = new StringBuilder();
            sbHtml.AppendFormat("<li class='page-item{0}'><a class='page-link' href='{1}'>«</a></li>",
                page <= 1 ? " disabled" : "", page <= 1 ? "#" : SetPage(page - 1));

            int start = Math.Max(1, page - 2);
            int end = Math.Min(totalPages, page + 2);
            for (int i = start; i <= end; i++)
            {
                sbHtml.AppendFormat("<li class='page-item{0}'><a class='page-link' href='{1}'>{2}</a></li>",
                    i == page ? " active" : "", SetPage(i), i);
            }

            sbHtml.AppendFormat("<li class='page-item{0}'><a class='page-link' href='{1}'>»</a></li>",
                page >= totalPages ? " disabled" : "", page >= totalPages ? "#" : SetPage(page + 1));

            return sbHtml.ToString();
        }
    }
}
