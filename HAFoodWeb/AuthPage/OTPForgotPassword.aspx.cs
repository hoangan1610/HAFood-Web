using System;
using System.Diagnostics;
using System.Threading.Tasks;
using System.Web;
using System.Web.UI;
using HAFoodWeb.BLL;

namespace HAFoodWeb.AuthPage
{
    public partial class OTPForgotPassword : Page
    {
        protected string Email;
        private UserBLL userBLL;
        private int? otpId; // lưu otpId nếu có

        protected void Page_Load(object sender, EventArgs e)
        {
            userBLL = new UserBLL();

            // ✅ Lấy email từ Session hoặc QueryString
            string sessionEmail = Session["ResetEmail"] as string;
            string queryEmail = Request.QueryString["email"];
            if (!string.IsNullOrEmpty(sessionEmail))
                Email = sessionEmail;
            else if (!string.IsNullOrEmpty(queryEmail))
                Email = HttpUtility.UrlDecode(queryEmail);
            else
                Email = null;

            // ✅ Lấy otpId từ Session hoặc QueryString
            object s = Session["OtpId"] ?? Session["otpId"] ?? Session["OTPId"];
            if (s != null && int.TryParse(s.ToString(), out int parsedSessionOtp))
            {
                otpId = parsedSessionOtp;
            }

            if (!otpId.HasValue)
            {
                string qOtp = Request.QueryString["otpId"];
                if (!string.IsNullOrEmpty(qOtp) && int.TryParse(qOtp, out int parsedQueryOtp))
                {
                    otpId = parsedQueryOtp;
                    Session["OtpId"] = otpId.Value;
                }
            }

            Debug.WriteLine("=== OTPForgotPassword Page_Load ===");
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

            if (string.IsNullOrEmpty(Email))
            {
                lblError.Text = "Không xác định được email. Vui lòng quay lại bước quên mật khẩu.";
                return;
            }

            try
            {
                bool verified = await userBLL.VerifyForgotPasswordOtpViaApi(Email, otpCode);
                Debug.WriteLine("VerifyForgotPasswordOtpViaApi result = " + verified);

                if (verified)
                {
                    // Lưu lại otpId vào session nếu có
                    if (!otpId.HasValue)
                    {
                        object s = Session["OtpId"];
                        if (s != null && int.TryParse(s.ToString(), out int parsed))
                        {
                            otpId = parsed;
                        }
                    }

                    if (otpId.HasValue)
                    {
                        Session["OtpId"] = otpId.Value;
                    }

                    lblSuccess.Text = "✅ Xác thực thành công! Chuyển đến trang đặt lại mật khẩu...";

                    string redirectUrl = otpId.HasValue
                        ? $"~/AuthPage/ResetPassword.aspx?otpId={otpId.Value}"
                        : "~/AuthPage/ResetPassword.aspx";

                    string script = $"setTimeout(function(){{ window.location = '{ResolveUrl(redirectUrl)}'; }}, 800);";
                    ClientScript.RegisterStartupScript(this.GetType(), "redirect", script, true);
                }
                else
                {
                    lblError.Text = "❌ OTP không hợp lệ hoặc đã hết hạn. Vui lòng thử lại.";
                }
            }
            catch (Exception ex)
            {
                Debug.WriteLine("VerifyOtpAsync Exception: " + ex.ToString());
                lblError.Text = "❌ Có lỗi xảy ra trong quá trình xác thực. Vui lòng thử lại.";
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

            if (string.IsNullOrEmpty(Email))
            {
                lblError.Text = "Không xác định được email. Vui lòng quay lại bước quên mật khẩu.";
                return;
            }

            string deviceUuid = Session["DeviceUuid"] as string;
            if (string.IsNullOrEmpty(deviceUuid))
            {
                deviceUuid = Guid.NewGuid().ToString();
                Session["DeviceUuid"] = deviceUuid;
            }

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