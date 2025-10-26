using System.Collections.Generic;
using System.Threading.Tasks;
using HAFoodWeb.Models;

namespace HAFoodWeb.Services
{
    public interface IOrderService
    {
        Task<OrderPageDto> GetOrdersByUserAsync(long userId, int? status = null, int page = 1, int pageSize = 20);
        Task<OrderDetailDto> GetOrderDetailAsync(long orderId);

    }
}
