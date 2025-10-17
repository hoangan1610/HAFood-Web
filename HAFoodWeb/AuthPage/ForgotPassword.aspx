<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ForgotPassword.aspx.cs" Inherits="HAFoodWeb.AuthPage.ForgotPassword" Async="true" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Forgot Password - HAFood</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f9;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
        }

        .container {
            background-color: #fff;
            border-radius: 10px;
            padding: 40px;
            width: 380px;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
        }

        h2 {
            text-align: center;
            color: #333;
            margin-bottom: 25px;
        }

        .input-group {
            margin-bottom: 20px;
            display: flex;
        }

        input[type="email"] {
            width: 100%;       
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 6px;
            font-size: 15px;
        }
        .btn-container {
            display: flex;
            justify-content: center;
            justify-content: center; /* căn giữa theo ngang */
        }

        .btn {
            width: 50%;
            padding: 14px;
            background-color: #e55a00; 
            border: none;
            color: white;
            border-radius: 20px; 
            font-size: 16px;
            cursor: pointer;
            transition: background-color 0.3s ease, transform 0.2s;
        }

        .btn:hover {
            background-color: #d14e00; 
            transform: translateY(-2px); 
        }

        .message {
            text-align: center;
            color: red;
            margin-top: 15px;
        }
    </style>
</head>
<body>
    <form id="formForgot" runat="server">
        <div class="container">
            <h2>Quên mật khẩu</h2>
                <asp:Label ID="lblMessage" runat="server" CssClass="message"></asp:Label>
            <div class="input-group">
                <asp:TextBox ID="txtEmail" runat="server" Placeholder="Nhập email của bạn" TextMode="Email"></asp:TextBox>
            </div>
            <div class="btn-container">
                <asp:Button ID="btnConfirmEmail" runat="server" Text="Xác nhận email" CssClass="btn" OnClick="btnConfirmEmail_Click" />
            </div>

            <asp:Label ID="lblMessage" runat="server" CssClass="message"></asp:Label>
        </div>
    </form>
</body>
</html>
