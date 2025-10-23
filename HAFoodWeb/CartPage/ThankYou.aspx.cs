using System;
using System.Web.UI;

namespace HAFoodWeb.Pages
{
    public partial class ThankYou : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                var code = Request["code"];
                phCode.Visible = !string.IsNullOrWhiteSpace(code);
                if (phCode.Visible) lblCode.Text = code;

                // set link về trang chủ
                btnHome.HRef = ResolveUrl("~/HomePage/HomePage.aspx");
            }
        }

    }
}
