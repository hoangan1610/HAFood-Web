<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="HAFoodWeb.AuthPage.Login" Async="true" %>
<%@ Register Src="~/Control/Header.ascx" TagPrefix="uc" TagName="Header" %>
<%@ Register Src="~/Control/Footer.ascx" TagPrefix="uc" TagName="Footer" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Login - HAFood</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />

    <style>
        body { 
            background-color: #f8f9fa; 
            font-family: 'Poppins', sans-serif; 
        }

        .login-container {
            max-width: 450px;
            margin: 80px auto;
            padding: 40px;
            background: #fff;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }

        .login-container h3 { 
            text-align: center; 
            margin-bottom: 30px; 
            color: #ff6600; 
            font-family: "Georgia", serif;
        }

        .btn-login { 
            background-color: #ff6600 !important;
            color: #ffffff !important;
            border: none;
            border-radius: 999px !important;
            font-weight: 600;
            font-family: "Georgia", serif !important;
            padding: 10px 40px;
            width: 40%; 
            display: inline-block;
            text-align: center;
            transition: all 0.3s ease;
        }

        .btn-login:hover { 
            background-color: #e55a00 !important;
            color: #ffffff !important;
            transform: scale(1.05);
        }

        .link-option {
            text-decoration: none;
            color: #6c757d;
            font-size: 16px;
            margin: 0 30px;
            transition: color 0.3s ease;
        }

        .link-option:hover {
            color: #000000;
        }

        .text-danger {
            font-size: 0.85rem;
            margin-top: 5px;
            display: block;
        }
    </style>
</head>
<body>
<form id="form1" runat="server">
    <uc:Header runat="server" ID="HeaderControl" />

    <div class="login-container">
        <h3>Login</h3>

        <div class="mb-3">
            <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" placeholder="Email" />
            <asp:Label ID="lblEmailError" runat="server" CssClass="text-danger"></asp:Label>
        </div>

        <div class="mb-3">
            <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control" TextMode="Password" placeholder="Password" />
            <asp:Label ID="lblPasswordError" runat="server" CssClass="text-danger"></asp:Label>
        </div>

            <asp:Label ID="lblLoginError" runat="server" CssClass="text-danger text-center mb-2"></asp:Label>

        <div class="text-center mb-3">
            <asp:HyperLink ID="lnkCreateAccount" runat="server" NavigateUrl="~/AuthPage/Register.aspx" CssClass="link-option">Create Account</asp:HyperLink>
            <asp:HyperLink ID="lnkForgotPassword" runat="server" NavigateUrl="~/AuthPage/ForgotPassword.aspx" CssClass="link-option">Forgot Password</asp:HyperLink>
        </div>

        <div class="text-center">
            <asp:Button ID="btnLogin" runat="server" Text="Login" CssClass="btn btn-login" OnClick="btnLogin_Click" />
        </div>
    </div>

    <uc:Footer ID="Footer1" runat="server" />
</form>
</body>
</html>
