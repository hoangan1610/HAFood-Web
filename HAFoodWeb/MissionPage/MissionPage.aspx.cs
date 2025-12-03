using System;
using System.Web.UI;

namespace HAFoodWeb.MissionPage
{
    public partial class MissionPage : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Nếu cần, có thể check login rồi redirect về trang Login
            // if (Session["JwtToken"] == null) Response.Redirect("~/Account/Login.aspx");
        }
    }
}
