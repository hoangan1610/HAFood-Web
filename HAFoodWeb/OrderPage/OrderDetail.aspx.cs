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
                if (!long.TryParse(Request.QueryString["id"], out long id) || id <= 0)
                {
                    litDebug.Text = "<pre>❌ Id không hợp lệ.</pre>";
                    litDebug.Visible = true;
                    return;
                }

                // ensure utf-8 output
                Response.ContentEncoding = Encoding.UTF8;
                Response.Charset = "utf-8";

                await LoadOrderDetailAsync(id);
            }
        }

        private async Task LoadOrderDetailAsync(long id)
        {
            try
            {
                Debug.WriteLine($"📦 Gọi API lấy chi tiết đơn hàng id={id}");
                var detail = await _orderService.GetOrderDetailAsync(id);

                if (detail == null || detail.header == null)
                {
                    litDebug.Text = "<pre>❌ Không tìm thấy đơn hàng hoặc API lỗi.</pre>";
                    litDebug.Visible = true;
                    return;
                }

                var h = detail.header;

                // decode entities vì API có thể trả chuỗi đã encode (ví dụ "Trần H&#249;ng")
                string Decode(string s) => string.IsNullOrEmpty(s) ? "" : HttpUtility.HtmlDecode(s);

                // Header (no total here)
                litOrderCode.InnerText = Decode(h.order_Code ?? $"#{h.id}");
                litShipName.InnerText = Decode(h.ship_Name ?? "");
                litShipPhone.InnerText = Decode(h.ship_Phone ?? "");
                litShipAddress.InnerText = Decode(h.ship_Full_Address ?? "");
                litNote.InnerText = Decode(h.note ?? "");

                // Payment: đặt dưới ghi chú, chỉ hiện nếu có giá trị
                string paymentText = null;
                if (!string.IsNullOrWhiteSpace(h.payment_Provider))
                    paymentText = Decode(h.payment_Provider);
                else if (!string.IsNullOrWhiteSpace(h.payment_Status))
                    paymentText = Decode(h.payment_Status);
                else if (h.payment_Method.HasValue)
                    paymentText = h.payment_Method.Value.ToString();

                if (!string.IsNullOrWhiteSpace(paymentText))
                {
                    litPayment.InnerText = paymentText;
                    pnlPayment.Visible = true;
                }
                else
                {
                    pnlPayment.Visible = false;
                }

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

                // Summary (totals) — only place showing totals
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
                Debug.WriteLine("❌ LoadOrderDetailAsync error: " + ex);
                litDebug.Text = "<pre>" + Server.HtmlEncode(ex.ToString()) + "</pre>";
                litDebug.Visible = true;
            }
        }

        private string GetStatusText(int status)
        {
            switch (status)
            {
                case 0: return "Chờ xác nhận";
                case 1: return "Đã xác nhận";
                case 2: return "Đang giao";
                case 3: return "Đã giao";
                case 4: return "Đã hủy";
                default: return "Không rõ";
            }
        }
    }
}