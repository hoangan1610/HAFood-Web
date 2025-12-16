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

        public async Task<IList<ProductCardVM>> GetRecommendedCardsAsync(int take)
        {
            return await BuildCardsAsync(page: 1, pageSize: take, sort: "updated_at:desc");
        }

        public Task<IList<ProductCardVM>> GetRecommendedPageAsync(int page, int pageSize)
        {
            return BuildCardsAsync(page, pageSize, sort: "updated_at:desc");
        }

        // ================== Core builders ==================

        private async Task<IList<ProductCardVM>> BuildCardsAsync(int page, int pageSize, string sort)
        {
            var list = await GetProductListAsync(page, pageSize, sort);

            if (list == null || list.Items == null || list.Items.Count == 0)
            {
                var fallback = await BuildFromConfiguredIdsAsync(pageSize);
                if (fallback.Count > 0) return fallback;
                return new List<ProductCardVM>();
            }

            var tasks = new List<Task<ProductDetailDto>>();
            foreach (var item in list.Items)
                tasks.Add(GetProductDetailAsync(item.Product_Id));

            var details = await Task.WhenAll(tasks.ToArray());
            var cards = new List<ProductCardVM>(details.Length);

            for (int i = 0; i < details.Length; i++)
            {
                var d = details[i];
                var li = list.Items[i];

                var allVars = d?.Variants ?? new List<VariantDto>();
                var activeVars = allVars.Where(x => x.Status == 1).ToList();
                var useVars = activeVars.Count > 0 ? activeVars : allVars;

                // default variant + stock
                long defaultVar = useVars.FirstOrDefault()?.Id ?? 0;
                int totalStock = (activeVars.Count > 0 ? activeVars : useVars).Sum(v => v?.Stock ?? 0);

                // card image: ưu tiên image của variant đầu tiên có ảnh, fallback product image
                string img = useVars.FirstOrDefault(v => !string.IsNullOrWhiteSpace(v.Image))?.Image;
                if (string.IsNullOrWhiteSpace(img))
                {
                    img = (!string.IsNullOrWhiteSpace(d?.Image_Product) &&
                           d.Image_Product.StartsWith("http", StringComparison.OrdinalIgnoreCase))
                          ? d.Image_Product
                          : "/images/product-default.png";
                }

                // options dropdown: dùng useVars (đừng lọc Status==1 lần nữa!)
                var opts = new List<VariantOptionVM>(useVars.Count);
                foreach (var v in useVars)
                {
                    var nm = string.IsNullOrWhiteSpace(v.Name) ? v.Sku : v.Name;
                    var vImg = string.IsNullOrWhiteSpace(v.Image) ? "" : v.Image;

                    opts.Add(new VariantOptionVM
                    {
                        Id = v.Id,
                        Name = nm,
                        Price = v.Retail_Price,
                        Image = vImg,
                        Label = nm + " (" + FormatVnd(v.Retail_Price) + ")"
                    });
                }

                // Giá min-max (ưu tiên từ list nếu có, fallback tự tính)
                decimal min = li.Min_Retail_Price;
                decimal max = li.Max_Retail_Price;
                if (min == 0 && max == 0 && useVars.Count > 0)
                {
                    min = useVars.Min(v => v.Retail_Price);
                    max = useVars.Max(v => v.Retail_Price);
                }

                string priceHtml = (min == max)
                    ? "<span class='price-now'>" + FormatVnd(min) + "</span>"
                    : "<span class='price-now'>" + FormatVnd(min) + " - " + FormatVnd(max) + "</span>";

                cards.Add(new ProductCardVM
                {
                    Id = d.Id,
                    Name = d.Name,
                    ImageUrl = img,
                    MinRetail = min,
                    MaxRetail = max,
                    PriceRangeHtml = priceHtml,
                    DiscountBadgeHtml = "",
                    TotalStock = totalStock,
                    DefaultVariantId = defaultVar,
                    Variants = opts
                });
            }

            return cards;
        }

        private async Task<IList<ProductCardVM>> BuildFromConfiguredIdsAsync(int take)
        {
            var idsRaw = ConfigurationManager.AppSettings["NewArrivalsIds"] ?? "";
            var tokens = idsRaw.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
            if (tokens.Length == 0) return new List<ProductCardVM>();

            var result = new List<ProductCardVM>();

            foreach (var s in tokens)
            {
                if (!long.TryParse(s.Trim(), out var id)) continue;

                var d = await GetProductDetailAsync(id);
                if (d == null || string.IsNullOrWhiteSpace(d.Name)) continue;

                var allVars = d.Variants ?? new List<VariantDto>();
                var activeVars = allVars.Where(x => x.Status == 1).ToList();
                var useVars = activeVars.Count > 0 ? activeVars : allVars;

                long defaultVar = useVars.FirstOrDefault()?.Id ?? 0;
                int totalStock = (activeVars.Count > 0 ? activeVars : useVars).Sum(v => v?.Stock ?? 0);

                string img = useVars.FirstOrDefault(v => !string.IsNullOrWhiteSpace(v.Image))?.Image;
                if (string.IsNullOrWhiteSpace(img))
                    img = (!string.IsNullOrWhiteSpace(d.Image_Product) && d.Image_Product.StartsWith("http", StringComparison.OrdinalIgnoreCase))
                        ? d.Image_Product
                        : "/images/product-default.png";

                var opts = new List<VariantOptionVM>(useVars.Count);
                decimal min = 0, max = 0;

                if (useVars.Count > 0)
                {
                    min = useVars.Min(v => v.Retail_Price);
                    max = useVars.Max(v => v.Retail_Price);

                    foreach (var v in useVars)
                    {
                        var nm = string.IsNullOrWhiteSpace(v.Name) ? v.Sku : v.Name;
                        opts.Add(new VariantOptionVM
                        {
                            Id = v.Id,
                            Name = nm,
                            Price = v.Retail_Price,
                            Image = string.IsNullOrWhiteSpace(v.Image) ? "" : v.Image,
                            Label = nm + " (" + FormatVnd(v.Retail_Price) + ")"
                        });
                    }
                }

                string priceHtml = (min == max)
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
                    TotalStock = totalStock,
                    DefaultVariantId = defaultVar,
                    Variants = opts
                });

                if (result.Count >= take) break;
            }

            return result;
        }

        // ================== HTTP helpers ==================

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
            }, seconds: 300);
        }

        public async Task<IList<ProductCardVM>> GetCardsByIdsAsync(IEnumerable<long> productIds, int take)
        {
            var ids = (productIds ?? Array.Empty<long>())
                .Where(x => x > 0)
                .Distinct()
                .Take(Math.Max(1, take))
                .ToArray();

            if (ids.Length == 0) return new List<ProductCardVM>();

            var details = await Task.WhenAll(ids.Select(GetProductDetailAsync).ToArray());
            var cards = new List<ProductCardVM>();

            foreach (var d in details)
            {
                if (d == null || d.Id <= 0) continue;

                var all = d.Variants ?? new List<VariantDto>();
                var active = all.Where(v => v.Status == 1).ToList();
                var use = active.Count > 0 ? active : all;

                long defaultVar = use.FirstOrDefault()?.Id ?? 0;
                int totalStock = (active.Count > 0 ? active : use).Sum(v => v?.Stock ?? 0);

                decimal min = 0, max = 0;
                if (use.Count > 0)
                {
                    min = use.Min(v => v.Retail_Price);
                    max = use.Max(v => v.Retail_Price);
                }

                string img = use.FirstOrDefault(v => !string.IsNullOrWhiteSpace(v.Image))?.Image;
                if (string.IsNullOrWhiteSpace(img)) img = d.Image_Product;
                if (string.IsNullOrWhiteSpace(img)) img = "/images/product-default.png";

                var opts = new List<VariantOptionVM>(use.Count);
                foreach (var v in use)
                {
                    var nm = string.IsNullOrWhiteSpace(v.Name) ? v.Sku : v.Name;
                    opts.Add(new VariantOptionVM
                    {
                        Id = v.Id,
                        Name = nm,
                        Price = v.Retail_Price,
                        Image = string.IsNullOrWhiteSpace(v.Image) ? "" : v.Image,
                        Label = nm + " (" + FormatVnd(v.Retail_Price) + ")"
                    });
                }

                string priceHtml = (min == max)
                    ? "<span class='price-now'>" + FormatVnd(min) + "</span>"
                    : "<span class='price-now'>" + FormatVnd(min) + " - " + FormatVnd(max) + "</span>";

                cards.Add(new ProductCardVM
                {
                    Id = d.Id,
                    Name = d.Name,
                    ImageUrl = img,
                    MinRetail = min,
                    MaxRetail = max,
                    PriceRangeHtml = priceHtml,
                    DiscountBadgeHtml = "",
                    TotalStock = totalStock,
                    DefaultVariantId = defaultVar,
                    Variants = opts
                });
            }

            return cards;
        }

        private static string FormatVnd(decimal v)
        {
            var vi = CultureInfo.GetCultureInfo("vi-VN");
            return string.Format(vi, "{0:#,0}đ", v);
        }
    }
}
