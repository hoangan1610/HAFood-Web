using HAFoodWeb.Services;
using System;
using System.Threading.Tasks;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls; // [NOTIFY] RepeaterCommandEventArgs

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

                    // [NOTIFY] load thông báo
                    await LoadNotificationsAsync().ConfigureAwait(false);
                }));
            }
            catch (InvalidOperationException)
            {
                // Fallback khi không dùng được async task
                EnsureDeviceAndCartAsync().GetAwaiter().GetResult();
                LoadNotificationsAsync().GetAwaiter().GetResult();
            }
            catch
            {
                // nuốt lỗi an toàn
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
            catch { }
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
                    cartCountBadge.Attributes["style"] = "display:flex;";
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

        // [NOTIFY] load danh sách thông báo mới nhất 
        private async Task LoadNotificationsAsync()
        {
            try
            {
                var token = Request?.Cookies["AuthToken"]?.Value;

                if (string.IsNullOrEmpty(token))
                {
                    if (notifyDot != null) notifyDot.Visible = false;
                    if (lblNotifyEmpty != null)
                    {
                        lblNotifyEmpty.Visible = true;
                        lblNotifyEmpty.Text = "Hãy đăng nhập để xem thông báo.";
                    }
                    if (rptNotifications != null)
                    {
                        rptNotifications.DataSource = null;
                        rptNotifications.DataBind();
                    }
                    return;
                }

                var notifyService = new NotificationService();
                var latest = await notifyService.GetLatestAsync(token, 10).ConfigureAwait(false);

                if (latest != null && latest.items != null && latest.items.Count > 0)
                {
                    if (rptNotifications != null)
                    {
                        rptNotifications.DataSource = latest.items;
                        rptNotifications.DataBind();
                    }

                    if (lblNotifyEmpty != null)
                    {
                        lblNotifyEmpty.Visible = false;
                        lblNotifyEmpty.Text = string.Empty;
                    }

                    if (notifyDot != null)
                    {
                        notifyDot.Visible = latest.totalUnread > 0;
                    }
                }
                else
                {
                    if (rptNotifications != null)
                    {
                        rptNotifications.DataSource = null;
                        rptNotifications.DataBind();
                    }

                    if (lblNotifyEmpty != null)
                    {
                        lblNotifyEmpty.Visible = true;
                        lblNotifyEmpty.Text = "Hiện không có thông báo nào.";
                    }

                    if (notifyDot != null)
                    {
                        notifyDot.Visible = false;
                    }
                }
            }
            catch
            {
                try
                {
                    if (notifyDot != null) notifyDot.Visible = false;
                    if (lblNotifyEmpty != null)
                    {
                        lblNotifyEmpty.Visible = true;
                        lblNotifyEmpty.Text = "Không thể tải thông báo.";
                    }
                }
                catch { }
            }
        }

        // WebMethod tiện lợi nếu bạn cần gọi từ client
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

        // [NOTIFY] click 1 item -> đánh dấu đã đọc
        protected async void rptNotifications_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "MarkRead") return;

            try
            {
                var token = Request?.Cookies["AuthToken"]?.Value;
                if (string.IsNullOrEmpty(token)) return;

                if (long.TryParse(Convert.ToString(e.CommandArgument), out var id))
                {
                    var notifyService = new NotificationService();
                    try
                    {
                        await notifyService.MarkAsReadAsync(token, id).ConfigureAwait(false);
                    }
                    catch { }
                }

                await LoadNotificationsAsync().ConfigureAwait(false);
            }
            catch { }
        }

        // [NOTIFY] nút "Đánh dấu tất cả đã đọc"
        protected async void btnMarkAllRead_Click(object sender, EventArgs e)
        {
            try
            {
                var token = Request?.Cookies["AuthToken"]?.Value;
                if (string.IsNullOrEmpty(token)) return;

                var notifyService = new NotificationService();
                try
                {
                    await notifyService.MarkAllAsReadAsync(token).ConfigureAwait(false);
                }
                catch { }

                await LoadNotificationsAsync().ConfigureAwait(false);
            }
            catch { }
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
