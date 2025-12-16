using System.Web.Routing;
using Microsoft.AspNet.FriendlyUrls;

namespace HAFoodWeb
{
    public static class RouteConfig
    {
        public static void RegisterRoutes(RouteCollection routes)
        {
            routes.Ignore("{resource}.axd/{*pathInfo}");

            // ✅ quan trọng: để route vẫn chạy dù URL trỏ vào folder/file thật
            routes.RouteExistingFiles = true;

            // ✅ Blog list: bắt cả /blog và /blog/
            routes.MapPageRoute("BlogListNoSlash", "blog", "~/Blog/BlogList.aspx");
            routes.MapPageRoute("BlogListSlash", "blog/", "~/Blog/BlogList.aspx");

            // ✅ Detail
            routes.MapPageRoute("BlogDetail", "blog/{slug}", "~/Blog/BlogDetail.aspx");

            var settings = new FriendlyUrlSettings { AutoRedirectMode = RedirectMode.Permanent };
            routes.EnableFriendlyUrls(settings);
        }
    }
}
