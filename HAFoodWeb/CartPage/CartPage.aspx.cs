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
        private CartService _cartService = new CartService();

        protected async void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                await BindCart();
            }

            AttachSelectionHandlers();
        }

        private async Task BindCart()
        {
            var deviceCookie = Request.Cookies["HADeviceId"];
            if (deviceCookie == null || !long.TryParse(deviceCookie.Value, out var deviceId))
            {
                rptCart.Visible = false;
                pnlEmpty.Visible = true;
                lblTotal.Text = "0 ₫";
                return;
            }

            var cart = await _cartService.GetCartAsync(deviceId);

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

            dynamic data = e.Item.DataItem;
            var cartItem = (CartItem)e.Item.FindControl("CartItemControl");
            if (cartItem == null || data == null) return;

            cartItem.VariantId = Convert.ToInt64(data.variant_Id);
            cartItem.ProductName = data.product_Name;
            cartItem.VariantName = data.variant_Name;
            cartItem.ImageUrl = data.image_Variant;
            cartItem.Price = Convert.ToDecimal(data.price_Variant);
            cartItem.Quantity = Convert.ToInt32(data.quantity);

            var btnInc = cartItem.FindControl("btnIncrease") as LinkButton;
            var btnDec = cartItem.FindControl("btnDecrease") as LinkButton;
            var btnRem = cartItem.FindControl("btnRemove") as LinkButton;

            var vid = data.variant_Id?.ToString();
            if (!string.IsNullOrEmpty(vid))
            {
                if (btnInc != null) btnInc.CommandArgument = vid;
                if (btnDec != null) btnDec.CommandArgument = vid;
                if (btnRem != null) btnRem.CommandArgument = vid;
            }

            cartItem.SelectionChanged -= CartItem_SelectionChanged;
            cartItem.SelectionChanged += CartItem_SelectionChanged;
        }

        private void CartItem_SelectionChanged(object sender, EventArgs e)
        {
            UpdateTotal();
        }

        protected async void rptCart_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            System.Diagnostics.Debug.WriteLine($"ItemCommand called: CommandName={e.CommandName}, CommandArgument={e.CommandArgument}");

            if (!long.TryParse(e.CommandArgument?.ToString(), out var variantId))
                return;

            var deviceCookie = Request.Cookies["HADeviceId"];
            if (deviceCookie == null || !long.TryParse(deviceCookie.Value, out var deviceId))
                return;

            int currentQty = 0;
            var cartControl = e.Item.FindControl("CartItemControl") as CartItem;
            if (cartControl != null)
            {
                currentQty = cartControl.Quantity;
            }

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
                    await _cartService.DeleteCartItemAsync(variantId, deviceId);
                    await BindCart();
                    AttachSelectionHandlers();
                    return;
                default:
                    return;
            }

            await _cartService.UpdateQuantityAsync(variantId, deviceId, newQty);

            await BindCart();
            AttachSelectionHandlers();
        }

        private void UpdateTotal()
        {
            decimal total = 0;

            foreach (RepeaterItem item in rptCart.Items)
            {
                var cartItem = (CartItem)item.FindControl("CartItemControl");
                if (cartItem != null && cartItem.Selected)
                {
                    total += cartItem.Price * cartItem.Quantity;
                }
            }

            lblTotal.Text = string.Format(System.Globalization.CultureInfo.GetCultureInfo("vi-VN"), "{0:N0} ₫", total);
        }

        protected void chkSelectAll_CheckedChanged(object sender, EventArgs e)
        {
            bool checkedAll = chkSelectAll.Checked;

            foreach (RepeaterItem item in rptCart.Items)
            {
                var cartItem = (CartItem)item.FindControl("CartItemControl");
                if (cartItem != null)
                {
                    cartItem.Selected = checkedAll;
                }
            }

            UpdateTotal();
        }
    }
}