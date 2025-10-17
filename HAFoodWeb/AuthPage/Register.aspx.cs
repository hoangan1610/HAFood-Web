using System;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using HAFoodWeb.BLL;
using System.Diagnostics;
using System.Web;

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
                // Xóa lỗi cũ
                lblFullNameError.Text = "";
                lblEmailError.Text = "";
                lblPasswordError.Text = "";
                lblPhoneError.Text = "";

                // Lấy dữ liệu từ input
                string fullName = txtFullName.Text.Trim();
                string email = txtEmail.Text.Trim();
                string password = txtPassword.Text.Trim();
                string phone = txtPhone.Text.Trim();

                bool isValid = true;

                // Kiểm tra từng trường
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

                Debug.WriteLine("=== Register START ===");
                Debug.WriteLine($"FullName={fullName}, Email={email}, Phone={phone}");

                bool isRegistered = await userBLL.RegisterViaApi(fullName, email, password, phone);

                Debug.WriteLine("RegisterViaApi result = " + isRegistered);

                if (isRegistered)
                {
                    Session["OTPEmail"] = email;
                    string otpUrl = "OTP.aspx?email=" + HttpUtility.UrlEncode(email);
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
                Debug.WriteLine("Register_Click Exception: " + ex.Message);
                if (ex.InnerException != null)
                    Debug.WriteLine("Inner: " + ex.InnerException.Message);

                lblEmailError.Text = "Có lỗi xảy ra trong quá trình đăng ký. Vui lòng thử lại sau.";
            }
        }
    }
}