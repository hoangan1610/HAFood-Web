using System;
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
        private int? otpId;

        protected void Page_Load(object sender, EventArgs e)
        {
            userBLL = new UserBLL();

            string sessionEmail = Session["ResetEmail"] as string;
            string queryEmail = Request.QueryString["email"];

            if (!string.IsNullOrEmpty(sessionEmail))
                Email = sessionEmail;
            else if (!string.IsNullOrEmpty(queryEmail))
                Email = HttpUtility.UrlDecode(queryEmail);
            else
                Email = null;

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

            if (!string.IsNullOrEmpty(Email))
            {
                lblEmailInfo.Text = $"Mã OTP đã được gửi tới email: <b>{Email}</b>";
            }
            else
            {
                lblEmailInfo.Text = "";
                ShowToast("⚠️ Không xác định được email. Vui lòng thử lại.", "error");
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

            if (string.IsNullOrEmpty(otpCode))
            {
                ShowToast("Vui lòng nhập mã OTP.", "error");
                return;
            }

            if (string.IsNullOrEmpty(Email))
            {
                ShowToast("Không xác định được email. Vui lòng quay lại bước quên mật khẩu.", "error");
                return;
            }

            try
            {
                bool verified = await userBLL.VerifyForgotPasswordOtpViaApi(Email, otpCode);

                if (verified)
                {
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

                    ShowToast("✅ Xác thực thành công! Chuyển đến trang đặt lại mật khẩu...", "success");

                    string redirectUrl = otpId.HasValue
                        ? $"~/AuthPage/ResetPassword.aspx?otpId={otpId.Value}"
                        : "~/AuthPage/ResetPassword.aspx";

                    string script = $"setTimeout(function(){{ window.location = '{ResolveUrl(redirectUrl)}'; }}, 800);";
                    ClientScript.RegisterStartupScript(this.GetType(), "redirect", script, true);
                }
                else
                {
                    ShowToast("❌ OTP không hợp lệ hoặc đã hết hạn. Vui lòng thử lại.", "error");
                }
            }
            catch
            {
                ShowToast("❌ Có lỗi xảy ra trong quá trình xác thực. Vui lòng thử lại.", "error");
            }
        }

        protected async void btnVerifyOtp_Click(object sender, EventArgs e)
        {
            try
            {
                await VerifyOtpAsync();
            }
            catch
            {
                ShowToast("❌ Có lỗi xảy ra. Vui lòng thử lại.", "error");
            }
        }

        protected async Task ResendOtpAsync()
        {
            lblError.Text = "";
            lblSuccess.Text = "";

            if (string.IsNullOrEmpty(Email))
            {
                ShowToast("Không xác định được email. Vui lòng quay lại bước quên mật khẩu.", "error");
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
                ShowToast("✅ Mã OTP mới đã được gửi đến email của bạn.", "success");
                btnResendOtp.Enabled = false;
                ClientScript.RegisterStartupScript(this.GetType(), "startTimer", "startResendCountdown();", true);
            }
            else
            {
                ShowToast("❌ Gửi lại OTP thất bại. Vui lòng thử lại sau.", "error");
            }
        }

        protected async void btnResendOtp_Click(object sender, EventArgs e)
        {
            try
            {
                await ResendOtpAsync();
            }
            catch
            {
                ShowToast("❌ Có lỗi xảy ra. Vui lòng thử lại.", "error");
            }
        }
    }
}
