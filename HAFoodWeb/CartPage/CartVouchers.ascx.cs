using System;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace HAFoodWeb.Cart
{
    public partial class CartVouchers : UserControl
    {
        public HiddenField HidApiBase;
        public HiddenField HidJwt;
        public HiddenField HidDeviceUuid;

        public string TxtPromoClientId;
        public string LblSubtotalClientId;
        public string LblVatClientId;
        public string LblShippingClientId;
        public string LblDiscountClientId;
        public string LblGrandClientId;
        public string HidSelectedLinesClientId;

        public string HidPromoCodeClientId;
        public string HidPromoDiscountClientId;
        public string HidPromoMetaJsonClientId;

        protected void Page_Load(object sender, EventArgs e)
        {
            // KHÔNG ép kiểu Page sang CartPage nữa
            var page = this.Page;

            // HiddenField trên trang
            HidApiBase = page.FindControl("hidApiBase") as HiddenField;
            HidJwt = page.FindControl("hidJwt") as HiddenField;
            HidDeviceUuid = page.FindControl("hidDeviceUuid") as HiddenField;

            // Lấy ClientID an toàn (null => "")
            TxtPromoClientId = page.FindControl("txtPromo")?.ClientID ?? "";
            LblSubtotalClientId = page.FindControl("lblSubtotal")?.ClientID ?? "";
            LblVatClientId = page.FindControl("lblVat")?.ClientID ?? "";
            LblShippingClientId = page.FindControl("lblShipping")?.ClientID ?? "";
            LblDiscountClientId = page.FindControl("lblDiscount")?.ClientID ?? "";
            LblGrandClientId = page.FindControl("lblGrandTotal")?.ClientID ?? "";
            HidSelectedLinesClientId = page.FindControl("hidSelectedLines")?.ClientID ?? "";

            HidPromoCodeClientId = page.FindControl("hidPromoCodeSelected")?.ClientID ?? "";
            HidPromoDiscountClientId = page.FindControl("hidPromoDiscount")?.ClientID ?? "";
            HidPromoMetaJsonClientId = page.FindControl("hidPromoMetaJson")?.ClientID ?? "";
        }
    }
}
