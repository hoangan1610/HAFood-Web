using System.Collections.Generic;
using System.Threading.Tasks;
using HAFoodWeb.Models;

namespace HAFoodWeb.Services
{
    public interface IOrderService
    {
        Task<OrderPageDto> GetOrdersByUserAsync(long userId, int? status = null, int page = 1, int pageSize = 20);
        Task<OrderDetailDto> GetOrderDetailAsync(long orderId);

        // Lấy chi tiết theo MÃ ĐƠN (dò /api/orders, tìm order_Code rồi gọi detail theo id)
        Task<OrderDetailDto> GetOrderDetailByCodeAsync(string orderCode);

        // Tiện dụng: truyền code hoặc id, ưu tiên code trước rồi fallback id
        Task<OrderDetailDto> GetOrderDetailSmartAsync(string codeOrId);
    }
}
