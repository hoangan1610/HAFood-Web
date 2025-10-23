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

/* các cột số: căn giữa theo grid cell + text */
.cart-item-price, .cart-item-total, .cart-item-remove, .cart-item-qty{
  justify-self:center;
  text-align:center;
}

/* ===== QUANTITY BOX ===== */
.cart-item-qty{ display:flex; justify-content:center; align-items:center; }

.qty-box{
  display:flex; align-items:center; justify-content:center;
  height:40px; border:1px solid #ddd; border-radius:8px; overflow:hidden;
  margin:0 auto; box-sizing:border-box;
  width:136px; /* 40 + 56 + 40 */
}

/* LinkButton render <a> → ép style đồng nhất */
.qty-btn,
.qty-btn:link,
.qty-btn:visited{
  width:40px; height:40px;                  /* <-- THÊM width để hết lệch */
  display:flex; align-items:center; justify-content:center;
  background:#fff; border:none; cursor:pointer; line-height:1;
  color:#222 !important; text-decoration:none !important;
  padding:0;
}
.qty-btn i{ font-size:18px; line-height:1; display:block; pointer-events:none; }

/* Ô hiển thị số lượng */
.qty-num{
  width:56px; height:40px;
  display:flex; align-items:center; justify-content:center;
  font-weight:600; text-align:center;
}

/* đảm bảo chiều cao đồng nhất */
.cart-item-qty .qty-box, 
.cart-item-qty .qty-box * { line-height:40px; }

.btn-remove{
  color:#fff; background:#e74c3c; border:none; border-radius:8px; padding:8px 14px; cursor:pointer;
}
.btn-qty-disabled{ opacity:.55; pointer-events:none; }
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
        <div class="qty-box">
            <!-- Đặt "+" bên trái, "-" bên phải đúng layout -->
            <asp:LinkButton ID="btnIncrease" runat="server" CssClass="qty-btn" CommandName="Increase" ToolTip="Tăng"
                            CausesValidation="false">
                <i class="bi bi-plus"></i>
            </asp:LinkButton>

            <span class="qty-num"><asp:Literal ID="litQty" runat="server" /></span>

            <asp:LinkButton ID="btnDecrease" runat="server" CssClass="qty-btn" CommandName="Decrease" ToolTip="Giảm"
                            CausesValidation="false">
                <i class="bi bi-dash"></i>
            </asp:LinkButton>
        </div>
    </div>

    <div class="cart-item-total">
        <asp:Literal ID="litTotal" runat="server" />
    </div>

    <div class="cart-item-remove" style="text-align:center">
        <asp:LinkButton ID="btnRemove" runat="server" CssClass="btn-remove" CommandName="Remove"
                        CausesValidation="false">Xoá</asp:LinkButton>
    </div>
</div>