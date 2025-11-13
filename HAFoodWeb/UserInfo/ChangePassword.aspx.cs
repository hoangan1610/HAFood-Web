using HAFoodWeb.Services;
using System;
using System.Web;
using System.Web.UI;

namespace HAFoodWeb.UserInfo
{
    public partial class ChangePassword : Page
    {
        private readonly IUserService _userService = new UserService();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                var token = Request.Cookies["AuthToken"]?.Value;
                if (string.IsNullOrEmpty(token))
                {
                    Response.Redirect("~/AuthPage/Login.aspx");
                }
            }
        }

        private void ShowToast(string message, string type)
        {
            string safeMessage = HttpUtility.JavaScriptStringEncode(message ?? string.Empty);
            string safeType = HttpUtility.JavaScriptStringEncode(type ?? string.Empty);

            // Chạy sau khi trang load xong
            string script = $@"
                window.addEventListener('load', function() {{
                    showToast('{safeMessage}', '{safeType}');
                }});";

            ClientScript.RegisterStartupScript(this.GetType(), "toastMessage", script, true);
        }

        protected async void btnSubmit_Click(object sender, EventArgs e)
        {
            string oldPass = txtOldPassword.Text.Trim();
            string newPass = txtNewPassword.Text.Trim();

            if (string.IsNullOrEmpty(oldPass) || string.IsNullOrEmpty(newPass))
            {
                ShowToast("Vui lòng nhập đầy đủ thông tin.", "error");
                return;
            }

            if (newPass.Length < 8)
            {
                ShowToast("Mật khẩu mới phải có ít nhất 8 ký tự.", "error");
                return;
            }

            if (newPass == oldPass)
            {
                ShowToast("Mật khẩu mới không được giống mật khẩu cũ.", "error");
                return;
            }

            var token = Request.Cookies["AuthToken"]?.Value;
            if (string.IsNullOrEmpty(token))
            {
                Response.Redirect("~/AuthPage/Login.aspx");
                return;
            }

            var result = await _userService.ChangePasswordAsync(token, oldPass, newPass);

            if (result != null && result.Success)
            {
                ShowToast("Thay đổi mật khẩu thành công!", "success");

                txtOldPassword.Text = "";
                txtNewPassword.Text = "";

                ClientScript.RegisterStartupScript(
                    this.GetType(),
                    "redirectUserProfile",
                    "setTimeout(function(){ window.location.href='/UserInfo/UserProfile.aspx'; }, 3000);",
                    true
                );
            }
            else
            {
                ShowToast("Mật khẩu hiện tại không đúng, vui lòng thử lại !", "error");
            }
        }
    }
}
