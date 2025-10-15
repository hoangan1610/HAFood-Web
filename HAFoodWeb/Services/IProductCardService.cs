using System.Collections.Generic;
using System.Threading.Tasks;
using HAFoodWeb.Models;

namespace HAFoodWeb.Services
{
    public interface IProductCardService
    {
        // Gợi ý/trang đầu
        Task<IList<ProductCardVM>> GetRecommendedCardsAsync(int take);

        // Phân trang cho “Mới về” / Load More
        Task<IList<ProductCardVM>> GetRecommendedPageAsync(int page, int pageSize);
    }
}
