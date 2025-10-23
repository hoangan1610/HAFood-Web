using HAFoodWeb.Models;
using HAFoodWeb.Services;
using HAFoodWeb.Cart;
using System;
using System.Linq;
using System.Threading.Tasks;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace HAFoodWeb
{
    public partial class CartPage : Page
    {
        private readonly CartService _cartService = new CartService();
        private const decimal VAT_RATE = 0.08m;

        public class CheckoutDraft
        {
            public string ShipName { get; set; }
            public string ShipPhone { get; set; }
            public string ShipAddress { get; set; }
            public string PromoCode { get; set; }
            public string Note { get; set; }
            public long[] SelectedLineIds { get; set; }
            public (long variant_Id, int quantity)[] Items { get; set; }
            public string DeviceUuid { get; set; }
        }

        protected async void Page_Load(object sender, EventArgs e)
        {
            var tracker = new DeviceTracker(Request, Response);
            tracker.GetOrCreateDeviceUuid();
            await tracker.SendAsync(null);

            if (!IsPostBack)
                await BindCart();

            AttachSelectionHandlers();
        }

        private async Task BindCart()
        {
            var tracker = new DeviceTracker(Request, Response);
            string deviceUuid = tracker.GetOrCreateDeviceUuid();
            var cart = await _cartService.GetCartAsync(deviceUuid);

            if (cart?.items == null || !cart.items.Any())
            {
                rptCart.Visible = false;
                pnlEmpty.Visible = true;

                lblTotal.Text = "0 ₫";
                lblSumItems.Text = "0";
                lblTotalWeight.Text = "0";
                lblSubtotal.Text = "0 ₫";
                lblShipping.Text = "0 ₫";
                lblVat.Text = "0 ₫";
                lblGrandTotal.Text = "0 ₫";
            }
            else
            {
                pnlEmpty.Visible = false;
                rptCart.Visible = true;

                rptCart.DataSource = cart.items;
                rptCart.DataBind();

                // Auto-select tất cả
                SelectAllCartItems(true);
                chkSelectAll.Checked = true;

                UpdateTotalsPanel();
            }
            // update panels
            updCart.Update();
            updSummary.Update();
        }

        private void SelectAllCartItems(bool selected)
        {
            foreach (RepeaterItem item in rptCart.Items)
            {
                var ci = item.FindControl("CartItemControl") as CartItem;
                if (ci != null) ci.Selected = selected;
            }
        }

        protected async void rptCart_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (!long.TryParse(e.CommandArgument?.ToString(), out var variantId))
                return;

            var tracker = new DeviceTracker(Request, Response);
            string deviceUuid = tracker.GetOrCreateDeviceUuid();

            var cartControl = e.Item.FindControl("CartItemControl") as CartItem;
            int currentQty = cartControl?.Quantity ?? 0;
            int newQty = currentQty;

            switch (e.CommandName)
            {
                case "Increase": newQty = currentQty + 1; break;
                case "Decrease": newQty = Math.Max(1, currentQty - 1); break;
                case "Remove":
                    await _cartService.DeleteCartItemAsync(variantId, deviceUuid);
                    await BindCart();
                    AttachSelectionHandlers();
                    return;
                default: return;
            }

            await _cartService.UpdateQuantityAsync(variantId, deviceUuid, newQty);
            await BindCart();
            AttachSelectionHandlers();
        }

        private void AttachSelectionHandlers()
        {
            if (rptCart == null) return;
            foreach (RepeaterItem item in rptCart.Items)
            {
                var cartItem = item.FindControl("CartItemControl") as CartItem;
                if (cartItem == null) continue;

                cartItem.SelectionChanged -= CartItem_SelectionChanged;
                cartItem.SelectionChanged += CartItem_SelectionChanged;
            }
        }

        protected void rptCart_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item && e.Item.ItemType != ListItemType.AlternatingItem) return;

            var data = e.Item.DataItem as CartItemDto;
            var cartItem = (CartItem)e.Item.FindControl("CartItemControl");
            if (cartItem == null || data == null) return;

            cartItem.VariantId = data.variant_Id;
            cartItem.ProductName = data.product_Name;
            cartItem.VariantName = data.variant_Name;
            cartItem.ImageUrl = data.image_Variant;
            cartItem.Price = data.price_Variant;
            cartItem.Quantity = data.quantity;

            cartItem.WeightPerUnit = 0m; // TODO: bind khi backend có

            var btnInc = cartItem.FindControl("btnIncrease") as LinkButton;
            var btnDec = cartItem.FindControl("btnDecrease") as LinkButton;
            var btnRem = cartItem.FindControl("btnRemove") as LinkButton;

            var vid = data.variant_Id.ToString();
            if (btnInc != null) btnInc.CommandArgument = vid;
            if (btnDec != null) btnDec.CommandArgument = vid;
            if (btnRem != null) btnRem.CommandArgument = vid;
        }

        private void CartItem_SelectionChanged(object sender, EventArgs e)
        {
            bool allSelected = true;
            foreach (RepeaterItem item in rptCart.Items)
            {
                var ci = item.FindControl("CartItemControl") as CartItem;
                if (ci == null) continue;
                if (!ci.Selected) { allSelected = false; break; }
            }
            chkSelectAll.Checked = allSelected;

            UpdateTotalsPanel();
            updSummary.Update();
        }

        protected void chkSelectAll_CheckedChanged(object sender, EventArgs e)
        {
            bool checkedAll = chkSelectAll.Checked;
            SelectAllCartItems(checkedAll);
            UpdateTotalsPanel();
            updCart.Update();
            updSummary.Update();
        }

        private void UpdateTotalsPanel()
        {
            decimal subtotal = 0m;
            int sumItems = 0;
            decimal shipping = 0m;
            decimal weight = 0m; // gram

            foreach (RepeaterItem item in rptCart.Items)
            {
                var cartItem = (CartItem)item.FindControl("CartItemControl");
                if (cartItem != null && cartItem.Selected)
                {
                    subtotal += cartItem.Price * cartItem.Quantity;
                    sumItems += cartItem.Quantity;
                    // weight += cartItem.WeightPerUnit * cartItem.Quantity;
                }
            }

            var vat = Math.Round(subtotal * VAT_RATE, 0, MidpointRounding.AwayFromZero);
            var grand = subtotal + shipping + vat;

            var viVN = System.Globalization.CultureInfo.GetCultureInfo("vi-VN");
            lblTotal.Text = string.Format(viVN, "{0:N0} ₫", subtotal);
            lblSumItems.Text = sumItems.ToString();
            lblTotalWeight.Text = string.Format("{0:N0}", weight);
            lblSubtotal.Text = string.Format(viVN, "{0:N0} ₫", subtotal);
            lblShipping.Text = string.Format(viVN, "{0:N0} ₫", shipping);
            lblVat.Text = string.Format(viVN, "{0:N0} ₫", vat);
            lblGrandTotal.Text = string.Format(viVN, "{0:N0} ₫", grand);
        }

        // ===== Helpers =====
        private static string MergeAddress(string street, string wardText, string cityText)
        {
            string[] parts = new[] { street, wardText, cityText };
            return string.Join(", ",
                parts.Where(s => !string.IsNullOrWhiteSpace(s))
                     .Select(s => s.Trim().Trim(',')));
        }

        private void AddPageError(string message)
        {
            var cv = new CustomValidator
            {
                IsValid = false,
                ErrorMessage = message,
                Display = ValidatorDisplay.None,
                EnableClientScript = false,
                ValidationGroup = "Checkout"
            };
            Page.Validators.Add(cv);
        }

        private bool IsLoggedIn()
        {
            var hasToken = Request.Cookies["AuthToken"] != null
                           && !string.IsNullOrWhiteSpace(Request.Cookies["AuthToken"].Value);
            return hasToken || (Context?.User?.Identity?.IsAuthenticated ?? false);
        }

        // ===== SINGLE handler duy nhất =====
        protected void btnCheckout_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            var items = new System.Collections.Generic.List<(long, int)>();
            var lineIds = new System.Collections.Generic.List<long>();
            foreach (RepeaterItem it in rptCart.Items)
            {
                var ci = it.FindControl("CartItemControl") as Cart.CartItem;
                if (ci == null || !ci.Selected) continue;
                if (ci.LineId > 0) lineIds.Add(ci.LineId);
                items.Add((ci.VariantId, ci.Quantity));
            }
            if (items.Count == 0)
            {
                AddPageError("Vui lòng chọn ít nhất 1 sản phẩm để tiếp tục.");
                return;
            }

            string cityText = txtCitySel.Text?.Trim();
            string wardText = txtWardSel.Text?.Trim();
            string fullAddr = MergeAddress(txtAddress.Text, wardText, cityText);

            var tracker = new DeviceTracker(Request, Response);
            var deviceUuid = tracker.GetOrCreateDeviceUuid();

            var draft = new CheckoutDraft
            {
                ShipName = txtReceiver.Text.Trim(),
                ShipPhone = txtPhone.Text.Trim(),
                ShipAddress = fullAddr,
                PromoCode = txtPromo?.Text?.Trim(),
                Note = txtNote?.Text?.Trim(),
                SelectedLineIds = lineIds.Count > 0 ? lineIds.ToArray() : null,
                Items = items.ToArray(),
                DeviceUuid = deviceUuid
            };

            // Lưu draft trước khi điều hướng
            Session["checkout_draft"] = draft;

            // Bắt đăng nhập
            if (!IsLoggedIn())
            {
                var returnUrl = Server.UrlEncode(ResolveUrl("~/CartPage/CheckoutConfirm.aspx"));
                var loginUrl = ResolveUrl("~/AuthPage/Login.aspx") + "?returnUrl=" + returnUrl;

                Response.Redirect(loginUrl, false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            // Đã đăng nhập -> sang trang xác nhận
            var url = ResolveUrl("~/CartPage/CheckoutConfirm.aspx");
            Response.Redirect(url, false);
            Context.ApplicationInstance.CompleteRequest();
        }
    }
}
