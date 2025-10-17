// Services/ISearchService.cs
using System.Threading.Tasks;
using HAFoodWeb.Models;

namespace HAFoodWeb.Services
{
    public interface ISearchService
    {
        Task<PagedResult<ProductListItemDto>> SearchProductsAsync(
            string q, long? categoryId, string brand,
            decimal? minPrice, decimal? maxPrice,
            int page, int pageSize, string sort = "updated_at:desc",
            bool onlyInStock = false);
    }
}
