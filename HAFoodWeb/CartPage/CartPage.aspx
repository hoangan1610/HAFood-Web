<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CartPage.aspx.cs" Inherits="HAFoodWeb.CartPage" Async="true"%>
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
        body {
            font-family: 'Poppins', sans-serif;
            background-color: #f8f9fa;
            margin: 0;
            padding: 0;
        }

        .cart-container {
            max-width: 1000px;
            margin: 40px auto;
            padding: 20px;
            background: #fff;
            border-radius: 12px;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.05);
        }

        .cart-title {
            font-size: 24px;
            font-weight: 600;
            margin-bottom: 20px;
            text-align: center;
        }

        /* MATCH GRID: phải giống với grid trong CartItem.ascx */
       .cart-header {
            display: grid;
            grid-template-columns: 40px 120px 1fr 110px 95px 100px 60px;
            align-items: center;
            padding: 10px 0;
            border-bottom: 2px solid #eee;
            gap: 12px;
       }

        /* make select-all span across first two columns so label has room */
        .cart-header .select-all {
            grid-column: 1 / span 1;       /* span 2 cột (checkbox + image column) */
            display: flex;
            align-items: center;
            justify-content: flex-start;  /* căn trái */
            gap: 8px;
            padding-left: 6px;            /* chỉnh để khớp với layout */
        }

        /* ngăn wrap nhãn "Chọn tất cả" */
        .cart-header .select-all label {
            margin-left: 4px;
            cursor: pointer;
            user-select: none;
            white-space: nowrap;          /* <--- không cho xuống dòng */
            font-weight: 600;
        }

        /* nếu muốn checkbox hơi lệch xuống giữa ô, dùng align */
        .cart-header .select-all input[type="checkbox"] {
            transform: translateY(0);     /* giữ checkbox thẳng hàng */
        }

        /* tiêu đề cột "SẢN PHẨM" căn trái để khớp với ảnh + text */
        .cart-header > div:nth-child(3) {
            text-align: left;
            padding-left: 20px;
        }

        /* Nếu muốn, có thể đưa tiêu đề "GIÁ" "SL" "SỐ TIỀN" hơi sang trái/ phải:
           ví dụ căn phải cho cột Giá hoặc Số tiền nếu cần:
        */
        /* .cart-header > div:nth-child(4), .cart-header > div:nth-child(6) {
            text-align: center;
        } */

        .total {
            margin-top: 25px;
            font-size: 20px;
            font-weight: bold;
            text-align: right;
        }

        .select-all {
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .select-all label {
            margin-left: 4px;
            cursor: pointer;
            user-select: none;
        }
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
                    <label for="chkSelectAll">Chọn tất cả</label>
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
                Tổng thanh toán: <asp:Label ID="lblTotal" runat="server" Text="0 VND"></asp:Label>
            </div>
        </div>

        <uc:Footer ID="Footer1" runat="server" />
    </form>
</body>
</html>