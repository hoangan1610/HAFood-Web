using System;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using HAFoodWeb.BLL;

namespace HAFoodWeb.AuthPage
{
    public partial class Register : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected async void btnRegister_Click(object sender, EventArgs e)
        {
            try
            {
                lblFullNameError.Text = "";
                lblEmailError.Text = "";
                lblPasswordError.Text = "";
                lblPhoneError.Text = "";

                string fullName = txtFullName.Text.Trim();
                string email = txtEmail.Text.Trim();
                string password = txtPassword.Text.Trim();
                string phone = txtPhone.Text.Trim();

                bool isValid = true;

                if (string.IsNullOrEmpty(fullName))
                {
                    lblFullNameError.Text = "Vui lòng nhập họ tên.";
                    isValid = false;
                }

                if (string.IsNullOrEmpty(email))
                {
                    lblEmailError.Text = "Vui lòng nhập email.";
                    isValid = false;
                }
                else if (!Regex.IsMatch(email, @"^[^@\s]+@[^@\s]+\.[^@\s]+$"))
                {
                    lblEmailError.Text = "Email không hợp lệ.";
                    isValid = false;
                }

                if (string.IsNullOrEmpty(password))
                {
                    lblPasswordError.Text = "Vui lòng nhập mật khẩu.";
                    isValid = false;
                }
                else if (password.Length < 8)
                {
                    lblPasswordError.Text = "Mật khẩu phải dài ít nhất 8 ký tự.";
                    isValid = false;
                }

                if (string.IsNullOrEmpty(phone))
                {
                    lblPhoneError.Text = "Vui lòng nhập số điện thoại.";
                    isValid = false;
                }
                else if (!Regex.IsMatch(phone, @"^0\d{9}$"))
                {
                    lblPhoneError.Text = "Số điện thoại phải gồm 10 chữ số và bắt đầu bằng 0.";
                    isValid = false;
                }

                if (!isValid)
                    return;

                UserBLL userBLL = new UserBLL();
                bool isRegistered = await userBLL.RegisterViaApi(fullName, email, password, phone);

                if (isRegistered)
                {
                    string otpUrl = $"OTP.aspx";
                    Response.Redirect(otpUrl, false);
                    Context.ApplicationInstance.CompleteRequest();
                }
                else
                {
                    lblEmailError.Text = "Đăng ký thất bại. Email có thể đã được sử dụng.";
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Register_Click Exception: " + ex.Message);
                if (ex.InnerException != null)
                    System.Diagnostics.Debug.WriteLine("Inner: " + ex.InnerException.Message);

                lblEmailError.Text = "Có lỗi xảy ra trong quá trình đăng ký. Vui lòng thử lại sau.";
            }
        }
    }
}
