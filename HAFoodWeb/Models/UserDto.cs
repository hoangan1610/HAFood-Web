using Newtonsoft.Json;

namespace HAFoodWeb.Models
{
    public class UserDto
    {
        public long UserInfoId { get; set; }
        public string FullName { get; set; }
        public string Email { get; set; }
        public string Phone { get; set; }
        public string Avatar { get; set; }
        public byte Status { get; set; }
        public string Token { get; set; }   // Lưu session.token
    }

    public class AuthUser
    {
        public long userInfoId { get; set; }
        public string fullName { get; set; }
        public string email { get; set; }
        public string phone { get; set; }
        public string avatar { get; set; }
        public byte? status { get; set; }
    }

    public class AuthMeResponse
    {
        public bool authenticated { get; set; }
        public AuthUser user { get; set; }
        public string code { get; set; }
        public string message { get; set; }
    }

    // ✅ Dùng để gửi yêu cầu cập nhật thông tin người dùng (chỉ gửi field thay đổi)
    public class UserUpdateRequest
    {
        [JsonProperty("fullName", NullValueHandling = NullValueHandling.Ignore)]
        public string fullName { get; set; }

        [JsonProperty("phone", NullValueHandling = NullValueHandling.Ignore)]
        public string phone { get; set; }

        [JsonProperty("avatar", NullValueHandling = NullValueHandling.Ignore)]
        public string avatar { get; set; }

        // ✅ (Khuyến nghị) Không gửi chuỗi rỗng / toàn khoảng trắng
        public bool ShouldSerializefullName() => !string.IsNullOrWhiteSpace(fullName);
        public bool ShouldSerializephone() => !string.IsNullOrWhiteSpace(phone);
        public bool ShouldSerializeavatar() => !string.IsNullOrWhiteSpace(avatar);
    }

    public class ApiBaseResponse
    {
        public bool Success { get; set; }
        public string Code { get; set; }
        public string Message { get; set; }
    }
}
