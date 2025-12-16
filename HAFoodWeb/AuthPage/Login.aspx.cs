using HAFoodWeb.BLL;
using System;
using System.Reflection;
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

            // UX
            txtEmail.Attributes["type"] = "email";
            txtEmail.Attributes["autocomplete"] = "email";
            txtPassword.Attributes["autocomplete"] = "current-password";

            if (!IsPostBack && Session["UserId"] != null)
            {
                Response.Redirect("~/HomePage/HomePage.aspx");
            }

            ClearErrorLabels();
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            RegisterAsyncTask(new PageAsyncTask(LoginAsync));
        }

        private async Task LoginAsync(System.Threading.CancellationToken ct)
        {
            ClearErrorLabels();

            string email = txtEmail.Text.Trim();
            string password = txtPassword.Text.Trim();
            bool isValid = true;

            // Validate Email
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

            // Validate Password
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

                bool success = TryGetBoolProp(loginResult, "success", "Success");
                int userInfoId = TryGetIntProp(loginResult, "userInfoId", "UserInfoId");
                string jwtToken = TryGetStringProp(loginResult, "jwtToken", "JwtToken");
                string code = TryGetStringProp(loginResult, "code", "Code");
                string message = TryGetStringProp(loginResult, "message", "Message");

                // ✅ Chỉ login OK khi success=true và userInfoId > 0
                if (success && userInfoId > 0)
                {
                    Session["UserId"] = userInfoId.ToString();
                    Session["UserEmail"] = email;
                    Session["JwtToken"] = jwtToken;
                    Session["Username"] = email.Contains("@") ? email.Split('@')[0] : email;

                    if (!string.IsNullOrEmpty(jwtToken))
                    {
                        var authCookie = new HttpCookie("AuthToken", jwtToken)
                        {
                            HttpOnly = true,
                            Secure = Request.IsSecureConnection,
                            Expires = DateTime.UtcNow.AddDays(7),
                            Path = "/"
                        };
                        Response.Cookies.Add(authCookie);
                    }

                    Response.Redirect("~/HomePage/HomePage.aspx", false);
                    Context.ApplicationInstance.CompleteRequest();
                    return;
                }

                // ❌ Login fail -> hiển thị dưới Email / Password theo code/message
                ApplyCredentialErrors(code, message);

                // Nếu API trả code/message quá chung chung -> gán lỗi cả 2 trường để user biết kiểm tra
                if (string.IsNullOrWhiteSpace(lblEmailError.Text) && string.IsNullOrWhiteSpace(lblPasswordError.Text))
                {
                    lblEmailError.Text = "Vui lòng kiểm tra lại email.";
                    lblPasswordError.Text = "Vui lòng kiểm tra lại mật khẩu.";
                }
            }
            catch (Exception ex)
            {
                // Lỗi hệ thống (network/API down/parse...)
                lblLoginError.Text = "Đăng nhập thất bại. Vui lòng thử lại sau!";
                System.Diagnostics.Debug.WriteLine("Login Exception: " + ex);
            }
        }

        private void ApplyCredentialErrors(string code, string message)
        {
            string c = (code ?? "").Trim().ToLowerInvariant();
            string m = (message ?? "").Trim().ToLowerInvariant();

            if (!string.IsNullOrEmpty(c))
            {
                if (c.Contains("email") || c.Contains("user_not_found") || c.Contains("account_not_found") || c.Contains("not_found"))
                {
                    lblEmailError.Text = "Email không tồn tại hoặc không đúng.";
                    txtEmail.Focus();
                    return;
                }

                if (c.Contains("password") || c.Contains("wrong_password") || c.Contains("invalid_password"))
                {
                    lblPasswordError.Text = "Mật khẩu không đúng.";
                    txtPassword.Focus();
                    return;
                }

                if (c.Contains("invalid_credentials") || c.Contains("invalid_login") || c.Contains("unauthorized"))
                {
                    lblEmailError.Text = "Email không đúng.";
                    lblPasswordError.Text = "Mật khẩu không đúng.";
                    return;
                }
            }

            // ===== Nếu CODE không rõ -> dựa vào MESSAGE =====
            if (!string.IsNullOrEmpty(m))
            {
                if (m.Contains("email") && (m.Contains("không tồn tại") || m.Contains("not found") || m.Contains("does not exist")))
                {
                    lblEmailError.Text = "Email không tồn tại hoặc không đúng.";
                    txtEmail.Focus();
                    return;
                }

                if ((m.Contains("mật khẩu") || m.Contains("password")) &&
                    (m.Contains("sai") || m.Contains("không đúng") || m.Contains("incorrect") || m.Contains("wrong") || m.Contains("invalid")))
                {
                    lblPasswordError.Text = "Mật khẩu không đúng.";
                    txtPassword.Focus();
                    return;
                }

                if (m.Contains("invalid") || m.Contains("credentials") || m.Contains("không đúng"))
                {
                    lblEmailError.Text = "Vui lòng kiểm tra lại email.";
                    lblPasswordError.Text = "Vui lòng kiểm tra lại mật khẩu.";
                    return;
                }
            }
        }

        private static string TryGetStringProp(object obj, params string[] propNames)
        {
            if (obj == null || propNames == null || propNames.Length == 0) return null;

            var t = obj.GetType();
            foreach (var name in propNames)
            {
                var p = t.GetProperty(name, BindingFlags.Public | BindingFlags.Instance | BindingFlags.IgnoreCase);
                if (p == null) continue;
                var val = p.GetValue(obj, null);
                if (val == null) continue;

                var s = val.ToString();
                if (!string.IsNullOrWhiteSpace(s)) return s;
            }
            return null;
        }

        private static bool TryGetBoolProp(object obj, params string[] propNames)
        {
            var s = TryGetStringProp(obj, propNames);
            if (string.IsNullOrWhiteSpace(s)) return false;

            bool b;
            if (bool.TryParse(s, out b)) return b;

            // nếu backend trả 0/1
            if (s == "1") return true;
            if (s == "0") return false;

            return false;
        }

        private static int TryGetIntProp(object obj, params string[] propNames)
        {
            var s = TryGetStringProp(obj, propNames);
            if (string.IsNullOrWhiteSpace(s)) return 0;

            int n;
            if (int.TryParse(s, out n)) return n;

            return 0;
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
                Expires = DateTime.UtcNow.AddYears(10),
                Path = "/"
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
            catch { return false; }
        }
    }
}
