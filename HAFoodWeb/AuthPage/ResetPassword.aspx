<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ResetPassword.aspx.cs" Inherits="HAFoodWeb.AuthPage.ResetPassword" Async="true" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Reset Password - HAFood</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f7f7f7;
            display:flex;
            justify-content:center;
            align-items:center;
            height:100vh;
            margin:0;
        }
        .card {
            width: 360px;
            background: #fff;
            padding: 28px;
            border-radius: 10px;
            box-shadow: 0 6px 18px rgba(0,0,0,0.08);
            text-align: left;
        }
        .card h2 { margin:0 0 12px 0; font-size:20px; color:#333; }
        .form-group { margin-bottom:14px; }
        .form-group label { display:block; font-size:14px; color:#444; margin-bottom:6px; }
        .form-group input[type="password"] {
            width:100%;
            padding:10px 12px;
            border-radius:8px;
            border:1px solid #ccc;
            font-size:14px;
            box-sizing:border-box;
        }
        .error-label {
            display:block;
            font-size:13px;
            color:#c0392b;
            margin-top:4px;
        }
        .aspNetButton {
            width:100%;
            padding:12px;
            margin-top:6px;
            border:none;
            border-radius:18px;
            background:#ff6600;
            color:white;
            font-size:15px;
            cursor:pointer;
        }
        .aspNetButton:hover:not(:disabled) {
            background-color: #e55a00;
            transform: translateY(-2px);
        }
        .message { margin-top:12px; font-size:14px; margin-bottom:12px; }
        #lblSuccess { color: #16a085; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="card">
            <h2>Đặt lại mật khẩu</h2>

            <asp:Label ID="lblInfo" runat="server" CssClass="message" />

            <div class="form-group">
                <label for="txtNewPassword">Mật khẩu mới</label>
                <asp:TextBox ID="txtNewPassword" runat="server" TextMode="Password" />
                <asp:Label ID="lblNewPasswordError" runat="server" CssClass="error-label" />
            </div>

            <div class="form-group">
                <label for="txtConfirmPassword">Xác nhận mật khẩu mới</label>
                <asp:TextBox ID="txtConfirmPassword" runat="server" TextMode="Password" />
                <asp:Label ID="lblConfirmPasswordError" runat="server" CssClass="error-label" />
            </div>

            <asp:Button ID="btnConfirm" runat="server" CssClass="aspNetButton" Text="Xác nhận mật khẩu"
                        OnClick="btnConfirm_Click" />

            <div class="message">
                <asp:Label ID="lblSuccess" runat="server" />
            </div>
        </div>
    </form>
</body>
</html>