<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ForgotPassword.aspx.cs" Inherits="HAFoodWeb.AuthPage.ForgotPassword" Async="true" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Quên mật khẩu - HAFood</title>

    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600&display=swap" rel="stylesheet" />

    <style>
        :root{
            --border:#e5e7eb;
        }
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
            display: none;
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

        /* === TOAST CUSTOM === */
        .toast-stack{
            position:fixed;
            right:16px;
            top:16px;
            z-index:2300;
            display:flex;
            flex-direction:column;
            gap:10px;
        }
        .toast{
            width: auto;
            max-width: min(480px, calc(100vw - 32px)); 
            border-radius:14px;
            padding:14px 18px;
            box-shadow:0 8px 20px rgba(0,0,0,.12);
            border:1px solid var(--border);
            background:#fff;
            color:#111;
            font-weight:600;
            font-size:15.5px;
            display:flex;
            align-items:flex-start;
            gap:10px;
            word-break: break-word;
            white-space: normal;
            opacity:0;
            transform:translateY(-8px);
            transition:opacity .18s ease, transform .18s ease;
        }

        .toast.show{
            opacity:1;
            transform:translateY(0);
        }
        .toast-success{
            background:#22c55e !important;
            border-color:#16a34a !important;
            color:#fff !important;
        }
        .toast-error{
            background:#ef4444 !important;
            border-color:#b91c1c !important;
            color:#fff !important;
        }
        .toast-text{
            display:inline-block;
            flex:1;
        }
        .toast-close{
            cursor:pointer;
            font-size:18px;
            line-height:1;
            margin-left:8px;
            opacity:.85;
        }
        .toast-close:hover{
            opacity:1;
        }
    </style>

    <script type="text/javascript">
        // Tạo toast custom trong trang, không dùng Bootstrap Toast, không dùng alert
        function showToast(message, type) {
            try {
                var stack = document.getElementById('toastStack');
                if (!stack) {
                    stack = document.createElement('div');
                    stack.id = 'toastStack';
                    stack.className = 'toast-stack';
                    document.body.appendChild(stack);
                }

                var toast = document.createElement('div');
                toast.className = 'toast';

                if (type === 'success') {
                    toast.classList.add('toast-success');
                } else if (type === 'error') {
                    toast.classList.add('toast-error');
                }

                var text = document.createElement('div');
                text.className = 'toast-text';
                text.innerHTML = message;

                var close = document.createElement('div');
                close.className = 'toast-close';
                close.innerHTML = '&times;';
                close.onclick = function () {
                    hideToast(toast);
                };

                toast.appendChild(text);
                toast.appendChild(close);
                stack.appendChild(toast);

                // delay 1 tí để CSS transition chạy
                setTimeout(function () {
                    toast.classList.add('show');
                }, 10);

                // auto hide sau 3.5s
                setTimeout(function () {
                    hideToast(toast);
                }, 3500);
            } catch (e) {
                console.error('showToast error', e);
            }
        }

        function hideToast(toast) {
            if (!toast) return;
            toast.classList.remove('show');
            setTimeout(function () {
                if (toast && toast.parentNode) {
                    toast.parentNode.removeChild(toast);
                }
            }, 200);
        }
    </script>
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

                <!-- Label cũ (ẩn) -->
                <asp:Label ID="lblMessage" runat="server" CssClass="message"></asp:Label>

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

        <!-- Toast container (stack) -->
        <div id="toastStack" class="toast-stack"></div>
    </form>
</body>
</html>
