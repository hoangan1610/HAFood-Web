using HAFoodWeb.Models;
using HAFoodWeb.Services;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Web;

namespace HAFoodWeb.UserAddress
{
    public partial class CreateUserAddress : System.Web.UI.Page
    {
        private readonly IAddressService _service = new AddressService();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session == null || Session["UserId"] == null)
            {
                Response.Redirect("~/AuthPage/Login.aspx");
                return;
            }
        }

        protected async void btnSave_Click(object sender, EventArgs e)
        {
            if (!ValidateRequired()) return;

            try
            {
                var token = Request?.Cookies["AuthToken"]?.Value;

                var fullAddr = BuildFullAddress();
                Debug.WriteLine($"[CreateUserAddress] Built fullAddress = \"{fullAddr}\"");

                var request = new AddressCreateRequest
                {
                    type = int.TryParse(rblType.SelectedValue, out var t) ? t : (int?)0,
                    isDefault = swDefault.Checked,
                    fullName = txtFullName.Text?.Trim(),
                    phone = txtPhone.Text?.Trim(),
                    fullAddress = fullAddr
                };

                Debug.WriteLine($"[CreateUserAddress] POST body = {JsonConvert.SerializeObject(request)}");

                var sw = Stopwatch.StartNew();
                var created = await _service.CreateAddressAsync(token, request).ConfigureAwait(false);
                sw.Stop();

                Debug.WriteLine($"[CreateUserAddress] API duration = {sw.ElapsedMilliseconds} ms");
                Debug.WriteLine($"[CreateUserAddress] Response DTO = {JsonConvert.SerializeObject(created)}");

                if (swDefault.Checked && created != null && !created.isDefault)
                {
                    try { await _service.SetDefaultAsync(token, created.id).ConfigureAwait(false); }
                    catch (Exception ex) { Debug.WriteLine($"[CreateUserAddress] SetDefault failed: {ex.Message}"); }
                }

                // ✅ KHÔNG gọi Toast trước Redirect (sẽ không hiển thị)
                RedirectWithToast("~/UserAddress/UserAddressList.aspx", "created");
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"[CreateUserAddress] ERROR: {ex}");
                // ❗Lỗi: hiển thị ngay ở trang hiện tại bằng Bootstrap toast đỏ
                Toast("Không thể lưu địa chỉ. Vui lòng thử lại.", "danger");
            }
        }

        private bool ValidateRequired()
        {
            var missing = new List<string>();
            if (string.IsNullOrWhiteSpace(txtFullName.Text)) missing.Add("Họ và tên");
            if (string.IsNullOrWhiteSpace(txtPhone.Text)) missing.Add("Số điện thoại");
            // BẮT BUỘC chọn từ danh sách (code phải có)
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
            url += (url.Contains("?") ? "&" : "?") + "toast=" + HttpUtility.UrlEncode(toastKey);
            Response.Redirect(url, false);
            Context.ApplicationInstance.CompleteRequest();
        }

        private string BuildFullAddress()
        {
            var city = (txtCitySel.Text ?? "").Trim();   // tên hiển thị
            var ward = (txtWardSel.Text ?? "").Trim();   // tên hiển thị
            var address = (txtAddress.Text ?? "").Trim();

            string Join(params string[] parts)
                => string.Join(", ", Array.FindAll(parts, p => !string.IsNullOrWhiteSpace(p)));

            return Join(address, ward, city);
        }
    }
}
