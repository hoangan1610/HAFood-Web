using System;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Web.UI;
using HAFoodWeb.BLL;

namespace HAFoodWeb.AuthPage
{
    public partial class Login : System.Web.UI.Page
    {
        private UserBLL userBLL;

        protected void Page_Load(object sender, EventArgs e)
        {
            userBLL = new UserBLL();

            if (!IsPostBack)
            {
                // Nếu đã đăng nhập thì chuyển về trang chủ
                if (Session["UserId"] != null)
                {
                    Response.Redirect("~/HomePage/HomePage.aspx");
                }

                ClearErrorLabels();
            }
        }

        protected async void btnLogin_Click(object sender, EventArgs e)
        {
            ClearErrorLabels();

            string email = txtEmail.Text.Trim();
            string password = txtPassword.Text.Trim();
            bool isValid = true;

            // Validate email
            if (string.IsNullOrEmpty(email))
            {
                lblEmailError.Text = "Vui lòng nhập email!";
                isValid = false;
            }
            else if (!IsValidEmail(email))
            {
                lblEmailError.Text = "Email không hợp lệ!";
                isValid = false;
            }

            // Validate password
            if (string.IsNullOrEmpty(password))
            {
                lblPasswordError.Text = "Vui lòng nhập mật khẩu!";
                isValid = false;
            }
            else if (password.Length < 8)
            {
                lblPasswordError.Text = "Mật khẩu phải có ít nhất 8 ký tự!";
                isValid = false;
            }

            if (!isValid) return;

            try
            {
                bool loginSuccess = await userBLL.LoginViaApi(email, password);

                if (loginSuccess)
                {
                    Session["UserEmail"] = email;
                    // Nếu API trả về token hoặc userId, bạn có thể mở rộng lấy thêm ở đây
                    Response.Redirect("~/HomePage/HomePage.aspx");
                }
                else
                {
                    lblLoginError.Text = "Email hoặc mật khẩu không đúng!";
                }
            }
            catch (Exception ex)
            {
                lblLoginError.Text = "Login failed: " + ex.Message;
            }
        }

        private void ClearErrorLabels()
        {
            lblEmailError.Text = "";
            lblPasswordError.Text = "";
            lblLoginError.Text = "";
        }

        private bool IsValidEmail(string email)
        {
            try
            {
                var regex = new Regex(@"^[^@\s]+@[^@\s]+\.[^@\s]+$");
                return regex.IsMatch(email);
            }
            catch
            {
                return false;
            }
        }
    }
}