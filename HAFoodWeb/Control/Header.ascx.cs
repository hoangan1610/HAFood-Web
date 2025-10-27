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

            var token = Request?.Cookies["AuthToken"]?.Value;
            var isAuth = !string.IsNullOrEmpty(token);

            if (guestDropdown != null) guestDropdown.Visible = !isAuth;
            if (authDropdown != null) authDropdown.Visible = isAuth;

            if (hfIsAuth != null) hfIsAuth.Value = isAuth ? "1" : "0";

            try
            {
                Page.RegisterAsyncTask(new PageAsyncTask(async () =>
                {
                    await EnsureDeviceAndCartAsync().ConfigureAwait(false);
                }));
            }
            catch (InvalidOperationException)
            {
                EnsureDeviceAndCartAsync().GetAwaiter().GetResult();
            }
            catch (Exception)
            {
            }
        }

        private async Task EnsureDeviceAndCartAsync()
        {
            try
            {
                var tracker = new DeviceTracker(Request, Response);

                int? userInfoId = null;
                try
                {
                    if (Session != null && Session["UserId"] != null)
                    {
                        if (int.TryParse(Convert.ToString(Session["UserId"]), out var tmp))
                            userInfoId = tmp;
                    }
                }
                catch {  }

                tracker.GetOrCreateDeviceUuid();

                await tracker.SendAsync(userInfoId).ConfigureAwait(false);

                await LoadCartCountAsync().ConfigureAwait(false);
            }
            catch
            {
            }
        }

       
        private async Task LoadCartCountAsync()
        {
            try
            {
                var tracker = new DeviceTracker(Request, Response);
                var deviceUuid = tracker.GetOrCreateDeviceUuid();

                var cartService = new CartService();
                var cart = await cartService.GetCartAsync(deviceUuid).ConfigureAwait(false);

                var count = cart?.header?.item_Count ?? 0;

                if (cartCountBadge != null)
                {
                    cartCountBadge.Visible = true;
                    cartCountBadge.InnerText = count.ToString();
                    cartCountBadge.Attributes["style"] = count > 0 ? "display:flex;" : "display:none;";
                }
            }
            catch
            {
                if (cartCountBadge != null)
                {
                    cartCountBadge.Visible = true;
                    cartCountBadge.InnerText = "0";
                    cartCountBadge.Attributes["style"] = "display:none;";
                }
            }
        }

    
        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static int GetCartCount()
        {
            try
            {
                var ctx = HttpContext.Current;
                if (ctx == null) return 0;

                var tracker = new DeviceTracker(ctx.Request, ctx.Response);
                var deviceUuid = tracker.GetOrCreateDeviceUuid();

                var cartService = new CartService();
                var cart = cartService.GetCartAsync(deviceUuid).GetAwaiter().GetResult();

                return cart?.header?.item_Count ?? 0;
            }
            catch
            {
                return 0;
            }
        }

      
        protected async void btnLogout_Click(object sender, EventArgs e)
        {
            try
            {
                var token = Request?.Cookies["AuthToken"]?.Value;
                if (!string.IsNullOrEmpty(token))
                {
                    var userService = new UserService();
                    try
                    {
                        await userService.LogoutAsync(token).ConfigureAwait(false);
                    }
                    catch
                    {
                    }
                }

                if (Request?.Cookies["AuthToken"] != null)
                {
                    var cookie = new HttpCookie("AuthToken", "")
                    {
                        Expires = DateTime.UtcNow.AddDays(-1),
                        Path = "/"
                    };
                    Response.Cookies.Add(cookie);
                }

                // Clear session
                try
                {
                    Session?.Clear();
                    Session?.Abandon();
                }
                catch { }

                // Redirect an toàn (không dùng Response.End)
                Response.Redirect("~/HomePage/HomePage.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
            }
            catch
            {
                try
                {
                    Response.Redirect("~/HomePage/HomePage.aspx", false);
                    Context.ApplicationInstance.CompleteRequest();
                }
                catch { }
            }
        }
    }
}
