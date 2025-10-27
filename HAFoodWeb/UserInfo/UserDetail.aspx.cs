using HAFoodWeb.Services;
using System;

namespace HAFoodWeb.UserPage
{
    public partial class UserDetail : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session == null || Session["UserId"] == null)
            {
                Response.Redirect("~/AuthPage/Login.aspx");
                return;
            }

        
        }

        protected async void lnkLogout_Click(object sender, EventArgs e)
        {
            try
            {
                var token = Request?.Cookies["AuthToken"]?.Value;
                if (!string.IsNullOrEmpty(token))
                {
                    var userService = new UserService();
                    try
                    {
                        await userService.LogoutAsync(token).ConfigureAwait(false);
                    }
                    catch
                    {
                        // ignore service errors — vẫn tiếp tục xóa cookie & session
                    }
                }

                // Xóa cookie AuthToken (đặt expiry trong quá khứ)
                if (Request?.Cookies["AuthToken"] != null)
                {
                    var cookie = new System.Web.HttpCookie("AuthToken", "")
                    {
                        Expires = DateTime.UtcNow.AddDays(-1),
                        Path = "/"
                    };
                    Response.Cookies.Add(cookie);
                }

                try
                {
                    Session?.Clear();
                    Session?.Abandon();
                }
                catch { }

                // Redirect an toàn về trang chủ
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
