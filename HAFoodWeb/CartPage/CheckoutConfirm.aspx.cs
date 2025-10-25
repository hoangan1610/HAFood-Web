using System;
using System.Linq;
using System.Threading.Tasks;
using System.Web.UI;
using HAFoodWeb.Services;

namespace HAFoodWeb
{
    public partial class CheckoutConfirm : Page
    {
        private const decimal VAT_RATE = 0.08m;

        private readonly OrderService _orderService = new OrderService();
        private readonly CartService _cartService = new CartService();

        protected async void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Bắt đăng nhập
                if (!(Request.Cookies["AuthToken"] != null && !string.IsNullOrWhiteSpace(Request.Cookies["AuthToken"].Value))
                    && !(Context?.User?.Identity?.IsAuthenticated ?? false))
                {
                    var returnUrl = Server.UrlEncode(ResolveUrl("~/CartPage/CheckoutConfirm.aspx"));
                    Response.Redirect(ResolveUrl("~/AuthPage/Login.aspx") + "?returnUrl=" + returnUrl, false);
                    Context.ApplicationInstance.CompleteRequest();
                    return;
                }
            }

            await LoadDraftAndBindAsync();
        }

        private async Task LoadDraftAndBindAsync()
        {
            var draft = Session["checkout_draft"] as CartPage.CheckoutDraft;
            if (draft == null)
            {
                Response.Redirect("~/CartPage/CartPage.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            lblShipName.Text = draft.ShipName;
            lblShipPhone.Text = draft.ShipPhone;
            lblShipAddress.Text = draft.ShipAddress;
            lblPromo.Text = string.IsNullOrWhiteSpace(draft.PromoCode) ? "(không)" : draft.PromoCode;

            var viVN = System.Globalization.CultureInfo.GetCultureInfo("vi-VN");
            decimal subtotal = 0m;
            decimal shipping = 0m;

            var cart = await _cartService.GetCartAsync(draft.DeviceUuid);
            var selectedLines = (draft.SelectedLineIds ?? new long[0]).ToHashSet();

            System.Collections.Generic.List<object> displayItems;

            if (cart?.items != null && cart.items.Any())
            {
                var freshItems = cart.items
                    .Where(x => selectedLines.Contains(x.id))
                    .Select(x =>
                    {
                        var lineTotal = x.price_Variant * x.quantity;
                        subtotal += lineTotal;
                        return new
                        {
                            ProductName = x.product_Name,
                            VariantName = x.variant_Name,
                            Quantity = x.quantity,
                            ImageUrl = string.IsNullOrWhiteSpace(x.image_Variant) ? "/images/product-default.png" : x.image_Variant,
                            LineTotal = string.Format(viVN, "{0:N0} ₫", lineTotal),
                            VariantId = x.variant_Id
                        };
                    })
                    .ToList();

                displayItems = freshItems.Cast<object>().ToList();

                // Cập nhật draft.Items theo giỏ hiện tại để lần “quay lại” vẫn đúng
                draft.Items = freshItems.Select(fi => (fi.VariantId, fi.Quantity)).ToArray();
                Session["checkout_draft"] = draft;
            }
            else
            {
                // Fallback hiếm khi giỏ rỗng: hiển thị từ draft (không có giá)
                displayItems = draft.Items.Select(it => new
                {
                    ProductName = $"Sản phẩm #{it.variant_Id}",
                    VariantName = $"Biến thể #{it.variant_Id}",
                    Quantity = it.quantity,
                    ImageUrl = "/images/product-default.png",
                    LineTotal = "—"
                }).Cast<object>().ToList();
            }

            rptItems.DataSource = displayItems;
            rptItems.DataBind();

            var vat = Math.Round(subtotal * VAT_RATE, 0, MidpointRounding.AwayFromZero);
            var grand = subtotal + shipping + vat;

            lblSubtotal.Text = string.Format(viVN, "{0:N0} ₫", subtotal);
            lblShipping.Text = string.Format(viVN, "{0:N0} ₫", shipping);
            lblVat.Text = string.Format(viVN, "{0:N0} ₫", vat);
            lblGrandTotal.Text = string.Format(viVN, "{0:N0} ₫", grand);

            Session["checkout_totals"] = (subtotal, shipping);
        }

        protected async void btnPlaceOrder_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            var draft = Session["checkout_draft"] as CartPage.CheckoutDraft;
            if (draft == null)
            {
                ShowError("Phiên đặt hàng đã hết hạn. Vui lòng quay lại giỏ hàng.");
                return;
            }

            if (!int.TryParse(rblPayment.SelectedValue, out var paymentMethod))
                paymentMethod = 0; // COD

            var req = new OrderCheckoutRequest
            {
                cart_Id = 0,
                ship_Name = draft.ShipName,
                ship_Full_Address = draft.ShipAddress,
                ship_Phone = draft.ShipPhone,
                payment_Method = paymentMethod,
                ip = Request.UserHostAddress,
                note = draft.Note,
                address_Id = 0,
                device_Id = 0,
                promo_Code = draft.PromoCode,
                selected_Line_Ids = draft.SelectedLineIds ?? new long[0],
                items = draft.Items.Select(i => new OrderItem
                {
                    variant_Id = i.variant_Id,
                    quantity = i.quantity
                }).ToArray()
            };

            try
            {
                var resp = await _orderService.CheckoutAsync(req);

                if (!string.IsNullOrWhiteSpace(resp.payment_Url))
                {
                    Response.Redirect(resp.payment_Url, false);
                    Context.ApplicationInstance.CompleteRequest();
                    return;
                }

                if (resp == null || (resp.order_Id <= 0 && string.IsNullOrWhiteSpace(resp.order_Code)))
                {
                    ShowError("Không tạo được đơn hàng. Phản hồi trống từ máy chủ.");
                    return;
                }

                // Clear draft
                Session.Remove("checkout_draft");
                var code = !string.IsNullOrWhiteSpace(resp.order_Code) ? resp.order_Code : resp.order_Id.ToString();

                Response.Redirect("~/CartPage/ThankYou.aspx?code=" + Uri.EscapeDataString(code), false);
                Context.ApplicationInstance.CompleteRequest();
            }
            catch (Exception ex)
            {
                ShowError("Có lỗi khi tạo đơn hàng: " + ex.Message);
            }
        }

        private void ShowError(string msg)
        {
            lblError.Text = msg;
            lblError.Visible = true;
        }
    }
}
