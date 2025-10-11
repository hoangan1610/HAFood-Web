using System;
using System.Threading.Tasks;
using HAFoodWeb.BLL;

namespace HAFoodWeb.AuthPage
{
    public partial class OTP : System.Web.UI.Page
    {
        protected string Email;
        private UserBLL userBLL;

        protected void Page_Load(object sender, EventArgs e)
        {
            userBLL = new UserBLL();
            Email = Request.QueryString["email"];

            if (string.IsNullOrEmpty(Email))
            {
                lblError.Text = "Không xác định được email. Vui lòng đăng ký lại.";
                btnVerifyOtp.Enabled = false;
                btnResendOtp.Enabled = false;
                return;
            }

            if (!IsPostBack)
            {
                // Khởi động đếm ngược khi load trang
                ClientScript.RegisterStartupScript(this.GetType(), "startTimer", "startCountdown();", true);
            }
        }

        protected async void btnVerifyOtp_Click(object sender, EventArgs e)
        {
            lblError.Text = "";
            lblSuccess.Text = "";
            string otpCode = txtOtp.Text.Trim();

            if (string.IsNullOrEmpty(otpCode))
            {
                lblError.Text = "Vui lòng nhập mã OTP.";
                return;
            }

            bool result = await userBLL.VerifyOtpViaApi(Email, otpCode);

            if (result)
            {
                lblSuccess.Text = "Xác minh thành công! Đang chuyển đến trang đăng nhập...";
                await Task.Delay(2000);
                Response.Redirect("Login.aspx?verify=success", false);
                Context.ApplicationInstance.CompleteRequest();
            }
            else
            {
                lblError.Text = "Mã OTP không đúng hoặc đã hết hạn. Vui lòng thử lại.";
            }
        }

        protected async void btnResendOtp_Click(object sender, EventArgs e)
        {
            lblError.Text = "";
            lblSuccess.Text = "";

            bool result = await userBLL.ResendOtpViaApi(Email);

            if (result)
            {
                lblSuccess.Text = "Mã OTP mới đã được gửi đến email của bạn.";
                ClientScript.RegisterStartupScript(this.GetType(), "restartTimer", "startCountdown();", true);
            }
            else
            {
                lblError.Text = "Gửi lại OTP thất bại. Vui lòng thử lại sau.";
            }
        }
    }
}