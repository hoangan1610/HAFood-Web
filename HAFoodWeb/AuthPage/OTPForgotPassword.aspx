<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="OTPForgotPassword.aspx.cs" Inherits="HAFoodWeb.AuthPage.OTPForgotPassword" Async="true" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Quên mật khẩu - HAFood</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600&display=swap" rel="stylesheet" />

    <style>
        :root {
            --border: #e5e7eb;
        }

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

        .otp-wrapper {
            width: 100%;
            max-width: 420px;
            padding: 16px;
        }

        .otp-container {
            background-color: #fff;
            padding: 34px 30px 28px;
            border-radius: 20px;
            box-shadow: 0 24px 50px rgba(0,0,0,0.08);
            width: 100%;
            text-align: center;
            position: relative;
            overflow: hidden;
        }

        .otp-container::before {
            content: "";
            position: absolute;
            top: -80px;
            right: -80px;
            width: 160px;
            height: 160px;
            background: rgba(255, 143, 66, 0.18);
            border-radius: 50%;
        }

        .otp-header {
            position: relative;
            z-index: 1;
            margin-bottom: 18px;
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

        }

        .otp-header {
            position: relative;
            z-index: 1;
            margin-bottom: 18px;
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
            color: #333;
            font-size: 23px;
            font-weight: 600;
        }

        .otp-sub {
            font-size: 13px;
            color: #6c757d;
            margin-top: 6px;
            margin-bottom: 18px;
        }

        .message {
            font-size: 14px;
            margin-bottom: 6px;
        }

        #lblEmailInfo { color: #555; }
        #lblError, #lblSuccess { display: none; }
        #lblError { color: red; }
        #lblSuccess { color: green; }
        #lblEmailInfo { color: #555; }

        .otp-inputs {
            display: flex;
            justify-content: space-between;
            margin: 18px 0 14px;
            position: relative;
            z-index: 1;
        }

        .otp-inputs input {
            width: 46px;
            height: 52px;
            text-align: center;
            font-size: 22px;
            border-radius: 12px;
            border: 1px solid #dde2e7;
            outline: none;
            transition: all 0.2s;
            background-color: #f8f9fa;
        }

        .otp-inputs input:focus {
            border-color: #ff7a1a;
            background-color: #ffffff;
            box-shadow: 0 0 0 3px rgba(40, 167, 69, 0.18);
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
            box-shadow: 0 14px 30px rgba(40, 167, 69, 0.3);
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
            box-shadow: 0 18px 36px rgba(40, 167, 69, 0.35);
        }

        .hiddenField { display: none; }

        .resend-note {
            font-size: 13px;
            color: #6c757d;
            margin-top: 10px;
        }

        /* TOAST CUSTOM */
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
            background:transparent;
            border:none;
            color:inherit;
        }
        .toast-close:hover{
            opacity:1;
        }
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

        function hideToast(toast) {
            if (!toast) return;
            toast.classList.remove('show');
            setTimeout(function () {
                if (toast && toast.parentNode) {
                    toast.parentNode.removeChild(toast);
                }
            }, 200);
        }

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

                if (type === 'success') toast.classList.add('toast-success');
                else if (type === 'error') toast.classList.add('toast-error');

                var text = document.createElement('div');
                text.className = 'toast-text';
                text.innerHTML = message;

                var closeBtn = document.createElement('button');
                closeBtn.type = 'button';
                closeBtn.className = 'toast-close';
                closeBtn.innerHTML = '&times;';
                closeBtn.onclick = function () { hideToast(toast); };

                toast.appendChild(text);
                toast.appendChild(closeBtn);
                stack.appendChild(toast);

                setTimeout(function () { toast.classList.add('show'); }, 10);
                setTimeout(function () { hideToast(toast); }, 3500);
            } catch (e) {
                console.error('showToast error', e);
                alert(message);
            }
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
        <div class="otp-wrapper">
            <div class="otp-container">
                <div class="otp-header">
                    <div class="logo-circle">HAFood</div>
                    <h2>Nhập OTP</h2>
                    <p class="otp-sub">Mã OTP đã được gửi đến email của bạn để đặt lại mật khẩu.</p>
                </div>

                <asp:Label ID="lblEmailInfo" runat="server" CssClass="message" />
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

                <asp:Button ID="btnVerifyOtp" runat="server" Text="Xác thực OTP"
                    CssClass="aspNetButton"
                    OnClick="btnVerifyOtp_Click"
                    OnClientClick="console.log('btnVerifyOtp OnClientClick'); return validateAndCombineOtp();" />

                <asp:Button ID="btnResendOtp" runat="server" Text="Gửi lại OTP"
                    CssClass="aspNetButton"
                    OnClick="btnResendOtp_Click"
                    OnClientClick="console.log('btnResendOtp OnClientClick'); return validateResend();" />


                <asp:Label ID="lblEmailInfo" runat="server" CssClass="message" />
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

                <asp:Button ID="btnVerifyOtp" runat="server" Text="Xác thực OTP"
                    CssClass="aspNetButton"
                    OnClick="btnVerifyOtp_Click"
                    OnClientClick="console.log('btnVerifyOtp OnClientClick'); return validateAndCombineOtp();" />

                <asp:Button ID="btnResendOtp" runat="server" Text="Gửi lại OTP"
                    CssClass="aspNetButton"
                    OnClick="btnResendOtp_Click"
                    OnClientClick="console.log('btnResendOtp OnClientClick'); return validateResend();" />

                <div class="resend-note">
                    Bạn có thể gửi lại mã sau khi hết thời gian đếm ngược. Vui lòng không chia sẻ mã OTP cho bất kỳ ai.
                </div>
            </div>
        </div>

        <!-- Toast stack -->
        <div id="toastStack" class="toast-stack"></div>
    </form>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
