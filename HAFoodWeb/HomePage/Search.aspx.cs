using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Web.UI;
using HAFoodWeb.Models;
using HAFoodWeb.Services;

namespace HAFoodWeb
{
    public partial class Search : Page
    {
        private readonly ISearchService _search = new SearchService();
        private readonly ICategoryService _cats = new CategoryService();

        protected async void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                await BindCategoryTreeAsync();
                await BindAsync();
            }
        }

        private ProductSearchRequest ReadRequest()
        {
            int.TryParse(Request["page"], out var page);
            int.TryParse(Request["page_size"], out var pageSize);
            long.TryParse(Request["category_id"], out var catId);

            double? min = null, max = null;
            if (double.TryParse(Request["min_price"], out var mp)) min = mp;
            if (double.TryParse(Request["max_price"], out var xp)) max = xp;

            return new ProductSearchRequest
            {
                Query = (Request["q"] ?? "").Trim(),
                CategoryId = catId > 0 ? (long?)catId : null,
                Brand = (Request["brand"] ?? "").Trim(),
                MinPrice = min,
                MaxPrice = max,
                OnlyInStock = string.Equals(Request["only_in_stock"], "true", StringComparison.OrdinalIgnoreCase),
                Sort = string.IsNullOrWhiteSpace(Request["sort"]) ? "updated_at:desc" : Request["sort"],
                Page = page > 0 ? page : 1,
                PageSize = pageSize > 0 ? pageSize : 20,
                Status = 1
            };
        }

        // ====================== HELPERS ======================

        // Path trang hiện tại (vd: /HomePage/Search hoặc /HomePage/Search.aspx)
        private string CurrentSearchPath()
        {
            return ResolveUrl(Request.CurrentExecutionFilePath);
        }

        // Build URL giữ nguyên query hiện có, chỉ thay category_id và reset page=1
        private string BuildCategoryLink(long id)
        {
            var qs = Request.QueryString.AllKeys
                .Where(k => !string.IsNullOrEmpty(k)
                            && !k.Equals("category_id", StringComparison.OrdinalIgnoreCase)
                            && !k.Equals("page", StringComparison.OrdinalIgnoreCase))
                .ToDictionary(k => k, k => Request.QueryString[k] ?? "");

            qs["category_id"] = id.ToString();
            qs["page"] = "1";

            var sb = new StringBuilder(CurrentSearchPath());
            sb.Append("?");

            bool first = true;
            foreach (var kv in qs)
            {
                if (!first) sb.Append("&");
                sb.Append(Uri.EscapeDataString(kv.Key))
                  .Append("=")
                  .Append(Uri.EscapeDataString(kv.Value));
                first = false;
            }
            return sb.ToString();
        }

        // ====================== CATEGORY TREE ======================

        private async Task BindCategoryTreeAsync()
        {
            var all = await _cats.GetAllAsync() ?? new List<CategoryTreeDto>();

            // Nhóm con theo Parent_Id (key non-null)
            var byParent = all
                .Where(x => x.Parent_Id.HasValue)
                .GroupBy(x => x.Parent_Id.Value)
                .ToDictionary(
                    g => g.Key,
                    g => g.OrderBy(x => x.Sort_Order ?? int.MaxValue)
                          .ThenBy(x => x.Name)
                          .ToList()
                );

            // ROOTS: Parent_Id is null hoặc Parent_Id không nằm trong danh sách Id
            var idSet = new HashSet<long>(all.Select(x => x.Id));
            var roots = all
                .Where(x => !x.Parent_Id.HasValue || !idSet.Contains(x.Parent_Id.Value))
                .OrderBy(x => x.Sort_Order ?? int.MaxValue)
                .ThenBy(x => x.Name)
                .ToList();

            // Nhánh cần mở (ancestor của category đang chọn)
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

        // Render 1 node (đệ quy)
        private void RenderNode(
            CategoryTreeDto n,
            StringBuilder sb,
            Dictionary<long, List<CategoryTreeDto>> byParent,
            HashSet<long> expandSet,
            long? selectedId)
        {
            byParent.TryGetValue(n.Id, out var children);
            bool hasChild = children != null && children.Count > 0;
            bool expanded = (selectedId.HasValue && n.Id == selectedId.Value) || (expandSet?.Contains(n.Id) ?? false);

            sb.Append("<div class='cat-node'>");

            if (hasChild)
            {
                sb.Append("<div class='d-flex justify-content-between align-items-center'>");
                sb.AppendFormat("<a class='text-decoration-none' href='{0}'>{1}</a>",
                    BuildCategoryLink(n.Id), Server.HtmlEncode(n.Name));
                sb.AppendFormat("<span class='cat-toggle small text-muted' data-toggle-cat='{0}'>{1}</span>",
                    n.Id, expanded ? "–" : "+");
                sb.Append("</div>");

                sb.AppendFormat("<div id='cat-children-{0}' class='cat-children {1}'>",
                    n.Id, expanded ? "" : "d-none");

                foreach (var c in children)
                    RenderNode(c, sb, byParent, expandSet, selectedId);

                sb.Append("</div>");
            }
            else
            {
                sb.AppendFormat("<a class='text-decoration-none' href='{0}'>{1}</a>",
                    BuildCategoryLink(n.Id), Server.HtmlEncode(n.Name));
            }

            sb.Append("</div>");
        }

        // ====================== PRODUCTS ======================

        protected async Task BindAsync()
        {
            var req = ReadRequest();

            var list = await _search.SearchListAsync(req);   // danh sách để lấy total/paging
            var cards = await _search.BuildCardsAsync(req);   // có ảnh + variants

            // Lọc trọng lượng client-side theo label biến thể (nếu có tick)
            var ranges = ParseWeightFiltersFromRequest();
            if (ranges.Any())
                cards = FilterCardsByWeight(cards, ranges);

            ltTotal.Text = $"{list.TotalCount:n0} sản phẩm";
            rpProducts.DataSource = cards;
            rpProducts.DataBind();

            ltPager.Text = BuildPager(req.Page, req.PageSize, list.TotalCount);
        }

        private IReadOnlyList<(int From, int To)> ParseWeightFiltersFromRequest()
        {
            var res = new List<(int, int)>();
            if (Request["w_100_250"] == "on") res.Add((100, 250));
            if (Request["w_250_500"] == "on") res.Add((250, 500));
            if (Request["w_500_1000"] == "on") res.Add((500, 1000));
            if (Request["w_1000_5000"] == "on") res.Add((1000, 5000));
            if (Request["w_5000"] == "on") res.Add((5000, int.MaxValue));
            return res;
        }

        private static readonly Regex WeightRegex =
            new Regex(@"(\d+(?:[\.,]\d+)?)\s*(kg|g|gram)", RegexOptions.IgnoreCase | RegexOptions.Compiled);

        private static int? ExtractWeightGram(string text)
        {
            if (string.IsNullOrWhiteSpace(text)) return null;
            var m = WeightRegex.Match(text);
            if (!m.Success) return null;

            var num = m.Groups[1].Value.Replace(',', '.');
            if (!double.TryParse(num, System.Globalization.NumberStyles.Any,
                                 System.Globalization.CultureInfo.InvariantCulture, out var v))
                return null;

            var unit = m.Groups[2].Value.ToLowerInvariant();
            return unit == "kg" ? (int)Math.Round(v * 1000) : (int)Math.Round(v); // g
        }

        private IList<ProductCardVM> FilterCardsByWeight(IList<ProductCardVM> cards, IReadOnlyList<(int From, int To)> ranges)
        {
            var keep = new List<ProductCardVM>();
            foreach (var c in cards)
            {
                bool match = false;
                foreach (var opt in c.Variants ?? Enumerable.Empty<VariantOptionVM>())
                {
                    var w = ExtractWeightGram(opt.Label);
                    if (w == null) continue;
                    foreach (var r in ranges)
                    {
                        if (w.Value >= r.From && w.Value < r.To) { match = true; break; }
                    }
                    if (match) break;
                }
                if (match) keep.Add(c);
            }
            return keep.Count > 0 ? keep : cards;
        }

        private string BuildPager(int page, int pageSize, int total)
        {
            if (total <= pageSize) return "";
            var totalPages = (int)Math.Ceiling((double)total / pageSize);

            string SetPage(int p)
            {
                var qs = Request.QueryString.AllKeys
                    .Where(k => !string.IsNullOrEmpty(k)
                                && !k.Equals("page", StringComparison.OrdinalIgnoreCase))
                    .ToDictionary(k => k, k => Request.QueryString[k] ?? "");

                qs["page"] = p.ToString();

                var sb = new StringBuilder(CurrentSearchPath());
                sb.Append("?");

                bool first = true;
                foreach (var kv in qs)
                {
                    if (!first) sb.Append("&");
                    sb.Append(Uri.EscapeDataString(kv.Key))
                      .Append("=")
                      .Append(Uri.EscapeDataString(kv.Value));
                    first = false;
                }
                return sb.ToString();
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
