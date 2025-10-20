using System;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace HAFoodWeb.Cart
{
    public partial class CartItem : UserControl
    {
        public event EventHandler SelectionChanged;

        public long VariantId
        {
            get { return ViewState["VariantId"] != null ? (long)ViewState["VariantId"] : 0L; }
            set
            {
                ViewState["VariantId"] = value;
                try
                {
                    // đảm bảo nút có CommandArgument ngay khi setter được gọi
                    btnDecrease.CommandArgument = value.ToString();
                    btnIncrease.CommandArgument = value.ToString();
                    btnRemove.CommandArgument = value.ToString();
                }
                catch { /* control có thể chưa khởi tạo */ }
            }
        }

        public string ProductName
        {
            set { litProductName.Text = Server.HtmlEncode(value ?? ""); }
        }

        public string VariantName
        {
            set { litVariantName.Text = Server.HtmlEncode(value ?? ""); }
        }

        public string ImageUrl
        {
            set
            {
                var url = value ?? "/images/product-default.png";
                imgProduct.Src = url;
            }
        }

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
                // nếu quantity <= 1 thì disable nút decrease (không cho giảm xuống 0)
                try
                {
                    if (value <= 1)
                    {
                        btnDecrease.Enabled = false;
                        // style để trông disabled (an toàn ngay cả khi control render <span>)
                        btnDecrease.CssClass = "btn-qty btn-qty-disabled";
                    }
                    else
                    {
                        btnDecrease.Enabled = true;
                        btnDecrease.CssClass = "btn-qty";
                    }
                }
                catch { /* ignore nếu control chưa sẵn sàng */ }

                UpdateTotal();
            }
        }

        public bool Selected
        {
            get { return chkSelect.Checked; }
            set { chkSelect.Checked = value; }
        }

        protected void chkSelect_CheckedChanged(object sender, EventArgs e)
        {
            SelectionChanged?.Invoke(this, EventArgs.Empty);
        }

        private void UpdateTotal()
        {
            litTotal.Text = string.Format(System.Globalization.CultureInfo.GetCultureInfo("vi-VN"), "{0:N0} ₫", Price * Quantity);
        }
    }
}