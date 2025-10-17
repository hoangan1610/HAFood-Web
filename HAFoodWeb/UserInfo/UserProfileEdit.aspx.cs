using HAFoodWeb.Models;
using HAFoodWeb.Services;
using Newtonsoft.Json;
using System;
using System.Net.Http;
using System.Threading.Tasks;
using System.Web.UI;

namespace HAFoodWeb
{
    public partial class UserProfileEdit : Page
    {
        private readonly UserService _userService = new UserService();

        protected async void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                var token = Request.Cookies["AuthToken"]?.Value; // ✅ Lấy từ cookie cho thống nhất
                if (string.IsNullOrEmpty(token))
                {
                    Response.Redirect("~/AuthPage/Login.aspx");
                    return;
                }

                var profile = await _userService.GetProfileAsync(token);
                if (profile != null && profile.user != null)
                {
                    txtFullName.Text = profile.user.fullName;
                    txtEmail.Text = profile.user.email;
                    txtPhone.Text = profile.user.phone;
                    imgAvatar.ImageUrl = string.IsNullOrEmpty(profile.user.avatar)
                        ? "~/images/default-avatar.png"
                        : profile.user.avatar;
                }
            }
        }

        protected async void btnSave_Click(object sender, EventArgs e)
        {
            var token = Request.Cookies["AuthToken"]?.Value;
            if (string.IsNullOrEmpty(token)) return;

            string avatarUrl = imgAvatar.ImageUrl;

            // Nếu người dùng chọn file mới → upload lên Cloudinary
            if (fileAvatar.HasFile)
            {
                avatarUrl = await UploadToCloudinary(fileAvatar);
            }

            // ✅ Dùng đúng property tên thường theo model
            var updateRequest = new UserUpdateRequest
            {
                fullName = txtFullName.Text.Trim(),
                phone = txtPhone.Text.Trim(),
                avatar = avatarUrl
            };

            var result = await _userService.UpdateProfileAsync(token, updateRequest);

            if (result != null && result.Success)
            {
                lblMessage.Text = "✅ Bạn đã thay đổi thông tin thành công!";
                lblMessage.CssClass = "success-message";

                // Cập nhật lại avatar
                imgAvatar.ImageUrl = avatarUrl;

                ScriptManager.RegisterStartupScript(this, GetType(), "redirectProfile",
                "setTimeout(function(){ window.location.href = 'UserProfile.aspx'; }, 1000);", true);
            }
            else
            {
                lblMessage.Text = "❌ Cập nhật thất bại, vui lòng thử lại.";
                lblMessage.CssClass = "error-message";
            }
        }

        private async Task<string> UploadToCloudinary(System.Web.UI.WebControls.FileUpload fileUpload)
        {
            string cloudName = "dzdexwcqp";
            string uploadPreset = "upload";

            using (var httpClient = new HttpClient())
            {
                var content = new MultipartFormDataContent();
                var fileContent = new StreamContent(fileUpload.FileContent);
                content.Add(fileContent, "file", fileUpload.FileName);
                content.Add(new StringContent(uploadPreset), "upload_preset");

                var response = await httpClient.PostAsync(
                    $"https://api.cloudinary.com/v1_1/{cloudName}/image/upload", content);

                var json = await response.Content.ReadAsStringAsync();
                dynamic result = JsonConvert.DeserializeObject(json);
                return result.secure_url;
            }
        }
    }
}
