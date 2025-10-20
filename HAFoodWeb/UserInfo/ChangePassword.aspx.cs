using HAFoodWeb.Services;
using System;
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

        protected async void btnSubmit_Click(object sender, EventArgs e)
        {
            string oldPass = txtOldPassword.Text.Trim();
            string newPass = txtNewPassword.Text.Trim();

            // ✅ Kiểm tra dữ liệu đầu vào
            if (string.IsNullOrEmpty(oldPass) || string.IsNullOrEmpty(newPass))
            {
                lblMessage.Text = "<span class='error'>Vui lòng nhập đầy đủ thông tin.</span>";
                return;
            }

            if (newPass.Length < 8)
            {
                lblMessage.Text = "<span class='error'>Mật khẩu mới phải có ít nhất 8 ký tự.</span>";
                return;
            }

            if (newPass == oldPass)
            {
                lblMessage.Text = "<span class='error'>Mật khẩu mới không được giống mật khẩu cũ.</span>";
                return;
            }

            var token = Request.Cookies["AuthToken"]?.Value;
            if (string.IsNullOrEmpty(token))
            {
                Response.Redirect("~/AuthPage/Login.aspx");
                return;
            }

            // ✅ Gọi service đổi mật khẩu
            var result = await _userService.ChangePasswordAsync(token, oldPass, newPass);

            if (result != null && result.Success)
            {
                lblMessage.Text = "<span class='success'>Thay đổi mật khẩu thành công!</span>";
                txtOldPassword.Text = "";
                txtNewPassword.Text = "";
            }
            else
            {
                lblMessage.Text = $"<span class='error'>{result?.Message ?? "Thay đổi mật khẩu thất bại, mật khẩu cũ không đúng"}</span>";
            }
        }
    }
}