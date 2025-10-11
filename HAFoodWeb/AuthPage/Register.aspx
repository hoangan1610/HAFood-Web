<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Register.aspx.cs" Inherits="HAFoodWeb.AuthPage.Register" Async="true" %>
<%@ Register Src="~/Control/Header.ascx" TagPrefix="uc" TagName="Header" %>
<%@ Register Src="~/Control/Footer.ascx" TagPrefix="uc" TagName="Footer" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Create Account - HAFood</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />

    <style>
        body {
            background-color: #f8f9fa;
            font-family: 'Poppins', sans-serif;
        }

        .register-container {
            max-width: 500px;
            margin: 60px auto;
            padding: 40px;
            background: #fff;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }

        .register-container h3 {
            text-align: center;
            margin-bottom: 30px;
            color: #ff6600;
            font-family: "Georgia", serif;
        }

        .btn-register {
            background-color: #ff6600 !important;
            color: #ffffff !important;
            border: none;
            border-radius: 999px !important;
            font-weight: 600;
            font-family: "Georgia", serif !important;
            padding: 10px 40px;
            width: 30%;
            display: inline-block;
            text-align: center;
            transition: all 0.3s ease;
        }

        .btn-register:hover {
            background-color: #e55a00 !important;
            color: #ffffff !important;
            transform: scale(1.05);
        }

        .return-link {
            text-decoration: none;
            color: #6c757d;
            font-size: 16px;
            transition: color 0.3s ease;
        }

        .return-link:hover {
            color: #000000;
        }

        .text-danger {
            font-size: 0.9em;
        }
    </style>
</head>
<body>
<form id="form1" runat="server">
    <uc:Header runat="server" ID="HeaderControl" />

    <div class="register-container">
        <h3>Create Account</h3>

        <!-- Full Name -->
        <div class="mb-3">
            <asp:TextBox ID="txtFullName" runat="server" CssClass="form-control" placeholder="Full Name" />
            <asp:Label ID="lblFullNameError" runat="server" CssClass="text-danger" />
        </div>

        <!-- Email -->
        <div class="mb-3">
            <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" placeholder="Email" />
            <asp:Label ID="lblEmailError" runat="server" CssClass="text-danger" />
        </div>

        <!-- Password -->
        <div class="mb-3">
            <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control" TextMode="Password" placeholder="Password" />
            <asp:Label ID="lblPasswordError" runat="server" CssClass="text-danger" />
        </div>

        <!-- Phone -->
        <div class="mb-3">
            <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control" placeholder="Phone Number" />
            <asp:Label ID="lblPhoneError" runat="server" CssClass="text-danger" />
        </div>

        <div class="text-center">
            <asp:Button ID="btnRegister" runat="server" Text="Create" CssClass="btn btn-register" OnClick="btnRegister_Click" />
        </div>

        <div class="mt-3 text-center">
            <asp:HyperLink ID="lnkReturn" runat="server" NavigateUrl="~/HomePage/HomePage.aspx" CssClass="return-link">
                &lt; Return to Store
            </asp:HyperLink>
        </div>
    </div>
</form>

<uc:Footer ID="Footer1" runat="server" />
</body>
</html>