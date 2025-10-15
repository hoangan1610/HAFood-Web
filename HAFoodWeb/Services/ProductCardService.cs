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
    public class ProductCardService : IProductCardService
    {
        private readonly string _apiBase;

        public ProductCardService()
        {
            _apiBase = (ConfigurationManager.AppSettings["ApiBaseUrl"] ?? "").TrimEnd('/');
        }

        // Dùng cho "Gợi ý" và "Mới về" mặc định (trang 1)
        public async Task<IList<ProductCardVM>> GetRecommendedCardsAsync(int take)
        {
            return await BuildCardsAsync(page: 1, pageSize: take, sort: "updated_at:desc");
        }

        // Dùng cho "Load more" — lấy trang bất kỳ
        public Task<IList<ProductCardVM>> GetRecommendedPageAsync(int page, int pageSize)
        {
            return BuildCardsAsync(page, pageSize, sort: "updated_at:desc");
        }

        // ================== Core builders ==================

        private async Task<IList<ProductCardVM>> BuildCardsAsync(int page, int pageSize, string sort)
        {
            var list = await GetProductListAsync(page, pageSize, sort);

            // Nếu list rỗng (API lỗi), thử fallback ID cấu hình (tùy chọn)
            if (list == null || list.Items == null || list.Items.Count == 0)
            {
                var fallback = await BuildFromConfiguredIdsAsync(pageSize);
                if (fallback.Count > 0) return fallback;
                return new List<ProductCardVM>(); // cuối cùng: trả rỗng, UI không vỡ
            }

            // gọi detail để lấy ảnh & variants (đã cache chi tiết)
            var tasks = new List<Task<ProductDetailDto>>();
            foreach (var item in list.Items)
                tasks.Add(GetProductDetailAsync(item.Product_Id));
            var details = await Task.WhenAll(tasks.ToArray());

            var cards = new List<ProductCardVM>(details.Length);

            for (int i = 0; i < details.Length; i++)
            {
                var d = details[i];
                var li = list.Items[i];

                // Ảnh: ưu tiên variant -> ảnh product -> fallback
                string img = null;
                foreach (var v in d.Variants)
                {
                    if (!string.IsNullOrWhiteSpace(v.Image)) { img = v.Image; break; }
                }
                if (string.IsNullOrWhiteSpace(img))
                {
                    img = (!string.IsNullOrWhiteSpace(d.Image_Product) &&
                           d.Image_Product.StartsWith("http", StringComparison.OrdinalIgnoreCase))
                          ? d.Image_Product
                          : "/images/product-default.png";
                }

                // Options dropdown
                var opts = new List<VariantOptionVM>(d.Variants.Count);
                foreach (var v in d.Variants)
                {
                    string name = string.IsNullOrWhiteSpace(v.Name) ? v.Sku : v.Name;
                    opts.Add(new VariantOptionVM { Id = v.Id, Label = name + " (" + FormatVnd(v.Retail_Price) + ")" });
                }

                // Giá min-max (đã có ở list)
                string priceHtml = (li.Min_Retail_Price == li.Max_Retail_Price)
                    ? "<span class='price-now'>" + FormatVnd(li.Min_Retail_Price) + "</span>"
                    : "<span class='price-now'>" + FormatVnd(li.Min_Retail_Price) + " - " + FormatVnd(li.Max_Retail_Price) + "</span>";

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

        // Fallback: đọc danh sách ID sản phẩm từ appSettings (tuỳ chọn)
        private async Task<IList<ProductCardVM>> BuildFromConfiguredIdsAsync(int take)
        {
            var idsRaw = ConfigurationManager.AppSettings["NewArrivalsIds"] ?? ""; // ví dụ: "1,2,3,4"
            var tokens = idsRaw.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
            if (tokens.Length == 0) return new List<ProductCardVM>();

            var result = new List<ProductCardVM>();
            foreach (var s in tokens)
            {
                if (!long.TryParse(s.Trim(), out var id)) continue;
                var d = await GetProductDetailAsync(id);
                if (d == null || string.IsNullOrWhiteSpace(d.Name)) continue;

                // Ảnh
                string img = null;
                foreach (var v in d.Variants) { if (!string.IsNullOrWhiteSpace(v.Image)) { img = v.Image; break; } }
                if (string.IsNullOrWhiteSpace(img))
                    img = (!string.IsNullOrWhiteSpace(d.Image_Product) && d.Image_Product.StartsWith("http", StringComparison.OrdinalIgnoreCase))
                        ? d.Image_Product : "/images/product-default.png";

                // Options + min/max tự tính từ variants
                var opts = new List<VariantOptionVM>(d.Variants.Count);
                decimal min = decimal.MaxValue, max = 0;
                foreach (var v in d.Variants)
                {
                    if (v.Retail_Price < min) min = v.Retail_Price;
                    if (v.Retail_Price > max) max = v.Retail_Price;

                    var name = string.IsNullOrWhiteSpace(v.Name) ? v.Sku : v.Name;
                    opts.Add(new VariantOptionVM { Id = v.Id, Label = name + " (" + FormatVnd(v.Retail_Price) + ")" });
                }
                if (min == decimal.MaxValue) min = 0;

                var priceHtml = (min == max || max == 0)
                    ? "<span class='price-now'>" + FormatVnd(min) + "</span>"
                    : "<span class='price-now'>" + FormatVnd(min) + " - " + FormatVnd(max) + "</span>";

                result.Add(new ProductCardVM
                {
                    Id = d.Id,
                    Name = d.Name,
                    ImageUrl = img,
                    MinRetail = min,
                    MaxRetail = max,
                    PriceRangeHtml = priceHtml,
                    DiscountBadgeHtml = "",
                    Variants = opts
                });

                if (result.Count >= take) break;
            }
            return result;
        }

        // ================== HTTP helpers (có cache qua AppCache) ==================

        private async Task<PagedResult<ProductListItemDto>> GetProductListAsync(int page, int pageSize, string sort)
        {
            var cacheKey = $"products:list:p={page}:ps={pageSize}:sort={sort}";
            return await AppCache.GetOrAddAsync(cacheKey, async () =>
            {
                var url = string.Format(
                    "{0}/api/products?page={1}&page_size={2}&status=1&sort={3}",
                    _apiBase, page, pageSize, Uri.EscapeDataString(sort));

                var fallback = new PagedResult<ProductListItemDto>
                {
                    Items = new List<ProductListItemDto>(),
                    Page = page,
                    PageSize = pageSize,
                    TotalCount = 0
                };
                return await HttpJson.TryGetJsonAsync(url, fallback);
            }, seconds: 60);
        }

        private async Task<ProductDetailDto> GetProductDetailAsync(long id)
        {
            var cacheKey = $"product:detail:{id}";
            return await AppCache.GetOrAddAsync(cacheKey, async () =>
            {
                var url = string.Format("{0}/api/products/{1}", _apiBase, id);
                var fallback = new ProductDetailDto
                {
                    Id = id,
                    Name = "",
                    Variants = new List<VariantDto>()
                };
                return await HttpJson.TryGetJsonAsync(url, fallback);
            }, seconds: 300); // 5 phút
        }

        private static string FormatVnd(decimal v)
        {
            var vi = CultureInfo.GetCultureInfo("vi-VN");
            return string.Format(vi, "{0:#,0}đ", v);
        }
    }
}
