using System;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.Diagnostics;
using System.Web;
using System.Linq;
using System.Text.RegularExpressions;
using Newtonsoft.Json;
using HAFoodWeb.Models;
using HAFoodWeb.Services;

namespace HAFoodWeb.UserAddress
{
    public partial class UpdateUserAddress : System.Web.UI.Page
    {
        private readonly IAddressService _service = new AddressService();

        protected async void Page_Load(object sender, EventArgs e)
        {
            if (Session == null || Session["UserId"] == null)
            {
                Response.Redirect("~/AuthPage/Login.aspx");
                return;
            }

            if (!IsPostBack)
                await LoadAddressAsync();
        }

        /* ===== Chuẩn hoá City/Ward và tách fullAddress (phục hồi ward chính xác hơn) ===== */

        private static string NormalizeCity(string s)
        {
            if (string.IsNullOrWhiteSpace(s)) return "";
            s = s.Trim();
            s = Regex.Replace(s, @"^(tỉnh|thành\s*phố|tp\.?)\s*", "", RegexOptions.IgnoreCase);
            s = Regex.Replace(s, @"\s{2,}", " ");
            return s;
        }

        private static string NormalizeWard(string s)
        {
            if (string.IsNullOrWhiteSpace(s)) return "";
            s = s.Trim();
            s = Regex.Replace(s, @"\s*[-,–]\s*(quận|huyện|thị\s*xã|thành\s*phố|q\.|h\.|tx\.|tp\.).*$",
                              "", RegexOptions.IgnoreCase);
            s = Regex.Replace(s, @"\s*\(.*?\)\s*", "", RegexOptions.IgnoreCase);
            s = Regex.Replace(s, @"\b0+(\d)", "$1");
            s = Regex.Replace(s, @"\s{2,}", " ");
            return s;
        }

        private static void SplitFullAddress(string full, out string address, out string ward, out string city)
        {
            address = ward = city = "";
            var parts = (full ?? "").Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries)
                                    .Select(p => p.Trim())
                                    .ToArray();

            if (parts.Length == 0) return;

            if (parts.Length == 1)
            {
                address = parts[0];
                return;
            }

            city = NormalizeCity(parts[parts.Length - 1]);

            if (parts.Length >= 4)
            {
                ward = NormalizeWard(parts[parts.Length - 3]);
                address = string.Join(", ", parts.Take(parts.Length - 3));
            }
            else
            {
                ward = NormalizeWard(parts[1]);
                address = parts[0];
            }
        }

        private async Task LoadAddressAsync()
        {
            var idStr = Request.QueryString["id"];
            if (!long.TryParse(idStr, out var id))
            {
                Response.Redirect("UserAddressList.aspx");
                return;
            }
            hfId.Value = id.ToString();

            try
            {
                var token = Request?.Cookies["AuthToken"]?.Value;
                var dto = await _service.GetMyAddressByIdAsync(token, id).ConfigureAwait(false);
                if (dto == null)
                {
                    Response.Redirect("UserAddressList.aspx");
                    return;
                }

                txtFullName.Text = dto.fullName;
                txtPhone.Text = dto.phone;

                SplitFullAddress(dto.fullAddress, out var address, out var ward, out var city);

                txtCitySel.Text = city ?? "";
                txtWardSel.Text = ward ?? "";
                txtCityCode.Text = "";
                txtWardCode.Text = "";
                txtAddress.Text = address ?? "";

                rblType.SelectedValue = (dto.type ?? 0).ToString();
                swDefault.Checked = dto.isDefault;
            }
            catch
            {
                Toast("Không tải được địa chỉ.", "danger");
            }
        }

