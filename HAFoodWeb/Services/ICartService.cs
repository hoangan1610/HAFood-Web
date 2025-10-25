using System.Threading.Tasks;
using HAFoodWeb.Models;

namespace HAFoodWeb.Services
{
    public interface ICartService
    {
        // ĐÃ đăng nhập (JWT -> không gửi device_uuid)
        Task<CartResponseDto> GetCartAsync();

        // KHÁCH (gửi device_uuid)
        Task<CartResponseDto> GetCartAsync(string deviceUuid);

        Task<CartResponseDto> AddCartItemAsync(string deviceUuid, CartAddRequest item);
        Task<CartResponseDto> UpdateQuantityAsync(long variantId, string deviceUuid, int quantity);
        Task<CartResponseDto> DeleteCartItemAsync(long variantId, string deviceUuid);
        Task<CartResponseDto> ClearCartAsync(string deviceUuid);
    }
}
