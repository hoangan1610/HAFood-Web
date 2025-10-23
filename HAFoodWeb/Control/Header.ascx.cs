using HAFoodWeb.Models;
using HAFoodWeb.Services;
using System;
using System.Threading.Tasks;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;

namespace HAFoodWeb.Control
{
    public partial class Header : UserControl
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack) DataBind();

            var token = Request.Cookies["AuthToken"]?.Value;
            guestDropdown.Visible = string.IsNullOrEmpty(token);
            authDropdown.Visible = !string.IsNullOrEmpty(token);

            // Thử đăng ký async; nếu trang không hỗ trợ thì chạy sync
            try
            {
                Page.RegisterAsyncTask(new PageAsyncTask(async () =>
                {
                    await EnsureDeviceAndCartAsync();
                }));
            }
            catch (InvalidOperationException)
            {
                // Trang không Async="true"
                EnsureDeviceAndCartAsync().GetAwaiter().GetResult();
            }
        }

        private async Task EnsureDeviceAndCartAsync()
        {
            var tracker = new DeviceTracker(Request, Response);

            int? userInfoId = null;
            try
            {
                if (int.TryParse(Convert.ToString(Session["UserId"]), out var tmp))
                    userInfoId = tmp;
            }
            catch { }

            tracker.GetOrCreateDeviceUuid();
            await tracker.SendAsync(userInfoId);
            await LoadCartCountAsync();
        }

        private async Task LoadCartCountAsync()
        {
            try
            {
                var tracker = new DeviceTracker(Request, Response);
                var deviceUuid = tracker.GetOrCreateDeviceUuid();

                var cartService = new CartService();
                var cart = await cartService.GetCartAsync(deviceUuid);

                var count = cart?.header?.item_Count ?? 0;
                cartCountBadge.InnerText = count.ToString();
                cartCountBadge.Visible = count > 0;
            }
            catch
            {
                cartCountBadge.InnerText = "0";
                cartCountBadge.Visible = false;
            }
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static int GetCartCount()
        {
            try
            {
                var ctx = HttpContext.Current;
                var tracker = new DeviceTracker(ctx.Request, ctx.Response);
                var deviceUuid = tracker.GetOrCreateDeviceUuid();

                var cartService = new CartService();
                var cart = cartService.GetCartAsync(deviceUuid).GetAwaiter().GetResult();
                return cart?.header?.item_Count ?? 0;
            }
            catch { return 0; }
        }

        protected async void btnLogout_Click(object sender, EventArgs e)
        {
            var token = Request.Cookies["AuthToken"]?.Value;
            if (!string.IsNullOrEmpty(token))
            {
                var userService = new UserService();
                await userService.LogoutAsync(token);
            }

            if (Request.Cookies["AuthToken"] != null)
            {
                var cookie = new HttpCookie("AuthToken") { Expires = DateTime.Now.AddDays(-1) };
                Response.Cookies.Add(cookie);
            }

            Session.Clear();
            Session.Abandon();

            Response.Redirect("~/HomePage/HomePage.aspx", false);
            Context.ApplicationInstance.CompleteRequest();
        }
    }
}
