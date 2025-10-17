<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="OTPForgotPassword.aspx.cs" Inherits="HAFoodWeb.AuthPage.OTPForgotPassword" Async="true" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Forgot Password - HAFood</title>
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

        h2 { margin-bottom: 10px; color: #333; }

        .otp-inputs {
            display: flex;
            justify-content: space-between;
            margin: 20px 0;
        }

        .otp-inputs input {
            width: 45px;
            height: 50px;
            text-align: center;
            font-size: 22px;
            border-radius: 8px;
            border: 1px solid #ccc;
            outline: none;
            transition: all 0.2s;
        }

        .otp-inputs input:focus {
            border-color: #e55a00;
            box-shadow: 0 0 5px rgba(40, 167, 69, 0.3);
        }

        .aspNetButton {
            width: 100%;
            padding: 12px;
            margin-top: 10px;
            border: none;
            border-radius: 20px;
            background-color: #ff6600;
            color: white;
            font-size: 16px;
            cursor: pointer;
            box-shadow: 0 4px 10px rgba(40, 167, 69, 0.3);
            transition: background-color 0.3s ease, transform 0.2s;
        }

        .aspNetButton:disabled {
            background-color: #ccc;
            color: #666;
            cursor: not-allowed;
            box-shadow: none;
        }

        .aspNetButton:hover:not(:disabled) {
            background-color: #e55a00;
            transform: translateY(-2px);
        }

        .hiddenField { display: none; }

        .message { font-size: 14px; margin-bottom: 10px; }
        #lblError { color: red; }
        #lblSuccess { color: green; }
    </style>

    <script type="text/javascript">
        function combineOtp() {
            console.log('combineOtp called');
            var otp = '';
            for (var i = 1; i <= 6; i++) {
                var input = document.getElementById('otp' + i);
                if (input) otp += input.value;
            }
            var hiddenField = document.getElementById('<%= txtOtp.ClientID %>');
            if (hiddenField) hiddenField.value = otp;
            return otp;
        }

        function validateAndCombineOtp() {
            console.log('validateAndCombineOtp called');
            var otp = combineOtp();
            console.log('combined otp =', otp);
            if (otp.length !== 6) {
                alert('Vui lòng nhập đủ 6 số OTP');
                return false;
            }
            var btn = document.getElementById('<%= btnVerifyOtp.ClientID %>');
            // disable nhẹ nhàng sau khi submit được khởi tạo để tránh trình duyệt hủy submit
            setTimeout(function () {
                try {
                    btn.value = '⏳ Đang xác minh...';
                    btn.disabled = true;
                } catch (e) { console.warn(e); }
            }, 50);

            return true;
        }

        function validateResend() {
            console.log('validateResend called');
            var btn = document.getElementById('<%= btnResendOtp.ClientID %>');
            setTimeout(function () {
                try {
                    btn.value = '📨 Đang gửi...';
                    btn.disabled = true;
                } catch (e) { console.warn(e); }
            }, 50);
            return true;
        }

        function startResendCountdown() {
            console.log('startResendCountdown called');
            var btn = document.getElementById('<%= btnResendOtp.ClientID %>');
            if (!btn) return;
            var countdown = 60;
            btn.disabled = true;
            var interval = setInterval(function () {
                if (countdown <= 0) {
                    clearInterval(interval);
                    btn.disabled = false;
                    btn.value = "Gửi lại OTP";
                } else {
                    btn.value = "Gửi lại OTP (" + countdown + "s)";
                    countdown--;
                }
            }, 1000);
        }

        function setupOtpInputs() {
            console.log('setupOtpInputs called');
            const inputs = document.querySelectorAll(".otp-inputs input");
            inputs.forEach((input, index) => {
                input.addEventListener("input", function () {
                    this.value = this.value.replace(/[^0-9]/g, '');
                    if (this.value.length === 1 && index < inputs.length - 1) {
                        inputs[index + 1].focus();
                    }
                    combineOtp();
                });

                input.addEventListener("keydown", function (e) {
                    if (e.key === "Backspace" && !this.value && index > 0) {
                        inputs[index - 1].focus();
                    }
                });

                input.addEventListener("paste", function (e) {
                    e.preventDefault();
                    const pasted = e.clipboardData.getData('text').replace(/[^0-9]/g, '');
                    for (let i = 0; i < Math.min(6, pasted.length); i++) {
                        inputs[i].value = pasted[i];
                    }
                    if (pasted.length > 0) inputs[Math.min(5, pasted.length - 1)].focus();
                    combineOtp();
                });
            });

            if (inputs.length > 0) inputs[0].focus();
        }

        window.addEventListener('load', function () {
            try {
                setupOtpInputs();
                combineOtp();
                startResendCountdown();
            } catch (e) {
                console.error('init error', e);
            }
        });
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="otp-container">
            <h2>Nhập OTP</h2>
            <asp:Label ID="lblEmailInfo" runat="server" CssClass="message" ForeColor="#555" />
            <asp:Label ID="lblError" runat="server" CssClass="message" />
            <asp:Label ID="lblSuccess" runat="server" CssClass="message" />

            <div class="otp-inputs">
                <input type="text" id="otp1" maxlength="1" inputmode="numeric" />
                <input type="text" id="otp2" maxlength="1" inputmode="numeric" />
                <input type="text" id="otp3" maxlength="1" inputmode="numeric" />
                <input type="text" id="otp4" maxlength="1" inputmode="numeric" />
                <input type="text" id="otp5" maxlength="1" inputmode="numeric" />
                <input type="text" id="otp6" maxlength="1" inputmode="numeric" />
            </div>

            <asp:TextBox ID="txtOtp" runat="server" CssClass="hiddenField" TextMode="SingleLine" EnableViewState="true" />

            <asp:Button ID="btnVerifyOtp" runat="server" Text="Xác minh OTP"
                CssClass="aspNetButton"
                OnClick="btnVerifyOtp_Click"
                OnClientClick="console.log('btnVerifyOtp OnClientClick'); return validateAndCombineOtp();" />

            <asp:Button ID="btnResendOtp" runat="server" Text="Gửi lại OTP"
                CssClass="aspNetButton"
                OnClick="btnResendOtp_Click"
                OnClientClick="console.log('btnResendOtp OnClientClick'); return validateResend();" />
        </div>
    </form>
</body>
</html>