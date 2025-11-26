using System;
using System.Threading.Tasks;
using HAFoodWeb.BLL;
using System.Diagnostics;
using System.Web;
using System.Web.UI;

namespace HAFoodWeb.AuthPage
{
    public partial class OTP : Page
    {
        protected string Email;
        private UserBLL userBLL;

        protected void Page_Load(object sender, EventArgs e)
        {
            userBLL = new UserBLL();

            Debug.WriteLine("=== OTP Page_Load ===");
            string sessionEmail = Session["RegisterEmail"] as string;
            string queryEmail = Request.QueryString["email"];

            Email = !string.IsNullOrEmpty(sessionEmail)
                ? sessionEmail
                : !string.IsNullOrEmpty(queryEmail)
                    ? HttpUtility.UrlDecode(queryEmail)
                    : null;

            Debug.WriteLine($"RegisterEmail from Session = {sessionEmail}");
            Debug.WriteLine($"QueryString Email = {queryEmail}");
            Debug.WriteLine($"Final Email used = {Email}");

            if (!string.IsNullOrEmpty(Email))
            {
                Session["OTPEmail"] = Email;
                lblEmailInfo.Text = $"Mã xác thực đã được gửi qua email: <b>{Email}</b>";
            }
            else
            {
                lblEmailInfo.Text = "";
                ShowToast("⚠️ Không xác định được email. Vui lòng đăng ký lại.", "error");
                btnVerifyOtp.Enabled = false;
                btnResendOtp.Enabled = false;
                return;
            }

            if (!IsPostBack)
            {
                Debug.WriteLine("Page_Load: First load, start resend timer.");
                btnVerifyOtp.Enabled = true;
                btnResendOtp.Enabled = false;
                ClientScript.RegisterStartupScript(this.GetType(), "startTimer", "startResendCountdown();", true);
            }
        }

        private void ShowToast(string message, string type)
        {
            string safeMessage = (message ?? string.Empty)
                .Replace("'", "\\'")
                .Replace("\r", " ")
                .Replace("\n", " ");
            string safeType = type == "success" ? "success" : "error";
            string script = $"showToast('{safeMessage}', '{safeType}');";
            ClientScript.RegisterStartupScript(this.GetType(), Guid.NewGuid().ToString(), script, true);
        }

        protected async Task VerifyOtpAsync()
        {
            lblError.Text = "";
            lblSuccess.Text = "";

            string otpCode = txtOtp.Text?.Trim();
            Debug.WriteLine($"VerifyOtpAsync: Email={Email}, OTP={otpCode}");

            if (string.IsNullOrEmpty(otpCode))
            {
                ShowToast("Vui lòng nhập mã OTP.", "error");
                return;
            }

            if (string.IsNullOrEmpty(Email))
            {
                ShowToast("Không xác định được email. Vui lòng quay lại bước đăng ký.", "error");
                return;
            }

            try
            {
                var result = await userBLL.VerifyRegisterOtpViaApi(Email, otpCode);

                Debug.WriteLine($"VerifyRegisterOtpViaApi: Verified={result.Verified}, OtpId={result.OtpId}, Message={result.Message}");

                if (result.Verified)
                {
                    ShowToast("✅ Xác thực thành công! Bạn sẽ được chuyển đến trang đăng nhập...", "success");
                    string script = "setTimeout(function(){ window.location='Login.aspx'; }, 1500);";
                    ClientScript.RegisterStartupScript(this.GetType(), "redirect", script, true);
                }
                else
                {
                    string msg = !string.IsNullOrEmpty(result.Message)
                        ? "❌ " + result.Message
                        : "❌ Mã OTP không hợp lệ hoặc đã hết hạn.";
                    ShowToast(msg, "error");
                    btnVerifyOtp.Enabled = true;
                    btnVerifyOtp.Text = "Xác minh OTP";
                }
            }
            catch (Exception ex)
            {
                Debug.WriteLine("VerifyOtpAsync Exception: " + ex.ToString());
                ShowToast("❌ Có lỗi xảy ra trong quá trình xác thực. Vui lòng thử lại.", "error");
                btnVerifyOtp.Enabled = true;
                btnVerifyOtp.Text = "Xác minh OTP";
            }
        }

        protected async void btnVerifyOtp_Click(object sender, EventArgs e)
        {
            Debug.WriteLine("btnVerifyOtp_Click triggered.");
            Debug.WriteLine("txtOtp.Text = " + txtOtp.Text);
            try
            {
                await VerifyOtpAsync();
                Debug.WriteLine("btnVerifyOtp_Click completed.");
            }
            catch (Exception ex)
            {
                Debug.WriteLine("btnVerifyOtp_Click Exception: " + ex.ToString());
                ShowToast("❌ Có lỗi xảy ra. Vui lòng thử lại.", "error");
                btnVerifyOtp.Enabled = true;
                btnVerifyOtp.Text = "Xác minh OTP";
            }
        }

        protected async Task ResendOtpAsync()
        {
            lblError.Text = "";
            lblSuccess.Text = "";

            Debug.WriteLine("ResendOtpAsync: Resending OTP for Email=" + Email);

            string deviceUuid = Session["DeviceUuid"] as string;
            if (string.IsNullOrEmpty(deviceUuid))
            {
                deviceUuid = Guid.NewGuid().ToString();
                Session["DeviceUuid"] = deviceUuid;
                Debug.WriteLine("Generated new DeviceUuid = " + deviceUuid);
            }

            bool result = await userBLL.ResendOtpViaApi(Email, deviceUuid);
            Debug.WriteLine("ResendOtpViaApi result = " + result);

            if (result)
            {
                ShowToast("✅ Mã OTP mới đã được gửi đến email của bạn.", "success");
                btnResendOtp.Enabled = false;
                ClientScript.RegisterStartupScript(this.GetType(), "startTimer", "startResendCountdown();", true);
            }
            else
            {
                ShowToast("❌ Gửi lại OTP thất bại. Vui lòng thử lại sau.", "error");
                btnResendOtp.Enabled = true;
                btnResendOtp.Text = "Gửi lại OTP";
            }
        }

        protected async void btnResendOtp_Click(object sender, EventArgs e)
        {
            Debug.WriteLine("btnResendOtp_Click triggered.");
            try
            {
                await ResendOtpAsync();
            }
            catch (Exception ex)
            {
                Debug.WriteLine("btnResendOtp_Click Exception: " + ex.ToString());
                ShowToast("❌ Có lỗi xảy ra. Vui lòng thử lại.", "error");
            }
        }
    }
}
