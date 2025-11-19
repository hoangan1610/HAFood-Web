using System;
using System.Globalization;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;

namespace HAFoodWeb.Cart
{
    public partial class CartItem : UserControl
    {
        private HtmlGenericControl Wrap => (HtmlGenericControl)FindControl("wrap");

        public long LineId
        {
            get => ViewState["LineId"] is long v ? v : 0L;
            set => ViewState["LineId"] = value;
        }

        public long VariantId
        {
            get => ViewState["VariantId"] is long v ? v : 0L;
            set => ViewState["VariantId"] = value;
        }

        public string ProductName
        {
            set { litProductName.Text = HttpUtility.HtmlEncode(value ?? ""); }
        }

        public string VariantName
        {
            set { litVariantName.Text = HttpUtility.HtmlEncode(value ?? ""); }
        }

        public string ImageUrl
        {
            set { imgProduct.Src = string.IsNullOrWhiteSpace(value) ? "/images/product-default.png" : value; }
        }

        public decimal WeightPerUnit
        {
            get => ViewState["WeightPerUnit"] is decimal v ? v : 0m;
            set => ViewState["WeightPerUnit"] = value;
        }

        public decimal Price
        {
            get => ViewState["Price"] is decimal v ? v : 0m;
            set
            {
                ViewState["Price"] = value;
                litPrice.Text = string.Format(
                    System.Globalization.CultureInfo.GetCultureInfo("vi-VN"),
                    "{0:N0} ₫", value);
                UpdateTotal();
            }
        }

        public int Quantity
        {
            get => ViewState["Quantity"] is int v ? v : 1;
            set
            {
                ViewState["Quantity"] = value;
                litQty.Text = Math.Max(1, value).ToString();
                UpdateTotal();
            }
        }

        public bool Selected
        {
            get => chkSelect.Checked;
            set => chkSelect.Checked = value;
        }

        protected void Page_PreRender(object sender, EventArgs e)
        {
            // gán data-* để JS đọc
            if (Wrap != null)
            {
                Wrap.Attributes["class"] = "cart-item";

                if (LineId > 0) Wrap.Attributes["data-line-id"] = LineId.ToString();
                else Wrap.Attributes.Remove("data-line-id");

                if (VariantId > 0) Wrap.Attributes["data-variant-id"] = VariantId.ToString();
                else Wrap.Attributes.Remove("data-variant-id");

                Wrap.Attributes["data-price"] = Price.ToString(System.Globalization.CultureInfo.InvariantCulture);

                Wrap.Attributes["data-weight"] = WeightPerUnit.ToString(CultureInfo.InvariantCulture);
            }

            // đảm bảo số lượng > 0 và sync literal
            if (string.IsNullOrEmpty(litQty.Text))
                litQty.Text = Math.Max(1, Quantity).ToString();

            UpdateTotal();
        }

        private void UpdateTotal()
        {
            var total = Price * Math.Max(1, Quantity);
            litTotal.Text = string.Format(
                System.Globalization.CultureInfo.GetCultureInfo("vi-VN"),
                "{0:N0} ₫", total);
        }
    }
}
