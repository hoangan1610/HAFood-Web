using System;
using System.Collections.Generic;
using System.Configuration;
using System.Globalization;
using System.Linq;
using System.Threading.Tasks;
using HAFoodWeb.Infrastructure;
using HAFoodWeb.Models;

namespace HAFoodWeb.Services
{
    public class SearchService : ISearchService
    {
        private readonly string _apiBase;

        public string LastListUrl { get; private set; } = "";
        public IList<string> LastDetailUrls { get; } = new List<string>();

        public SearchService()
        {
            _apiBase = (ConfigurationManager.AppSettings["ApiBaseUrl"] ?? "").TrimEnd('/');
        }

        public async Task<IList<string>> SuggestAsync(string q)
        {
            if (string.IsNullOrWhiteSpace(q)) return new List<string>();
            var url = $"{_apiBase}/api/search/suggest?q={Uri.EscapeDataString(q)}";
            var fallback = new SuggestResult { Items = new List<string>() };
            var data = await HttpJson.TryGetJsonAsync(url, fallback);
            return data.Items ?? new List<string>();
        }

        public async Task<PagedResult<ProductListItemDto>> SearchListAsync(ProductSearchRequest req)
        {
            var sort = string.IsNullOrWhiteSpace(req.Sort) ? "updated_at:desc" : req.Sort;

            var url = $"{_apiBase}/api/products?page={req.Page}&page_size={req.PageSize}"
                      + $"&only_in_stock={(req.OnlyInStock ? "true" : "false")}"
                      + $"&sort={Uri.EscapeDataString(sort)}";

            if (!string.IsNullOrWhiteSpace(req.Query))
                url += $"&q={Uri.EscapeDataString(req.Query)}";
            if (req.CategoryId.HasValue && req.CategoryId.Value > 0)
                url += $"&category_id={req.CategoryId.Value}";
            if (!string.IsNullOrWhiteSpace(req.Brand))
                url += $"&brand={Uri.EscapeDataString(req.Brand)}";
            if (req.MinPrice.HasValue)
                url += $"&min_price={req.MinPrice.Value.ToString(CultureInfo.InvariantCulture)}";
            if (req.MaxPrice.HasValue)
                url += $"&max_price={req.MaxPrice.Value.ToString(CultureInfo.InvariantCulture)}";
            if (req.Status.HasValue)
                url += $"&status={req.Status.Value}";

            // Gửi weight ranges dạng &w=from-to (nhiều lần)
            if (req.WeightRanges != null && req.WeightRanges.Count > 0)
            {
                foreach (var wr in req.WeightRanges)
                {
                    var v = wr.To.HasValue ? $"{wr.From}-{wr.To.Value}" : $"{wr.From}-";
                    url += $"&w={Uri.EscapeDataString(v)}";
                }
            }

            LastListUrl = url; // DEBUG

            var fallback = new PagedResult<ProductListItemDto>
            {
                Items = new List<ProductListItemDto>(),
                Page = req.Page,
                PageSize = req.PageSize,
                TotalCount = 0
            };

            return await HttpJson.TryGetJsonAsync(url, fallback);
        }

        public async Task<IList<ProductCardVM>> BuildCardsAsync(ProductSearchRequest req)
        {
            // Giữ để tương thích, nhưng code mới (Search.aspx) sẽ dùng overload có list
            var list = await SearchListAsync(req);
            return await BuildCardsAsync(req, list);
        }

        public async Task<IList<ProductCardVM>> BuildCardsAsync(
            ProductSearchRequest req,
            PagedResult<ProductListItemDto> list)
        {
            if (list == null || list.Items == null || list.Items.Count == 0)
                return new List<ProductCardVM>();

            LastDetailUrls.Clear();

            // Lấy chi tiết để có ảnh + variants
            var tasks = list.Items.Select(x =>
            {
                var du = $"{_apiBase}/api/products/{x.Product_Id}";
                LastDetailUrls.Add(du);
                return GetProductDetailAsync(x.Product_Id);
            }).ToArray();

            var details = await Task.WhenAll(tasks);

            var cards = new List<ProductCardVM>(details.Length);
            for (int i = 0; i < details.Length; i++)
            {
                var d = details[i];
                var li = list.Items[i];

                // Ảnh: ưu tiên variant, rồi tới ảnh product, rồi fallback
                string img = (d != null && d.Variants != null)
                    ? d.Variants.FirstOrDefault(v => !string.IsNullOrWhiteSpace(v.Image))?.Image
                    : null;

                if (string.IsNullOrWhiteSpace(img))
                {
                    if (!string.IsNullOrWhiteSpace(d?.Image_Product) &&
                        d.Image_Product.StartsWith("http", StringComparison.OrdinalIgnoreCase))
                    {
                        img = d.Image_Product;
                    }
                    else
                    {
                        img = "/images/product-default.png";
                    }
                }

                // Dropdown biến thể
                var opts = new List<VariantOptionVM>();
                if (d?.Variants != null && d.Variants.Count > 0)
                {
                    foreach (var v in d.Variants)
                    {
                        var name = string.IsNullOrWhiteSpace(v.Name) ? v.Sku : v.Name;
                        var label = $"{name} ({FormatVnd(v.Retail_Price)})";
                        opts.Add(new VariantOptionVM { Id = v.Id, Label = label });
                    }
                }

                // Giá min-max (dùng Min/Max từ list để nhất quán)
                string priceHtml;
                if (li.Min_Retail_Price == li.Max_Retail_Price)
                {
                    priceHtml = $"<span class='price-now'>{FormatVnd(li.Min_Retail_Price)}</span>";
                }
                else
                {
                    priceHtml = $"<span class='price-now'>{FormatVnd(li.Min_Retail_Price)} - {FormatVnd(li.Max_Retail_Price)}</span>";
                }

                cards.Add(new ProductCardVM
                {
                    Id = d != null ? d.Id : li.Product_Id,
                    Name = d != null ? d.Name : li.Product_Name,
                    ImageUrl = img,
                    MinRetail = li.Min_Retail_Price,
                    MaxRetail = li.Max_Retail_Price,
                    PriceRangeHtml = priceHtml,
                    DiscountBadgeHtml = "",
                    Variants = opts
                });
            }

            return cards;
        }


        // ------------ Helpers ------------
        private async Task<ProductDetailDto> GetProductDetailAsync(long id)
        {
            var cacheKey = $"product:detail:{id}";
            return await AppCache.GetOrAddAsync(cacheKey, async () =>
            {
                var url = $"{_apiBase}/api/products/{id}";
                var fallback = new ProductDetailDto { Id = id, Name = "", Variants = new List<VariantDto>() };
                return await HttpJson.TryGetJsonAsync(url, fallback);
            }, seconds: 300);
        }

        private static string FormatVnd(decimal v)
        {
            var vi = CultureInfo.GetCultureInfo("vi-VN");
            return string.Format(vi, "{0:#,0}đ", v);
        }

        private class SuggestResult { public IList<string> Items { get; set; } = new List<string>(); }
    }
}
