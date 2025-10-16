using System.Threading.Tasks;
using HAFoodWeb.Models;

namespace HAFoodWeb.Services
{
    public interface IUserService
    {
        Task<AuthMeResponse> GetProfileAsync(string token);
        Task<bool> LogoutAsync(string token);
        Task<ApiBaseResponse> UpdateProfileAsync(string token, UserUpdateRequest request);
    }
}
