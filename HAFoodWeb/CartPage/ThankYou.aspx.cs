using System;
using System.Web.UI;

namespace HAFoodWeb.Pages
{
    public partial class ThankYou : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // chống cache
            Response.Cache.SetCacheability(System.Web.HttpCacheability.NoCache);
            Response.Cache.SetNoStore();
            Response.Cache.SetRevalidation(System.Web.HttpCacheRevalidation.AllCaches);
            Response.Cache.SetExpires(DateTime.UtcNow.AddSeconds(-1));

            if (!IsPostBack)
            {
                var code = Request["code"];
                phCode.Visible = !string.IsNullOrWhiteSpace(code);
                if (phCode.Visible) lblCode.Text = code;

                btnHome.HRef = ResolveUrl("~/HomePage/HomePage.aspx");

                string[] checkoutKeys = {
            "checkout_draft",
            "checkout_totals",
            "pending_order_code",
            "pending_payment_url",
            "pending_payment_created_utc",
            "pending_payment_method"
        };
                foreach (var k in checkoutKeys)
                {
                    try { Session.Remove(k); } catch { }
                }
            }
        }


    }
}
