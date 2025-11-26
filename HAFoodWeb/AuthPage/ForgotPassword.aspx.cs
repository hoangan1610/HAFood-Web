using System;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.UI;
using HAFoodWeb.BLL;

namespace HAFoodWeb.AuthPage
{
    public partial class ForgotPassword : Page
    {
        private UserBLL userBLL;

        protected void Page_Load(object sender, EventArgs e)
        {
            userBLL = new UserBLL();
        }

        /// <summary>
        /// Gọi JS showToast(message, type) – type: "success" hoặc "error"
        /// </summary>
        private void ShowToast(string message, string type)
        {
            string safeMessage = (message ?? string.Empty)
                .Replace("'", "\\'")
                .Replace("\r", " ")
                .Replace("\n", " ");
            string safeType = (type == "success") ? "success" : "error";

            string script = $"showToast('{safeMessage}', '{safeType}');";
            ClientScript.RegisterStartupScript(
                this.GetType(),
                Guid.NewGuid().ToString(),   // key unique để không bị đè
                script,
                true
            );
        }

        protected async void btnConfirmEmail_Click(object sender, EventArgs e)
        {
            try
            {
                string email = txtEmail.Text.Trim();
                lblMessage.Text = ""; // giữ compat nhưng không dùng nữa

                if (string.IsNullOrEmpty(email))
                {
                    ShowToast("Vui lòng nhập email.", "error");
                    return;
                }

                if (!Regex.IsMatch(email, @"^[^@\s]+@[^@\s]+\.[^@\s]+$"))
                {
                    ShowToast("Email không hợp lệ.", "error");
                    return;
                }

                int? otpId = await userBLL.ForgotPasswordViaApi(email);

                if (otpId.HasValue)
                {
                    // Email tồn tại → lưu session + thông báo thành công
                    Session["ResetEmail"] = email;
                    Session["OtpId"] = otpId.Value;

                    ShowToast("Xác thực thành công", "success");

                    // Redirect sang OTPForgotPassword sau 1 giây để user kịp thấy toast
                    string url = $"~/AuthPage/OTPForgotPassword.aspx?email={Server.UrlEncode(email)}&otpId={otpId.Value}";
                    string script = $"setTimeout(function(){{ window.location = '{ResolveUrl(url)}'; }}, 1000);";
                    ClientScript.RegisterStartupScript(this.GetType(), "redirectOtpForgot", script, true);
                }
                else
                {
                    // Email không tồn tại
                    ShowToast("Email không tồn tại", "error");
                }
            }
            catch (Exception)
            {
                ShowToast("Có lỗi xảy ra. Vui lòng thử lại.", "error");
            }
        }
    }
}
