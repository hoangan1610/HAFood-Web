using System.Threading.Tasks;
using HAFoodWeb.Models;

namespace HAFoodWeb.Services
{
    public interface IProductDetailService
    {
        Task<ProductDetailDto> GetProductDetailAsync(long id);
    }
}
