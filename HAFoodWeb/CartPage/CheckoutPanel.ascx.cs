using System;
using System.Globalization;
using System.Web.UI;

namespace HAFoodWeb.Cart
{
    public partial class CheckoutPanel : UserControl
    {
        // Event để Page bắt được khi người dùng nhấn đặt hàng
        public event EventHandler PlaceOrderClicked;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // demo: bạn có thể load danh sách tỉnh/quận từ API nếu cần.
                ddlProvince.Items.Clear();
                ddlProvince.Items.Add("Chọn tỉnh");
                ddlProvince.Items.Add("Bắc Giang");
                ddlProvince.Items.Add("Hà Nội");

                ddlDistrict.Items.Clear();
                ddlDistrict.Items.Add("Chọn quận");
                ddlDistrict.Items.Add("Huyện Lục Ngạn");

                ddlWard.Items.Clear();
                ddlWard.Items.Add("Chọn phường");
                ddlWard.Items.Add("Xã Hộ Đáp");

                UpdateSummary(0, 0m, 0m);
            }
        }

        // Public setter để page gọi khi bind cart
        public void UpdateSummary(int totalItems, decimal subtotal, decimal shipping)
        {
            lblTotalItems.Text = totalItems.ToString();
            lblSubtotal.Text = FormatVnd(subtotal);
            lblShipping.Text = FormatVnd(shipping);
            var vat = Math.Round(subtotal * 0.08m);
            lblVat.Text = FormatVnd(vat);
            var totalPay = subtotal + shipping + vat;
            lblTotalPay.Text = FormatVnd(totalPay);
        }

        public string ReceiverName => txtName.Text?.Trim() ?? "";
        public string ReceiverPhone => txtPhone.Text?.Trim() ?? "";
        public string ReceiverAddress => txtAddress.Text?.Trim() ?? "";
        public string Province => ddlProvince.SelectedValue;
        public string District => ddlDistrict.SelectedValue;
        public string Ward => ddlWard.SelectedValue;

        protected void btnPlaceOrder_Click(object sender, EventArgs e)
        {
            PlaceOrderClicked?.Invoke(this, EventArgs.Empty);
        }

        private string FormatVnd(decimal v)
        {
            var vi = CultureInfo.GetCultureInfo("vi-VN");
            return string.Format(vi, "{0:N0} ₫", v);
        }
    }
}