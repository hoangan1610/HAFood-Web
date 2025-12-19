using HAFoodWeb.Models;
using HAFoodWeb.Services;
using Newtonsoft.Json; // ✅ dùng để đổ JSON sang hidden field
using System;
using System.Diagnostics;
using System.Globalization;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using System.Web.UI;
using System.Text;

namespace HAFoodWeb
{
    public partial class OrderDetail : Page
    {
        private readonly IOrderService _orderService = new OrderService();

        public bool CanReview { get; private set; } = false;
        public bool CanCancel { get; private set; } = false;

        protected async void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Response.ContentEncoding = Encoding.UTF8;
                Response.Charset = "utf-8";

                var raw = Request.QueryString["code"];
                if (string.IsNullOrWhiteSpace(raw))
                    raw = Request.QueryString["id"];

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
                Debug.WriteLine("📦 Gọi API lấy chi tiết đơn hàng smart key=" + codeOrId);
                var detail = await _orderService.GetOrderDetailSmartAsync(codeOrId);

                if (detail == null || detail.header == null)
                {
                    litDebug.Text = "<pre>❌ Không tìm thấy đơn hàng hoặc API lỗi.</pre>";
                    litDebug.Visible = true;
                    return;
                }

                var h = detail.header;

                Func<string, string> Decode = s =>
                    string.IsNullOrEmpty(s) ? "" : HttpUtility.HtmlDecode(s);

                // ===== Header =====
                litOrderCode.InnerText = Decode(h.order_Code ?? ("#" + h.id));
                litShipName.InnerText = Decode(h.ship_Name ?? "");
                litShipPhone.InnerText = Decode(h.ship_Phone ?? "");
                litShipAddress.InnerText = Decode(h.ship_Full_Address ?? "");
                litNote.InnerText = Decode(h.note ?? "");

                // ===== Payment helpers =====
                Func<string, string> NiceProvider = p =>
                {
                    p = (p ?? "").Trim();
                    if (p.Length == 0) return "";
                    var up = p.ToUpperInvariant();
                    if (up == "PAY2S") return "Pay2S";
                    if (up == "ZALOPAY") return "ZaloPay";
                    if (up == "VNPAY") return "VNPAY";
                    if (up == "COD") return "COD";
                    return p;
                };

                Func<string, string> NiceStatus = s =>
                {
                    s = (s ?? "").Trim();
                    if (s.Length == 0) return "";
                    var lo = s.ToLowerInvariant();
                    if (lo == "paid") return "Đã thanh toán";
                    if (lo == "pending") return "Đang chờ thanh toán";
                    if (lo == "unpaid") return "Chưa thanh toán";
                    if (lo == "failed") return "Thất bại";
                    return s;
                };

                Func<byte?, string> FromMethod = m =>
                {
                    if (!m.HasValue) return "";
                    switch (m.Value)
                    {
                        case 0: return "COD";
                        case 1: return "ZaloPay";
                        case 2: return "Pay2S";
                        default: return "Khác";
                    }
                };

                Func<string, bool> IsPaid = s =>
                {
                    s = (s ?? "").Trim().ToLowerInvariant();
                    return s == "paid" || s == "success" || s == "succeeded";
                };

                // ===== Payment build (LUÔN HIỆN) =====
                string providerTxt = NiceProvider(h.payment_Provider);
                if (string.IsNullOrWhiteSpace(providerTxt))
                    providerTxt = FromMethod(h.payment_Method);

                if (string.IsNullOrWhiteSpace(providerTxt))
                    providerTxt = "COD";

                string statusRaw = (h.payment_Status ?? "");
                string statusTxt = NiceStatus(statusRaw);

                string providerUp = providerTxt.Trim().ToUpperInvariant();
                string paymentText;

                if (providerUp == "COD")
                {
                    paymentText = "COD – Thanh toán khi nhận hàng";
                }
                else
                {
                    if (string.IsNullOrWhiteSpace(statusTxt))
                        paymentText = providerTxt;
                    else
                        paymentText = providerTxt + " – " + statusTxt;
                }

                // ===== Extra line (payment ref + paid at) =====
                string extraText = "";
                bool onlinePaid = (providerUp != "COD") && IsPaid(statusRaw);

                if (onlinePaid)
                {
                    string refTxt = (h.payment_Ref ?? "").Trim();
                    DateTime? paidAt = h.paid_At;

                    string paidAtTxt = "";
                    if (paidAt.HasValue)
                    {
                        paidAtTxt = paidAt.Value.ToString("dd/MM/yyyy HH:mm", new CultureInfo("vi-VN"));
                    }

                    if (!string.IsNullOrWhiteSpace(refTxt) && !string.IsNullOrWhiteSpace(paidAtTxt))
                        extraText = "Mã GD: " + refTxt + " • Lúc: " + paidAtTxt;
                    else if (!string.IsNullOrWhiteSpace(refTxt))
                        extraText = "Mã GD: " + refTxt;
                    else if (!string.IsNullOrWhiteSpace(paidAtTxt))
                        extraText = "Lúc: " + paidAtTxt;
                }

                // ===== Render payment =====
                pnlPayment.Visible = true;
                litPayment.InnerText = paymentText;

                try
                {
                    var extraCtrl = this.FindControl("litPaymentExtra") as System.Web.UI.HtmlControls.HtmlGenericControl;
                    if (!string.IsNullOrWhiteSpace(extraText))
                    {
                        if (extraCtrl != null)
                        {
                            extraCtrl.InnerText = extraText;
                            extraCtrl.Visible = true;
                        }
                        else
                        {
                            litPayment.Attributes["title"] = extraText;
                        }
                    }
                    else
                    {
                        if (extraCtrl != null)
                        {
                            extraCtrl.InnerText = "";
                            extraCtrl.Visible = false;
                        }
                        litPayment.Attributes["title"] = "";
                    }
                }
                catch { }

