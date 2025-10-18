using System;
using System.Configuration;
using System.Threading.Tasks;
using HAFoodWeb.Infrastructure;
using HAFoodWeb.Models;

namespace HAFoodWeb.Services
{
    public class ProductDetailService : IProductDetailService
    {
        private readonly string _apiBase;

        public ProductDetailService()
        {
            _apiBase = (ConfigurationManager.AppSettings["ApiBaseUrl"] ?? "").TrimEnd('/');
        }

        public async Task<ProductDetailDto> GetProductDetailAsync(long id)
        {
            var cacheKey = $"product:detail:{id}";
            return await AppCache.GetOrAddAsync(cacheKey, async () =>
            {
                var url = $"{_apiBase}/api/products/{id}";
                var fallback = new ProductDetailDto
                {
                    Id = id,
                    Name = "",
                    Variants = new System.Collections.Generic.List<VariantDto>()
                };
                return await HttpJson.TryGetJsonAsync(url, fallback);
            }, seconds: 300);
        }
    }
}
