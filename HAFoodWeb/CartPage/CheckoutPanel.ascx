<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="CheckoutPanel.ascx.cs" Inherits="HAFoodWeb.Cart.CheckoutPanel" %>

<style>
.checkout-panel {
    width: 320px;
    padding: 18px;
    background: #fff;
    border-radius: 6px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.04);
    font-family: 'Poppins', sans-serif;
}
.checkout-panel h4 { margin-top:0; margin-bottom:10px; font-size:16px; }
.cp-row { margin-bottom:10px; }
.cp-row label { display:block; font-size:13px; margin-bottom:4px; color:#333; }
.cp-row input[type="text"], .cp-row input[type="tel"], .cp-row select {
    width:100%; padding:8px 10px; border:1px solid #ddd; border-radius:4px;
    font-size:14px; box-sizing:border-box;
}
.cp-summary { margin-top:14px; border-top:1px solid #eee; padding-top:12px; font-size:14px; }
.cp-summary .row { display:flex; justify-content:space-between; margin-bottom:6px; color:#333; }
.cp-summary .total { font-weight:700; font-size:18px; color:#d9534f; }
.btn-place { display:inline-block; margin-top:12px; background:#ff7a00; color:#fff; border:none; padding:10px 14px; border-radius:6px; cursor:pointer; }
.small-muted { font-size:12px; color:#888; }
</style>

<div class="checkout-panel">
    <h4>Thông tin địa chỉ nhận hàng</h4>

    <div class="cp-row">
        <label for="ddlProvince">Thành phố / Tỉnh</label>
        <asp:DropDownList ID="ddlProvince" runat="server" CssClass="" />
    </div>

    <div class="cp-row">
        <label for="ddlDistrict">Quận / Huyện</label>
        <asp:DropDownList ID="ddlDistrict" runat="server" CssClass="" />
    </div>

    <div class="cp-row">
        <label for="ddlWard">Phường / Xã</label>
        <asp:DropDownList ID="ddlWard" runat="server" CssClass="" />
    </div>

    <div class="cp-row">
        <label for="txtAddress">Địa chỉ nhận hàng</label>
        <asp:TextBox ID="txtAddress" runat="server" />
    </div>

    <div class="cp-row">
        <label for="txtPhone">Số điện thoại liên lạc</label>
        <asp:TextBox ID="txtPhone" runat="server" />
    </div>

    <div class="cp-row">
        <label for="txtName">Tên người nhận</label>
        <asp:TextBox ID="txtName" runat="server" />
    </div>

    <div class="cp-summary">
        <div class="row"><span>Tổng số sản phẩm:</span><span><asp:Label ID="lblTotalItems" runat="server" Text="0" /></span></div>
        <div class="row"><span>Tổng tiền hàng:</span><span><asp:Label ID="lblSubtotal" runat="server" Text="0 ₫" /></span></div>
        <div class="row"><span>Phí vận chuyển:</span><span><asp:Label ID="lblShipping" runat="server" Text="0 ₫" /></span></div>
        <div class="row"><span>VAT(8%):</span><span><asp:Label ID="lblVat" runat="server" Text="0 ₫" /></span></div>
        <div class="row total"><span>Tổng thanh toán:</span><span><asp:Label ID="lblTotalPay" runat="server" Text="0 ₫" /></span></div>
    </div>

    <asp:Button ID="btnPlaceOrder" runat="server" CssClass="btn-place" Text="Tiếp Tục Đặt Hàng" OnClick="btnPlaceOrder_Click" />
    <div class="small-muted">Bạn có thể chỉnh sửa thông tin trước khi đặt hàng.</div>
</div>