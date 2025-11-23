using System.Threading.Tasks;
using HAFoodWeb.Models;

namespace HAFoodWeb.Services
{
    public interface INotificationService
    {
        Task<NotificationLatestResultDto> GetLatestAsync(string token, int take = 10);
        Task<NotificationPagedResultDto> GetPagedAsync(
            string token,
            int page = 1,
            int pageSize = 20,
            bool onlyUnread = false,
            int? type = null);
        Task<ApiBaseResponse> MarkAsReadAsync(string token, long id);
        Task<ApiBaseResponse> MarkAllAsReadAsync(string token);
    }
}
