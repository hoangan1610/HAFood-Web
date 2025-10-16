using System;
using System.Diagnostics;
using System.Threading.Tasks;
using System.Web.UI;
using HAFoodWeb.BLL;

namespace HAFoodWeb.AuthPage
{
    public partial class OTPForgotPassword : Page
    {
        protected string Email;
        private UserBLL userBLL;

        protected void Page_Load(object sender, EventArgs e)
        {
            userBLL = new UserBLL();

            Debug.WriteLine("=== OTPForgotPassword Page_Load ===");

            string sessionEmail = Session["ResetEmail"] as string;
            string queryEmail = Request.QueryString["email"];
            Email = !string.IsNullOrEmpty(sessionEmail) ? sessionEmail : null;

            Debug.WriteLine($"ResetEmail from Session = {sessionEmail}");
            Debug.WriteLine($"Final Email used = {Email}");

            if (!string.IsNullOrEmpty(Email))
            {
                lblEmailInfo.Text = $"Mã OTP đã được gửi tới email: <b>{Email}</b>";
            }
            else
            {
                lblEmailInfo.Text = "";
                lblError.Text = "⚠️ Không xác định được email. Vui lòng thử lại.";
                btnVerifyOtp.Enabled = false;
                btnResendOtp.Enabled = false;
                return;
            }

            if (!IsPostBack)
            {
                btnVerifyOtp.Enabled = true;
                btnResendOtp.Enabled = false;
                ClientScript.RegisterStartupScript(this.GetType(), "startTimer", "startResendCountdown();", true);
            }
        }

        protected async Task VerifyOtpAsync()
        {
            lblError.Text = "";
            lblSuccess.Text = "";

            string otpCode = txtOtp.Text?.Trim();
            Debug.WriteLine($"VerifyOtpAsync: Email={Email}, OTP={otpCode}");

            if (string.IsNullOrEmpty(otpCode))
            {
                lblError.Text = "Vui lòng nhập mã OTP.";
                return;
            }

            // ✅ Chỉ thay đổi API verify cho forgot password
            bool verified = await userBLL.VerifyForgotPasswordOtpViaApi(Email, otpCode);
            Debug.WriteLine("VerifyForgotPasswordOtpViaApi result = " + verified);

            if (verified)
            {
                lblSuccess.Text = "✅ Xác thực thành công! Chuyển đến trang đặt lại mật khẩu...";
                string script = "setTimeout(function(){ window.location='ResetPassword.aspx'; }, 2000);";
                ClientScript.RegisterStartupScript(this.GetType(), "redirect", script, true);
            }
            else
            {
                lblError.Text = "❌ OTP không hợp lệ hoặc đã hết hạn. Vui lòng thử lại.";
            }
        }

        protected async void btnVerifyOtp_Click(object sender, EventArgs e)
        {
            try
            {
                await VerifyOtpAsync();
            }
            catch (Exception ex)
            {
                Debug.WriteLine("btnVerifyOtp_Click Exception: " + ex.ToString());
                lblError.Text = "❌ Có lỗi xảy ra. Vui lòng thử lại.";
            }
        }

        protected async Task ResendOtpAsync()
        {
            lblError.Text = "";
            lblSuccess.Text = "";

            string deviceUuid = Session["DeviceUuid"] as string;
            if (string.IsNullOrEmpty(deviceUuid))
            {
                deviceUuid = Guid.NewGuid().ToString();
                Session["DeviceUuid"] = deviceUuid;
            }

            // ✅ Dùng chung API resend cũ
            bool result = await userBLL.ResendOtpViaApi(Email, deviceUuid);

            if (result)
            {
                lblSuccess.Text = "✅ Mã OTP mới đã được gửi đến email của bạn.";
                btnResendOtp.Enabled = false;
                ClientScript.RegisterStartupScript(this.GetType(), "startTimer", "startResendCountdown();", true);
            }
            else
            {
                lblError.Text = "❌ Gửi lại OTP thất bại. Vui lòng thử lại sau.";
            }
        }

        protected async void btnResendOtp_Click(object sender, EventArgs e)
        {
            try
            {
                await ResendOtpAsync();
            }
            catch (Exception ex)
            {
                Debug.WriteLine("btnResendOtp_Click Exception: " + ex.ToString());
                lblError.Text = "❌ Có lỗi xảy ra. Vui lòng thử lại.";
            }
        }
    }
}