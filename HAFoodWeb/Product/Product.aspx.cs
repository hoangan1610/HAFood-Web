using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Threading.Tasks;
using System.Web.Script.Serialization;
using HAFoodWeb.Models;
using HAFoodWeb.Services;

namespace HAFoodWeb
{
    public partial class Product : System.Web.UI.Page
    {
        private readonly IProductDetailService _detailService = new ProductDetailService();
        private readonly IProductCardService _cardService = new ProductCardService();

        protected async void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;

            if (!long.TryParse(Request.QueryString["id"], out var id) || id <= 0)
            {
                Response.StatusCode = 404;
                Response.End();
                return;
            }

            var dto = await _detailService.GetProductDetailAsync(id);
            if (dto == null || string.IsNullOrWhiteSpace(dto.Name))
            {
                Response.StatusCode = 404;
                Response.End();
                return;
            }

            BindProduct(dto);
            await BindRelatedAsync();
        }

        private void BindProduct(ProductDetailDto d)
        {
            pageTitle.Text = d.Name + " - HAFood";
            litNameCrumb.Text = Server.HtmlEncode(d.Name);
            litName.Text = Server.HtmlEncode(d.Name);
            litBrand.Text = Server.HtmlEncode(d.Brand_Name ?? "");

            // Gallery: ảnh variant trước, rồi tới ảnh product, cuối cùng default
            var gallery = new List<string>();
            if (d.Variants != null)
            {
                foreach (var v in d.Variants)
                    if (!string.IsNullOrWhiteSpace(v.Image) && v.Image.StartsWith("http", StringComparison.OrdinalIgnoreCase))
                        gallery.Add(v.Image);
            }
            if (!string.IsNullOrWhiteSpace(d.Image_Product) && d.Image_Product.StartsWith("http", StringComparison.OrdinalIgnoreCase))
                gallery.Add(d.Image_Product);

            if (gallery.Count == 0) gallery.Add("/images/product-default.png");

            imgMain.Src = gallery[0];
            rpThumbs.DataSource = gallery.Select(x => new { Url = x }).ToList();
            rpThumbs.DataBind();

            // Min/Max & dropdown
            decimal min = decimal.MaxValue, max = 0;
            var opts = new List<Tuple<long, string, VariantDto>>();
            foreach (var v in d.Variants ?? new List<VariantDto>())
            {
                if (v.Retail_Price < min) min = v.Retail_Price;
                if (v.Retail_Price > max) max = v.Retail_Price;
                var name = string.IsNullOrWhiteSpace(v.Name) ? v.Sku : v.Name;
                opts.Add(Tuple.Create(v.Id, $"{name} ({FormatVnd(v.Retail_Price)})", v));
            }
            if (min == decimal.MaxValue) min = 0;

            ddlVariant.DataSource = opts.Select(o => new { Id = o.Item1, Text = o.Item2 });
            ddlVariant.DataTextField = "Text";
            ddlVariant.DataValueField = "Id";
            ddlVariant.DataBind();

            // Hiển thị giá tổng quát (range) lúc đầu
            litPrice.Text = (min == max || max == 0)
                ? FormatVnd(min)
                : $"{FormatVnd(min)} - {FormatVnd(max)}";

            // Thông tin của biến thể đầu tiên (nếu có) để hiện SKU/stock
            var first = opts.FirstOrDefault()?.Item3;
            litSku.Text = first?.Sku ?? "";
            litStock.Text = (first?.Stock ?? 0).ToString();

            // Mô tả
            litDetail.Text = string.IsNullOrWhiteSpace(d.Detail)
                ? "Đang cập nhật mô tả sản phẩm."
                : d.Detail; // d.Detail giả định đã là HTML an toàn

            // JSON cho JS
            var json = new JavaScriptSerializer().Serialize(
                (d.Variants ?? new List<VariantDto>()).Select(v => new
                {
                    id = v.Id,
                    sku = v.Sku,
                    name = string.IsNullOrWhiteSpace(v.Name) ? v.Sku : v.Name,
                    retailPrice = v.Retail_Price,
                    stock = v.Stock,
                    image = v.Image
                }).ToList());
            hVariantsJson.Value = json;
        }

        private async Task BindRelatedAsync()
        {
            // Tạm dùng gợi ý “mới cập nhật” (8 SP). Sau này có endpoint liên quan theo category thì thay.
            var cards = await _cardService.GetRecommendedCardsAsync(8);
            rpRelated.DataSource = cards;
            rpRelated.DataBind();
        }

        private static string FormatVnd(decimal v)
        {
            var vi = CultureInfo.GetCultureInfo("vi-VN");
            return string.Format(vi, "{0:#,0}đ", v);
        }
    }
}
