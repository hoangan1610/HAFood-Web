using System;
using System.Web;
using HAFoodWeb.Services;

namespace HAFoodWeb.Control
{
    public partial class Header : System.Web.UI.UserControl
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                this.DataBind(); // cần cho <%# ... %> trong data-*
                var token = Request.Cookies["AuthToken"]?.Value;
                guestDropdown.Visible = string.IsNullOrEmpty(token);
                authDropdown.Visible = !string.IsNullOrEmpty(token);
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
            // Chuyển hướng về trang chủ
            Response.Redirect("~/HomePage/HomePage.aspx", false);
            Context.ApplicationInstance.CompleteRequest();
        }
    }
}