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

                    string avatarUrl = string.IsNullOrEmpty(profile.user.avatar)
                        ? ResolveUrl("~/images/default-avatar.png")
                        : profile.user.avatar;

                    if (!avatarUrl.StartsWith("http", StringComparison.OrdinalIgnoreCase))
                    {
                        avatarUrl = "https://api.hafood.id.vn" + avatarUrl;
                    }

                    imgAvatar.ImageUrl = avatarUrl;
                }
            }
        }

        protected async void btnSave_Click(object sender, EventArgs e)
        {
            var token = Request.Cookies["AuthToken"]?.Value;
            if (string.IsNullOrEmpty(token)) return;

            // --- Kiểm tra tên ---
            string fullName = (txtFullName.Text ?? string.Empty).Trim();
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

            // --- Kiểm tra số điện thoại ---
            string phone = (txtPhone.Text ?? string.Empty).Trim();
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

            // 1) Upload ảnh nếu có
            if (fileAvatar.HasFile)
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
                        avatarUrl = "https://api.hafood.id.vn" + avatarUrl;

                    imgAvatar.ImageUrl = avatarUrl + "?t=" + DateTime.Now.Ticks;
                }
            }

            // 2) Cập nhật thông tin
            var updateRequest = new UserUpdateRequest
            {
                fullName = fullName,
                phone = phone
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
                ShowFormError("❌ " + msg);
                ShowFieldError("phoneError", "❌ " + msg);
                ShowToast(msg, "error");
                return;
            }

            if (statusCode == 500)
            {
                var msg = "Đã xảy ra lỗi hệ thống, vui lòng thử lại sau.";
                ShowFormError("❌ " + msg);
                ShowToast(msg, "error");
                return;
            }

            // Các lỗi khác: thông điệp mặc định ngắn gọn
            ShowFormError("❌ Cập nhật thông tin thất bại, vui lòng thử lại.");
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

        // Lấy status code "dẻo": int? → int → string → parse từ RawBody
        private int? GetStatusCode(object result)
        {
            // 1) Thử lấy int?
            var scNullable = TryGet<int?>(result, "StatusCode");
            if (scNullable.HasValue) return scNullable.Value;

            // 2) Thử lấy int (không nullable)
            var scInt = TryGet<int>(result, "StatusCode");
            if (scInt > 0) return scInt;

            // 3) Thử lấy string rồi parse
            var scStr = TryGet<string>(result, "StatusCode");
            if (!string.IsNullOrWhiteSpace(scStr) && int.TryParse(scStr, out var scParsed))
                return scParsed;

            // 4) Fallback: parse từ RawBody (Problem Details)
            var rawBody = TryGet<string>(result, "RawBody");
            if (!string.IsNullOrWhiteSpace(rawBody))
            {
                try
                {
                    dynamic p = JsonConvert.DeserializeObject(rawBody);
                    int? st = (int?)p?.status;
                    if (st.HasValue) return st.Value;
                }
                catch { /* ignore */ }
            }

            return null;
        }

        // Đọc property bằng reflection (chấp nhận cả nullable & non-nullable)
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

                    // Nếu cùng kiểu, cast thẳng
                    if (val is T tval) return tval;

                    // Trường hợp cần convert (vd: int -> int?)
                    var targetType = typeof(T);
                    var underlying = Nullable.GetUnderlyingType(targetType) ?? targetType;

                    try
                    {
                        var converted = Convert.ChangeType(val, underlying);
                        // nếu T là nullable, cần box qua object trước khi cast
                        if (Nullable.GetUnderlyingType(targetType) != null)
                            return (T)(object)converted;
                        return (T)converted;
                    }
                    catch { /* ignore convert fail */ }
                }
            }
            catch { }
            return default(T);
        }
    }
}
