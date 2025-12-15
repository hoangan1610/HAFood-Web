using HAFoodWeb.Models;
using System;
using System.Net.Http;
using System.Threading.Tasks;
using System.Web.Script.Serialization;

namespace HAFoodWeb.Services
{
    public interface IArticleService
    {
        Task<ArticleListResponseDto> ListAsync(string q, int page, int pageSize);
        Task<ArticlePublicDto> GetBySlugAsync(string slug);
    }

    public sealed class ArticleService : IArticleService
    {
        private readonly string _apiBase;

        public ArticleService()
        {
            _apiBase = System.Configuration.ConfigurationManager.AppSettings["ApiBaseUrl"] ?? "";
            _apiBase = _apiBase.TrimEnd('/');
        }

        private static readonly HttpClient _http = new HttpClient(new HttpClientHandler
        {
            AutomaticDecompression = System.Net.DecompressionMethods.GZip | System.Net.DecompressionMethods.Deflate
        })
        {
            Timeout = TimeSpan.FromSeconds(20)
        };

        public async Task<ArticleListResponseDto> ListAsync(string q, int page, int pageSize)
        {
            if (page <= 0) page = 1;
            if (pageSize <= 0) pageSize = 10;

            var url = _apiBase + "/api/articles?page=" + page + "&pageSize=" + pageSize;
            if (!string.IsNullOrWhiteSpace(q))
                url += "&q=" + Uri.EscapeDataString(q.Trim());

            var json = await _http.GetStringAsync(url).ConfigureAwait(false);

            var ser = new JavaScriptSerializer { MaxJsonLength = int.MaxValue };
            return ser.Deserialize<ArticleListResponseDto>(json) ?? new ArticleListResponseDto();
        }

        public async Task<ArticlePublicDto> GetBySlugAsync(string slug)
        {
            slug = (slug ?? "").Trim();
            if (slug.Length == 0) return null;

            var url = _apiBase + "/api/articles/" + Uri.EscapeDataString(slug);
            using (var resp = await _http.GetAsync(url).ConfigureAwait(false))
            {
                if (resp.StatusCode == System.Net.HttpStatusCode.NotFound) return null;
                resp.EnsureSuccessStatusCode();

                var json = await resp.Content.ReadAsStringAsync().ConfigureAwait(false);
                var ser = new JavaScriptSerializer { MaxJsonLength = int.MaxValue };
                return ser.Deserialize<ArticlePublicDto>(json);
            }
        }
    }
}
