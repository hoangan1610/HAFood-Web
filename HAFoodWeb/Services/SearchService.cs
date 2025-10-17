// Services/SearchService.cs
using HAFoodWeb.Infrastructure;
using HAFoodWeb.Models;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Threading.Tasks;
using System.Web;

namespace HAFoodWeb.Services
{
    public class SearchService : ISearchService
    {
        private const string ApiBase = "https://api.hafood.id.vn";

        public async Task<PagedResult<ProductListItemDto>> SearchProductsAsync(
            string q, long? categoryId, string brand,
            decimal? minPrice, decimal? maxPrice,
            int page, int pageSize, string sort = "updated_at:desc",
            bool onlyInStock = false)
        {
            var qs = HttpUtility.ParseQueryString(string.Empty);

            if (!string.IsNullOrWhiteSpace(q)) qs["q"] = q;
            if (categoryId.HasValue) qs["category_id"] = categoryId.Value.ToString();
            if (!string.IsNullOrWhiteSpace(brand)) qs["brand"] = brand;
            if (minPrice.HasValue) qs["min_price"] = minPrice.Value.ToString(CultureInfo.InvariantCulture);
            if (maxPrice.HasValue) qs["max_price"] = maxPrice.Value.ToString(CultureInfo.InvariantCulture);

            qs["only_in_stock"] = onlyInStock ? "true" : "false";
            qs["page"] = Math.Max(1, page).ToString();
            qs["page_size"] = Math.Max(1, pageSize).ToString();
            qs["sort"] = string.IsNullOrWhiteSpace(sort) ? "updated_at:desc" : sort;

            var url = $"{ApiBase}/api/products?{qs}";

            // DÙNG BẢN SAFE (khuyên dùng cho trang search)
            var fallback = new PagedResult<ProductListItemDto>
            {
                Items = new List<ProductListItemDto>(),
                TotalCount = 0,
                Page = page,
                PageSize = pageSize
            };
            return await HttpJson.TryGetJsonAsync(url, fallback);
        }
    }
}
