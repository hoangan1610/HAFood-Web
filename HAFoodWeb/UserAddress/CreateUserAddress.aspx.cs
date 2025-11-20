using HAFoodWeb.Models;
using HAFoodWeb.Services;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Web;
using System.Text.RegularExpressions;
using System.Web.UI; // cần cho ScriptManager

namespace HAFoodWeb.UserAddress
{
    public partial class CreateUserAddress : System.Web.UI.Page
    {
        private readonly IAddressService _service = new AddressService();

        private bool IsEmbed() => "1".Equals(Request["embed"]);

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

                if (created != null) Session["selected_address_obj"] = created;

                if (IsEmbed())
                {
                    var back = ResolveUrl("~/CartPage/AddressSelect.aspx?refresh=1&t=" + DateTimeOffset.UtcNow.ToUnixTimeMilliseconds());
                    Response.Redirect(back, false);
                    Context.ApplicationInstance.CompleteRequest();
                    return;
                }

                RedirectWithToast("~/UserAddress/UserAddressList.aspx", "created");
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"[CreateUserAddress] ERROR: {ex}");
                Toast("Không thể lưu địa chỉ. Vui lòng thử lại.", "danger");
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

            var errs = new List<string>();

            var name = (txtFullName.Text ?? "").Trim();
            if (!Regex.IsMatch(name, @"^[\p{L}\s]+$", RegexOptions.CultureInvariant))
                errs.Add("Họ và tên không được chứa ký tự đặc biệt");

            var phone = (txtPhone.Text ?? "").Trim();
            if (!Regex.IsMatch(phone, @"^\d{10}$"))
                errs.Add("Số điện thoại phải gồm đúng 10 chữ số");
            if (!Regex.IsMatch(phone, @"^0"))
                errs.Add("Số điện thoại phải bắt đầu bằng số 0");

            var address = (txtAddress.Text ?? "").Trim();
            if (!Regex.IsMatch(address, @"^[\p{L}\d\s,\.\-\/]+$", RegexOptions.CultureInvariant))
                errs.Add("Địa chỉ nhận hàng không được chứa ký tự đặc biệt");

            if (errs.Count > 0)
            {
                Toast("Vui lòng kiểm tra:\n• " + string.Join("\n• ", errs), "danger");
                return false;
            }
            return true;
        }

        private void Toast(string message, string variant)
        {
            var msg = HttpUtility.JavaScriptStringEncode(message, true);
            var key = "toast_" + Guid.NewGuid().ToString("N");

            var js = $@"
(function() {{
  function fire() {{
    if (window.showToast) {{
      window.showToast({msg}, '{variant}');
    }} else {{
      setTimeout(fire, 50);
    }}
  }}
  if (document.readyState === 'complete') fire();
  else window.addEventListener('load', fire);
}})();";

            var sm = ScriptManager.GetCurrent(this);
            if (sm != null)
                ScriptManager.RegisterStartupScript(this, GetType(), key, js, true);
            else
                ClientScript.RegisterStartupScript(GetType(), key, js, true);
        }

        private void RedirectWithToast(string relativeUrl, string toastKey)
        {
            var url = VirtualPathUtility.ToAbsolute(relativeUrl);
            // thêm ts để tránh cache URL cũ
            url += (url.Contains("?") ? "&" : "?") + "toast=" + HttpUtility.UrlEncode(toastKey) + "&ts=" + DateTime.UtcNow.Ticks;
            Response.Redirect(url, false);
            Context.ApplicationInstance.CompleteRequest();
        }

        private string BuildFullAddress()
        {
            var city = (txtCitySel.Text ?? "").Trim();
            var ward = (txtWardSel.Text ?? "").Trim();
            var address = (txtAddress.Text ?? "").Trim();

            string Join(params string[] parts)
                => string.Join(", ", Array.FindAll(parts, p => !string.IsNullOrWhiteSpace(p)));

            return Join(address, ward, city);
        }
    }
}
