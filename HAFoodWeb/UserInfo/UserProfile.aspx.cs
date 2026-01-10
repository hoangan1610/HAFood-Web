using HAFoodWeb.Models;
using HAFoodWeb.Services;
using Newtonsoft.Json;
using System;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading.Tasks;
using System.Web.UI;

namespace HAFoodWeb
{
    // Model nhỏ để map dữ liệu từ /api/gam/loyalty
    public class LoyaltyResponse
    {
        public int user_info_id { get; set; }
        public int total_points { get; set; }
        public int lifetime_points { get; set; }
        public int tier { get; set; }
        public int streak_days { get; set; }
        public int max_streak_days { get; set; }
        public DateTime? last_checkin_date { get; set; }
    }

    public partial class UserProfile : Page
    {
        private readonly UserService _userService = new UserService();

        // dùng 1 HttpClient dùng chung
        private static readonly HttpClient _httpClient = new HttpClient
        {
            BaseAddress = new Uri("http://localhost:8080")
        };

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

                // load hồ sơ
                var profile = await _userService.GetProfileAsync(token);
                if (profile != null && profile.user != null)
                {
                    lblFullName.Text = profile.user.fullName;
                    lblEmail.Text = profile.user.email;
                    lblPhone.Text = profile.user.phone;

                    string avatarUrl = string.IsNullOrEmpty(profile.user.avatar)
                        ? ResolveUrl("~/images/default-avatar.png")
                        : profile.user.avatar;

                    // Nếu avatar trả về là đường dẫn tương đối → nối với domain
                    if (!avatarUrl.StartsWith("http", StringComparison.OrdinalIgnoreCase))
                    {
                        avatarUrl = "http://localhost:8080" + avatarUrl;
                    }

                    // Thêm timestamp để tránh cache ảnh cũ
                    imgAvatar.ImageUrl = avatarUrl + (avatarUrl.Contains("?") ? "&" : "?") + "t=" + DateTime.Now.Ticks;
                }

                // load điểm thành viên và tier
                await LoadLoyaltyAsync(token);
            }
        }

        private async Task LoadLoyaltyAsync(string token)
        {
            try
            {
                using (var request = new HttpRequestMessage(HttpMethod.Get, "/api/gam/loyalty"))
                {
                    // nếu backend dùng kiểu token khác thì đổi lại header cho đúng
                    request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token);

                    var response = await _httpClient.SendAsync(request);
                    if (!response.IsSuccessStatusCode)
                    {
                        lblMemberPoints.Text = "Điểm thành viên: 0";
                        return;
                    }

                    var json = await response.Content.ReadAsStringAsync();
                    var loyalty = JsonConvert.DeserializeObject<LoyaltyResponse>(json);

                    if (loyalty != null)
                    {
                        var tierName = GetTierName(loyalty.total_points);
                        lblMemberPoints.Text = $"Điểm thành viên: {loyalty.total_points} ({tierName})";
                    }
                    else
                    {
                        lblMemberPoints.Text = "Điểm thành viên: 0";
                    }
                }
            }
            catch
            {
                // có lỗi thì không cho page crash, chỉ hiển thị 0 điểm
                lblMemberPoints.Text = "Điểm thành viên: 0";
            }
        }

        // Hardcode tier theo điểm:
        // 0-1000: Đồng
        // 1001-2000: Bạc
        // 2001-3000: Vàng
        // 3001-4000 (và lớn hơn): Bạch Kim
        private string GetTierName(int totalPoints)
        {
            if (totalPoints <= 1000)
                return "Thành viên Đồng";
            if (totalPoints <= 2000)
                return "Thành viên Bạc";
            if (totalPoints <= 3000)
                return "Thành viên Vàng";
            // từ 3001 trở lên coi là Bạch Kim
            return "Thành viên Bạch Kim";
        }

        protected void btnEdit_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/UserInfo/UserProfileEdit.aspx");
        }

        protected void btnChangePassword_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/UserInfo/ChangePassword.aspx");
        }
    }
}
