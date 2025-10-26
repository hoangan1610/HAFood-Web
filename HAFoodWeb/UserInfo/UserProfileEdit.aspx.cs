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

            // --- Kiểm tra tên: không rỗng, không chứa ký tự đặc biệt hoặc số ---
            string fullName = txtFullName.Text?.Trim() ?? string.Empty;
            if (string.IsNullOrEmpty(fullName))
            {
                lblMessage.Text = "❌ Vui lòng nhập họ và tên.";
                lblMessage.CssClass = "error-message";
                return;
            }

            if (!System.Text.RegularExpressions.Regex.IsMatch(fullName, @"^[\p{L}\s]+$"))
            {
                lblMessage.Text = "❌ Tên không được chứa ký tự đặc biệt hoặc số.";
                lblMessage.CssClass = "error-message";
                return;
            }

            // --- Kiểm tra số điện thoại ---
            string phone = txtPhone.Text?.Trim() ?? string.Empty;
            if (string.IsNullOrEmpty(phone))
            {
                lblMessage.Text = "❌ Vui lòng nhập số điện thoại.";
                lblMessage.CssClass = "error-message";
                return;
            }

            if (phone.Length != 9)
            {
                lblMessage.Text = "❌ Số điện thoại phải gồm đúng 9 chữ số.";
                lblMessage.CssClass = "error-message";
                return;
            }

            if (!phone.StartsWith("0"))
            {
                lblMessage.Text = "❌ Số điện thoại phải bắt đầu bằng số 0.";
                lblMessage.CssClass = "error-message";
                return;
            }

            if (!System.Text.RegularExpressions.Regex.IsMatch(phone, @"^0\d{8}$"))
            {
                lblMessage.Text = "❌ Số điện thoại phải gồm 9 chữ số và bắt đầu bằng số 0.";
                lblMessage.CssClass = "error-message";
                return;
            }

            // 1️⃣ Upload ảnh nếu có chọn
            if (fileAvatar.HasFile)
            {
                var avatarResult = await _userService.UpdateAvatarAsync(token, fileAvatar);
                if (!avatarResult.Success)
                {
                    // giữ lỗi input hiển thị bên dưới form (không phải toast)
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
                fullName = fullName,
                phone = phone,
            };

            var profileResult = await _userService.UpdateProfileAsync(token, updateRequest);

            if (profileResult != null && profileResult.Success)
            {
                // ẩn server label lỗi nếu còn
                lblMessage.Text = string.Empty;

                // Hiển thị toast success (3s) và redirect nhẹ
                ScriptManager.RegisterStartupScript(this, GetType(), "showSuccess",
                    "showToast('Cập nhật thông tin thành công!', 'success');", true);

                ScriptManager.RegisterStartupScript(this, GetType(), "redirectProfile",
                    "setTimeout(function(){ window.location.href = '../UserInfo/UserProfile.aspx?t=' + new Date().getTime(); }, 1000);", true);
            }
            else
            {
                // Hiển thị toast error (3s)
                ScriptManager.RegisterStartupScript(this, GetType(), "showError",
                    "showToast('Cập nhật thông tin thất bại, vui lòng thử lại.', 'error');", true);
            }
        }
    }
}