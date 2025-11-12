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

            // Xác định trạng thái đăng nhập để hiện đúng dropdown + set hidden field
            var token = Request?.Cookies["AuthToken"]?.Value;
            var isAuth = !string.IsNullOrEmpty(token);

            if (guestDropdown != null) guestDropdown.Visible = !isAuth;
            if (authDropdown != null) authDropdown.Visible = isAuth;
            if (hfIsAuth != null) hfIsAuth.Value = isAuth ? "1" : "0";

            // Chỉ còn đồng bộ device + giỏ (không còn bind danh mục/sản phẩm)
            try
            {
                Page.RegisterAsyncTask(new PageAsyncTask(async () =>
                {
                    await EnsureDeviceAndCartAsync().ConfigureAwait(false);
                }));
            }
            catch (InvalidOperationException)
            {
                // Fallback khi không dùng được async task (ví dụ trong lifecycle đặc biệt)
                EnsureDeviceAndCartAsync().GetAwaiter().GetResult();
            }
            catch { /* nuốt lỗi an toàn cho header */ }
        }

        private async Task EnsureDeviceAndCartAsync()
        {
            try
            {
                var tracker = new DeviceTracker(Request, Response);
                int? userInfoId = null;
                try
                {
                    if (Session != null && Session["UserId"] != null &&
                        int.TryParse(Convert.ToString(Session["UserId"]), out var tmp))
                    {
                        userInfoId = tmp;
                    }
                }
                catch { }

                tracker.GetOrCreateDeviceUuid();
                await tracker.SendAsync(userInfoId).ConfigureAwait(false);

                await LoadCartCountAsync().ConfigureAwait(false);
            }
            catch { /* tránh làm vỡ header nếu có lỗi nhỏ */ }
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

                // LUÔN hiển thị badge, kể cả khi 0
                if (cartCountBadge != null)
                {
                    cartCountBadge.Visible = true;
                    cartCountBadge.InnerText = (count < 0 ? 0 : count).ToString();
                    cartCountBadge.Attributes["style"] = "display:flex;"; // luôn hiển thị
                }
            }
            catch
            {
                if (cartCountBadge != null)
                {
                    cartCountBadge.Visible = true;
                    cartCountBadge.InnerText = "0";
                    cartCountBadge.Attributes["style"] = "display:flex;";
                }
            }
        }

        // WebMethod tiện lợi nếu bạn cần gọi từ client (không phụ thuộc vào .ashx)
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
                    try { await userService.LogoutAsync(token).ConfigureAwait(false); } catch { }
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

                try { Session?.Clear(); Session?.Abandon(); } catch { }

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
