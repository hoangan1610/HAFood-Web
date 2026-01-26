using System;
using System.Linq;
using System.Threading.Tasks;
using System.Web.UI;
using HAFoodWeb.Services;
using System.Web;
using HAFoodWeb.Models;
using System.Net.Http;
using System.Configuration;              // ConfigurationManager
using System.Text;                       // Encoding
using Newtonsoft.Json;                   // Newtonsoft.Json
using Newtonsoft.Json.Linq;              // JObject/JToken

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
        private const string SK_PENDING_ORDER_ID = "pending_order_id";

        private const string THANKYOU_PATH = "~/CartPage/ThankYou.aspx";

        // Helper lấy đơn giá đang áp dụng
        private static decimal Eff(decimal priceEffective, decimal priceVariant)
            => priceEffective > 0 ? priceEffective : priceVariant;

        // ✅ Helper tính phí ship giống rule BE
        private static decimal CalcShipping(decimal subtotal, string cityCode, string wardCode)
        {
            var hasAddr = !string.IsNullOrWhiteSpace(cityCode)
                          && !string.IsNullOrWhiteSpace(wardCode);

            // Chưa có địa chỉ đủ / không có tiền hàng → không tính ship
            if (!hasAddr || subtotal <= 0) return 0m;

            // Rule mẫu: >= 300k free, < 300k thu 25k
            if (subtotal >= 300000m) return 0m;

            return 25000m;
        }

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
                    var provQ = (Request.QueryString["prov"] ?? "").Trim().ToLowerInvariant();
                    string provName;

                    if (!string.IsNullOrWhiteSpace(provQ))
                    {
                        // ✅ slot 1: MoMo, slot 2: Pay2S
                        provName = provQ == "momo" ? "MoMo"
                                : provQ == "pay2s" ? "Pay2S"
                                : "cổng thanh toán";
                    }
                    else
                    {
                        var m = GetPendingMethodFromSession();
                        provName = m == 2 ? "Pay2S"
                                : m == 1 ? "MoMo"
                                : "cổng thanh toán";
                    }

                    ShowNiceError(
                        code: "PAY_CANCEL",
                        title: $"Bạn vừa hủy thanh toán {provName}",
                        message: "Bạn có thể chọn phương thức khác hoặc thử thanh toán lại.",
                        actionsHtml:
                            $"<button type='button' class='btn-soft' onclick=\"location.reload()\">Thử lại</button>" +
                            $"<button type='button' class='btn-link' onclick=\"location.href='{ResolveUrl("~/CartPage/CartPage.aspx")}'\">Về giỏ hàng</button>",
                        variant: "warning",
                        icon: "bi bi-x-circle"
                    );

                    Session.Remove(SK_PENDING_PAYMENT_URL);
                    Session.Remove(SK_PENDING_PAYMENT_CREATED);
                    Session.Remove(SK_PENDING_PAYMENT_METHOD);
                }
            }

            await LoadDraftAndBindAsync();
        }

        private async Task LoadDraftAndBindAsync()
        {
            var draft = Session[SK_DRAFT] as CheckoutDraft;
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
                        var unit = Eff(x.price_Effective, x.price_Variant);
                        var lineTotal = unit * x.quantity;
                        subtotal += lineTotal;
                        return new
                        {
                            ProductName = x.product_Name,
                            VariantName = x.variant_Name,
                            Quantity = x.quantity,
                            ImageUrl = string.IsNullOrWhiteSpace(x.image_Variant) ? "/images/product-default.png" : x.image_Variant,
                            LineTotal = string.Format(viVN, "{0:N0} ₫", lineTotal),
                            VariantId = x.variant_Id,
                            Price = unit
                        };
                    })
                    .ToList();

                displayItems = freshItems.Cast<object>().ToList();

                // đồng bộ Items
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

                    draft.Items = draft.Snapshot.Select(it => (it.VariantId, it.Quantity)).ToArray();
                    Session[SK_DRAFT] = draft;

                    subtotal = draft.SnapshotSubtotal;
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

            // ✅ ƯU TIÊN dùng đúng phí ship user thấy ở CartPage
            if (draft.SnapshotShipping > 0)
            {
                shipping = draft.SnapshotShipping;
            }
            else
            {
                shipping = CalcShipping(subtotal, draft.CityCode, draft.WardCode);
            }

            var vat = Math.Round(subtotal * VAT_RATE, 0, MidpointRounding.AwayFromZero);

            // ⭐ BẮT ĐẦU TỪ SNAPSHOT (GIÁ TRỊ GIẢM TẠM THỜI TÍNH Ở CART)
            decimal discount = draft.SnapshotDiscount;

            // Nếu có mã KM thì thử re-quote, chỉ override nếu kết quả > 0
            if (!string.IsNullOrWhiteSpace(draft.PromoCode))
            {
                try
                {
                    var quoted = await QuoteDiscountAsync(draft, subtotal);
                    if (quoted > 0) discount = quoted;
                }
                catch
                {
                    // lỗi thì giữ snapshot
                }
            }

            if (discount < 0) discount = 0;

            var grand = Math.Max(0m, subtotal + shipping + vat - discount);

            lblSubtotal.Text = string.Format(viVN, "{0:N0} ₫", subtotal);
            lblShipping.Text = string.Format(viVN, "{0:N0} ₫", shipping);
            lblVat.Text = string.Format(viVN, "{0:N0} ₫", vat);

            if (discount == 0)
                lblDiscount.Text = string.Format(viVN, "{0:N0} ₫", 0);
            else
                lblDiscount.Text = "-" + string.Format(viVN, "{0:N0} ₫", discount);

            lblGrandTotal.Text = string.Format(viVN, "{0:N0} ₫", grand);

            Session[SK_TOTALS] = (subtotal, shipping);
        }

        // Helper gọi /api/promotions/cart/quote để lấy tổng giảm (Newtonsoft.Json + C# 7.3)
        private async Task<decimal> QuoteDiscountAsync(CheckoutDraft draft, decimal subtotal)
        {
            if (string.IsNullOrWhiteSpace(draft.PromoCode)) return 0m;

            var cart = await _cartService.GetCartAsync(draft.DeviceUuid);
            var selected = (draft.SelectedLineIds ?? new long[0]).ToHashSet();

            var items = new System.Collections.Generic.List<object>();
            if (cart?.items != null)
            {
                foreach (var x in cart.items.Where(x => selected.Contains(x.id)))
                {
                    var unit = Eff(x.price_Effective, x.price_Variant);
                    items.Add(new
                    {
                        productId = (long?)null,
                        variantId = (long?)x.variant_Id,
                        qty = (int)x.quantity,
                        unitPrice = (decimal)unit
                    });
                }
            }

            if (items.Count == 0 && draft.Snapshot != null)
            {
                foreach (var s in draft.Snapshot)
                {
                    items.Add(new
                    {
                        productId = (long?)null,
                        variantId = (long?)s.VariantId,
                        qty = (int)s.Quantity,
                        unitPrice = (decimal)s.Price
                    });
                }
            }
            if (items.Count == 0) return 0m;

            var apiBase = ConfigurationManager.AppSettings["ApiBaseUrl"] ?? string.Empty;
            apiBase = apiBase.TrimEnd('/');
            var url = apiBase + "/api/promotions/cart/quote";

            using (var http = new HttpClient())
            {
                http.Timeout = TimeSpan.FromSeconds(8);
                if (!string.IsNullOrEmpty(draft.DeviceUuid))
                    http.DefaultRequestHeaders.Add("X-Device-Id", draft.DeviceUuid);

                var bodyObj = new
                {
                    code = draft.PromoCode,
                    items = items,
                    subtotal = subtotal,
                    shippingFee = 0m,
                    channel = (byte?)1
                };

                var json = JsonConvert.SerializeObject(bodyObj);
                using (var content = new StringContent(json, Encoding.UTF8, "application/json"))
                {
                    var resp = await http.PostAsync(url, content);
                    if (!resp.IsSuccessStatusCode) return draft.SnapshotDiscount;

                    var str = await resp.Content.ReadAsStringAsync();
                    if (string.IsNullOrWhiteSpace(str)) return draft.SnapshotDiscount;

                    JObject root;
                    try { root = JObject.Parse(str); }
                    catch { return draft.SnapshotDiscount; }

                    var best = root["best"] as JObject;
                    if (best == null) return draft.SnapshotDiscount;

                    var td = best["total_discount"] ?? best["totalDiscount"];
                    if (td != null)
                    {
                        if (decimal.TryParse(td.ToString(), System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture, out var dec))
                            return dec;
                        if (decimal.TryParse(td.ToString(), out dec)) return dec;
                    }
                    return draft.SnapshotDiscount;
                }
            }
        }

        // ===== Helpers =====
        private static byte? GetPendingMethodFromSession()
        {
            var obj = System.Web.HttpContext.Current?.Session?[SK_PENDING_PAYMENT_METHOD];
            if (obj == null) return null;
            if (obj is byte b) return b;
            if (obj is int i && i >= byte.MinValue && i <= byte.MaxValue) return (byte)i;
            if (obj is string s && byte.TryParse(s, out var bs)) return bs;
            return null;
        }

        private long? TryGetPendingOrderId()
        {
            var obj = Session[SK_PENDING_ORDER_ID];
            if (obj == null) return null;
            if (obj is long l) return l;
            if (obj is int i) return i;
            if (obj is string s && long.TryParse(s, out var ls)) return ls;
            return null;
        }

        private bool TryRedirectPendingPaymentIfAny(byte? selectedMethod = null)
        {
            var url = Session[SK_PENDING_PAYMENT_URL] as string;
            var createdUtc = Session[SK_PENDING_PAYMENT_CREATED] as DateTime?;
            var pendingMethod = GetPendingMethodFromSession();

            if (string.IsNullOrWhiteSpace(url)) return false;

            if (selectedMethod.HasValue && pendingMethod.HasValue && selectedMethod.Value != pendingMethod.Value)
                return false;

            var stillValid = createdUtc.HasValue && (DateTime.UtcNow - createdUtc.Value) < TimeSpan.FromMinutes(3);
            if (!stillValid)
            {
                Session.Remove(SK_PENDING_PAYMENT_URL);
                Session.Remove(SK_PENDING_PAYMENT_CREATED);
                Session.Remove(SK_PENDING_PAYMENT_METHOD);
                return false;
            }

            // Normalize trước khi đi
            url = NormalizeGatewayUrlForUA(url);
            System.Diagnostics.Trace.WriteLine($"[PAY-REDIRECT:PENDING] UA={Request?.UserAgent} URL={url}");

            Response.Redirect(url, false);
            Context.ApplicationInstance.CompleteRequest();
            return true;
        }

        protected async void btnPlaceOrder_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            // ✅ 0=COD, 1=MoMo, 2=Pay2S
            byte paymentMethod;
            if (!byte.TryParse(rblPayment.SelectedValue, out paymentMethod))
                paymentMethod = 0;

            var pendingCode = Session[SK_PENDING_ORDER_CODE] as string;

            // ==== ĐÃ CÓ ORDER (cart đã đóng) ====
            if (!string.IsNullOrWhiteSpace(pendingCode))
            {
                try
                {
                    if (paymentMethod == 0)
                    {
                        var sw = await _orderService.SwitchPaymentSafeAsync(pendingCode, 0, "USER_SWITCH_TO_COD");

                        var pid = TryGetPendingOrderId();

                        Session.Remove(SK_PENDING_PAYMENT_URL);
                        Session.Remove(SK_PENDING_PAYMENT_CREATED);
                        Session.Remove(SK_PENDING_PAYMENT_METHOD);
                        Session.Remove(SK_DRAFT);
                        Session.Remove(SK_PENDING_ORDER_CODE);

                        var url = ResolveUrl(THANKYOU_PATH) +
                                  "?code=" + Uri.EscapeDataString(pendingCode) +
                                  (pid.HasValue ? "&id=" + pid.Value : "");
                        Response.Redirect(url, false);
                        Context.ApplicationInstance.CompleteRequest();
                        return;
                    }
                    else
                    {
                        if (TryRedirectPendingPaymentIfAny(paymentMethod)) return;

                        var sw = await _orderService.SwitchPaymentSafeAsync(pendingCode, paymentMethod, "USER_SWITCH_GATEWAY");

                        if (sw.Outcome == SwitchPaymentOutcome.AlreadyPaid)
                        {
                            var pid = TryGetPendingOrderId();

                            Session.Remove(SK_PENDING_PAYMENT_URL);
                            Session.Remove(SK_PENDING_PAYMENT_CREATED);
                            Session.Remove(SK_PENDING_PAYMENT_METHOD);
                            Session.Remove(SK_PENDING_ORDER_CODE);
                            Session.Remove(SK_DRAFT);

                            var url = ResolveUrl(THANKYOU_PATH) +
                                      "?code=" + Uri.EscapeDataString(pendingCode) +
                                      (pid.HasValue ? "&id=" + pid.Value : "") +
                                      "&paid=1";
                            Response.Redirect(url, false);
                            Context.ApplicationInstance.CompleteRequest();
                            return;
                        }
                        if (sw.Outcome == SwitchPaymentOutcome.Switched)
                        {
                            var newPayUrl = await _orderService.CreatePaymentLinkForOrderAsync(pendingCode, paymentMethod);

                            var normalized = NormalizeGatewayUrlForUA(newPayUrl);
                            Session[SK_PENDING_PAYMENT_URL] = normalized;
                            Session[SK_PENDING_PAYMENT_CREATED] = DateTime.UtcNow;
                            Session[SK_PENDING_PAYMENT_METHOD] = paymentMethod;

                            System.Diagnostics.Trace.WriteLine($"[PAY-REDIRECT:SWITCHED] UA={Request?.UserAgent} URL={normalized}");
                            Response.Redirect(normalized, false);
                            Context.ApplicationInstance.CompleteRequest();
                            return;
                        }
                        if (sw.Outcome == SwitchPaymentOutcome.NotFound)
                        {
                            ShowNiceError("ORDER_NOT_FOUND", "Không tìm thấy đơn hàng", "Vui lòng đặt lại đơn mới.", null, "danger");
                            return;
                        }
                        if (sw.Outcome == SwitchPaymentOutcome.Unauthorized)
                        {
                            Response.Redirect("~/AuthPage/Login.aspx?returnUrl=" + Server.UrlEncode(Request.RawUrl), false);
                            Context.ApplicationInstance.CompleteRequest();
                            return;
                        }

                        ShowNiceError("SWITCH_PAYMENT_FAILED", "Không chuyển phương thức/khởi tạo link thanh toán được",
                            Server.HtmlEncode(sw?.Message ?? sw?.RawBody ?? "Lỗi không xác định"),
                            actionsHtml: $"<button type='button' class='btn-soft' onclick=\"location.reload()\">Thử lại</button>",
                            variant: "danger",
                            icon: "bi bi-exclamation-octagon-fill");
                        return;
                    }
                }
                catch (Exception ex)
                {
                    ShowNiceError(
                        code: "SWITCH_OR_LINK_FAIL",
                        title: "Không chuyển phương thức/khởi tạo link thanh toán được",
                        message: Server.HtmlEncode(ex.Message),
                        actionsHtml: $"<button type='button' class='btn-soft' onclick=\"location.reload()\">Thử lại</button>",
                        variant: "danger",
                        icon: "bi bi-exclamation-octagon-fill"
                    );
                    return;
                }
            }

            // ==== CHƯA CÓ ORDER → tạo đơn mới ====
            if (paymentMethod != 0 && TryRedirectPendingPaymentIfAny(paymentMethod)) return;

            var draft = Session[SK_DRAFT] as CheckoutDraft;

            if (draft == null)
            {
                ShowNiceError("SESSION_EXPIRED", "Phiên đặt hàng đã hết hạn", "Vui lòng quay lại giỏ hàng để đặt lại.",
                    actionsHtml: $"<button type='button' class='btn-soft' onclick=\"location.href='{ResolveUrl("~/CartPage/CartPage.aspx")}'\">Về giỏ hàng</button>",
                    variant: "warning",
                    icon: "bi bi-hourglass-split");
                return;
            }

            // Bảo đảm có Items gửi lên API
            var itemsTuple = draft.Items ?? Array.Empty<(long variant_Id, int quantity)>();
            if ((itemsTuple.Length == 0) && (draft.Snapshot != null && draft.Snapshot.Length > 0))
            {
                itemsTuple = draft.Snapshot.Select(s => (s.VariantId, s.Quantity)).ToArray();
                draft.Items = itemsTuple;
                Session[SK_DRAFT] = draft;
            }

            if ((itemsTuple.Length == 0) && !(draft.SelectedLineIds?.Any() ?? false))
            {
                ShowNiceError("CART_EMPTY", "Giỏ hàng trống",
                    "Vui lòng quay lại giỏ hoặc chọn lại sản phẩm.",
                    actionsHtml: $"<button type='button' class='btn-soft' onclick=\"location.href='{ResolveUrl("~/CartPage/CartPage.aspx")}'\">Về giỏ hàng</button>",
                    variant: "warning",
                    icon: "bi bi-cart-x");
                return;
            }

            // Chuẩn hoá IP (tuỳ chọn)
            var ip = Request.UserHostAddress;
            if (!string.IsNullOrWhiteSpace(ip) && ip.Contains(":")) ip = "127.0.0.1";

            var req = new OrderCheckoutRequest
            {
                cart_Id = null,
                ship_Name = draft.ShipName,
                ship_Full_Address = draft.ShipAddress,
                ship_Phone = draft.ShipPhone,
                payment_Method = paymentMethod,
                ip = ip,
                note = draft.Note,
                address_Id = null,
                device_Id = null,
                promo_Code = draft.PromoCode,

                ship_City_Code = draft.CityCode,
                ship_Ward_Code = draft.WardCode,
                total_Weight_Gram = draft.TotalWeightGram,

                selected_Line_Ids = (draft.SelectedLineIds != null && draft.SelectedLineIds.Length > 0)
                    ? draft.SelectedLineIds
                    : (long[])null,

                items = itemsTuple
                    .Select(i => new OrderItem { variant_Id = i.variant_Id, quantity = i.quantity })
                    .ToArray()
            };

            try
            {
                var resp = await _orderService.CheckoutAsync(req);

                if (!string.IsNullOrWhiteSpace(resp?.payment_Url))
                {
                    if (!string.IsNullOrWhiteSpace(resp.order_Code))
                        Session[SK_PENDING_ORDER_CODE] = resp.order_Code;

                    if (resp.order_Id > 0) Session[SK_PENDING_ORDER_ID] = resp.order_Id;

                    var payUrl = NormalizeGatewayUrlForUA(resp.payment_Url);
                    Session[SK_PENDING_PAYMENT_URL] = payUrl;
                    Session[SK_PENDING_PAYMENT_CREATED] = DateTime.UtcNow;
                    Session[SK_PENDING_PAYMENT_METHOD] = paymentMethod;

                    System.Diagnostics.Trace.WriteLine($"[PAY-REDIRECT:CREATE] UA={Request?.UserAgent} URL={payUrl}");
                    Response.Redirect(payUrl, false);
                    Context.ApplicationInstance.CompleteRequest();
                    return;
                }

                if (resp == null || (resp.order_Id <= 0 && string.IsNullOrWhiteSpace(resp.order_Code)))
                {
                    ShowNiceError("EMPTY_RESPONSE", "Không tạo được đơn hàng", "Phản hồi trống từ máy chủ.", null, "danger", "bi bi-exclamation-octagon-fill");
                    return;
                }

                var code = !string.IsNullOrWhiteSpace(resp.order_Code) ? resp.order_Code : resp.order_Id.ToString();

                Session.Remove(SK_DRAFT);
                Session.Remove(SK_PENDING_ORDER_CODE);
                Session.Remove(SK_PENDING_PAYMENT_URL);
                Session.Remove(SK_PENDING_PAYMENT_CREATED);
                Session.Remove(SK_PENDING_PAYMENT_METHOD);

                var url = ResolveUrl(THANKYOU_PATH) +
                          "?id=" + resp.order_Id +
                          "&code=" + Uri.EscapeDataString(code);
                Response.Redirect(url, false);
                Context.ApplicationInstance.CompleteRequest();
            }
            catch (Exception ex)
            {
                var msg = ex.Message ?? "";

                if (msg.IndexOf("OUT_OF_STOCK", StringComparison.OrdinalIgnoreCase) >= 0)
                {
                    ShowNiceError("OUT_OF_STOCK", "Một số sản phẩm đã hết hàng",
                        "Vui lòng giảm số lượng hoặc bỏ các sản phẩm tạm hết khỏi giỏ, rồi thử lại.",
                        actionsHtml: $"<button type='button' class='btn-soft' onclick=\"location.href='{ResolveUrl("~/CartPage/CartPage.aspx")}'\">Về giỏ hàng để cập nhật</button>",
                        variant: "warning",
                        icon: "bi bi-box-seam");
                    return;
                }

                if (msg.IndexOf("CART_EMPTY", StringComparison.OrdinalIgnoreCase) >= 0)
                {
                    var pendingUrl = Session[SK_PENDING_PAYMENT_URL] as string;
                    if (!string.IsNullOrWhiteSpace(pendingUrl))
                    {
                        pendingUrl = NormalizeGatewayUrlForUA(pendingUrl);
                        ShowNiceError("CART_EMPTY", "Đơn hàng đã khởi tạo trước đó", "Đang chuyển tới trang thanh toán…",
                            null, "info", "bi bi-arrow-right-circle");
                        System.Diagnostics.Trace.WriteLine($"[PAY-REDIRECT:RESTORE] UA={Request?.UserAgent} URL={pendingUrl}");
                        Response.Redirect(pendingUrl, false);
                        Context.ApplicationInstance.CompleteRequest();
                        return;
                    }
                    var code = Session[SK_PENDING_ORDER_CODE] as string;
                    var pid = TryGetPendingOrderId();

                    if (!string.IsNullOrWhiteSpace(code))
                    {
                        var url2 = ResolveUrl(THANKYOU_PATH) +
                                  "?code=" + Uri.EscapeDataString(code) +
                                  (pid.HasValue ? "&id=" + pid.Value : "") +
                                  "&restored=1";
                        Response.Redirect(url2, false);
                        Context.ApplicationInstance.CompleteRequest();
                        return;
                    }

                    ShowNiceError("CART_EMPTY", "Giỏ hàng trống",
                        "Vui lòng quay lại giỏ hàng để đặt lại.",
                        actionsHtml: $"<button type='button' class='btn-soft' onclick=\"location.href='{ResolveUrl("~/CartPage/CartPage.aspx")}'\">Về giỏ hàng</button>",
                        variant: "warning",
                        icon: "bi bi-cart-x");
                    return;
                }

                ShowNiceError("UNKNOWN", "Có lỗi khi tạo đơn hàng", Server.HtmlEncode(msg),
                    actionsHtml: $"<button type='button' class='btn-soft' onclick=\"location.reload()\">Thử lại</button>",
                    variant: "danger",
                    icon: "bi bi-exclamation-octagon-fill");
            }
        }

        // ✅ NÂNG CẤP: alert đẹp + variant + icon + nút đóng
        private void ShowNiceError(string code, string title, string message, string actionsHtml = null, string variant = "danger", string icon = null)
        {
            var v = (variant ?? "danger").Trim().ToLowerInvariant();

            var cls = v == "success" ? "alertx alertx-success"
                    : v == "warning" ? "alertx alertx-warning"
                    : v == "info" ? "alertx alertx-info"
                    : "alertx alertx-danger";

            var iconCls = !string.IsNullOrWhiteSpace(icon)
                ? icon
                : (v == "success" ? "bi bi-check-circle"
                 : v == "warning" ? "bi bi-exclamation-triangle"
                 : v == "info" ? "bi bi-info-circle"
                 : "bi bi-exclamation-octagon-fill");

            var html =
                "<div class='" + cls + "'>" +
                    "<div class='ax-ic'><i class='" + iconCls + "'></i></div>" +
                    "<div class='ax-body'>" +
                        "<div class='ax-title'>" + Server.HtmlEncode(title) + "</div>" +
                        "<p class='ax-msg'>" + (message ?? "") + "</p>" +
                        (string.IsNullOrWhiteSpace(actionsHtml) ? "" : "<div class='ax-actions'>" + actionsHtml + "</div>") +
                        "<input type='hidden' value='" + Server.HtmlEncode(code ?? "") + "' />" +
                    "</div>" +
                    "<button type='button' class='ax-close' onclick=\"this.parentElement.remove()\">" +
                        "<i class='bi bi-x-lg'></i>" +
                    "</button>" +
                "</div>";

            litError.Text = html;
            litError.Visible = true;
        }

        // ===== Detect & normalize gateway URL theo User-Agent =====
        private static bool IsMobileUA(string ua)
        {
            if (string.IsNullOrEmpty(ua)) return false;
            ua = ua.ToLowerInvariant();
            return ua.Contains("android") || ua.Contains("iphone") || ua.Contains("ipad")
                || ua.Contains("ipod") || ua.Contains("mobile");
        }

        private string NormalizeGatewayUrlForUA(string url)
        {
            if (string.IsNullOrWhiteSpace(url)) return url;

            // Log original để debug chính xác
            System.Diagnostics.Trace.WriteLine($"[GATEWAY-ORIGINAL-URL] {url}");

            // ✅ giữ logic normalize cho ZaloPay nếu URL là qcgateway (trường hợp bạn dùng lại về sau)
            if (url.Contains("qcgateway.zalopay.vn"))
            {
                try
                {
                    var uri = new Uri(url);
                    var fullQuery = uri.Query;
                    if (fullQuery.Contains("order=") || fullQuery.Contains("zp_trans_token=") || fullQuery.Contains("q="))
                    {
                        var queryPart = fullQuery.StartsWith("?") ? fullQuery : "?" + fullQuery;
                        var normalized = "https://qcgateway.zalopay.vn/openinapp" + queryPart;

                        System.Diagnostics.Trace.WriteLine($"[GATEWAY-NORMALIZED-URL] {normalized}");
                        return normalized;
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Trace.WriteLine($"[GATEWAY-NORMALIZE-ERROR] {ex.Message} | Original URL: {url}");
                }
            }

            return url;
        }
    }
}

