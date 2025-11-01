using System;
using System.Web.UI;

namespace HAFoodWeb.Pages
{
    public partial class ThankYou : Page
    {
        // 👉 Sau 5 giây sẽ về trang UserDetail, tab "orders", mở ngay OrderDetail theo orderId
        private const string USER_DETAIL_PATH = "~/UserInfo/UserDetail.aspx";

        private const string SK_PENDING_ORDER_ID = "pending_order_id";
        private const string SK_PENDING_ORDER_CODE = "pending_order_code";

        protected string RedirectDetailUrl = "";
        protected int CountdownSeconds = 5;

        protected void Page_Load(object sender, EventArgs e)
        {
            Response.Cache.SetCacheability(System.Web.HttpCacheability.NoCache);
            Response.Cache.SetNoStore();
            Response.Cache.SetRevalidation(System.Web.HttpCacheRevalidation.AllCaches);
            Response.Cache.SetExpires(DateTime.UtcNow.AddSeconds(-1));

            if (IsPostBack) return;

            // Lấy code để hiển thị
            var code = (Request["code"] ?? "").Trim();
            if (string.IsNullOrWhiteSpace(code))
            {
                var sc = Session[SK_PENDING_ORDER_CODE] as string;
                if (!string.IsNullOrWhiteSpace(sc)) code = sc;
            }
            phCode.Visible = !string.IsNullOrWhiteSpace(code);
            if (phCode.Visible) lblCode.Text = code;

            // Lấy id để điều hướng
            long id = 0;
            long.TryParse(Request.QueryString["id"], out id);
            if (id <= 0)
            {
                var pid = TryGetPendingOrderIdFromSession();
                if (pid.HasValue) id = pid.Value;
            }

            if (id > 0)
            {
                // 👉 Chuyển về UserDetail, mở tab Orders + OrderDetail
                RedirectDetailUrl = ResolveUrl(USER_DETAIL_PATH) + "?tab=orders&orderId=" + id;
                phFallback.Visible = false;
            }
            else
            {
                phFallback.Visible = true;
                btnOrders.HRef = ResolveUrl("~/OrderPage/OrderPage.aspx");
            }

            // Tuỳ chọn: dọn session checkout (không xoá pending order id/code để fallback)
            string[] cleanup = {
                "checkout_draft","checkout_totals",
                "pending_payment_url","pending_payment_created_utc","pending_payment_method"
            };
            foreach (var k in cleanup) { try { Session.Remove(k); } catch { } }
        }

        private long? TryGetPendingOrderIdFromSession()
        {
            var obj = Session[SK_PENDING_ORDER_ID];
            if (obj == null) return null;
            if (obj is long l) return l;
            if (obj is int i) return i;
            if (obj is string s && long.TryParse(s, out var v)) return v;
            return null;
        }
    }
}
