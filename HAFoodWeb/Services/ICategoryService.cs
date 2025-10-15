namespace HAFoodWeb.Services
{
    using System.Collections.Generic;
    using System.Threading.Tasks;
    using HAFoodWeb.Models;

    public interface ICategoryService
    {
        Task<IReadOnlyList<CategoryTreeDto>> GetAllAsync();
        Task<IReadOnlyList<CategoryTreeDto>> GetFeaturedAsync();
        string BuildImageUrl(CategoryTreeDto c);
    }
}
