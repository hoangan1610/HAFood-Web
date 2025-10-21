using HAFoodWeb.Models;
using System.Threading.Tasks;

public interface ICartService
{
    Task<CartResponseDto> GetCartAsync(string deviceUuid);
    Task<CartResponseDto> AddCartItemAsync(string deviceUuid, CartAddRequest item);
    Task<CartResponseDto> UpdateQuantityAsync(long variantId, string deviceUuid, int quantity);
    Task<CartResponseDto> DeleteCartItemAsync(long variantId, string deviceUuid);
    Task<CartResponseDto> ClearCartAsync(string deviceUuid);
}
