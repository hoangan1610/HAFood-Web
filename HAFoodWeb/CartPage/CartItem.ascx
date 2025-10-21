<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="CartItem.ascx.cs" Inherits="HAFoodWeb.Cart.CartItem" %>

<style>
.cart-item { display:grid; grid-template-columns: 40px 120px 1fr 100px 120px 120px 60px; gap:12px; align-items:center; padding:18px 6px; border-bottom:1px solid #f0f0f0; }
.item-checkbox { display:flex; justify-content:center; align-items:center; }
.cart-image { display:flex; align-items:center; justify-content:center; }
.cart-item-image { width:100px; height:100px; object-fit:cover; border-radius:8px; }
.cart-item-info { text-align:left; }
.product-name { font-weight:600; margin-bottom:6px; }
.variant-name { color:#666; font-size:13px; }
.cart-item-price, .cart-item-total { text-align:center; font-weight:600; }
.cart-item-qty { display:flex; align-items:center; justify-content:center; gap:8px; }
.btn-qty { width:30px; height:30px; display:inline-flex; align-items:center; justify-content:center; border:1px solid #ddd; border-radius:4px; cursor:pointer; background:#fff; }
.qty { min-width:28px; text-align:center; display:inline-block; }
.cart-item-remove { text-align:center; }
.btn-remove { color:#e74c3c; cursor:pointer; background:transparent; border:none; }
.btn-qty.btn-qty-disabled { opacity:.55; cursor:default; pointer-events:none; }
</style>

<div class="cart-item">
    <div class="item-checkbox">
        <asp:CheckBox ID="chkSelect" runat="server" AutoPostBack="true" OnCheckedChanged="chkSelect_CheckedChanged" />
    </div>

    <div class="cart-image">
        <img id="imgProduct" runat="server" class="cart-item-image" />
    </div>

    <div class="cart-item-info">
        <div class="product-name"><asp:Literal ID="litProductName" runat="server" /></div>
        <div class="variant-name"><asp:Literal ID="litVariantName" runat="server" /></div>
    </div>

    <div class="cart-item-price">
        <asp:Literal ID="litPrice" runat="server" />
    </div>

    <div class="cart-item-qty">
        <asp:LinkButton ID="btnDecrease" runat="server" CssClass="btn-qty" CommandName="Decrease">
            <i class="bi bi-dash"></i>
        </asp:LinkButton>
        <span class="qty"><asp:Literal ID="litQty" runat="server" /></span>
        <asp:LinkButton ID="btnIncrease" runat="server" CssClass="btn-qty" CommandName="Increase">
            <i class="bi bi-plus"></i>
        </asp:LinkButton>
    </div>

    <div class="cart-item-total">
        <asp:Literal ID="litTotal" runat="server" />
    </div>

    <div class="cart-item-remove">
        <asp:LinkButton ID="btnRemove" runat="server" CssClass="btn-remove" CommandName="Remove">
            <i class="bi bi-trash"></i>
        </asp:LinkButton>
    </div>
</div>