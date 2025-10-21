using HAFoodWeb.Models;
using HAFoodWeb.Services;
using HAFoodWeb.Cart;
using System;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace HAFoodWeb
{
    public partial class CartPage : Page
    {
        private readonly CartService _cartService = new CartService();

        protected async void Page_Load(object sender, EventArgs e)
        {
            var tracker = new DeviceTracker(Request, Response);
            tracker.GetOrCreateDeviceUuid(); // đảm bảo có cookie

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
            }
            else
            {
                pnlEmpty.Visible = false;
                rptCart.Visible = true;
                rptCart.DataSource = cart.items;
                rptCart.DataBind();
                lblTotal.Text = "0 ₫";
            }
        }

        protected async void rptCart_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (!long.TryParse(e.CommandArgument?.ToString(), out var variantId))
                return;

            var tracker = new DeviceTracker(Request, Response);
            string deviceUuid = tracker.GetOrCreateDeviceUuid();            // 🔁

            int currentQty = 0;
            var cartControl = e.Item.FindControl("CartItemControl") as CartItem;
            if (cartControl != null) currentQty = cartControl.Quantity;

            int newQty = currentQty;
            switch (e.CommandName)
            {
                case "Increase":
                    newQty = currentQty + 1;
                    break;

                case "Decrease":
                    newQty = Math.Max(1, currentQty - 1);
                    break;

                case "Remove":
                    await _cartService.DeleteCartItemAsync(variantId, deviceUuid); // 🔁
                    await BindCart();
                    AttachSelectionHandlers();
                    updCart.Update(); // ✅ chỉ update vùng UpdatePanel
                    return;

                default:
                    return;
            }

            await _cartService.UpdateQuantityAsync(variantId, deviceUuid, newQty); // 🔁
            await BindCart();
            AttachSelectionHandlers();
            updCart.Update(); // ✅ chỉ update vùng UpdatePanel
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

            var data = e.Item.DataItem as CartItemDto; // strongly-typed
            var cartItem = (CartItem)e.Item.FindControl("CartItemControl");
            if (cartItem == null || data == null) return;

            cartItem.VariantId = data.variant_Id;
            cartItem.ProductName = data.product_Name;
            cartItem.VariantName = data.variant_Name;
            cartItem.ImageUrl = data.image_Variant;
            cartItem.Price = data.price_Variant;   // decimal
            cartItem.Quantity = data.quantity;

            var btnInc = cartItem.FindControl("btnIncrease") as LinkButton;
            var btnDec = cartItem.FindControl("btnDecrease") as LinkButton;
            var btnRem = cartItem.FindControl("btnRemove") as LinkButton;

            var vid = data.variant_Id.ToString();
            if (btnInc != null) btnInc.CommandArgument = vid;
            if (btnDec != null) btnDec.CommandArgument = vid;
            if (btnRem != null) btnRem.CommandArgument = vid;

            cartItem.SelectionChanged -= CartItem_SelectionChanged;
            cartItem.SelectionChanged += CartItem_SelectionChanged;
        }

        private void CartItem_SelectionChanged(object sender, EventArgs e)
        {
            UpdateTotal();
            updCart.Update(); // ✅ update vùng tổng thanh toán
        }

        private void UpdateTotal()
        {
            decimal total = 0m;
            foreach (RepeaterItem item in rptCart.Items)
            {
                var cartItem = (CartItem)item.FindControl("CartItemControl");
                if (cartItem != null && cartItem.Selected)
                {
                    total += cartItem.Price * cartItem.Quantity;
                }
            }
            lblTotal.Text = string.Format(
                System.Globalization.CultureInfo.GetCultureInfo("vi-VN"),
                "{0:N0} ₫", total
            );
        }

        protected void chkSelectAll_CheckedChanged(object sender, EventArgs e)
        {
            bool checkedAll = chkSelectAll.Checked;
            foreach (RepeaterItem item in rptCart.Items)
            {
                var cartItem = (CartItem)item.FindControl("CartItemControl");
                if (cartItem != null)
                    cartItem.Selected = checkedAll;
            }
            UpdateTotal();
            updCart.Update(); // ✅ đồng bộ lại UI trong UpdatePanel
        }
    }
}
