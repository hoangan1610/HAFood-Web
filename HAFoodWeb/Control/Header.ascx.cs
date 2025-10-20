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
    public partial class Header : System.Web.UI.UserControl
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
                DataBind();

            var token = Request.Cookies["AuthToken"]?.Value;
            guestDropdown.Visible = string.IsNullOrEmpty(token);
            authDropdown.Visible = !string.IsNullOrEmpty(token);

            // ✅ Luôn đăng ký load cart count
            Page.RegisterAsyncTask(new PageAsyncTask(async () =>
            {
                await LoadCartCountAsync();
            }));
        }

        private async Task LoadCartCountAsync()
        {
            try
            {
                var deviceCookie = Request.Cookies["HADeviceId"];
                if (deviceCookie == null || !long.TryParse(deviceCookie.Value, out var deviceId))
                    return;

                var cartService = new CartService();
                CartResponseDto cart = await cartService.GetCartAsync(deviceId);

                int count = cart?.header?.item_Count ?? 0;
                cartCountBadge.InnerText = count.ToString();
                cartCountBadge.Visible = count > 0;

                if (cart?.header != null && cart.header.cart_Id > 0)
                {
                    var cartId = cart.header.cart_Id;
                    try { Session["CartId"] = cartId; } catch { }

                    var cookie = new HttpCookie("HACartId", cartId.ToString())
                    {
                        HttpOnly = false,
                        Secure = Request.IsSecureConnection,
                        Expires = DateTime.UtcNow.AddYears(1)
                    };
                    Response.Cookies.Remove("HACartId");
                    Response.Cookies.Add(cookie);
                }
            }
            catch
            {
                cartCountBadge.InnerText = "0";
                cartCountBadge.Visible = false;
            }
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
                var cookie = new HttpCookie("AuthToken")
                {
                    Expires = DateTime.Now.AddDays(-1)
                };
                Response.Cookies.Add(cookie);
            }

            Session.Clear();
            Session.Abandon();
            Response.Redirect("~/HomePage/HomePage.aspx", false);
            Context.ApplicationInstance.CompleteRequest();
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static async Task<int> GetCartCount()
        {
            try
            {
                var context = HttpContext.Current;
                var deviceCookie = context.Request.Cookies["HADeviceId"];
                if (deviceCookie == null || !long.TryParse(deviceCookie.Value, out var deviceId))
                    return 0;

                var cartService = new CartService();
                var cart = await cartService.GetCartAsync(deviceId);

                if (cart?.header != null && cart.header.cart_Id > 0)
                {
                    var cartId = cart.header.cart_Id;
                    try { context.Session["CartId"] = cartId; } catch { }

                    var cookie = new HttpCookie("HACartId", cartId.ToString())
                    {
                        HttpOnly = false,
                        Secure = context.Request.IsSecureConnection,
                        Expires = DateTime.UtcNow.AddYears(1)
                    };
                    context.Response.Cookies.Remove("HACartId");
                    context.Response.Cookies.Add(cookie);
                }

                return cart?.header?.item_Count ?? 0;
            }
            catch
            {
                return 0;
            }
        }
    }
}