using HAFoodWeb.Models;
using System.Threading;
using System.Threading.Tasks;

namespace HAFoodWeb.Services
{
    public interface IOrderService
    {
        // ✅ NEW (chuẩn theo BE mới): không cần userId (BE tự lấy uid từ JWT)
        Task<OrderPageDto> GetMyOrdersAsync(int? status = null, string orderCode = null, int page = 1, int pageSize = 20);

        // ✅ LEGACY: giữ lại cho code cũ khỏi lỗi compile (sẽ gọi sang GetMyOrdersAsync)
        Task<OrderPageDto> GetOrdersByUserAsync(long userId, int? status = null, int page = 1, int pageSize = 20);
        Task<OrderPageDto> GetOrdersByUserAsync(long userId, int? status, string orderCode, int page, int pageSize);

        Task<OrderDetailDto> GetOrderDetailAsync(long orderId);

        // ✅ NEW: giờ không scan nữa, dùng server filter order_code
        Task<OrderDetailDto> GetOrderDetailByCodeAsync(string orderCode);

        Task<OrderDetailDto> GetOrderDetailSmartAsync(string codeOrId);

        // (Các hàm bạn đang có trong OrderService)
        Task<OrderCheckoutResponse> CheckoutAsync(OrderCheckoutRequest body);
        Task<SwitchPaymentResult> SwitchPaymentSafeAsync(string orderCode, int newMethod, string reason = null, CancellationToken ct = default);
        Task<string> CreatePaymentLinkForOrderAsync(string orderCode, int method);
    }
}
