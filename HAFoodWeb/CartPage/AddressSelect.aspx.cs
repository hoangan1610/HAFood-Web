using HAFoodWeb.Models;
using HAFoodWeb.Services;
using System;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Script.Serialization; // <-- thêm để serialize payload

namespace HAFoodWeb
{
    public partial class AddressSelect : Page
    {
        private readonly IAddressService _addrService = new AddressService();

        protected async void Page_Load(object sender, EventArgs e)
        {
            // Bắt buộc đăng nhập — nếu thiếu token thì redirect TOÀN TRANG (không hiển thị login trong popup)
            if (Request.Cookies["AuthToken"] == null || string.IsNullOrWhiteSpace(Request.Cookies["AuthToken"].Value))
            {
                var ret = Server.UrlEncode(ResolveUrl("~/CartPage/CartPage.aspx"));
                var url = "~/AuthPage/Login.aspx?returnUrl=" + ret;
                Response.Redirect(url, false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            if (!IsPostBack)
            {
                await BindAddresses();
            }
        }

        private async Task BindAddresses()
        {
            var token = Request.Cookies["AuthToken"]?.Value;

            var list = await _addrService.GetMyAddressesAsync(token, onlyActive: true);
            var arr = (list ?? Array.Empty<AddressDto>()).ToArray();

            // Xác định id chọn trước: ưu tiên session selected -> mặc định -> cái đầu tiên
            long? preId = null;
            var chosen = Session["selected_address_obj"] as AddressDto;
            if (chosen != null) preId = chosen.id;
            if (preId == null) preId = arr.FirstOrDefault(a => a.isDefault)?.id;
            if (preId == null) preId = arr.FirstOrDefault()?.id;
            hfSelectedId.Value = preId?.ToString() ?? "";

            rptAddresses.DataSource = arr;
            rptAddresses.DataBind();

            pnlEmpty.Visible = arr.Length == 0;
        }

        protected void rptAddresses_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item && e.Item.ItemType != ListItemType.AlternatingItem) return;

            var dto = (AddressDto)e.Item.DataItem;
            var lit = (Literal)e.Item.FindControl("litRadio");

            var selected = (!string.IsNullOrWhiteSpace(hfSelectedId.Value) &&
                            long.TryParse(hfSelectedId.Value, out var sid) && sid == dto.id);
            var chk = selected ? " checked" : "";

            // Radio render bằng Literal để set checked server-side
            lit.Text = $"<input class='addr-radio' type='radio' name='addrSel' value='{dto.id}'{chk} />";
        }

        protected async void btnConfirm_Click(object sender, EventArgs e)
        {
            // Giá trị radio theo name=addrSel
            var selected = Request.Form["addrSel"];
            if (string.IsNullOrWhiteSpace(selected) || !long.TryParse(selected, out var id))
            {
                await BindAddresses();
                return;
            }

            var token = Request.Cookies["AuthToken"]?.Value;
            var list = await _addrService.GetMyAddressesAsync(token, onlyActive: true);
            var pick = list?.FirstOrDefault(a => a.id == id);
            if (pick != null)
            {
                // Lưu vào session để CartPage tiêu thụ khi fallback
                Session["selected_address_obj"] = pick;
            }

            // ==> GỬI KÈM PAYLOAD trực tiếp qua postMessage
            var payload = new
            {
                id = pick?.id,
                fullName = pick?.fullName,
                phone = pick?.phone,
                fullAddress = pick?.fullAddress
            };
            var json = new JavaScriptSerializer().Serialize(payload);

            // Bridge page: bắn message và để parent tự đóng popup
            Response.Clear();
            Response.ContentType = "text/html; charset=utf-8";
            Response.Write($@"<!DOCTYPE html><html><head><meta charset='utf-8'><title>Đang đóng…</title></head>
<body style='font:14px system-ui'>
<script>
  (function(){{
    var dto = {json};
    try {{
      window.parent && window.parent.postMessage({{ type: 'HAFood.AddressPicked', address: dto }}, '*');
    }} catch(_){{
    }}
  }})();
</script>
Đã chọn địa chỉ. Bạn có thể đóng cửa sổ này.
</body></html>");
            Response.End();
        }
    }
}
