using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading;
using System.Threading.Tasks;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace HAFoodWeb.UserInfo
{
    // model map từ /api/gam/loyalty
    public class LoyaltySummaryResponse
    {
        public long user_info_id { get; set; }
        public int total_points { get; set; }
        public int lifetime_points { get; set; }
        public int tier { get; set; }
        public int streak_days { get; set; }
        public int max_streak_days { get; set; }
        public DateTime? last_checkin_date { get; set; }
    }

    // model reward (map với /api/gam/loyalty/rewards)
    // model reward (map với /api/gam/loyalty/rewards)
    public class LoyaltyRewardItem
    {
        public long id { get; set; }
        public string name { get; set; }
        public string description { get; set; }
        public int points_cost { get; set; }
        public byte reward_type { get; set; }

        // ✅ cho phép null để map được "spins_Created": null
        public int? spins_created { get; set; }

        public long? promotion_id { get; set; }
    }


    // response từ /api/gam/loyalty/redeem
    public class LoyaltyRedeemResponse
    {
        public bool success { get; set; }
        public string error_Code { get; set; }
        public string error_Message { get; set; }
        public int? points_Spent { get; set; }
        public int? total_Points { get; set; }
        public int? spins_Created { get; set; }
        public string promotion_Code { get; set; }
        public long? promotion_Issue_Id { get; set; }
    }

    // response từ /api/gam/checkin
    public class GamCheckinResponse
    {
        public bool success { get; set; }
        public string error_Code { get; set; }
        public string error_Message { get; set; }
        public int? streak_Days { get; set; }
        public int? total_Points { get; set; }
        public int? spins_Created { get; set; }
    }

    // response từ /api/gam/status
    public class GamStatusResponse
    {
        public bool has_Checked_In_Today { get; set; }
        public int remaining_Spins { get; set; }
        public int? total_Points { get; set; }
        public int? streak_Days { get; set; }
    }

    public partial class Loyalty : Page
    {
        private static readonly HttpClient _httpClient = new HttpClient
        {
            BaseAddress = new Uri("http://localhost:8080")
        };

        // Để reuse token cho các request trong 1 page lifecycle
        private string _token;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                RegisterAsyncTask(new PageAsyncTask(LoadAsync));
            }
        }

        private async Task LoadAsync(CancellationToken ct)
        {
            _token = Request.Cookies["AuthToken"]?.Value;
            if (string.IsNullOrEmpty(_token))
            {
                RedirectToLogin();
                return;
            }

            // 1) STATUS: lượt quay + đã checkin chưa
            try
            {
                await LoadStatusAsync(ct);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Loyalty LoadStatusAsync error: " + ex);
                // fallback an toàn
                lblRemainingSpins.Text = "0";
                btnCheckin.Enabled = true;
                btnCheckin.Text = "Điểm danh";
            }

            // 2) SUMMARY: tổng điểm, streak
            try
            {
                await LoadSummaryAsync(ct);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Loyalty LoadSummaryAsync error: " + ex);
                BindSummaryFallback();
            }

            // 3) REWARDS: đổi điểm lấy quà / lượt quay
            try
            {
                await LoadRewardsAsync(ct);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Loyalty LoadRewardsAsync error: " + ex);
                phNoReward.Visible = true;
                rptRewards.DataSource = null;
                rptRewards.DataBind();
            }
        }

        // ===== STATUS: /api/gam/status =====
        private async Task LoadStatusAsync(CancellationToken ct)
        {
            using (var request = new HttpRequestMessage(HttpMethod.Get, "/api/gam/status?channel=1"))
            {
                request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", _token);

                var response = await _httpClient.SendAsync(request, ct);

                if (response.StatusCode == HttpStatusCode.Unauthorized)
                {
                    RedirectToLogin();
                    return;
                }

                if (!response.IsSuccessStatusCode)
                {
                    // fallback
                    lblRemainingSpins.Text = "0";
                    btnCheckin.Enabled = true;
                    btnCheckin.Text = "Điểm danh";
                    return;
                }

                var json = await response.Content.ReadAsStringAsync();
                var status = JsonConvert.DeserializeObject<GamStatusResponse>(json);

                if (status == null)
                {
                    lblRemainingSpins.Text = "0";
                    btnCheckin.Enabled = true;
                    btnCheckin.Text = "Điểm danh";
                    return;
                }

                // Số lượt quay còn lại
                lblRemainingSpins.Text = status.remaining_Spins.ToString();

                // Trạng thái điểm danh hôm nay
                if (status.has_Checked_In_Today)
                {
                    btnCheckin.Enabled = false;
                    btnCheckin.Text = "Đã điểm danh hôm nay";
                }
                else
                {
                    btnCheckin.Enabled = true;
                    btnCheckin.Text = "Điểm danh";
                }
            }
        }

        // ===== SUMMARY: /api/gam/loyalty =====
        private async Task LoadSummaryAsync(CancellationToken ct)
        {
            using (var request = new HttpRequestMessage(HttpMethod.Get, "/api/gam/loyalty"))
            {
                request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", _token);

                var response = await _httpClient.SendAsync(request, ct);

                if (response.StatusCode == HttpStatusCode.Unauthorized)
                {
                    RedirectToLogin();
                    return;
                }

                if (!response.IsSuccessStatusCode)
                {
                    // fallback: hiển thị 0
                    BindSummaryFallback();
                    return;
                }

                var json = await response.Content.ReadAsStringAsync();
                var summary = JsonConvert.DeserializeObject<LoyaltySummaryResponse>(json);

                if (summary == null)
                {
                    BindSummaryFallback();
                    return;
                }

                lblTotalPoints.Text = summary.total_points.ToString("N0");
                lblLifetimePoints.Text = summary.lifetime_points.ToString("N0");
                lblStreakDays.Text = summary.streak_days.ToString();
                lblMaxStreak.Text = summary.max_streak_days.ToString();

                if (summary.last_checkin_date.HasValue)
                {
                    lblLastCheckin.Text = summary.last_checkin_date.Value.ToString("dd/MM/yyyy");
                }
                else
                {
                    lblLastCheckin.Text = "Chưa từng";
                }

                lblTierName.Text = GetTierName(summary.total_points);
            }
        }

        // ===== REWARDS: /api/gam/loyalty/rewards =====
        private async Task LoadRewardsAsync(CancellationToken ct)
        {
            using (var request = new HttpRequestMessage(HttpMethod.Get, "/api/gam/loyalty/rewards?channel=1"))
            {
                request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", _token);

                var response = await _httpClient.SendAsync(request, ct);

                if (response.StatusCode == HttpStatusCode.Unauthorized)
                {
                    RedirectToLogin();
                    return;
                }

                if (!response.IsSuccessStatusCode)
                {
                    phNoReward.Visible = true;
                    rptRewards.DataSource = null;
                    rptRewards.DataBind();
                    return;
                }

                var json = await response.Content.ReadAsStringAsync();
                var list = JsonConvert.DeserializeObject<List<LoyaltyRewardItem>>(json) ?? new List<LoyaltyRewardItem>();

                if (list.Count == 0)
                {
                    phNoReward.Visible = true;
                    rptRewards.DataSource = null;
                    rptRewards.DataBind();
                    return;
                }

                phNoReward.Visible = false;

                // map thêm reward_type_text để show UI
                var vm = new List<dynamic>();
                foreach (var r in list)
                {
                    string rewardTypeText;
                    switch (r.reward_type)
                    {
                        case 1:
                            rewardTypeText = "<span class='reward-chip'><i class=\"fa-solid fa-rotate\"></i> Đổi điểm lấy lượt quay</span>";
                            break;
                        case 2:
                            rewardTypeText = "<span class='reward-chip'><i class=\"fa-solid fa-ticket\"></i> Đổi điểm lấy mã ưu đãi</span>";
                            break;
                        default:
                            rewardTypeText = "<span class='reward-chip'>Phần thưởng khác</span>";
                            break;
                    }

                    vm.Add(new
                    {
                        id = r.id,
                        name = r.name,
                        description = r.description,
                        points_cost = r.points_cost,
                        reward_type = r.reward_type,
                        reward_type_text = rewardTypeText,
                        spins_created = r.spins_created,
                        promotion_id = r.promotion_id
                    });
                }

                rptRewards.DataSource = vm;
                rptRewards.DataBind();
            }
        }

        private void BindSummaryFallback()
        {
            lblTotalPoints.Text = "0";
            lblLifetimePoints.Text = "0";
            lblStreakDays.Text = "0";
            lblMaxStreak.Text = "0";
            lblLastCheckin.Text = "Chưa có";
            lblTierName.Text = "Thành viên";
        }

        private string GetTierName(int totalPoints)
        {
            if (totalPoints <= 1000) return "Thành viên Đồng";
            if (totalPoints <= 2000) return "Thành viên Bạc";
            if (totalPoints <= 3000) return "Thành viên Vàng";
            return "Thành viên Bạch Kim";
        }

        private void ShowMessage(string text, bool isError = false, bool isSuccess = false)
        {
            phMessage.Visible = true;
            msgBox.InnerText = text;

            if (isError)
            {
                msgBox.Attributes["class"] = "alert alert-danger";
            }
            else if (isSuccess)
            {
                msgBox.Attributes["class"] = "alert alert-success";
            }
            else
            {
                msgBox.Attributes["class"] = "alert alert-info";
            }
        }

        private void RedirectToLogin()
        {
            // clear token nếu muốn
            if (Request.Cookies["AuthToken"] != null)
            {
                var expired = new HttpCookie("AuthToken")
                {
                    Expires = DateTime.UtcNow.AddDays(-1),
                    Path = "/"
                };
                Response.Cookies.Add(expired);
            }

            // KHÔNG abort thread
            Response.Redirect("~/AuthPage/Login.aspx", false);
            Context.ApplicationInstance.CompleteRequest();
        }

        // ========== REDEEM ==========

        protected void rptRewards_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Redeem")
            {
                if (!long.TryParse(e.CommandArgument as string, out var rewardId))
                    return;

                var txtQty = (TextBox)e.Item.FindControl("txtQty");
                int quantity = 1;
                if (txtQty != null)
                {
                    int.TryParse(txtQty.Text, out quantity);
                    if (quantity <= 0) quantity = 1;
                }

                RegisterAsyncTask(new PageAsyncTask(ct => RedeemAsync(rewardId, quantity, ct)));
            }
        }

        private async Task RedeemAsync(long rewardId, int quantity, CancellationToken ct)
        {
            _token = Request.Cookies["AuthToken"]?.Value;
            if (string.IsNullOrEmpty(_token))
            {
                RedirectToLogin();
                return;
            }

            try
            {
                var bodyObj = new
                {
                    rewardId = rewardId,
                    quantity = quantity
                };
                var jsonBody = JsonConvert.SerializeObject(bodyObj);

                using (var request = new HttpRequestMessage(HttpMethod.Post, "/api/gam/loyalty/redeem?channel=1"))
                {
                    request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", _token);
                    request.Content = new StringContent(jsonBody, System.Text.Encoding.UTF8, "application/json");

                    var response = await _httpClient.SendAsync(request, ct);

                    if (response.StatusCode == HttpStatusCode.Unauthorized)
                    {
                        RedirectToLogin();
                        return;
                    }

                    var json = await response.Content.ReadAsStringAsync();
                    var redeemRes = JsonConvert.DeserializeObject<LoyaltyRedeemResponse>(json);

                    if (!response.IsSuccessStatusCode || redeemRes == null)
                    {
                        ShowMessage("Đổi điểm thất bại. Vui lòng thử lại sau.", isError: true);
                        return;
                    }

                    if (!redeemRes.success)
                    {
                        switch (redeemRes.error_Code)
                        {
                            case "NOT_ENOUGH_POINTS":
                                ShowMessage("Bạn không đủ điểm để đổi phần thưởng này.", isError: true);
                                break;
                            case "REWARD_NOT_FOUND":
                                ShowMessage("Phần thưởng không còn khả dụng hoặc đã kết thúc.", isError: true);
                                break;
                            case "NO_SPIN_CONFIG":
                                ShowMessage("Hiện chưa có vòng quay đang hoạt động để tạo lượt quay.", isError: true);
                                break;
                            case "PROMOTION_NOT_CONFIGURED":
                            case "PROMOTION_NOT_FOUND":
                            case "PROMOTION_NOT_STARTED":
                            case "PROMOTION_EXPIRED":
                            case "PROMOTION_CHANNEL_MISMATCH":
                                ShowMessage(redeemRes.error_Message ?? "Không thể tạo voucher từ phần thưởng này.", isError: true);
                                break;
                            default:
                                ShowMessage(redeemRes.error_Message ?? "Đổi điểm thất bại.", isError: true);
                                break;
                        }
                        return;
                    }

                    // Thành công
                    string msg;
                    if (redeemRes.spins_Created.HasValue && redeemRes.spins_Created.Value > 0)
                    {
                        msg = $"Đã đổi điểm thành công: +{redeemRes.spins_Created.Value} lượt quay may mắn.";
                    }
                    else if (!string.IsNullOrEmpty(redeemRes.promotion_Code))
                    {
                        msg = $"Đã đổi điểm lấy mã ưu đãi: {redeemRes.promotion_Code}. Hãy dùng mã này ở giỏ hàng.";
                    }
                    else
                    {
                        msg = "Đổi điểm thành công.";
                    }

                    ShowMessage(msg, isSuccess: true);

                    if (redeemRes.total_Points.HasValue)
                    {
                        lblTotalPoints.Text = redeemRes.total_Points.Value.ToString("N0");
                        lblTierName.Text = GetTierName(redeemRes.total_Points.Value);
                    }

                    // Reload status + summary + rewards cho chắc
                    await LoadStatusAsync(ct);
                    await LoadSummaryAsync(ct);
                    await LoadRewardsAsync(ct);
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Có lỗi khi đổi điểm. Vui lòng thử lại sau.", isError: true);
                System.Diagnostics.Debug.WriteLine("RedeemAsync error: " + ex);
            }
        }

        // ========== CHECKIN ==========

        protected void btnCheckin_Click(object sender, EventArgs e)
        {
            RegisterAsyncTask(new PageAsyncTask(CheckinAsync));
        }

        private async Task CheckinAsync(CancellationToken ct)
        {
            _token = Request.Cookies["AuthToken"]?.Value;
            if (string.IsNullOrEmpty(_token))
            {
                RedirectToLogin();
                return;
            }

            try
            {
                using (var request = new HttpRequestMessage(HttpMethod.Post, "/api/gam/checkin?channel=1"))
                {
                    request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", _token);

                    var response = await _httpClient.SendAsync(request, ct);

                    if (response.StatusCode == HttpStatusCode.Unauthorized)
                    {
                        RedirectToLogin();
                        return;
                    }

                    var json = await response.Content.ReadAsStringAsync();
                    var res = JsonConvert.DeserializeObject<GamCheckinResponse>(json);

                    if (!response.IsSuccessStatusCode || res == null)
                    {
                        ShowMessage("Điểm danh thất bại. Vui lòng thử lại sau.", isError: true);
                        return;
                    }

                    if (!res.success)
                    {
                        if (string.Equals(res.error_Code, "CHECKIN_ALREADY_DONE", StringComparison.OrdinalIgnoreCase))
                        {
                            ShowMessage("Bạn đã điểm danh hôm nay rồi. Hãy quay lại vào ngày mai nhé.", isError: false);
                        }
                        else
                        {
                            ShowMessage(res.error_Message ?? "Điểm danh thất bại.", isError: true);
                        }
                        return;
                    }

                    var message = $"Điểm danh thành công. Bạn đang ở ngày thứ {res.streak_Days ?? 0} trong chuỗi.";
                    if (res.spins_Created.HasValue && res.spins_Created.Value > 0)
                    {
                        message += $" Nhận thêm {res.spins_Created.Value} lượt quay may mắn.";
                    }

                    ShowMessage(message, isSuccess: true);

                    // Reload lại tất cả
                    await LoadStatusAsync(ct);
                    await LoadSummaryAsync(ct);
                    await LoadRewardsAsync(ct);
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Có lỗi khi điểm danh. Vui lòng thử lại sau.", isError: true);
                System.Diagnostics.Debug.WriteLine("CheckinAsync error: " + ex);
            }
        }
    }
}
