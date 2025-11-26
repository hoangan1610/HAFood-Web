using HAFoodWeb.Models;
using HAFoodWeb.Services;
using System;
using System.Diagnostics;
using System.Globalization;
using System.Threading.Tasks;
using System.Web;
using System.Web.UI;
using System.Text;

namespace HAFoodWeb
{
    public partial class OrderDetail : Page
    {
        private readonly IOrderService _orderService = new OrderService();

        protected async void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // đảm bảo output UTF-8
                Response.ContentEncoding = Encoding.UTF8;
                Response.Charset = "utf-8";

                // Nhận cả id hoặc code qua ?id= / ?code=
                var raw = Request.QueryString["code"];
                if (string.IsNullOrWhiteSpace(raw))
                    raw = Request.QueryString["id"]; // vẫn giữ backward-compat

                if (string.IsNullOrWhiteSpace(raw))
                {
                    litDebug.Text = "<pre>❌ Thiếu tham số mã/ID đơn hàng.</pre>";
                    litDebug.Visible = true;
                    return;
                }

                await LoadOrderDetailSmartAsync(raw.Trim());
            }
        }

        private async Task LoadOrderDetailSmartAsync(string codeOrId)
        {
            try
            {
                Debug.WriteLine($"📦 Gọi API lấy chi tiết đơn hàng smart key={codeOrId}");
                var detail = await _orderService.GetOrderDetailSmartAsync(codeOrId);

                if (detail == null || detail.header == null)
                {
                    litDebug.Text = "<pre>❌ Không tìm thấy đơn hàng hoặc API lỗi.</pre>";
                    litDebug.Visible = true;
                    return;
                }

                var h = detail.header;
                string Decode(string s) => string.IsNullOrEmpty(s) ? "" : HttpUtility.HtmlDecode(s);

                // Header
                litOrderCode.InnerText = Decode(h.order_Code ?? $"#{h.id}");
                litShipName.InnerText = Decode(h.ship_Name ?? "");
                litShipPhone.InnerText = Decode(h.ship_Phone ?? "");
                litShipAddress.InnerText = Decode(h.ship_Full_Address ?? "");
                litNote.InnerText = Decode(h.note ?? "");

                // Thanh toán
                string paymentText = "";
                if (!string.IsNullOrWhiteSpace(h.payment_Provider))
                {
                    string provider = h.payment_Provider.ToUpperInvariant();
                    string status = (h.payment_Status ?? "").Trim().ToLowerInvariant();

                    if (provider == "VNPAY")
                    {
                        if (status == "pending") paymentText = "VNPAY – Đang chờ thanh toán";
                        else if (status == "paid") paymentText = "VNPAY – Đã thanh toán";
                        else paymentText = "VNPAY";
                    }
                    else
                    {
                        paymentText = Decode(h.payment_Provider);
                    }
                }
                else if (h.payment_Method.HasValue)
                {
                    switch (h.payment_Method.Value)
                    {
                        case 1: paymentText = "Thanh toán khi nhận hàng"; break;
                        case 2: paymentText = "Chuyển khoản ngân hàng"; break;
                        default: paymentText = "COD"; break;
                    }
                }
                else
                {
                    paymentText = "COD";
                }

                pnlPayment.Visible = !string.IsNullOrWhiteSpace(paymentText);
                if (pnlPayment.Visible) litPayment.InnerText = paymentText;

                // Trạng thái đơn
                litStatus.InnerText = GetStatusText(h.status);

                // Items
                if (detail.items != null && detail.items.Count > 0)
                {
                    rpItems.DataSource = detail.items;
                    rpItems.DataBind();
                    pnlItems.Visible = true;
                }
                else
                {
                    pnlItems.Visible = false;
                }

                // Summary
                litSubtotal.Text = string.Format(new CultureInfo("vi-VN"), "{0:#,0}đ", h.sub_Total);
                litDiscount.Text = string.Format(new CultureInfo("vi-VN"), "{0:#,0}đ", h.discount_Total);
                litShipping.Text = string.Format(new CultureInfo("vi-VN"), "{0:#,0}đ", h.shipping_Total);
                litVat.Text = string.Format(new CultureInfo("vi-VN"), "{0:#,0}đ", h.vat_Total);
                litPayTotal.Text = string.Format(new CultureInfo("vi-VN"), "{0:#,0}đ", h.pay_Total);

                pnlHeader.Visible = true;
                pnlSummary.Visible = true;
            }
            catch (Exception ex)
            {
                Debug.WriteLine("❌ LoadOrderDetailSmartAsync error: " + ex);
                litDebug.Text = "<pre>" + Server.HtmlEncode(ex.ToString()) + "</pre>";
                litDebug.Visible = true;
            }
        }

        private string GetStatusText(int status)
        {
            switch (status)
            {
                case 0: return "Đã được tạo ";
                case 1: return "Xác nhận";
                case 2: return "Đang giao";
                case 3: return "Đã giao";
                case 4: return "Đã hủy";
                default: return "Không rõ";
            }
        }
    }
}