                // debug attributes để inspect
                litPayment.Attributes["data-pay-provider"] = (h.payment_Provider ?? "");
                litPayment.Attributes["data-pay-status"] = (h.payment_Status ?? "");
                litPayment.Attributes["data-pay-method"] = (h.payment_Method.HasValue ? h.payment_Method.Value.ToString() : "");
                litPayment.Attributes["data-pay-ref"] = (h.payment_Ref ?? "");
                litPayment.Attributes["data-paid-at"] = (h.paid_At.HasValue ? h.paid_At.Value.ToString("o") : "");
                litPayment.Attributes["data-pay-text"] = paymentText;
                litPayment.Attributes["data-pay-extra"] = extraText;

                // ===== Status pill =====
                litStatus.InnerText = GetStatusText(h.status);
                litStatus.Attributes["class"] = "order-status-pill " + GetStatusCssClass(h.status);

                // Review/Cancel flags
                CanReview = (h.status == 3);
                hCanReview.Value = CanReview ? "1" : "0";

                CanCancel = (h.status == 0);
                hCanCancel.Value = CanCancel ? "1" : "0";

                // Hidden for JS
                hStatus.Value = h.status.ToString();
                hOrderId.Value = (h.id > 0 ? h.id.ToString() : "0");

                // ===== Items =====
                if (detail.items != null && detail.items.Count > 0)
                {
                    rpItems.DataSource = detail.items;
                    rpItems.DataBind();
                    pnlItems.Visible = true;

                    var first = detail.items.FirstOrDefault();
                    hFirstProductId.Value = ((first != null ? first.product_Id : 0)).ToString();
                    hFirstVariantId.Value = ((first != null ? first.variant_Id : 0)).ToString();
                    hOrderCode.Value = Decode(h.order_Code ?? ("#" + h.id));

                    // ✅ NEW: JSON danh sách sản phẩm/variant trong đơn (unique) + thông tin để render UI đẹp
                    // NOTE: nếu đơn có nhiều dòng trùng productId/variantId thì gộp lại và cộng quantity
                    var itemsSlim = detail.items
                        .Where(x => x != null && x.product_Id > 0)
                        .GroupBy(x => new { x.product_Id, x.variant_Id })
                        .Select(g =>
                        {
                            var any = g.FirstOrDefault();
                            var name = (any != null ? (any.product_Name ?? any.name_Variant) : "");
                            var sku = (any != null ? any.sku : "");
                            var img = (any != null ? (any.image_Variant ?? any.image_Product ?? "/images/product-default.png") : "/images/product-default.png");
                            int qty = 0;
                            try { qty = g.Sum(z => z.quantity); } catch { qty = 0; }

                            return new
                            {
                                productId = g.Key.product_Id,
                                variantId = g.Key.variant_Id,
                                name = name ?? "",
                                sku = sku ?? "",
                                image = img ?? "/images/product-default.png",
                                quantity = qty
                            };
                        })
                        .ToList();

                    hOrderItemsJson.Value = JsonConvert.SerializeObject(itemsSlim);
                }
                else
                {
                    pnlItems.Visible = false;
                    hFirstProductId.Value = "0";
                    hFirstVariantId.Value = "0";
                    hOrderCode.Value = Decode(h.order_Code ?? ("#" + h.id));

                    // ✅ luôn có JSON (tránh JSON.parse lỗi)
                    hOrderItemsJson.Value = "[]";
                }

                // ===== Summary =====
                var vi = new CultureInfo("vi-VN");
                litSubtotal.Text = string.Format(vi, "{0:#,0}đ", h.sub_Total);
                litDiscount.Text = string.Format(vi, "{0:#,0}đ", h.discount_Total);
                litShipping.Text = string.Format(vi, "{0:#,0}đ", h.shipping_Total);
                litVat.Text = string.Format(vi, "{0:#,0}đ", h.vat_Total);
                litPayTotal.Text = string.Format(vi, "{0:#,0}đ", h.pay_Total);

                pnlHeader.Visible = true;
                pnlSummary.Visible = true;
                pnlOrderReview.Visible = true;

                // ✅ Debug in-page nếu cần
                if ("1".Equals(Request.QueryString["debug"]))
                {
                    string dbg =
                        "payment_Provider=" + (h.payment_Provider ?? "NULL") + "\n" +
                        "payment_Status=" + (h.payment_Status ?? "NULL") + "\n" +
                        "payment_Method=" + (h.payment_Method.HasValue ? h.payment_Method.Value.ToString() : "NULL") + "\n" +
                        "payment_Ref=" + (h.payment_Ref ?? "NULL") + "\n" +
                        "paid_At=" + (h.paid_At.HasValue ? h.paid_At.Value.ToString("o") : "NULL") + "\n" +
                        "paymentText=" + paymentText + "\n" +
                        "paymentExtra=" + extraText + "\n" +
                        "itemsJson=" + (hOrderItemsJson.Value ?? "[]");

                    litDebug.Text = "<pre>DEBUG\n" + Server.HtmlEncode(dbg) + "</pre>";
                    litDebug.Visible = true;
                }
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
                case 0: return "Đã được tạo";
                case 1: return "Xác nhận";
                case 2: return "Đang giao";
                case 3: return "Đã giao";
                case 4: return "Đã hủy";
                default: return "Không rõ";
            }
        }

        private string GetStatusCssClass(int status)
        {
            return "status-" + status; // status-0..status-4
        }
    }
}
