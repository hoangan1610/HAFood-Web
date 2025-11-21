<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ResetPassword.aspx.cs" Inherits="HAFoodWeb.AuthPage.ResetPassword" Async="true" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Khôi phục mật khẩu - HAFood</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600&display=swap" rel="stylesheet" />

    <style>
        * { box-sizing: border-box; }

        body {
            font-family: 'Poppins', Arial, sans-serif;
            background: radial-gradient(circle at top left, #ffe0c2, #ffe9d6 40%, #f8f9fa 100%);
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            margin: 0;
        }

        .reset-wrapper {
            width: 100%;
            max-width: 430px;
            padding: 16px;
        }

        .card-reset {
            width: 100%;
            background: #fff;
            padding: 32px 28px 26px;
            border-radius: 20px;
            box-shadow: 0 24px 50px rgba(0,0,0,0.08);
            text-align: left;
            position: relative;
            overflow: hidden;
        }

        .card-reset::before {
            content: "";
            position: absolute;
            top: -80px;
            right: -80px;
            width: 160px;
            height: 160px;
            background: rgba(255, 143, 66, 0.18);
            border-radius: 50%;
        }

        .reset-header {
            position: relative;
            z-index: 1;
            margin-bottom: 18px;
            text-align: center;
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

        .card-reset h2 {
            margin: 0;
            font-size: 22px;
            color: #222;
            font-weight: 600;
        }

        .reset-subtitle {
            margin-top: 6px;
            font-size: 14px;
            color: #6c757d;
        }

        .form-group {
            margin-bottom: 14px;
            position: relative;
            z-index: 1;
        }

        .form-group label {
            display: block;
            font-size: 14px;
            color: #444;
            margin-bottom: 6px;
            font-weight: 500;
        }

        .input-control {
            width: 100%;
            padding: 11px 14px;
            border-radius: 999px;
            border: 1px solid #dde2e7;
            font-size: 14px;
            box-sizing: border-box;
            transition: all 0.2s ease;
        }

        .input-control:focus {
            outline: none;
            border-color: #ff7a1a;
            box-shadow: 0 0 0 3px rgba(255, 122, 26, 0.18);
        }

        .password-hint {
            font-size: 12px;
            color: #868e96;
            margin-top: 4px;
        }

        .error-label {
            display: block;
            font-size: 13px;
            color: #c0392b;
            margin-top: 4px;
        }

        .aspNetButton {
            width: 100%;
            padding: 11px;
            margin-top: 10px;
            border: none;
            border-radius: 999px;
            background: linear-gradient(135deg, #ff6600, #ff8c3b);
            color: white;
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
            box-shadow: 0 14px 30px rgba(255, 102, 0, 0.35);
            transition: background-color 0.3s ease, transform 0.2s, box-shadow 0.3s ease;
        }

        .aspNetButton:disabled {
            background-color: #ccc;
            color: #666;
            cursor: not-allowed;
            box-shadow: none;
        }

        .aspNetButton:hover:not(:disabled) {
            background: linear-gradient(135deg, #ff6600, #ff7a1a);
            transform: translateY(-2px);
            box-shadow: 0 18px 36px rgba(255, 102, 0, 0.4);
        }

        .aspNetButton:active:not(:disabled) {
            transform: translateY(0);
            box-shadow: 0 10px 18px rgba(255, 102, 0, 0.3);
        }

        .message {
            margin-top: 10px;
            font-size: 14px;
            margin-bottom: 4px;
            position: relative;
            z-index: 1;
        }

        #lblSuccess {
            color: #16a085;
        }

        .back-link {
            position: relative;
            z-index: 1;
            margin-top: 10px;
            font-size: 13px;
            text-align: center;
        }

        .back-link a {
            text-decoration: none;
            color: #6c757d;
            transition: color 0.2s ease, transform 0.2s ease;
        }

        .back-link a:hover {
            color: #ff6600;
            transform: translateY(-1px);
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="reset-wrapper">
            <div class="card-reset">
                <div class="reset-header">
                    <div class="logo-circle">HAFood</div>
                    <h2>Khôi phục mật khẩu</h2>
                    <p class="reset-subtitle">
                        Hãy đặt lại mật khẩu mới cho tài khoản của bạn. 
                        Nên sử dụng mật khẩu mạnh và không trùng với mật khẩu cũ.
                    </p>
                </div>

                <asp:Label ID="lblInfo" runat="server" CssClass="message" />

                <div class="form-group">
                    <label for="txtNewPassword">Mật khẩu mới</label>
                    <asp:TextBox ID="txtNewPassword" runat="server" TextMode="Password" CssClass="input-control" />
                    <span class="password-hint">Tối thiểu 6–8 ký tự, nên có chữ hoa, chữ thường và số.</span>
                    <asp:Label ID="lblNewPasswordError" runat="server" CssClass="error-label" />
                </div>

                <div class="form-group">
                    <label for="txtConfirmPassword">Xác nhận mật khẩu mới</label>
                    <asp:TextBox ID="txtConfirmPassword" runat="server" TextMode="Password" CssClass="input-control" />
                    <asp:Label ID="lblConfirmPasswordError" runat="server" CssClass="error-label" />
                </div>

                <asp:Button ID="btnConfirm" runat="server"
                    CssClass="aspNetButton"
                    Text="Xác nhận mật khẩu"
                    OnClick="btnConfirm_Click" />

                <div class="message">
                    <asp:Label ID="lblSuccess" runat="server" />
                </div>

                <div class="back-link">
                    <a href="Login.aspx">&lt; Quay lại đăng nhập</a>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
