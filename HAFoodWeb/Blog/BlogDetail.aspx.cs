using HAFoodWeb.Models;
using HAFoodWeb.Services;
using HAFoodWeb.Utils;
using System;
using System.Configuration;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Web;

namespace HAFoodWeb.Blog
{
    public partial class BlogDetail : System.Web.UI.Page
    {
        private readonly IArticleService _svc = new ArticleService();
        private readonly IProductCardService _cardSvc = new ProductCardService();

        protected async void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;

            var slug = (Page.RouteData.Values["slug"] as string ?? "").Trim();
            if (slug.Length == 0)
            {
                Response.StatusCode = 404;
                HttpContext.Current.ApplicationInstance.CompleteRequest();
                return;
            }

            var dto = await _svc.GetBySlugAsync(slug);
            if (dto == null)
            {
                Response.StatusCode = 404;
                HttpContext.Current.ApplicationInstance.CompleteRequest();
                return;
            }

            string apiBase = (ConfigurationManager.AppSettings["ApiBaseUrl"] ?? "").Trim().TrimEnd('/');
            Func<string, string> Normalize = (url) => NormalizeUrl(url, apiBase);

            var title = (dto.title ?? "").Trim();
            pageTitle.Text = title + " - HAFood";
            Page.Title = title + " - HAFood";
            litTitle.Text = Server.HtmlEncode(title);

            // excerpt (show dưới title)
            var excerpt = (dto.excerpt ?? "").Trim();
            excerpt = excerpt.Replace("\r", " ").Replace("\n", " ");
            if (excerpt.Length > 220) excerpt = excerpt.Substring(0, 220) + "…";
            litExcerpt.Text = Server.HtmlEncode(excerpt);

            // SEO
            var excerptSeo = (dto.excerpt ?? "").Trim().Replace("\r", " ").Replace("\n", " ");
            if (excerptSeo.Length > 160) excerptSeo = excerptSeo.Substring(0, 160);

            var cover = Normalize(dto.cover_Image_Url);

            var canonical =
                (Request.Url?.GetLeftPart(UriPartial.Authority) ?? "").TrimEnd('/')
                + "/blog/" + HttpUtility.UrlEncode(dto.slug ?? "");

            litHeadMeta.Text = $@"
<meta name=""description"" content=""{HttpUtility.HtmlAttributeEncode(excerptSeo)}"" />
<link rel=""canonical"" href=""{HttpUtility.HtmlAttributeEncode(canonical)}"" />

<meta property=""og:type"" content=""article"" />
<meta property=""og:title"" content=""{HttpUtility.HtmlAttributeEncode(title)}"" />
<meta property=""og:description"" content=""{HttpUtility.HtmlAttributeEncode(excerptSeo)}"" />
<meta property=""og:url"" content=""{HttpUtility.HtmlAttributeEncode(canonical)}"" />
{(string.IsNullOrWhiteSpace(cover) ? "" : $@"<meta property=""og:image"" content=""{HttpUtility.HtmlAttributeEncode(cover)}"" />")}
";

            var publishedIso = dto.published_At_Utc?.ToString("o") ?? "";
            litJsonLd.Text = $@"
<script type=""application/ld+json"">
{{
  ""@context"": ""https://schema.org"",
  ""@type"": ""Article"",
  ""headline"": ""{JavaScriptStringEncode(title)}"",
  ""description"": ""{JavaScriptStringEncode(excerptSeo)}"",
  ""datePublished"": ""{JavaScriptStringEncode(publishedIso)}"",
  ""mainEntityOfPage"": ""{JavaScriptStringEncode(canonical)}""
  {(string.IsNullOrWhiteSpace(cover) ? "" : $@", ""image"": ""{JavaScriptStringEncode(cover)}""")}
}}
</script>
";

            // Meta time (VN)
            var vnTime = dto.published_At_Utc.HasValue
                ? dto.published_At_Utc.Value.AddHours(7).ToString("dd/MM/yyyy HH:mm")
                : "";
            litMeta.Text = string.IsNullOrWhiteSpace(vnTime) ? "—" : ("Đăng lúc " + vnTime);

            // Cover
            if (!string.IsNullOrWhiteSpace(cover))
            {
                litCover.Text =
                    $"<img src=\"{Server.HtmlEncode(cover)}\" class=\"ha-cover\" alt=\"\" loading=\"lazy\" " +
                    "onerror=\"this.src='/images/blog-cover-default.png'\" />";
            }
            else
            {
                litCover.Text = "";
            }

            // Render EditorJS JSON -> HTML
            // Prefer HTML if available (TinyMCE)
            string html;
            if (!string.IsNullOrWhiteSpace(dto.content_Html))
            {
                html = NormalizeBodyHtml(dto.content_Html, apiBase); // optional normalize
            }
            else
            {
                html = EditorJsRenderer.Render(dto.content_Json, Normalize);
            }

            litContentHtml.Text = html;


            // reading time
            litReadTime.Text = EstimateReadingTime(html);

            // Cards (product suggestion)
            if (dto.cards != null && dto.cards.Count > 0)
            {
                var ids = dto.cards
                    .Select(x => x.product_Id)
                    .Where(x => x > 0)
                    .Distinct()
                    .ToArray();

                var cards = await _cardSvc.GetCardsByIdsAsync(ids, take: ids.Length);

                pCards.Visible = cards != null && cards.Count > 0;
                rpCards.DataSource = cards;
                rpCards.DataBind();
            }
            else
            {
                pCards.Visible = false;
            }

