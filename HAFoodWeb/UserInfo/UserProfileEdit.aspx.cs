using HAFoodWeb.Models;
using HAFoodWeb.Services;
using Newtonsoft.Json;
using System;
using System.Text.RegularExpressions;
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
                var token = Request.Cookies["AuthToken"]?.Value;
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

                    // ✅ Lưu giá trị gốc để so sánh khi PostBack
                    hdnOrigFullName.Value = (profile.user.fullName ?? string.Empty).Trim();
                    hdnOrigPhone.Value = (profile.user.phone ?? string.Empty).Trim();

                    string avatarUrl = string.IsNullOrEmpty(profile.user.avatar)
                        ? ResolveUrl("~/images/default-avatar.png")
                        : profile.user.avatar;

                    if (!avatarUrl.StartsWith("http", StringComparison.OrdinalIgnoreCase))
                    {
                        avatarUrl = "http://localhost:8080" + avatarUrl;
                    }

                    imgAvatar.ImageUrl = avatarUrl;
                }
            }
        }

        protected async void btnSave_Click(object sender, EventArgs e)
        {
            lblMessage.Text = string.Empty;

            var token = Request.Cookies["AuthToken"]?.Value;
            if (string.IsNullOrEmpty(token)) return;

            string fullName = (txtFullName.Text ?? string.Empty).Trim();
            string phone = (txtPhone.Text ?? string.Empty).Trim();

            // ✅ Lấy giá trị gốc
            string origFullName = (hdnOrigFullName.Value ?? string.Empty).Trim();
            string origPhone = (hdnOrigPhone.Value ?? string.Empty).Trim();

            bool fullNameChanged = !string.Equals(fullName, origFullName, StringComparison.Ordinal);
            bool phoneChanged = !string.Equals(phone, origPhone, StringComparison.Ordinal);
            bool avatarChanged = fileAvatar.HasFile;

            // ✅ Validate CHỈ những field thay đổi
            if (fullNameChanged)
            {
                if (string.IsNullOrEmpty(fullName))
                {
                    ShowFormError("❌ Vui lòng nhập họ và tên.");
                    return;
                }
                if (!Regex.IsMatch(fullName, @"^[\p{L}\s]+$"))
                {
                    ShowFormError("❌ Tên không được chứa ký tự đặc biệt hoặc số.");
                    return;
                }
            }

            if (phoneChanged)
            {
                if (string.IsNullOrEmpty(phone))
                {
                    ShowFormError("❌ Vui lòng nhập số điện thoại.");
                    return;
                }
                if (!Regex.IsMatch(phone, @"^0\d{9}$"))
                {
                    ShowFormError("❌ Số điện thoại phải gồm 10 chữ số và bắt đầu bằng số 0.");
                    return;
                }
            }

            // 1) Upload ảnh nếu có
            if (avatarChanged)
            {
                var avatarResult = await _userService.UpdateAvatarAsync(token, fileAvatar);
                if (!(avatarResult?.Success ?? false))
                {
                    ShowFormError("❌ Cập nhật ảnh thất bại.");
                    return;
                }

                // Refresh avatar
                var updatedProfile = await _userService.GetProfileAsync(token);
                if (updatedProfile?.user != null && !string.IsNullOrEmpty(updatedProfile.user.avatar))
                {
                    var avatarUrl = updatedProfile.user.avatar;
                    if (!avatarUrl.StartsWith("http", StringComparison.OrdinalIgnoreCase))
                        avatarUrl = "http://localhost:8080" + avatarUrl;

                    imgAvatar.ImageUrl = avatarUrl + "?t=" + DateTime.Now.Ticks;
                }
            }

            // ✅ Nếu không đổi name/phone thì KHÔNG gọi UpdateProfileAsync (tránh gửi phone)
            if (!fullNameChanged && !phoneChanged)
            {
                lblMessage.Text = string.Empty;
                ShowToast(avatarChanged ? "Cập nhật ảnh thành công!" : "Không có thay đổi để lưu.", "success");

                ScriptManager.RegisterStartupScript(this, GetType(), "redirectProfile_nochange",
                    "setTimeout(function(){ window.location.href = '../UserInfo/UserProfile.aspx?t=' + new Date().getTime(); }, 800);", true);
                return;
            }

            // 2) Cập nhật thông tin: ✅ chỉ gửi field thay đổi (field không đổi => null)
            var updateRequest = new UserUpdateRequest
            {
                fullName = fullNameChanged ? fullName : null,
                phone = phoneChanged ? phone : null,
                avatar = null
            };

            var profileResult = await _userService.UpdateProfileAsync(token, updateRequest);

            // Thành công
            if (profileResult != null && profileResult.Success)
            {
                lblMessage.Text = string.Empty;

                ScriptManager.RegisterStartupScript(this, GetType(), "showSuccess",
                    "showToast('Cập nhật thông tin thành công!', 'success');", true);

                ScriptManager.RegisterStartupScript(this, GetType(), "redirectProfile",
                    "setTimeout(function(){ window.location.href = '../UserInfo/UserProfile.aspx?t=' + new Date().getTime(); }, 1000);", true);
                return;
            }

            // === THẤT BẠI: CHỈ BẮT 2 TRƯỜNG HỢP 409 & 500 ===
            int? statusCode = GetStatusCode(profileResult);

            if (statusCode == 409)
            {
                var msg = "Số điện thoại đã được sử dụng, vui lòng đổi số điện thoại khác.";

                // ✅ KHÔNG hiện lblMessage nữa (chỉ hiện lỗi dưới ô SĐT + toast)
                lblMessage.Text = string.Empty;

                if (phoneChanged) ShowFieldError("phoneError", "❌ " + msg);
                ShowToast(msg, "error");
                return;
            }

            if (statusCode == 500)
            {
                var msg = "Đã xảy ra lỗi hệ thống, vui lòng thử lại sau.";

                // ✅ KHÔNG hiện lblMessage nữa
                lblMessage.Text = string.Empty;

                ShowToast(msg, "error");
                return;
            }

            lblMessage.Text = string.Empty;
            ShowToast("Cập nhật thông tin thất bại, vui lòng thử lại.", "error");
        }

        // ---- Helpers ----
        private void ShowFormError(string message)
        {
            lblMessage.Text = message;
            lblMessage.CssClass = "error-message";
        }

        private void ShowFieldError(string elementId, string message)
        {
            var safe = (message ?? string.Empty).Replace("'", "\\'");
            ScriptManager.RegisterStartupScript(this, GetType(), "fieldErr_" + elementId,
                $"(function(){{var el=document.getElementById('{elementId}'); if(el){{ el.innerText='{safe}'; el.style.display='block'; }} }})();",
                true);
        }

        private void ShowToast(string message, string type /* success|error */)
        {
            var safe = (message ?? string.Empty).Replace("'", "\\'");
            var t = (type == "success") ? "success" : "error";
            ScriptManager.RegisterStartupScript(this, GetType(), "toast_" + Guid.NewGuid().ToString("N"),
                $"showToast('{safe}', '{t}');", true);
        }

        private int? GetStatusCode(object result)
        {
            var scNullable = TryGet<int?>(result, "StatusCode");
            if (scNullable.HasValue) return scNullable.Value;

            var scInt = TryGet<int>(result, "StatusCode");
            if (scInt > 0) return scInt;

            var scStr = TryGet<string>(result, "StatusCode");
            if (!string.IsNullOrWhiteSpace(scStr) && int.TryParse(scStr, out var scParsed))
                return scParsed;

            var rawBody = TryGet<string>(result, "RawBody");
            if (!string.IsNullOrWhiteSpace(rawBody))
            {
                try
                {
                    dynamic p = JsonConvert.DeserializeObject(rawBody);
                    int? st = (int?)p?.status;
                    if (st.HasValue) return st.Value;
                }
                catch { }
            }

            return null;
        }

        private T TryGet<T>(object obj, string propName)
        {
            try
            {
                if (obj == null || string.IsNullOrEmpty(propName)) return default(T);
                var p = obj.GetType().GetProperty(propName);
                if (p != null && p.CanRead)
                {
                    var val = p.GetValue(obj);
                    if (val == null) return default(T);

                    if (val is T tval) return tval;

                    var targetType = typeof(T);
                    var underlying = Nullable.GetUnderlyingType(targetType) ?? targetType;

                    try
                    {
                        var converted = Convert.ChangeType(val, underlying);
                        if (Nullable.GetUnderlyingType(targetType) != null)
                            return (T)(object)converted;
                        return (T)converted;
                    }
                    catch { }
                }
            }
            catch { }
            return default(T);
        }
    }
}
