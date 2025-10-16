using System;
using System.Web;
using HAFoodWeb.Services;

namespace HAFoodWeb
{
    public partial class UserProfile : System.Web.UI.Page
    {
        private readonly IUserService _userService = new UserService();

        protected async void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                var token = Request.Cookies["AuthToken"]?.Value;
                if (string.IsNullOrEmpty(token))
                {
                    Response.Redirect("~/AuthPage/Login.aspx");
                    return;
                }

                // ✅ Lấy thông tin user từ API
                var resp = await _userService.GetProfileAsync(token);
                if (resp != null && resp.user != null)
                {
                    var u = resp.user;
                    lblFullName.Text = u.fullName;
                    lblPhone.Text = u.phone;
                    lblEmail.Text = u.email;
                    imgAvatar.ImageUrl = string.IsNullOrWhiteSpace(u.avatar)
                        ? "/assets/default-avatar.png"
                        : u.avatar;
                }
                else
                {
                    // Nếu không lấy được thông tin → về login
                    Response.Redirect("~/AuthPage/Login.aspx");
                }
            }
        }

        protected void btnEdit_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/UserInfo/UserProfileEdit.aspx");
        }
    }
}