        protected async void btnSave_Click(object sender, EventArgs e)
        {
            if (!long.TryParse(hfId.Value, out var id)) return;
            if (!ValidateRequired()) return;

            try
            {
                var token = Request?.Cookies["AuthToken"]?.Value;

                var fullAddr = BuildFullAddress();
                Debug.WriteLine($"[UpdateUserAddress] id={id} Built fullAddress = \"{fullAddr}\"");

                var req = new AddressUpdateRequest
                {
                    type = int.TryParse(rblType.SelectedValue, out var t) ? t : (int?)0,
                    isDefault = swDefault.Checked,
                    fullName = txtFullName.Text?.Trim(),
                    phone = txtPhone.Text?.Trim(),
                    fullAddress = fullAddr,
                    status = 1
                };

                Debug.WriteLine($"[UpdateUserAddress] id={id} PUT body = {JsonConvert.SerializeObject(req)}");

                var sw = Stopwatch.StartNew();
                var updated = await _service.UpdateAddressAsync(token, id, req).ConfigureAwait(false);
                sw.Stop();

                Debug.WriteLine($"[UpdateUserAddress] id={id} API duration = {sw.ElapsedMilliseconds} ms");

                // ✅ Redirect kèm ?toast=updated
                RedirectWithToast("~/UserAddress/UserAddressList.aspx", "updated");
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"[UpdateUserAddress] ERROR: {ex}");
                Toast("Không thể lưu địa chỉ.", "danger");
            }
        }

        protected async void btnDelete_Click(object sender, EventArgs e)
        {
            if (!long.TryParse(hfId.Value, out var id)) return;

            try
            {
                var token = Request?.Cookies["AuthToken"]?.Value;
                await _service.DeleteAddressAsync(token, id).ConfigureAwait(false);

                // ✅ Redirect kèm ?toast=deleted
                RedirectWithToast("~/UserAddress/UserAddressList.aspx", "deleted");
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"[UpdateUserAddress] Delete failed: {ex}");
                Toast("Không thể xóa địa chỉ.", "danger");
            }
        }

        private bool ValidateRequired()
        {
            var missing = new List<string>();
            if (string.IsNullOrWhiteSpace(txtFullName.Text)) missing.Add("Họ và tên");
            if (string.IsNullOrWhiteSpace(txtPhone.Text)) missing.Add("Số điện thoại");
            if (string.IsNullOrWhiteSpace(txtCityCode.Text)) missing.Add("Tỉnh/Thành (chọn từ danh sách)");
            if (string.IsNullOrWhiteSpace(txtWardCode.Text)) missing.Add("Phường/Xã (chọn từ danh sách)");
            if (string.IsNullOrWhiteSpace(txtAddress.Text)) missing.Add("Địa chỉ nhận hàng");
            if (string.IsNullOrWhiteSpace(rblType.SelectedValue)) missing.Add("Loại địa chỉ");

            if (missing.Count > 0)
            {
                Toast("Vui lòng điền: " + string.Join(", ", missing), "danger");
                return false;
            }
            return true;
        }

        private void Toast(string message, string variant)
        {
            var js = $"showToast({HttpUtility.JavaScriptStringEncode(message, true)}, '{variant}');";
            ClientScript.RegisterStartupScript(this.GetType(), Guid.NewGuid().ToString(), js, true);
        }

        private void RedirectWithToast(string relativeUrl, string toastKey)
        {
            var url = VirtualPathUtility.ToAbsolute(relativeUrl);
            url += (url.Contains("?") ? "&" : "?") + "toast=" + HttpUtility.UrlEncode(toastKey) + "&ts=" + DateTime.UtcNow.Ticks;
            Response.Redirect(url, false);
            Context.ApplicationInstance.CompleteRequest();
        }

        private string BuildFullAddress()
        {
            var city = (txtCitySel.Text ?? "").Trim();
            var ward = (txtWardSel.Text ?? "").Trim();
            var address = (txtAddress.Text ?? "").Trim();

            string Join(params string[] arr)
                => string.Join(", ", Array.FindAll(arr, p => !string.IsNullOrWhiteSpace(p)));

            return Join(address, ward, city);
        }
    }
}
