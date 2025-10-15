using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Threading.Tasks;
using HAFoodWeb.Infrastructure;
using HAFoodWeb.Models;

namespace HAFoodWeb.Services
{
    public class CategoryService : ICategoryService
    {
        private readonly string _apiBase = ConfigurationManager.AppSettings["ApiBaseUrl"]?.TrimEnd('/');
        private readonly string _cdnBase = (ConfigurationManager.AppSettings["CdnBaseUrl"]?.TrimEnd('/') ?? "") + "/";
        private readonly long _featuredRootId =
            long.TryParse(ConfigurationManager.AppSettings["FeaturedRootId"], out var v) ? v : 1;

        public async Task<IReadOnlyList<CategoryTreeDto>> GetAllAsync()
        {
            var url = string.Format("{0}/api/categories/tree", _apiBase);
            var list = await HttpJson.GetJsonAsync<List<CategoryTreeDto>>(url)
                       ?? new List<CategoryTreeDto>();   // <-- bỏ target-typed new()
            return list;
        }

        public async Task<IReadOnlyList<CategoryTreeDto>> GetFeaturedAsync()
        {
            var all = await GetAllAsync();
            return all
                .Where(x => x.Parent_Id == _featuredRootId && (x.Status ?? 0) == 1)
                .OrderBy(x => x.Sort_Order ?? int.MaxValue)
                .ThenBy(x => x.Name)
                .ToList();
        }

        public string BuildImageUrl(CategoryTreeDto c)
        {
            if (c == null || string.IsNullOrWhiteSpace(c.Image_Url))
                return "/assets/cat/default.png";

            if (c.Image_Url.StartsWith("http"))
                return c.Image_Url;

            return _cdnBase + c.Image_Url.TrimStart('/');
        }
    }
}
