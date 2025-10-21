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
            if (!IsPostBack) DataBind();

            var token = Request.Cookies["AuthToken"]?.Value;
            guestDropdown.Visible = string.IsNullOrEmpty(token);
            authDropdown.Visible = !string.IsNullOrEmpty(token);

            // Đảm bảo có UUID & cập nhật device về server (userInfoId nếu có)
            Page.RegisterAsyncTask(new PageAsyncTask(async () =>
            {
                var tracker = new DeviceTracker(Request, Response);

                // parse userInfoId từ Session nếu có
                int? userInfoId = null;
                try
                {
                    if (int.TryParse(Convert.ToString(Session["UserId"]), out var tmp))
                        userInfoId = tmp;
                }
                catch { }

                await tracker.SendAsync(userInfoId);   // <-- post lên server
                await LoadCartCountAsync();           
            }));
        }

        private async Task LoadCartCountAsync()
        {
            try
            {
                var tracker = new DeviceTracker(Request, Response);
                string deviceUuid = tracker.GetOrCreateDeviceUuid();

                var cartService = new CartService();
                var cart = await cartService.GetCartAsync(deviceUuid);

                int count = cart?.header?.item_Count ?? 0;
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
        public static async Task<int> GetCartCount()
        {
            try
            {
                var ctx = HttpContext.Current;
                var tracker = new DeviceTracker(ctx.Request, ctx.Response);

                // Lấy UUID từ cookie (HADeviceUuid)
                string deviceUuid = tracker.GetOrCreateDeviceUuid();

                var cartService = new CartService();
                var cart = await cartService.GetCartAsync(deviceUuid); // <-- dùng overload nhận string

                return cart?.header?.item_Count ?? 0;
            }
            catch
            {
                return 0;
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

        
        
    

