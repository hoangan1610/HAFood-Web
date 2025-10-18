using System.Collections.Generic;
using System.Threading.Tasks;
using HAFoodWeb.Models;

namespace HAFoodWeb.Services
{
    public interface ISearchService
    {
        Task<IList<string>> SuggestAsync(string q);
        Task<PagedResult<ProductListItemDto>> SearchListAsync(ProductSearchRequest req);
        Task<IList<ProductCardVM>> BuildCardsAsync(ProductSearchRequest req);
    }
}
