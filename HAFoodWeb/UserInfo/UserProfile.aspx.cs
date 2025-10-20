using HAFoodWeb.Models;
using HAFoodWeb.Services;
using System;
using System.Web.UI;

namespace HAFoodWeb
{
    public partial class UserProfile : Page
    {
        private readonly UserService _userService = new UserService();

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

                var profile = await _userService.GetProfileAsync(token);
                if (profile != null && profile.user != null)
                {
                    lblFullName.Text = profile.user.fullName;
                    lblEmail.Text = profile.user.email;
                    lblPhone.Text = profile.user.phone;

                    string avatarUrl = string.IsNullOrEmpty(profile.user.avatar)
                        ? ResolveUrl("~/images/default-avatar.png")
                        : profile.user.avatar;

                    // ✅ Nếu avatar trả về là đường dẫn tương đối → nối với domain
                    if (!avatarUrl.StartsWith("http", StringComparison.OrdinalIgnoreCase))
                    {
                        avatarUrl = "https://api.hafood.id.vn" + avatarUrl;
                    }

                    // ✅ Thêm timestamp để tránh cache ảnh cũ
                    imgAvatar.ImageUrl = avatarUrl + (avatarUrl.Contains("?") ? "&" : "?") + "t=" + DateTime.Now.Ticks;
                }
            }
        }

        protected void btnEdit_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/UserInfo/UserProfileEdit.aspx");
        }

        protected void btnChangePassword_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/UserInfo/ChangePassword.aspx");
        }
    }
}