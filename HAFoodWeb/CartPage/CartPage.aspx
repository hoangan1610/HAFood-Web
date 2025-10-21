<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CartPage.aspx.cs" Inherits="HAFoodWeb.CartPage" Async="true" %>
<%@ Register Src="~/Control/Header.ascx" TagPrefix="uc" TagName="Header" %>
<%@ Register Src="~/Control/Footer.ascx" TagPrefix="uc" TagName="Footer" %>
<%@ Register Src="~/CartPage/CartItem.ascx" TagPrefix="uc" TagName="CartItem" %>

<!DOCTYPE html>
<html lang="vi">
<head runat="server">
    <title>Giỏ hàng</title>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;700&display=swap" rel="stylesheet" />
    <style>
        body { font-family: 'Poppins', sans-serif; background:#f8f9fa; margin:0; padding:0; }
        .cart-container { max-width:1000px; margin:40px auto; padding:20px; background:#fff; border-radius:12px; box-shadow:0 4px 10px rgba(0,0,0,0.05); }
        .cart-title { font-size:24px; font-weight:600; margin-bottom:20px; text-align:center; }

        /* grid header khớp với item */
        .cart-header { display:grid; grid-template-columns: 40px 120px 1fr 100px 120px 120px 60px; align-items:center; padding:10px 0; border-bottom:2px solid #eee; gap:12px; }
        .cart-header .select-all { grid-column: 1 / span 1; display:flex; align-items:center; justify-content:flex-start; gap:8px; padding-left:6px; }
        .cart-header .select-all label { margin-left:4px; cursor:pointer; user-select:none; white-space:nowrap; font-weight:600; }
        .cart-header > div:nth-child(3) { text-align:left; padding-left:20px; }

        .total { margin-top:25px; font-size:20px; font-weight:bold; text-align:right; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <uc:Header ID="Header1" runat="server" />

        <div class="cart-container">
            <div class="cart-title">Giỏ hàng</div>

            <div class="cart-header">
                <div class="select-all">
                    <asp:CheckBox ID="chkSelectAll" runat="server" AutoPostBack="true" OnCheckedChanged="chkSelectAll_CheckedChanged" />
                    <label for="<%= chkSelectAll.ClientID %>">Chọn tất cả</label>
                </div>
                <div></div>
                <div>SẢN PHẨM</div>
                <div>GIÁ</div>
                <div>SL</div>
                <div>SỐ TIỀN</div>
                <div></div>
            </div>

            <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
                <p>Giỏ hàng bạn đang trống</p>
            </asp:Panel>

            <asp:Repeater ID="rptCart" runat="server" OnItemCommand="rptCart_ItemCommand" OnItemDataBound="rptCart_ItemDataBound">
                <ItemTemplate>
                    <uc:CartItem ID="CartItemControl" runat="server" />
                </ItemTemplate>
            </asp:Repeater>

            <div class="total">
                Tổng thanh toán: <asp:Label ID="lblTotal" runat="server" Text="0 ₫"></asp:Label>
            </div>
        </div>

        <uc:Footer ID="Footer1" runat="server" />
    </form>
</body>
</html>