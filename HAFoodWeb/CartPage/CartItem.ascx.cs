using System;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace HAFoodWeb.Cart
{
    public partial class CartItem : UserControl
    {
        public event EventHandler SelectionChanged;

        public long LineId
        {
            get { return ViewState["LineId"] != null ? (long)ViewState["LineId"] : 0L; }
            set { ViewState["LineId"] = value; }
        }

        public long VariantId
        {
            get { return ViewState["VariantId"] != null ? (long)ViewState["VariantId"] : 0L; }
            set
            {
                ViewState["VariantId"] = value;
                try
                {
                    btnDecrease.CommandArgument = value.ToString();
                    btnIncrease.CommandArgument = value.ToString();
                    btnRemove.CommandArgument = value.ToString();
                }
                catch { }
            }
        }

        public string ProductName { set { litProductName.Text = Server.HtmlEncode(value ?? ""); } }
        public string VariantName { set { litVariantName.Text = Server.HtmlEncode(value ?? ""); } }
        public string ImageUrl { set { imgProduct.Src = value ?? "/images/product-default.png"; } }
        public decimal WeightPerUnit { get; set; } // gram

        public decimal Price
        {
            get { return ViewState["Price"] != null ? (decimal)ViewState["Price"] : 0m; }
            set
            {
                ViewState["Price"] = value;
                litPrice.Text = string.Format(System.Globalization.CultureInfo.GetCultureInfo("vi-VN"), "{0:N0} ₫", value);
                UpdateTotal();
            }
        }

        public int Quantity
        {
            get { return ViewState["Quantity"] != null ? (int)ViewState["Quantity"] : 0; }
            set
            {
                ViewState["Quantity"] = value;
                litQty.Text = value.ToString();
                try
                {
                    if (value <= 1)
                    {
                        btnDecrease.Enabled = false;
                        btnDecrease.CssClass = "qty-btn btn-qty-disabled";
                    }
                    else
                    {
                        btnDecrease.Enabled = true;
                        btnDecrease.CssClass = "qty-btn";
                    }
                }
                catch { }
                UpdateTotal();
            }
        }

        public bool Selected { get { return chkSelect.Checked; } set { chkSelect.Checked = value; } }

        protected void chkSelect_CheckedChanged(object sender, EventArgs e)
        {
            SelectionChanged?.Invoke(this, EventArgs.Empty);
        }

        private void UpdateTotal()
        {
            var total = Price * Quantity;
            litTotal.Text = string.Format(System.Globalization.CultureInfo.GetCultureInfo("vi-VN"), "{0:N0} ₫", total);
        }

        protected override bool OnBubbleEvent(object source, EventArgs args)
        {
            if (args is CommandEventArgs cmd)
            {
                RaiseBubbleEvent(this, cmd);
                return true;
            }
            return base.OnBubbleEvent(source, args);
        }
    }
}
