using HAFoodWeb.Models;
using HAFoodWeb.Services;
using Newtonsoft.Json;
using System;
using System.Threading.Tasks;
using System.Web.UI;

namespace HAFoodWeb
{
    public partial class UserProfileEdit : Page
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
                    txtFullName.Text = profile.user.fullName;
                    txtEmail.Text = profile.user.email;
                    txtPhone.Text = profile.user.phone;

                    string avatarUrl = string.IsNullOrEmpty(profile.user.avatar)
                        ? ResolveUrl("~/images/default-avatar.png")
                        : profile.user.avatar;

                    if (!avatarUrl.StartsWith("http", StringComparison.OrdinalIgnoreCase))
                    {
                        avatarUrl = "https://api.hafood.id.vn" + avatarUrl;
                    }

                    imgAvatar.ImageUrl = avatarUrl;
                }
            }
        }

        protected async void btnSave_Click(object sender, EventArgs e)
        {
            var token = Request.Cookies["AuthToken"]?.Value;
            if (string.IsNullOrEmpty(token)) return;

            // 1️⃣ Upload ảnh nếu có chọn
            if (fileAvatar.HasFile)
            {
                var avatarResult = await _userService.UpdateAvatarAsync(token, fileAvatar);
                if (!avatarResult.Success)
                {
                    lblMessage.Text = "❌ Cập nhật ảnh thất bại.";
                    lblMessage.CssClass = "error-message";
                    return;
                }

                // 👉 Gọi lại API profile để lấy đường dẫn avatar mới
                var updatedProfile = await _userService.GetProfileAsync(token);
                if (updatedProfile != null && updatedProfile.user != null && !string.IsNullOrEmpty(updatedProfile.user.avatar))
                {
                    string avatarUrl = updatedProfile.user.avatar;

                    if (!avatarUrl.StartsWith("http", StringComparison.OrdinalIgnoreCase))
                    {
                        avatarUrl = "https://api.hafood.id.vn" + avatarUrl;
                    }

                    imgAvatar.ImageUrl = avatarUrl + "?t=" + DateTime.Now.Ticks;
                }
            }

            // 2️⃣ Cập nhật thông tin
            var updateRequest = new UserUpdateRequest
            {
                fullName = txtFullName.Text.Trim(),
                phone = txtPhone.Text.Trim(),
            };

            var profileResult = await _userService.UpdateProfileAsync(token, updateRequest);

            if (profileResult != null && profileResult.Success)
            {
                lblMessage.Text = "✅ Bạn đã thay đổi thông tin thành công!";
                lblMessage.CssClass = "success-message";

                // ✅ Redirect nhẹ về trang profile sau 1s
                ScriptManager.RegisterStartupScript(this, GetType(), "redirectProfile",
                    "setTimeout(function(){ window.location.href = '../UserInfo/UserProfile.aspx?t=' + new Date().getTime(); }, 1000);", true);
            }
            else
            {
                lblMessage.Text = "❌ Cập nhật thông tin thất bại, vui lòng thử lại.";
                lblMessage.CssClass = "error-message";
            }
        }
    }
}