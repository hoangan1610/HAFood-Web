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
        Task<PagedResult<ProductListItemDto>> SearchListAsync(ProductSearchRequest req);
        Task<IList<ProductCardVM>> BuildCardsAsync(ProductSearchRequest req);
    }
}
