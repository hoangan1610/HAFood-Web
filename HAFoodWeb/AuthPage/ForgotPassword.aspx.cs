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

        protected async void btnConfirmEmail_Click(object sender, EventArgs e)
        {
            try
            {
                string email = txtEmail.Text.Trim();
                lblMessage.Text = ""; // reset message
                bool isValid = true;

                // 1️⃣ Kiểm tra email rỗng
                if (string.IsNullOrEmpty(email))
                {
                    lblMessage.Text = "Vui lòng nhập email.";
                    isValid = false;
                }
                // 2️⃣ Kiểm tra định dạng email
                else if (!Regex.IsMatch(email, @"^[^@\s]+@[^@\s]+\.[^@\s]+$"))
                {
                    lblMessage.Text = "Email không hợp lệ.";
                    isValid = false;
                }

                if (!isValid)
                    return;

                // Gọi API: giờ trả otpId nếu thành công, null nếu thất bại
                int? otpId = await userBLL.ForgotPasswordViaApi(email);

                if (otpId.HasValue)
                {
                    // Lưu email và otpId vào Session để dùng cho các bước sau
                    Session["ResetEmail"] = email;
                    Session["OtpId"] = otpId.Value;

                    // Redirect kèm query string làm fallback
                    string url = $"~/AuthPage/OTPForgotPassword.aspx?email={Server.UrlEncode(email)}&otpId={otpId.Value}";
                    Response.Redirect(url, false);
                    Context.ApplicationInstance.CompleteRequest();
                }
                else
                {
                    lblMessage.Text = "Email không tồn tại hoặc có lỗi xảy ra. Vui lòng thử lại.";
                }
            }
            catch (Exception)
            {
                lblMessage.Text = "Có lỗi xảy ra. Vui lòng thử lại.";
            }
        }
    }
}