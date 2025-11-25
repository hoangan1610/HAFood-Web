<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Register.aspx.cs" Inherits="HAFoodWeb.AuthPage.Register" Async="true" %>
<%@ Register Src="~/Control/Header.ascx" TagPrefix="uc" TagName="Header" %>
<%@ Register Src="~/Control/Footer.ascx" TagPrefix="uc" TagName="Footer" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">

    <title>Tạo tài khoản - HAFood</title>

    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600&display=swap" rel="stylesheet" />

    <style>
        * { box-sizing: border-box; }

        body {
            background: radial-gradient(circle at top left, #ffe0c2, #ffe9d6 40%, #f8f9fa 100%);
            font-family: 'Poppins', sans-serif;
            margin: 0;
        }

        .register-page-wrapper {
            min-height: calc(100vh - 120px);
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 40px 16px;
        }

        .register-container {
            width: 100%;
            max-width: 520px;
            margin: 0 auto;
            padding: 34px 32px 28px;
            background: #fff;
            border-radius: 20px;
            box-shadow: 0 24px 50px rgba(0,0,0,0.08);
            position: relative;
            overflow: hidden;
        }

        .register-container::before {
            content: "";
            position: absolute;
            top: -80px;
            right: -80px;
            width: 170px;
            height: 170px;
            background: rgba(255, 143, 66, 0.18);
            border-radius: 50%;
        }

        .register-header {
            position: relative;
            z-index: 1;
            text-align: center;
            margin-bottom: 22px;
        }

        /* Logo HAFood dùng chung */
        .logo-circle {
            width: 110px;
            height: 110px;
            border-radius: 50%;
            background: linear-gradient(135deg, #ff6600, #ff9a3c);
            display: flex;
            align-items: center;
            justify-content: center;
            color: #fff;
            font-weight: 700;
            letter-spacing: 0.5px;
            font-size: 22px;
            box-shadow: 0 12px 26px rgba(255, 102, 0, 0.4);
            margin: 0 auto 16px;
        }

        .register-container h3 {
            text-align: center;
            margin-bottom: 6px;
            color: #ff6600;
            font-family: "Georgia", serif;
            font-size: 24px;
        }

        .register-subtitle {
            font-size: 14px;
            color: #6c757d;
        }

        .form-control {
            border-radius: 999px;
            padding: 11px 14px;
            font-size: 14px;
            border: 1px solid #dde2e7;
            transition: all 0.2s ease;
        }

        .form-control:focus {
            outline: none;
            border-color: #ff7a1a;
            box-shadow: 0 0 0 3px rgba(255, 122, 26, 0.18);
        }

        .mb-3 label {
            font-size: 14px;
            font-weight: 500;
            color: #495057;
            margin-bottom: 6px;
            display: block;
        }

        .btn-register {
            background-color: #ff6600 !important;
            background-image: linear-gradient(135deg, #ff6600, #ff8c3b) !important;
            color: #ffffff !important;
            border: none;
            border-radius: 999px !important;
            font-weight: 600;
            font-family: "Georgia", serif !important;
            padding: 10px 40px;
            width: 50%;
            display: inline-block;
            text-align: center;
            transition: all 0.25s ease;
            box-shadow: 0 14px 28px rgba(255, 102, 0, 0.35);
        }

        .btn-register:hover {
            background-image: linear-gradient(135deg, #ff6600, #ff7a1a) !important;
            transform: translateY(-2px);
            box-shadow: 0 18px 34px rgba(255, 102, 0, 0.4);
        }

        .btn-register:active {
            transform: translateY(0);
            box-shadow: 0 8px 16px rgba(255, 102, 0, 0.3);
        }

        .link-option {
            text-decoration: none;
            color: #6c757d;
            font-size: 14px;
            margin: 0 18px;
            transition: color 0.2s ease, transform 0.2s ease;
        }

        .link-option:hover {
            color: #ff6600;
            transform: translateY(-1px);
        }

        .return-link {
            text-decoration: none;
            color: #6c757d;
            font-size: 14px;
            transition: color 0.2s ease, transform 0.2s ease;
        }

        .return-link:hover {
            color: #000000;
            transform: translateY(-1px);
        }

        .text-danger {
            font-size: 0.9em;
            margin-top: 4px;
        }

        .bottom-meta {
            margin-top: 18px;
            font-size: 13px;
            color: #6c757d;
            text-align: center;
        }
    </style>
</head>
<body>
<form id="form1" runat="server">
    <uc:Header runat="server" ID="HeaderControl" />

    <div class="register-page-wrapper">
        <div class="register-container">
            <div class="register-header">
                <div class="logo-circle">HAFood</div>
                <h3>Tạo tài khoản</h3>
                <p class="register-subtitle">
                    Đăng ký tài khoản để bắt đầu đặt món, lưu địa chỉ và nhận ưu đãi từ HAFood.
                </p>
            </div>

            <div class="mb-3">
                <label for="txtFullName">Họ và tên</label>
                <asp:TextBox ID="txtFullName" runat="server" CssClass="form-control" placeholder="Họ và tên" />
                <asp:Label ID="lblFullNameError" runat="server" CssClass="text-danger" />
            </div>

            <div class="mb-3">
                <label for="txtEmail">Email</label>
                <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" placeholder="Email" />
                <asp:Label ID="lblEmailError" runat="server" CssClass="text-danger" />
            </div>

            <div class="mb-3">
                <label for="txtPassword">Mật khẩu</label>
                <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control" TextMode="Password" placeholder="Mật khẩu" />
                <asp:Label ID="lblPasswordError" runat="server" CssClass="text-danger" />
            </div>

            <div class="mb-3">
                <label for="txtPhone">Số điện thoại</label>
                <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control" placeholder="Số điện thoại" />
                <asp:Label ID="lblPhoneError" runat="server" CssClass="text-danger" />
            </div>

            <div class="text-center mb-3">
                <asp:HyperLink ID="lnkBackToLogin" runat="server" NavigateUrl="~/AuthPage/Login.aspx" CssClass="link-option">
                    Bạn đã có tài khoản ?
                </asp:HyperLink>
                <asp:HyperLink ID="lnkForgotPassword" runat="server" NavigateUrl="~/AuthPage/ForgotPassword.aspx" CssClass="link-option">
                    Quên mật khẩu
                </asp:HyperLink>
            </div>

            <div class="text-center">
                <asp:Button ID="btnRegister" runat="server" Text="Đăng ký" CssClass="btn btn-register" OnClick="btnRegister_Click" />
            </div>

            <div class="mt-3 text-center">
                <asp:HyperLink ID="lnkReturn" runat="server" NavigateUrl="~/HomePage/HomePage.aspx" CssClass="return-link">
                    &lt; Trở về trang chủ
                </asp:HyperLink>
            </div>

            <div class="bottom-meta">
                Bằng việc đăng ký, bạn đồng ý với điều khoản sử dụng và chính sách bảo mật của HAFood.
            </div>
        </div>
    </div>
</form>

<uc:Footer ID="Footer1" runat="server" />
</body>
</html>
