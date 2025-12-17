<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="HAFoodWeb.AuthPage.Login" Async="true" %>
<%@ Register Src="~/Control/Header.ascx" TagPrefix="uc" TagName="Header" %>
<%@ Register Src="~/Control/Footer.ascx" TagPrefix="uc" TagName="Footer" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Đăng nhập - HAFood</title>

    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" />

    <style>
        * { box-sizing: border-box; }

        body {
            background: radial-gradient(circle at top left, #ffe0c2, #ffe9d6 40%, #f8f9fa 100%);
            font-family: 'Poppins', sans-serif;
            margin: 0;
        }

        .login-page-wrapper {
            min-height: calc(100vh - 120px);
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 40px 16px;
        }

        .login-container {
            width: 100%;
            max-width: 460px;
            padding: 34px 32px 28px;
            background: #ffffff;
            border-radius: 20px;
            box-shadow: 0 24px 50px rgba(0, 0, 0, 0.08);
            position: relative;
            overflow: hidden;
        }

        .login-container::before {
            content: "";
            position: absolute;
            top: -80px;
            right: -80px;
            width: 170px;
            height: 170px;
            background: rgba(255, 143, 66, 0.18);
            border-radius: 50%;
        }

        .login-header {
            position: relative;
            z-index: 1;
            margin-bottom: 22px;
            text-align: center;
        }

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

        .login-container h3 {
            margin: 0;
            color: #ff6600;
            font-family: "Georgia", serif;
            font-size: 24px;
        }

        .login-subtitle {
            margin-top: 6px;
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

        .btn-login {
            background: linear-gradient(135deg, #ff6600, #ff8c3b) !important;
            color: #ffffff !important;
            border: none;
            border-radius: 999px !important;
            font-weight: 600;
            font-family: "Georgia", serif !important;
            padding: 10px 40px;
            width: 60%;
            display: inline-block;
            text-align: center;
            transition: all 0.25s ease;
            box-shadow: 0 14px 28px rgba(255, 102, 0, 0.35);
        }

        .btn-login:hover {
            background: linear-gradient(135deg, #ff6600, #ff7a1a) !important;
            transform: translateY(-2px);
            box-shadow: 0 18px 34px rgba(255, 102, 0, 0.4);
        }

        .btn-login:active {
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
            font-size: 0.85rem;
            margin-top: 5px;
            display: block;
        }

        .error-summary {
            font-size: 13px;
            margin-bottom: 8px;
        }

        .bottom-meta {
            margin-top: 18px;
            font-size: 13px;
            color: #6c757d;
        }

        /* ✅ Eye toggle */
        .password-wrapper { position: relative; }
        .password-input { padding-right: 44px !important; }
        .toggle-password {
            position: absolute;
            right: 14px;
            top: 50%;
            transform: translateY(-50%);
            border: none;
            background: transparent;
            padding: 0;
            color: #6c757d;
            cursor: pointer;
            z-index: 2;
        }
        .toggle-password:hover { color: #ff6600; }
    </style>

    <script type="text/javascript">
        function togglePassword(btn) {
            var targetId = btn.getAttribute('data-target');
            var input = document.getElementById(targetId);
            if (!input) return;

            var icon = btn.querySelector('i');
            var isHidden = (input.type === 'password');

            input.type = isHidden ? 'text' : 'password';
            if (icon) {
                icon.className = isHidden ? 'fa-regular fa-eye-slash' : 'fa-regular fa-eye';
            }
        }
    </script>
</head>
<body>
<form id="form1" runat="server">
    <uc:Header runat="server" ID="HeaderControl" />

    <div class="login-page-wrapper">
        <div class="login-container">
            <div class="login-header">
                <div class="logo-circle">HAFood</div>
                <h3>Đăng nhập</h3>
                <p class="login-subtitle">Chào mừng bạn trở lại với HAFood ✨</p>
            </div>

            <div class="mb-3">
                <label for="txtEmail">Email</label>
                <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" placeholder="Nhập email" />
                <asp:Label ID="lblEmailError" runat="server" CssClass="text-danger"></asp:Label>
            </div>

            <div class="mb-3">
                <label for="txtPassword">Mật khẩu</label>

                <div class="password-wrapper">
                    <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control password-input"
                        TextMode="Password" placeholder="Nhập mật khẩu" />
                    <button type="button" class="toggle-password"
                        data-target="<%= txtPassword.ClientID %>"
                        onclick="togglePassword(this)"
                        aria-label="Hiện/ẩn mật khẩu">
                        <i class="fa-regular fa-eye"></i>
                    </button>
                </div>

                <asp:Label ID="lblPasswordError" runat="server" CssClass="text-danger"></asp:Label>
            </div>

            <asp:Label ID="lblLoginError" runat="server" CssClass="text-danger text-center d-block error-summary"></asp:Label>

            <div class="text-center mb-3">
                <asp:HyperLink ID="lnkCreateAccount" runat="server" NavigateUrl="~/AuthPage/Register.aspx" CssClass="link-option">
                    Tạo tài khoản
                </asp:HyperLink>
                <asp:HyperLink ID="lnkForgotPassword" runat="server" NavigateUrl="~/AuthPage/ForgotPassword.aspx" CssClass="link-option">
                    Quên mật khẩu
                </asp:HyperLink>
            </div>

            <div class="text-center">
                <asp:Button ID="btnLogin" runat="server" Text="Đăng nhập" CssClass="btn btn-login" OnClick="btnLogin_Click" />
            </div>

            <div class="mt-3 text-center">
                <asp:HyperLink ID="lnkReturn" runat="server" NavigateUrl="~/HomePage/HomePage.aspx" CssClass="return-link">
                    &lt; Trở về trang chủ
                </asp:HyperLink>
            </div>

            <div class="bottom-meta text-center">
                Đăng nhập để tiếp tục đặt món, lưu đơn hàng và nhận khuyến mãi mới nhất từ HAFood 🍽️
            </div>
        </div>
    </div>

    <uc:Footer ID="Footer1" runat="server" />
</form>
</body>
</html>
