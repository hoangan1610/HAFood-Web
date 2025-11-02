using HAFoodWeb.Models;
using HAFoodWeb.Services;
using System;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace HAFoodWeb
{
    public partial class AddressSelect : Page
    {
        private readonly IAddressService _addrService = new AddressService();

        protected async void Page_Load(object sender, EventArgs e)
        {
            // Bắt buộc đăng nhập (dựa trên cookie token)
            if (Request.Cookies["AuthToken"] == null || string.IsNullOrWhiteSpace(Request.Cookies["AuthToken"].Value))
            {
                var ret = Server.UrlEncode(Request.RawUrl);
                var url = "~/AuthPage/Login.aspx?returnUrl=" + ret;

                // Tránh ThreadAbortException
                Response.Redirect(url, false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            if (!IsPostBack)
            {
                // resolve returnUrl
                var retUrl = Request.QueryString["returnUrl"];
                if (string.IsNullOrWhiteSpace(retUrl))
                    retUrl = ResolveUrl("~/CartPage/CartPage.aspx");
                hfReturnUrl.Value = retUrl;

                lnkBack.HRef = retUrl;
                lnkCancel.HRef = retUrl;

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

            // Radio được render bằng Literal để set checked server-side
            lit.Text = $"<input class='addr-radio' type='radio' name='addrSel' value='{dto.id}'{chk} />";
        }

        protected async void btnConfirm_Click(object sender, EventArgs e)
        {
            // Giá trị radio theo name=addrSel
            var selected = Request.Form["addrSel"];
            if (string.IsNullOrWhiteSpace(selected))
            {
                Response.Redirect(hfReturnUrl.Value, false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            if (!long.TryParse(selected, out var id)) return;

            var token = Request.Cookies["AuthToken"]?.Value;
            var list = await _addrService.GetMyAddressesAsync(token, onlyActive: true);
            var pick = list?.FirstOrDefault(a => a.id == id);
            if (pick != null)
            {
                // Lưu vào session để CartPage tiêu thụ
                Session["selected_address_obj"] = pick;
            }

            Response.Redirect(hfReturnUrl.Value, false);
            Context.ApplicationInstance.CompleteRequest();
        }
    }
}
