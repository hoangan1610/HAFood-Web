using System;
using System.Threading.Tasks;
using System.Web;
using System.Web.UI;
using HAFoodWeb.BLL;

namespace HAFoodWeb.AuthPage
{
    public partial class ResetPassword : Page
    {
        private UserBLL userBLL;
        private int? otpId = null; // otpId cần thiết cho API

        protected void Page_Load(object sender, EventArgs e)
        {
            userBLL = new UserBLL();

            if (!IsPostBack)
            {
                lblInfo.Text = "Vui lòng nhập mật khẩu mới";
            }

            // Lấy otpId từ Session hoặc QueryString
            object s = Session["OtpId"] ?? Session["otpId"] ?? Session["OTPId"];
            if (s != null && int.TryParse(s.ToString(), out int parsedSessionOtp))
            {
                otpId = parsedSessionOtp;
            }

            if (!otpId.HasValue)
            {
                string q = Request.QueryString["otpId"];
                if (!string.IsNullOrEmpty(q) && int.TryParse(q, out int parsedQueryOtp))
                {
                    otpId = parsedQueryOtp;
                }
            }
        }

        protected void btnConfirm_Click(object sender, EventArgs e)
        {
            Page.RegisterAsyncTask(new PageAsyncTask(async ct =>
            {
                await HandleResetAsync();
            }));
            Page.ExecuteRegisteredAsyncTasks();
        }

        private async Task HandleResetAsync()
        {
            string newPass = txtNewPassword.Text?.Trim() ?? "";
            string confirmPass = txtConfirmPassword.Text?.Trim() ?? "";

            // Reset lỗi trước mỗi lần kiểm tra
            lblNewPasswordError.Text = "";
            lblConfirmPasswordError.Text = "";
            lblSuccess.Text = "";

            bool hasError = false;

            if (string.IsNullOrEmpty(newPass))
            {
                lblNewPasswordError.Text = "Vui lòng nhập mật khẩu mới.";
                hasError = true;
            }
            else if (newPass.Length < 8)
            {
                lblNewPasswordError.Text = "Mật khẩu phải có ít nhất 8 ký tự.";
                hasError = true;
            }

            if (string.IsNullOrEmpty(confirmPass))
            {
                lblConfirmPasswordError.Text = "Vui lòng nhập lại mật khẩu xác nhận.";
                hasError = true;
            }
            else if (newPass != confirmPass)
            {
                lblConfirmPasswordError.Text = "Mật khẩu xác nhận không khớp.";
                hasError = true;
            }

            if (hasError) return;

            try
            {
                bool success = await userBLL.ResetPasswordConfirmViaApi(otpId.Value, newPass);
                if (success)
                {
                    lblSuccess.Text = "✅ Bạn đã đổi mật khẩu thành công. Đang chuyển hướng...";
                    string script = "setTimeout(function(){ window.location = 'Login.aspx'; }, 2000);";
                    ClientScript.RegisterStartupScript(this.GetType(), "redirectLogin", script, true);
                }
                else
                {
                    lblNewPasswordError.Text = "Đổi mật khẩu thất bại. Vui lòng thử lại.";
                }
            }
            catch
            {
                lblNewPasswordError.Text = "Có lỗi xảy ra. Vui lòng thử lại sau.";
            }
        }
    }
}