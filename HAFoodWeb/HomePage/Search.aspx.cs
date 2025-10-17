// Search.aspx.cs
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Threading.Tasks;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using HAFoodWeb.Models;
using HAFoodWeb.Services;

namespace HAFoodWeb.SearchPage
{
    public partial class SearchPage : Page
    {
        private readonly ISearchService _svc = new SearchService();

        protected async void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                await BindAsync();
            }
        }

        protected void btnApply_Click(object sender, EventArgs e)
        {
            var qs = HttpUtility.ParseQueryString(string.Empty);
            if (!string.IsNullOrWhiteSpace(tbQ.Text)) qs["q"] = tbQ.Text.Trim();
            if (!string.IsNullOrWhiteSpace(hfCate.Value)) qs["category_id"] = hfCate.Value;
            if (!string.IsNullOrWhiteSpace(tbBrand.Text)) qs["brand"] = tbBrand.Text.Trim();
            if (!string.IsNullOrWhiteSpace(tbMin.Text)) qs["min_price"] = tbMin.Text.Trim();
            if (!string.IsNullOrWhiteSpace(tbMax.Text)) qs["max_price"] = tbMax.Text.Trim();
            qs["page"] = "1";
            Response.Redirect("/Search.aspx?" + qs.ToString());
        }

        private async Task BindAsync()
        {
            string q = Request.QueryString["q"];
            long? cateId = ToLong(Request.QueryString["category_id"]);
            string brand = Request.QueryString["brand"];
            decimal? min = ToDecimal(Request.QueryString["min_price"]);
            decimal? max = ToDecimal(Request.QueryString["max_price"]);
            int page = (int)(ToLong(Request.QueryString["page"]) ?? 1);

            // điền lại UI
            tbQ.Text = q;
            tbBrand.Text = brand;
            tbMin.Text = min?.ToString(CultureInfo.InvariantCulture);
            tbMax.Text = max?.ToString(CultureInfo.InvariantCulture);
            hfCate.Value = cateId?.ToString();

            ltTitle.Text = string.IsNullOrWhiteSpace(q) && !cateId.HasValue
                ? "Kết quả tìm kiếm"
                : (!string.IsNullOrWhiteSpace(q) ? $"Tìm: ‘{HttpUtility.HtmlEncode(q)}’" : $"Danh mục #{cateId}");

            var result = await _svc.SearchProductsAsync(q, cateId, brand, min, max, page, 20);

            if (result == null || result.Items == null || result.Items.Count == 0)
            {
                phEmpty.Visible = true;
                rp.Visible = false;
                phPaging.Controls.Clear();
                ltSummary.Text = "0 sản phẩm";
                return;
            }

            // Map -> ProductCardVM để tái dùng card UI
            var cards = new List<ProductCardVM>();
            foreach (var p in result.Items)
            {
                cards.Add(ToCard(p));
            }

            rp.Visible = true;
            phEmpty.Visible = false;
            rp.DataSource = cards;
            rp.DataBind();

            int totalPages = Math.Max(1, (int)Math.Ceiling(result.TotalCount / (double)result.PageSize));
            ltSummary.Text = $"{result.TotalCount} sản phẩm • trang {result.Page}/{totalPages}";
            RenderPagination(result.Page, totalPages);
        }

        private void RenderPagination(int page, int totalPages)
        {
            phPaging.Controls.Clear();

            string BuildLink(int p)
            {
                var qs = HttpUtility.ParseQueryString(Request.QueryString.ToString());
                qs.Set("page", p.ToString());
                return "?" + qs.ToString();
            }

            void Add(string text, string href, bool active = false, bool disabled = false)
            {
                phPaging.Controls.Add(new Literal
                {
                    Text = $"<li class='page-item {(active ? "active" : "")} {(disabled ? "disabled" : "")}'>" +
                           $"<a class='page-link' href='{(disabled ? "#" : href)}'>{text}</a></li>"
                });
            }

            Add("‹", BuildLink(Math.Max(1, page - 1)), false, page == 1);
            for (int i = Math.Max(1, page - 2); i <= Math.Min(totalPages, page + 2); i++)
                Add(i.ToString(), BuildLink(i), i == page);
            Add("›", BuildLink(Math.Min(totalPages, page + 1)), false, page == totalPages);
        }

        // ===== Helpers =====
        private static long? ToLong(string s) => long.TryParse(s, out var v) ? v : (long?)null;
        private static decimal? ToDecimal(string s)
            => decimal.TryParse(s, NumberStyles.Any, CultureInfo.InvariantCulture, out var v) ? v : (decimal?)null;

        private static string FormatVnd(decimal v)
            => string.Format(new CultureInfo("vi-VN"), "{0:N0}₫", v);

        private static string BuildPriceRangeHtml(decimal min, decimal max)
        {
            if (min <= 0 && max <= 0) return "<span class='text-muted'>Liên hệ</span>";
            if (min == max) return $"<span class='fw-bold text-danger'>{FormatVnd(min)}</span>";
            return $"<span class='fw-bold text-danger'>{FormatVnd(min)}</span> " +
                   $"<span class='text-muted ms-1'>(đến {FormatVnd(max)})</span>";
        }

        private static ProductCardVM ToCard(ProductListItemDto p)
        {
            return new ProductCardVM
            {
                Id = p.Product_Id,
                Name = p.Product_Name,
                // API list chưa trả ảnh → dùng placeholder (nếu có ảnh thì thay ở đây)
                ImageUrl = "/images/product-default.png",
                MinRetail = p.Min_Retail_Price,
                MaxRetail = p.Max_Retail_Price,
                PriceRangeHtml = BuildPriceRangeHtml(p.Min_Retail_Price, p.Max_Retail_Price),
                DiscountBadgeHtml = string.Empty, // nếu có logic khuyến mãi thì render thêm
                Variants = new List<VariantOptionVM>() // trang list không cần fill variants
            };
        }
    }
}