            // Related posts
            await LoadRelatedAsync(dto, slug, apiBase);
        }

        private async Task LoadRelatedAsync(ArticlePublicDto current, string currentSlug, string apiBase)
        {
            try
            {
                var q = BuildKeywordQuery((current?.title ?? "") + " " + (current?.excerpt ?? ""));
                if (string.IsNullOrWhiteSpace(q))
                {
                    pRelated.Visible = false;
                    return;
                }

                var res = await _svc.ListAsync(q, 1, 12);

                var items = (res?.items ?? new System.Collections.Generic.List<ArticleListItemDto>())
                    .Where(x => !string.Equals(x.slug, currentSlug, StringComparison.OrdinalIgnoreCase))
                    .Take(6)
                    .ToList();

                foreach (var it in items)
                    it.cover_Image_Url = NormalizeUrl(it.cover_Image_Url, apiBase);

                pRelated.Visible = items.Count > 0;
                rpRelated.DataSource = items;
                rpRelated.DataBind();
            }
            catch
            {
                pRelated.Visible = false;
            }
        }

        private static string BuildKeywordQuery(string s)
        {
            s = (s ?? "").Trim();
            if (s.Length == 0) return "";

            var sb = new StringBuilder(s.Length);
            foreach (var ch in s)
            {
                if (char.IsLetterOrDigit(ch) || char.IsWhiteSpace(ch)) sb.Append(ch);
            }

            var parts = sb.ToString()
                .Split(new[] { ' ', '\t', '\r', '\n' }, StringSplitOptions.RemoveEmptyEntries)
                .Select(x => x.Trim())
                .Where(x => x.Length >= 3)
                .Distinct(StringComparer.OrdinalIgnoreCase)
                .Take(5)
                .ToArray();

            return string.Join(" ", parts);
        }

        protected string RenderVariantSelect(object dataItem)
        {
            var vm = dataItem as ProductCardVM;
            if (vm == null) return "";
            if (vm.Variants == null || vm.Variants.Count <= 1) return "";

            var vi = CultureInfo.GetCultureInfo("vi-VN");
            string FormatVnd(decimal v) => string.Format(vi, "{0:#,0}đ", v);

            var sb = new StringBuilder();
            sb.Append("<div class='mt-2'>")
              .Append("<select class='form-select form-select-sm js-variant'>");

            foreach (var v in vm.Variants)
            {
                var selected = (v.Id == vm.DefaultVariantId) ? " selected" : "";
                var priceText = FormatVnd(v.Price);
                var img = (v.Image ?? "").Trim();

                sb.Append("<option value='")
                  .Append(HttpUtility.HtmlAttributeEncode(v.Id.ToString()))
                  .Append("'")
                  .Append(selected)
                  .Append(" data-price='").Append(HttpUtility.HtmlAttributeEncode(priceText)).Append("'")
                  .Append(" data-img='").Append(HttpUtility.HtmlAttributeEncode(img)).Append("'")
                  .Append(">")
                  .Append(HttpUtility.HtmlEncode(v.Label ?? ""))
                  .Append("</option>");
            }

            sb.Append("</select></div>");
            return sb.ToString();
        }

        private static string NormalizeUrl(string url, string apiBase)
        {
            url = (url ?? "").Trim();
            if (url.Length == 0) return "";

            if (url.StartsWith("http://", StringComparison.OrdinalIgnoreCase) ||
                url.StartsWith("https://", StringComparison.OrdinalIgnoreCase))
                return url;

            if (url.StartsWith("/") && !string.IsNullOrWhiteSpace(apiBase))
                return apiBase + url;

            return url;
        }

        private static string JavaScriptStringEncode(string s)
        {
            s = (s ?? "").Replace("\r", " ").Replace("\n", " ");
            return s.Replace("\\", "\\\\").Replace("\"", "\\\"");
        }

        private static string EstimateReadingTime(string html)
        {
            try
            {
                // strip tags
                var text = Regex.Replace(html ?? "", "<.*?>", " ");
                text = HttpUtility.HtmlDecode(text ?? "") ?? "";
                text = Regex.Replace(text, @"\s+", " ").Trim();

                if (text.Length == 0) return "1 phút đọc";

                var words = text.Split(' ').Count(x => x.Length > 0);
                var mins = (int)Math.Ceiling(words / 200.0); // 200 wpm
                if (mins <= 0) mins = 1;
                return mins + " phút đọc";
            }
            catch
            {
                return "1 phút đọc";
            }
        }

        private static string NormalizeBodyHtml(string html, string apiBase)
        {
            html = (html ?? "");
            if (string.IsNullOrWhiteSpace(apiBase)) return html;

            // src="/..." or href="/..." -> apiBase + "/..."
            html = Regex.Replace(html, "(src|href)\\s*=\\s*([\"'])/(.+?)\\2",
                m => $"{m.Groups[1].Value}={m.Groups[2].Value}{apiBase}/{m.Groups[3].Value}{m.Groups[2].Value}",
                RegexOptions.IgnoreCase);

            return html;
        }

    }
}
