using System;
using System.Text.RegularExpressions;
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

            bool result = await userBLL.ForgotPasswordViaApi(email);

            if (result)
            {
                Session["ResetEmail"] = email;
                string otpUrl = "~/AuthPage/OTPForgotPassword.aspx";
                Response.Redirect(otpUrl, false);
                Context.ApplicationInstance.CompleteRequest();
            }
            else
            {
                lblMessage.Text = "Email không tồn tại hoặc có lỗi xảy ra. Vui lòng thử lại.";
            }
        }
    }
}
