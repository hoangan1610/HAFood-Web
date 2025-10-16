using HAFoodWeb.BLL;
using System;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Web;
using System.Web.UI;

namespace HAFoodWeb.AuthPage
{
    public partial class Login : System.Web.UI.Page
    {
        private UserBLL userBLL;

        protected void Page_Load(object sender, EventArgs e)
        {
            userBLL = new UserBLL();

            if (!IsPostBack && Session["UserId"] != null)
            {
                Response.Redirect("~/HomePage/HomePage.aspx");
            }

            ClearErrorLabels();
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            // Đăng ký async task
            RegisterAsyncTask(new PageAsyncTask(LoginAsync));
        }

        private async Task LoginAsync(System.Threading.CancellationToken ct)
        {
            ClearErrorLabels();

            string email = txtEmail.Text.Trim();
            string password = txtPassword.Text.Trim();
            bool isValid = true;

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
                string deviceUuid = GetOrCreateDeviceUuid();
                string ip = GetClientIp();

                var loginResult = await userBLL.LoginViaApi(email, password, deviceUuid, ip);

                // Debug log
                System.Diagnostics.Debug.WriteLine("loginResult: " + (loginResult == null ? "NULL" : "NOT NULL"));

                if (loginResult != null)
                {
                    try
                    {
                        // Lấy thông tin từ response
                        string userInfoId = loginResult.userInfoId?.ToString();
                        string jwtToken = loginResult.jwtToken?.ToString();

                        System.Diagnostics.Debug.WriteLine($"UserInfoId: {userInfoId}, JwtToken: {jwtToken}");

                        // Kiểm tra userInfoId có hợp lệ không
                        if (!string.IsNullOrEmpty(userInfoId))
                        {
                            // Lưu thông tin vào Session
                            Session["UserId"] = userInfoId;
                            Session["UserEmail"] = email;
                            Session["JwtToken"] = jwtToken;

                            // Có thể cần lấy thêm thông tin user từ API khác nếu cần username, phone
                            // Hoặc lưu tạm email làm username
                            Session["Username"] = email.Split('@')[0]; // Lấy phần trước @ làm username tạm

                            System.Diagnostics.Debug.WriteLine("Login thành công, redirect về HomePage");

                            // Redirect an toàn trong async
                            Response.Redirect("~/HomePage/HomePage.aspx", false);
                            Context.ApplicationInstance.CompleteRequest();
                        }
                        else
                        {
                            System.Diagnostics.Debug.WriteLine("loginResult không có userInfoId hợp lệ");
                            lblLoginError.Text = "Email hoặc mật khẩu không đúng!";
                        }
                    }
                    catch (Exception parseEx)
                    {
                        System.Diagnostics.Debug.WriteLine("Error parsing loginResult: " + parseEx.Message);
                        lblLoginError.Text = "Lỗi xử lý thông tin đăng nhập!";
                    }
                }
                else
                {
                    System.Diagnostics.Debug.WriteLine("loginResult is NULL - login failed");
                    lblLoginError.Text = "Email hoặc mật khẩu không đúng!";
                }
            }
            catch (Exception ex)
            {
                lblLoginError.Text = "Đăng nhập thất bại: " + ex.Message;
                System.Diagnostics.Debug.WriteLine("Login Exception: " + ex.ToString());
            }
        }

        private string GetOrCreateDeviceUuid()
        {
            string cookieName = "HADeviceUuid";
            var cookie = Request.Cookies[cookieName];
            if (cookie != null && !string.IsNullOrWhiteSpace(cookie.Value))
                return cookie.Value;

            var newUuid = Guid.NewGuid().ToString();
            var newCookie = new HttpCookie(cookieName, newUuid)
            {
                HttpOnly = true,
                Secure = Request.IsSecureConnection,
                Expires = DateTime.UtcNow.AddYears(10)
            };
            Response.Cookies.Add(newCookie);
            return newUuid;
        }

        private string GetClientIp()
        {
            string xff = Request.ServerVariables["HTTP_X_FORWARDED_FOR"];
            if (!string.IsNullOrEmpty(xff))
            {
                var ipList = xff.Split(',');
                if (ipList.Length > 0 && !string.IsNullOrEmpty(ipList[0]))
                    return ipList[0].Trim();
            }
            string ip = Request.ServerVariables["REMOTE_ADDR"] ?? Request.UserHostAddress;
            return ip ?? "127.0.0.1";
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