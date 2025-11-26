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
        private int? otpId = null;

        protected void Page_Load(object sender, EventArgs e)
        {
            userBLL = new UserBLL();

            if (!IsPostBack)
            {
                lblInfo.Text = "Vui lòng nhập mật khẩu mới";
            }

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

        private void ShowToast(string message, string type)
        {
            string safeMessage = (message ?? string.Empty)
                .Replace("'", "\\'")
                .Replace("\r", " ")
                .Replace("\n", " ");
            string safeType = type == "success" ? "success" : "error";
            string script = $"showToast('{safeMessage}', '{safeType}');";
            ClientScript.RegisterStartupScript(this.GetType(), Guid.NewGuid().ToString(), script, true);
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

            lblNewPasswordError.Text = "";
            lblConfirmPasswordError.Text = "";
            lblSuccess.Text = "";

            bool hasError = false;

            if (string.IsNullOrEmpty(newPass))
            {
                ShowToast("Vui lòng nhập mật khẩu mới.", "error");
                hasError = true;
            }
            else if (newPass.Length < 8)
            {
                ShowToast("Mật khẩu phải có ít nhất 8 ký tự.", "error");
                hasError = true;
            }

            if (string.IsNullOrEmpty(confirmPass))
            {
                ShowToast("Vui lòng nhập lại mật khẩu xác nhận.", "error");
                hasError = true;
            }
            else if (newPass != confirmPass)
            {
                ShowToast("Mật khẩu xác nhận không khớp.", "error");
                hasError = true;
            }

            if (hasError) return;

            try
            {
                bool success = await userBLL.ResetPasswordConfirmViaApi(otpId.Value, newPass);
                if (success)
                {
                    ShowToast("✅ Bạn đã đổi mật khẩu thành công. Đang chuyển hướng...", "success");
                    string script = "setTimeout(function(){ window.location = 'Login.aspx'; }, 2000);";
                    ClientScript.RegisterStartupScript(this.GetType(), "redirectLogin", script, true);
                }
                else
                {
                    ShowToast("Đổi mật khẩu thất bại. Vui lòng thử lại.", "error");
                }
            }
            catch
            {
                ShowToast("Có lỗi xảy ra. Vui lòng thử lại sau.", "error");
            }
        }
    }
}
