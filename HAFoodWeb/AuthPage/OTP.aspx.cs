using System;
using System.Threading.Tasks;
using HAFoodWeb.BLL;
using System.Diagnostics;

namespace HAFoodWeb.AuthPage
{
    public partial class OTP : System.Web.UI.Page
    {
        protected string Email;
        private UserBLL userBLL;

        protected void Page_Load(object sender, EventArgs e)
        {
            userBLL = new UserBLL();
            Email = Session["OTPEmail"] as string;

            Debug.WriteLine("Page_Load: OTPEmail from Session = " + Email);

            if (string.IsNullOrEmpty(Email))
            {
                lblError.Text = "Không xác định được email. Vui lòng đăng ký lại.";
                btnVerifyOtp.Enabled = false;
                btnResendOtp.Enabled = false;
                return;
            }

            if (!IsPostBack)
            {
                // Bật nút Verify OTP, vô hiệu hóa Resend OTP 60s
                btnVerifyOtp.Enabled = true;
                btnResendOtp.Enabled = false;
                ClientScript.RegisterStartupScript(this.GetType(), "startTimer", "startResendCountdown();", true);
            }
        }

        protected async Task VerifyOtpAsync()
        {
            lblError.Text = "";
            lblSuccess.Text = "";
            string otpCode = txtOtp.Text.Trim();

            Debug.WriteLine($"VerifyOtpAsync: Email={Email}, OTP={otpCode}");

            if (string.IsNullOrEmpty(otpCode))
            {
                lblError.Text = "Vui lòng nhập mã OTP.";
                return;
            }

            bool result = await userBLL.VerifyOtpViaApi(Email, otpCode);

            Debug.WriteLine("VerifyOtpAsync: VerifyOtpViaApi result = " + result);

            if (result)
            {
                lblSuccess.Text = "Xác minh thành công! Chuyển đến trang đăng nhập...";
                string script = "setTimeout(function(){ window.location='Login.aspx?verify=success'; }, 2000);";
                ClientScript.RegisterStartupScript(this.GetType(), "redirect", script, true);
            }
            else
            {
                lblError.Text = "Mã OTP không đúng hoặc đã hết hạn. Vui lòng thử lại.";
            }
        }

        protected void btnVerifyOtp_Click(object sender, EventArgs e)
        {
            // Gọi async method và không chặn UI
            _ = VerifyOtpAsync();
        }

        protected async Task ResendOtpAsync()
        {
            lblError.Text = "";
            lblSuccess.Text = "";

            Debug.WriteLine("ResendOtpAsync: Resending OTP for Email=" + Email);

            bool result = await userBLL.ResendOtpViaApi(Email);

            Debug.WriteLine("ResendOtpAsync: ResendOtpViaApi result = " + result);

            if (result)
            {
                lblSuccess.Text = "Mã OTP mới đã được gửi đến email của bạn.";
                btnResendOtp.Enabled = false;
                ClientScript.RegisterStartupScript(this.GetType(), "startTimer", "startResendCountdown();", true);
            }
            else
            {
                lblError.Text = "Gửi lại OTP thất bại. Vui lòng thử lại sau.";
            }
        }

        protected void btnResendOtp_Click(object sender, EventArgs e)
        {
            _ = ResendOtpAsync();
        }
    }
}