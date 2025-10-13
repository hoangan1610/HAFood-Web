<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="OTP.aspx.cs" Inherits="HAFoodWeb.AuthPage.OTP" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Verify OTP</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f7f7f7;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
        }

        .otp-container {
            background-color: #fff;
            padding: 40px 30px;
            border-radius: 10px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            width: 350px;
            text-align: center;
        }

        h2 {
            margin-bottom: 20px;
            color: #333;
        }

        input[type="text"] {
            width: 100%;
            padding: 12px;
            margin-bottom: 15px;
            border-radius: 5px;
            border: 1px solid #ccc;
            font-size: 16px;
        }

        input[type="button"], input[type="submit"], .aspNetButton {
            width: 100%;
            padding: 12px;
            margin-top: 10px;
            border: none;
            border-radius: 5px;
            background-color: #007bff;
            color: white;
            font-size: 16px;
            cursor: pointer;
            transition: background-color 0.3s;
        }

        input[type="button"]:disabled, input[type="submit"]:disabled {
            background-color: #6c757d;
            cursor: not-allowed;
        }

        input[type="button"]:hover:not(:disabled), input[type="submit"]:hover:not(:disabled) {
            background-color: #0056b3;
        }

        .message {
            margin-bottom: 15px;
            font-size: 14px;
        }

        #lblError {
            color: red;
        }

        #lblSuccess {
            color: green;
        }
    </style>

    <script type="text/javascript">
        var resendCountdown = 60;

        function startResendCountdown() {
            var btn = document.getElementById('<%= btnResendOtp.ClientID %>');
            resendCountdown = 60;
            btn.disabled = true;

            var interval = setInterval(function () {
                if (resendCountdown <= 0) {
                    clearInterval(interval);
                    btn.disabled = false;
                    btn.value = "Gửi lại OTP";
                } else {
                    btn.value = "Gửi lại OTP (" + resendCountdown + "s)";
                    resendCountdown--;
                }
            }, 1000);
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="otp-container">
            <h2>Xác minh OTP</h2>
            <asp:Label ID="lblError" runat="server" CssClass="message"></asp:Label>
            <asp:Label ID="lblSuccess" runat="server" CssClass="message"></asp:Label>

            <asp:TextBox ID="txtOtp" runat="server" placeholder="Nhập OTP" CssClass="otp-input"></asp:TextBox>

            <asp:Button ID="btnVerifyOtp" runat="server" Text="Xác minh OTP" OnClick="btnVerifyOtp_Click" CssClass="aspNetButton"/>
            <asp:Button ID="btnResendOtp" runat="server" Text="Gửi lại OTP" OnClick="btnResendOtp_Click" CssClass="aspNetButton"/>
        </div>
    </form>
</body>
</html>