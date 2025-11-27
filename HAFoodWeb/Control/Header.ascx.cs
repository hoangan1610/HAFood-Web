using HAFoodWeb.Models;
using HAFoodWeb.Services;
using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace HAFoodWeb.Control
{
    public partial class Header : UserControl
    {
        // Regex trích mã đơn (giữ nguyên phần legacy)
        private static readonly Regex OrderCodeStrong =
            new Regex(@"(?:đơn\s*hàng|mã\s*đơn|order)\s*#?\s*[:\-]?\s*([A-Z0-9\-]{6,})",
                RegexOptions.Compiled | RegexOptions.IgnoreCase | RegexOptions.CultureInvariant);

        private static readonly Regex OrderCodeFallback =
            new Regex(@"(?<!\d)(\d{10,20})(?!\d)",
                RegexOptions.Compiled | RegexOptions.CultureInvariant);

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
                    await LoadNotificationsAsync().ConfigureAwait(false);
                }));
            }
            catch (InvalidOperationException)
            {
                // Fallback nếu Page không cho đăng ký async task
                EnsureDeviceAndCartAsync().GetAwaiter().GetResult();
                LoadNotificationsAsync().GetAwaiter().GetResult();
            }
            catch { }
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
                        int.TryParse(Convert.ToString(Session["UserId"]), out var tmp)) { userInfoId = tmp; }
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

                if (cartCountBadge != null)
                {
                    cartCountBadge.Visible = true;
                    cartCountBadge.InnerText = Math.Max(0, count).ToString();
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

        private async Task LoadNotificationsAsync()
        {
            try
            {
                var token = Request?.Cookies["AuthToken"]?.Value;

                if (string.IsNullOrEmpty(token))
                {
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
                    if (hfNotifyUnread != null)
                    {
                        hfNotifyUnread.Value = "0";
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
                    if (hfNotifyUnread != null)
                    {
                        hfNotifyUnread.Value = latest.totalUnread.ToString();
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
                    if (hfNotifyUnread != null)
                    {
                        hfNotifyUnread.Value = "0";
                    }
                }
            }
            catch
            {
                try
                {
                    if (lblNotifyEmpty != null)
                    {
                        lblNotifyEmpty.Visible = true;
                        lblNotifyEmpty.Text = "Không thể tải thông báo.";
                    }
                    if (hfNotifyUnread != null)
                    {
                        hfNotifyUnread.Value = "0";
                    }
                }
                catch { }
            }
        }

        // ========= Helper chung =========

        private static string SafeEval(object dataItem, string path)
        {
            try
            {
                var v = DataBinder.Eval(dataItem, path);
                return v?.ToString();
            }
            catch { return null; }
        }

        private static long GetLong(object dataItem, params string[] paths)
        {
            if (dataItem == null || paths == null) return 0L;
            foreach (var p in paths)
            {
                try
                {
                    var v = DataBinder.Eval(dataItem, p);
                    if (v == null) continue;
                    if (v is long l) return l;
                    if (v is int i) return i;
                    if (long.TryParse(Convert.ToString(v), out var r)) return r;
                }
                catch { }
            }
            return 0L;
        }

        private static Dictionary<string, string> ParseKv(string payload)
        {
            var dict = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
            if (string.IsNullOrWhiteSpace(payload)) return dict;

            var parts = payload.Split(new[] { ';' }, StringSplitOptions.RemoveEmptyEntries);
            foreach (var p in parts)
            {
                var idx = p.IndexOf('=');
                if (idx > 0)
                {
                    var k = p.Substring(0, idx).Trim();
                    var v = p.Substring(idx + 1).Trim();
                    if (!dict.ContainsKey(k)) dict[k] = v;
                }
            }
            return dict;
        }

        private static string ExtractOrderCode(string text)
        {
            if (string.IsNullOrWhiteSpace(text)) return null;

            var m1 = OrderCodeStrong.Match(text);
            if (m1.Success) return TrimPunct(m1.Groups[1].Value);

            var m2 = OrderCodeFallback.Match(text);
            if (m2.Success) return TrimPunct(m2.Groups[1].Value);

            return null;
        }

        private static string TrimPunct(string s)
            => (s ?? "").Trim(' ', '.', ',', ';', ':', '#', ']', '[', ')', '(', '!', '?', '"', '\'');

        // ========= CommandArgument builder =========

        protected string BuildNotifyCommandArg(object dataItem)
        {
            try
            {
                string idStr = SafeEval(dataItem, "id") ?? "0";

                long pid = GetLong(
                    dataItem,
                    "product_Id", "productId",
                    "payload.product_Id", "payload.productId",
                    "data.product_Id", "data.productId"
                );

                long reviewId = GetLong(
                    dataItem,
                    "review_Id", "reviewId",
                    "payload.review_Id", "payload.reviewId",
                    "data.review_Id", "data.reviewId"
                );

                if (pid > 0 && reviewId > 0)
                {
                    return $"{idStr}|target=review;pid={pid};rid={reviewId}";
                }

                if (pid > 0)
                    return $"{idStr}|target=product;pid={pid}";

                var title = SafeEval(dataItem, "title");
                var body = SafeEval(dataItem, "body");

                string code = SafeEval(dataItem, "order_Code")
                              ?? SafeEval(dataItem, "orderCode")
                              ?? SafeEval(dataItem, "payload.orderCode")
                              ?? SafeEval(dataItem, "data.orderCode")
                              ?? ExtractOrderCode(title)
                              ?? ExtractOrderCode(body);

                return string.IsNullOrEmpty(code) ? idStr : $"{idStr}|{code}";
            }
            catch
            {
                return SafeEval(dataItem, "id");
            }
        }

        // ========= WebMethod giữ nguyên =========

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
            catch { return 0; }
        }

        // ========= Click thông báo =========

        protected async void rptNotifications_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "Open" && e.CommandName != "MarkRead") return;

            try
            {
                var token = Request?.Cookies["AuthToken"]?.Value;
                if (string.IsNullOrEmpty(token)) return;

                long notifyId = 0;
                string orderCode = null;

                var arg = Convert.ToString(e.CommandArgument ?? "");
                var parts = arg.Split('|');
                if (parts.Length > 0) long.TryParse(parts[0], out notifyId);

                if (notifyId > 0)
                {
                    var notifyService = new NotificationService();
                    try { await notifyService.MarkAsReadAsync(token, notifyId).ConfigureAwait(false); } catch { }
                }

                if (parts.Length > 1)
                {
                    var payload = parts[1];

                    if (payload.StartsWith("target=", StringComparison.OrdinalIgnoreCase))
                    {
                        var map = ParseKv(payload);

                        if (map.TryGetValue("target", out var target) &&
                            (string.Equals(target, "product", StringComparison.OrdinalIgnoreCase) ||
                             string.Equals(target, "review", StringComparison.OrdinalIgnoreCase)))
                        {
                            if (map.TryGetValue("pid", out var pidStr) &&
                                long.TryParse(pidStr, out var productId) &&
                                productId > 0)
                            {
                                var url = $"~/Product/Product.aspx?id={productId}";

                                if (map.TryGetValue("rid", out var ridStr) &&
                                    long.TryParse(ridStr, out var reviewId) &&
                                    reviewId > 0)
                                {
                                    url += "&review=" + reviewId;
                                }

                                Response.Redirect(ResolveUrl(url), false);
                                Context.ApplicationInstance.CompleteRequest();
                                return;
                            }
                        }
                    }
                    else
                    {
                        orderCode = payload;
                    }
                }

                if (!string.IsNullOrWhiteSpace(orderCode))
                {
                    var url = ResolveUrl("~/UserInfo/UserDetail.aspx?tab=orders&id=" + HttpUtility.UrlEncode(orderCode));
                    Response.Redirect(url, false);
                    Context.ApplicationInstance.CompleteRequest();
                    return;
                }

                await LoadNotificationsAsync().ConfigureAwait(false);
            }
            catch { }
        }

        protected async void btnMarkAllRead_Click(object sender, EventArgs e)
        {
            try
            {
                var token = Request?.Cookies["AuthToken"]?.Value;
                if (string.IsNullOrEmpty(token)) return;

                var notifyService = new NotificationService();
                try { await notifyService.MarkAllAsReadAsync(token).ConfigureAwait(false); } catch { }

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
