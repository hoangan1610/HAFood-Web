<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ForgotPassword.aspx.cs" Inherits="HAFoodWeb.AuthPage.ForgotPassword" Async="true" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Quên mật khẩu - HAFood</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600&display=swap" rel="stylesheet" />

    <style>
        * { box-sizing: border-box; }

        body {
            margin: 0;
            font-family: 'Poppins', Arial, sans-serif;
            background: radial-gradient(circle at top left, #ffe0c2, #ffe9d6 40%, #f8f9fa 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .auth-wrapper {
            width: 100%;
            max-width: 420px;
            padding: 16px;
        }

        .container-forgot {
            background-color: #ffffff;
            border-radius: 18px;
            padding: 32px 28px 28px;
            box-shadow: 0 20px 45px rgba(0, 0, 0, 0.08);
            position: relative;
            overflow: hidden;
        }

        .container-forgot::before {
            content: "";
            position: absolute;
            top: -60px;
            right: -60px;
            width: 140px;
            height: 140px;
            background: rgba(255, 143, 66, 0.15);
            border-radius: 50%;
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

        h2 {
            margin: 0;
            font-size: 24px;
            font-weight: 600;
            color: #222;
            text-align: center;
        }

        .subtitle {
            margin-top: 8px;
            font-size: 14px;
            color: #6c757d;
            text-align: center;
        }

        .input-group-custom {
            margin-top: 24px;
            margin-bottom: 8px;
        }

        .input-label {
            font-size: 14px;
            font-weight: 500;
            margin-bottom: 6px;
            color: #495057;
        }

        .input-control {
            width: 100%;
            padding: 11px 14px;
            border-radius: 999px;
            border: 1px solid #dde2e7;
            font-size: 14px;
            transition: all 0.2s ease;
        }

        .input-control:focus {
            outline: none;
            border-color: #ff7a1a;
            box-shadow: 0 0 0 3px rgba(255, 122, 26, 0.15);
        }

        .btn-container {
            margin-top: 18px;
        }

        .btn-main {
            width: 100%;
            padding: 11px;
            border: none;
            border-radius: 999px;
            background: linear-gradient(135deg, #ff6600, #ff8c3b);
            color: #ffffff;
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.25s ease;
            box-shadow: 0 12px 24px rgba(255, 111, 35, 0.35);
        }

        .btn-main:hover {
            transform: translateY(-1px);
            box-shadow: 0 16px 32px rgba(255, 111, 35, 0.4);
            background: linear-gradient(135deg, #ff6600, #ff7a1a);
        }

        .helper-text {
            margin-top: 10px;
            font-size: 13px;
            color: #6c757d;
            text-align: left;
        }

        .message {
            text-align: left;
            font-size: 13px;
            margin-top: 8px;
        }

        .message.error {
            color: #e03131;
        }

        .message.success {
            color: #2f9e44;
        }

        .footer-links {
            margin-top: 18px;
            display: flex;
            justify-content: space-between;
            font-size: 13px;
        }

        .footer-links a {
            text-decoration: none;
            color: #6c757d;
            transition: color 0.2s ease, transform 0.2s ease;
        }

        .footer-links a:hover {
            color: #ff6600;
            transform: translateY(-1px);
        }
    </style>
</head>
<body>
    <form id="formForgot" runat="server">
        <div class="auth-wrapper">
            <div class="container-forgot">
                <div class="logo-circle">HAFood</div>

                <h2>Quên mật khẩu</h2>
                <p class="subtitle">
                    Nhập địa chỉ email bạn đã đăng ký. Chúng tôi sẽ gửi mã xác thực để giúp bạn đặt lại mật khẩu.
                </p>

                <div class="input-group-custom">
                    <label class="input-label" for="txtEmail">Email</label>
                    <asp:TextBox ID="txtEmail" runat="server"
                        CssClass="input-control"
                        Placeholder="Nhập email của bạn"
                        TextMode="Email"></asp:TextBox>
                </div>

                <asp:Label ID="lblMessage" runat="server" CssClass="message error"></asp:Label>

                <div class="helper-text">
                    Hãy kiểm tra cả hộp thư quảng cáo / spam nếu bạn không thấy email trong vài phút.
                </div>

                <div class="btn-container">
                    <asp:Button ID="btnConfirmEmail" runat="server" Text="Gửi mã xác thực"
                        CssClass="btn-main" OnClick="btnConfirmEmail_Click" />
                </div>

                <div class="footer-links">
                    <asp:HyperLink ID="lnkBackLogin" runat="server" NavigateUrl="~/AuthPage/Login.aspx">
                        ← Quay lại đăng nhập
                    </asp:HyperLink>
                    <asp:HyperLink ID="lnkToHome" runat="server" NavigateUrl="~/HomePage/HomePage.aspx">
                        Về trang chủ
                    </asp:HyperLink>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
