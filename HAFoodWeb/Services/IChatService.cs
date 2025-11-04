using System.Threading.Tasks;
using HAFoodWeb.Models;

namespace HAFoodWeb.Services
{
    public interface IChatService
    {
        Task<ChatAskResponse> AskAsync(string token, string message);
    }
}
