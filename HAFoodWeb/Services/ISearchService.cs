using System.Collections.Generic;
using System.Threading.Tasks;
using HAFoodWeb.Models;

namespace HAFoodWeb.Services
{
    public interface ISearchService
    {
        // DEBUG: xem URL Web gọi API
        string LastListUrl { get; }
        IList<string> LastDetailUrls { get; }

        Task<IList<string>> SuggestAsync(string q);

        // Gọi API list (1 lần / request)
        Task<PagedResult<ProductListItemDto>> SearchListAsync(ProductSearchRequest req);

        // Cũ: vẫn giữ để tương thích, nhưng TRY AVOID trong code mới
        Task<IList<ProductCardVM>> BuildCardsAsync(ProductSearchRequest req);

        // Mới: dùng list đã có, tránh gọi lại API
        Task<IList<ProductCardVM>> BuildCardsAsync(
            ProductSearchRequest req,
            PagedResult<ProductListItemDto> list);
    }
}
