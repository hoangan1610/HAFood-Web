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

        private const string SK_DRAFT = "checkout_draft";
        private const string SK_TOTALS = "checkout_totals";
        private const string SK_PENDING_ORDER_CODE = "pending_order_code";
        private const string SK_PENDING_PAYMENT_URL = "pending_payment_url";
        private const string SK_PENDING_PAYMENT_CREATED = "pending_payment_created_utc";
        private const string SK_PENDING_PAYMENT_METHOD = "pending_payment_method";

        protected async void Page_Load(object sender, EventArgs e)
        {
            Response.Cache.SetCacheability(System.Web.HttpCacheability.NoCache);
            Response.Cache.SetNoStore();
            Response.Cache.SetRevalidation(System.Web.HttpCacheRevalidation.AllCaches);
            Response.Cache.SetExpires(DateTime.UtcNow.AddSeconds(-1));

            if (!IsPostBack)
            {
                if (!(Request.Cookies["AuthToken"] != null && !string.IsNullOrWhiteSpace(Request.Cookies["AuthToken"].Value))
                    && !(Context?.User?.Identity?.IsAuthenticated ?? false))
                {
                    var returnUrl = Server.UrlEncode(ResolveUrl("~/CartPage/CheckoutConfirm.aspx"));
                    Response.Redirect(ResolveUrl("~/AuthPage/Login.aspx") + "?returnUrl=" + returnUrl, false);
                    Context.ApplicationInstance.CompleteRequest();
                    return;
                }

                var payFail = string.Equals(Request.QueryString["payfail"], "1", StringComparison.OrdinalIgnoreCase)
                           || string.Equals(Request.QueryString["fail"], "1", StringComparison.OrdinalIgnoreCase);
                if (payFail)
                {
                    ShowNiceError(
                        code: "PAY_CANCEL",
                        title: "Bạn vừa hủy thanh toán VNPay",
                        message: "Bạn có thể chọn phương thức khác hoặc thử thanh toán lại.",
                        actionsHtml:
                            $"<button class='btn-soft' onclick=\"location.reload()\">Thử lại</button>" +
                            $"<button class='btn-link' onclick=\"location.href='{ResolveUrl("~/CartPage/CartPage.aspx")}'\">Về giỏ hàng</button>"
                    );

                    Session.Remove(SK_PENDING_PAYMENT_URL);
                    Session.Remove(SK_PENDING_PAYMENT_CREATED);
                    Session.Remove(SK_PENDING_PAYMENT_METHOD);
                    // GIỮ SK_PENDING_ORDER_CODE để có thể hoàn tất bằng COD nếu muốn
                }
            }

            await LoadDraftAndBindAsync();
        }

        private async Task LoadDraftAndBindAsync()
        {
            var draft = Session[SK_DRAFT] as CartPage.CheckoutDraft;
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

            if (cart?.items != null && cart.items.Any() && selectedLines.Any())
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

                // snapshot item
                draft.Items = freshItems.Select(fi => (fi.VariantId, fi.Quantity)).ToArray();
                Session[SK_DRAFT] = draft;
            }
            else
            {
                if (draft.Snapshot != null && draft.Snapshot.Length > 0)
                {
                    displayItems = draft.Snapshot.Select(it => new
                    {
                        ProductName = it.ProductName ?? $"Sản phẩm #{it.VariantId}",
                        VariantName = it.VariantName ?? $"Biến thể #{it.VariantId}",
                        Quantity = it.Quantity,
                        ImageUrl = string.IsNullOrWhiteSpace(it.ImageUrl) ? "/images/product-default.png" : it.ImageUrl,
                        LineTotal = string.Format(viVN, "{0:N0} ₫", it.Price * it.Quantity)
                    }).Cast<object>().ToList();

                    subtotal = draft.SnapshotSubtotal;
                    shipping = draft.SnapshotShipping;
                }
                else
                {
                    displayItems = (draft.Items ?? Array.Empty<(long variant_Id, int quantity)>())
                        .Select(it => new
                        {
                            ProductName = $"Sản phẩm #{it.variant_Id}",
                            VariantName = $"Biến thể #{it.variant_Id}",
                            Quantity = it.quantity,
                            ImageUrl = "/images/product-default.png",
                            LineTotal = "—"
                        }).Cast<object>().ToList();
                    subtotal = 0m; shipping = 0m;
                }
            }

            rptItems.DataSource = displayItems;
            rptItems.DataBind();

            var vat = Math.Round(subtotal * VAT_RATE, 0, MidpointRounding.AwayFromZero);
            var grand = subtotal + shipping + vat;

            lblSubtotal.Text = string.Format(viVN, "{0:N0} ₫", subtotal);
            lblShipping.Text = string.Format(viVN, "{0:N0} ₫", shipping);
            lblVat.Text = string.Format(viVN, "{0:N0} ₫", vat);
            lblGrandTotal.Text = string.Format(viVN, "{0:N0} ₫", grand);

            Session[SK_TOTALS] = (subtotal, shipping);
        }

        private bool TryRedirectPendingPaymentIfAny(int? selectedMethod = null)
        {
            var url = Session[SK_PENDING_PAYMENT_URL] as string;
            var createdUtc = Session[SK_PENDING_PAYMENT_CREATED] as DateTime?;
            var pendingMethodObj = Session[SK_PENDING_PAYMENT_METHOD];
            int? pendingMethod = pendingMethodObj is int i ? i : (pendingMethodObj as int?);

            if (string.IsNullOrWhiteSpace(url)) return false;

            if (selectedMethod.HasValue && pendingMethod.HasValue && selectedMethod.Value != pendingMethod.Value)
                return false;

            var stillValid = createdUtc.HasValue && (DateTime.UtcNow - createdUtc.Value) < TimeSpan.FromMinutes(12);
            if (!stillValid)
            {
                Session.Remove(SK_PENDING_PAYMENT_URL);
                Session.Remove(SK_PENDING_PAYMENT_CREATED);
                Session.Remove(SK_PENDING_PAYMENT_METHOD);
                return false;
            }

            Response.Redirect(url, false);
            Context.ApplicationInstance.CompleteRequest();
            return true;
        }

        protected async void btnPlaceOrder_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            if (!int.TryParse(rblPayment.SelectedValue, out var paymentMethod))
                paymentMethod = 0; // 0=COD, 1=MoMo, 2=VNPay

            var pendingCode = Session[SK_PENDING_ORDER_CODE] as string;

            // ==== ĐÃ CÓ ORDER (cart đã đóng) ====
            if (!string.IsNullOrWhiteSpace(pendingCode))
            {
                try
                {
                    if (paymentMethod == 0)
                    {
                        // 1) Đổi sang COD để DB không còn Pending VNPay/MoMo
                        await _orderService.SwitchPaymentAsync(pendingCode, 0, "USER_SWITCH_TO_COD");

                        // 2) Dọn session + ThankYou
                        Session.Remove(SK_PENDING_PAYMENT_URL);
                        Session.Remove(SK_PENDING_PAYMENT_CREATED);
                        Session.Remove(SK_PENDING_PAYMENT_METHOD);
                        Session.Remove(SK_DRAFT);

                        Response.Redirect("~/CartPage/ThankYou.aspx?code=" + Uri.EscapeDataString(pendingCode) + "&cod=1", false);
                        Context.ApplicationInstance.CompleteRequest();
                        return;
                    }
                    else
                    {
                        // 1) Nếu link cũ cùng cổng còn hạn → reuse
                        if (TryRedirectPendingPaymentIfAny(paymentMethod)) return;

                        // 2) Đổi cổng trên DB
                        await _orderService.SwitchPaymentAsync(pendingCode, paymentMethod, "USER_SWITCH_GATEWAY");

                        // 3) Xin link thanh toán mới cho CHÍNH order này
                        var newPayUrl = await _orderService.CreatePaymentLinkForOrderAsync(pendingCode, paymentMethod);

                        // 4) Cache & redirect
                        Session[SK_PENDING_PAYMENT_URL] = newPayUrl;
                        Session[SK_PENDING_PAYMENT_CREATED] = DateTime.UtcNow;
                        Session[SK_PENDING_PAYMENT_METHOD] = paymentMethod;

                        Response.Redirect(newPayUrl, false);
                        Context.ApplicationInstance.CompleteRequest();
                        return;
                    }
                }
                catch (Exception ex)
                {
                    ShowNiceError(
                        code: "SWITCH_OR_LINK_FAIL",
                        title: "Không chuyển phương thức/khởi tạo link thanh toán được",
                        message: Server.HtmlEncode(ex.Message),
                        actionsHtml: $"<button class='btn-soft' onclick=\"location.reload()\">Thử lại</button>"
                    );
                    return;
                }
            }

            // ==== CHƯA CÓ ORDER → tạo đơn mới như cũ ====
            if (paymentMethod != 0 && TryRedirectPendingPaymentIfAny(paymentMethod)) return;

            var draft = Session[SK_DRAFT] as CartPage.CheckoutDraft;
            if (draft == null)
            {
                ShowNiceError("SESSION_EXPIRED", "Phiên đặt hàng đã hết hạn", "Vui lòng quay lại giỏ hàng để đặt lại.",
                    actionsHtml: $"<button class='btn-soft' onclick=\"location.href='{ResolveUrl("~/CartPage/CartPage.aspx")}'\">Về giỏ hàng</button>");
                return;
            }

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
                items = (draft.Items ?? Array.Empty<(long variant_Id, int quantity)>())
                    .Select(i => new OrderItem { variant_Id = i.variant_Id, quantity = i.quantity })
                    .ToArray()
            };

            try
            {
                var resp = await _orderService.CheckoutAsync(req);

                if (!string.IsNullOrWhiteSpace(resp.payment_Url))
                {
                    if (!string.IsNullOrWhiteSpace(resp.order_Code))
                        Session[SK_PENDING_ORDER_CODE] = resp.order_Code;

                    Session[SK_PENDING_PAYMENT_URL] = resp.payment_Url;
                    Session[SK_PENDING_PAYMENT_CREATED] = DateTime.UtcNow;
                    Session[SK_PENDING_PAYMENT_METHOD] = paymentMethod;

                    Response.Redirect(resp.payment_Url, false);
                    Context.ApplicationInstance.CompleteRequest();
                    return;
                }

                if (resp == null || (resp.order_Id <= 0 && string.IsNullOrWhiteSpace(resp.order_Code)))
                {
                    ShowNiceError("EMPTY_RESPONSE", "Không tạo được đơn hàng", "Phản hồi trống từ máy chủ.");
                    return;
                }

                // COD ok → dọn session, redirect
                Session.Remove(SK_DRAFT);
                Session.Remove(SK_PENDING_ORDER_CODE);
                Session.Remove(SK_PENDING_PAYMENT_URL);
                Session.Remove(SK_PENDING_PAYMENT_CREATED);
                Session.Remove(SK_PENDING_PAYMENT_METHOD);

                var code = !string.IsNullOrWhiteSpace(resp.order_Code) ? resp.order_Code : resp.order_Id.ToString();
                Response.Redirect("~/CartPage/ThankYou.aspx?code=" + Uri.EscapeDataString(code), false);
                Context.ApplicationInstance.CompleteRequest();
            }
            catch (Exception ex)
            {
                var msg = ex.Message ?? "";

                if (msg.IndexOf("OUT_OF_STOCK", StringComparison.OrdinalIgnoreCase) >= 0)
                {
                    ShowNiceError("OUT_OF_STOCK", "Một số sản phẩm đã hết hàng",
                        "Vui lòng giảm số lượng hoặc bỏ các sản phẩm tạm hết khỏi giỏ, rồi thử lại.",
                        actionsHtml: $"<button class='btn-soft' onclick=\"location.href='{ResolveUrl("~/CartPage/CartPage.aspx")}'\">Về giỏ hàng để cập nhật</button>");
                    return;
                }

                if (msg.IndexOf("CART_EMPTY", StringComparison.OrdinalIgnoreCase) >= 0)
                {
                    var pendingUrl = Session[SK_PENDING_PAYMENT_URL] as string;
                    if (!string.IsNullOrWhiteSpace(pendingUrl))
                    {
                        ShowNiceError("CART_EMPTY", "Đơn hàng đã khởi tạo trước đó", "Đang chuyển tới trang thanh toán…");
                        Response.Redirect(pendingUrl, false);
                        Context.ApplicationInstance.CompleteRequest();
                        return;
                    }
                    var code = Session[SK_PENDING_ORDER_CODE] as string;
                    if (!string.IsNullOrWhiteSpace(code))
                    {
                        Response.Redirect("~/CartPage/ThankYou.aspx?code=" + Uri.EscapeDataString(code) + "&restored=1", false);
                        Context.ApplicationInstance.CompleteRequest();
                        return;
                    }

                    ShowNiceError("CART_EMPTY", "Giỏ hàng trống",
                        "Vui lòng quay lại giỏ hàng để đặt lại.",
                        actionsHtml: $"<button class='btn-soft' onclick=\"location.href='{ResolveUrl("~/CartPage/CartPage.aspx")}'\">Về giỏ hàng</button>");
                    return;
                }

                ShowNiceError("UNKNOWN", "Có lỗi khi tạo đơn hàng", Server.HtmlEncode(msg),
                    actionsHtml: $"<button class='btn-soft' onclick=\"location.reload()\">Thử lại</button>");
            }
        }


        // RENDER alert đẹp mắt
        private void ShowNiceError(string code, string title, string message, string actionsHtml = null)
        {
            var html =
                "<div class='alertx'>" +
                    "<i class='bi bi-exclamation-octagon-fill'></i>" +
                    "<div class='ax-body'>" +
                        $"<div class='ax-title'>{Server.HtmlEncode(title)}</div>" +
                        $"<p class='ax-msg'>{message}</p>" +
                        (string.IsNullOrWhiteSpace(actionsHtml) ? "" : $"<div class='ax-actions'>{actionsHtml}</div>") +
                        $"<input type='hidden' value='{Server.HtmlEncode(code)}' />" +
                    "</div>" +
                "</div>";

            litError.Text = html;
            litError.Visible = true;
        }
    }
}
