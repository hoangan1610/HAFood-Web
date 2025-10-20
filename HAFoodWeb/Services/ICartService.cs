using HAFoodWeb.Models;
using System.Threading.Tasks;

public interface ICartService
{
    Task<CartResponseDto> GetCartAsync(long deviceId);
    Task<CartResponseDto> AddCartItemAsync(long deviceId, CartAddRequest item);
    Task<CartResponseDto> UpdateQuantityAsync(long variantId, long deviceId, int quantity);
    Task<CartResponseDto> DeleteCartItemAsync(long variantId, long deviceId);
    Task<CartResponseDto> ClearCartAsync(long deviceId);
}