<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="CartItem.ascx.cs" Inherits="HAFoodWeb.Cart.CartItem" %>

<style>
.cart-item{
  display:grid;
  grid-template-columns:40px 120px 1fr 120px 160px 120px 60px;
  gap:12px; align-items:center;
  padding:16px; border-bottom:1px solid #e9ecef; background:#fff; border-radius:8px;
  box-sizing:border-box;
}
.item-checkbox{display:flex; justify-content:center; align-items:center;}
.cart-item-image{width:80px; height:80px; object-fit:cover; border-radius:8px}
.product-name{font-weight:600; margin-bottom:6px}
.variant-name{color:#666; font-size:13px}
.cart-item-price, .cart-item-total, .cart-item-remove, .cart-item-qty{ justify-self:center; text-align:center; }
.cart-item-qty{ display:flex; justify-content:center; align-items:center; }
.qty-box{
  display:flex; align-items:center; justify-content:center; height:40px;
  border:1px solid #ddd; border-radius:8px; overflow:hidden; margin:0 auto;
  box-sizing:border-box; width:136px;
}
.qty-btn, .qty-btn:link, .qty-btn:visited{
  width:40px; height:40px; display:flex; align-items:center; justify-content:center;
  background:#fff; border:none; cursor:pointer; line-height:1; color:#222 !important;
  text-decoration:none !important; padding:0;
}
.qty-btn i{ font-size:18px; line-height:1; display:block; pointer-events:none; }
.qty-num{ width:56px; height:40px; display:flex; align-items:center; justify-content:center; font-weight:600; text-align:center; }
.cart-item-qty .qty-box, .cart-item-qty .qty-box * { line-height:40px; }
.btn-remove{ color:#fff; background:#e74c3c; border:none; border-radius:8px; padding:8px 14px; cursor:pointer; }
.btn-qty-disabled{ opacity:.55; pointer-events:none; }
</style>

<%-- Root phải runat="server" để gán data-* --%>
<div id="wrap" runat="server" class="cart-item">
    <div class="item-checkbox">
        <!-- KHÔNG AutoPostBack -->
        <asp:CheckBox ID="chkSelect" runat="server" />
    </div>

    <div class="cart-image">
        <img id="imgProduct" runat="server" class="cart-item-image" alt="" />
    </div>

    <div class="cart-item-info">
        <div class="product-name"><asp:Literal ID="litProductName" runat="server" /></div>
        <div class="variant-name"><asp:Literal ID="litVariantName" runat="server" /></div>
    </div>

    <div class="cart-item-price">
        <asp:Literal ID="litPrice" runat="server" />
    </div>

    <div class="cart-item-qty">
        <div class="qty-box">
            <button type="button" class="qty-btn" data-dec="1" title="Giảm">
                <i class="bi bi-dash"></i>
            </button>

            <span class="qty-num"><asp:Literal ID="litQty" runat="server" /></span>

            <button type="button" class="qty-btn" data-inc="1" title="Tăng">
                <i class="bi bi-plus"></i>
            </button>
        </div>
    </div>

    <div class="cart-item-total">
        <asp:Literal ID="litTotal" runat="server" />
    </div>

    <div class="cart-item-remove" style="text-align:center">
        <button type="button" class="btn-remove" data-remove="1">Xoá</button>
    </div>
</div>
