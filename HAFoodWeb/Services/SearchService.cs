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

        public SearchService()
        {
            _apiBase = (ConfigurationManager.AppSettings["ApiBaseUrl"] ?? "").TrimEnd('/');
        }

        // -------------------- Public APIs --------------------
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
            var url = $"{_apiBase}/api/products?page={req.Page}&page_size={req.PageSize}"
                      + $"&only_in_stock={(req.OnlyInStock ? "true" : "false")}"
                      + $"&sort={Uri.EscapeDataString(req.Sort ?? "updated_at:desc")}";
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
            var list = await SearchListAsync(req);
            if (list?.Items == null || list.Items.Count == 0)
                return new List<ProductCardVM>();

            // Lấy chi tiết để có ảnh + variants
            var detailTasks = list.Items.Select(x => GetProductDetailAsync(x.Product_Id)).ToArray();
            var details = await Task.WhenAll(detailTasks);

            var cards = new List<ProductCardVM>(details.Length);
            for (int i = 0; i < details.Length; i++)
            {
                var d = details[i];
                var li = list.Items[i];

                // Ảnh ưu tiên variant -> ảnh product -> fallback
                string img = d?.Variants?.FirstOrDefault(v => !string.IsNullOrWhiteSpace(v.Image))?.Image;
                if (string.IsNullOrWhiteSpace(img))
                    img = (!string.IsNullOrWhiteSpace(d?.Image_Product) &&
                           d.Image_Product.StartsWith("http", StringComparison.OrdinalIgnoreCase))
                          ? d.Image_Product
                          : "/images/product-default.png";

                // Dropdown biến thể
                var opts = new List<VariantOptionVM>(d?.Variants?.Count ?? 0);
                if (d?.Variants != null)
                {
                    foreach (var v in d.Variants)
                    {
                        var name = string.IsNullOrWhiteSpace(v.Name) ? v.Sku : v.Name;
                        opts.Add(new VariantOptionVM { Id = v.Id, Label = $"{name} ({FormatVnd(v.Retail_Price)})" });
                    }
                }

                // Giá min-max
                string priceHtml = (li.Min_Retail_Price == li.Max_Retail_Price)
                    ? $"<span class='price-now'>{FormatVnd(li.Min_Retail_Price)}</span>"
                    : $"<span class='price-now'>{FormatVnd(li.Min_Retail_Price)} - {FormatVnd(li.Max_Retail_Price)}</span>";

                cards.Add(new ProductCardVM
                {
                    Id = d.Id,
                    Name = d.Name,
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

        // -------------------- Helpers --------------------
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
