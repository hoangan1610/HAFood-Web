<%@ Page Language="C#" Async="true" AutoEventWireup="true" CodeBehind="OTP.aspx.cs" Inherits="HAFoodWeb.AuthPage.OTP" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Xác minh OTP</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

    <script>
        let countdown;
        function startCountdown() {
            let seconds = 60; // thời gian đếm ngược 60s
            const timerElement = document.getElementById("timer");
            const resendBtn = document.getElementById("<%= btnResendOtp.ClientID %>");

            resendBtn.disabled = true;
            timerElement.innerText = `(${seconds}s)`;

            countdown = setInterval(() => {
                seconds--;
                timerElement.innerText = `(${seconds}s)`;

                if (seconds <= 0) {
                    clearInterval(countdown);
                    resendBtn.disabled = false;
                    timerElement.innerText = "(Bạn có thể gửi lại OTP)";
                }
            }, 1000);
        }
    </script>
</head>

<body class="bg-light">
    <form id="form1" runat="server" class="container mt-5">
        <div class="card mx-auto shadow-sm" style="max-width: 400px;">
            <div class="card-body text-center">
                <h4 class="mb-3">🔐 Xác minh OTP</h4>
                <p>Nhập mã OTP đã được gửi đến email: <strong><%= Email %></strong></p>

                <asp:TextBox ID="txtOtp" runat="server" CssClass="form-control mb-3 text-center" placeholder="Nhập mã OTP"></asp:TextBox>

                <asp:Label ID="lblError" runat="server" CssClass="text-danger d-block mb-2"></asp:Label>
                <asp:Label ID="lblSuccess" runat="server" CssClass="text-success d-block mb-2"></asp:Label>

                <asp:Button ID="btnVerifyOtp" runat="server" CssClass="btn btn-primary w-100 mb-2" Text="Xác minh" OnClick="btnVerifyOtp_Click" />

                <asp:Button ID="btnResendOtp" runat="server" CssClass="btn btn-outline-secondary w-100" Text="Gửi lại OTP" OnClick="btnResendOtp_Click" />

                <p id="timer" class="mt-2 text-muted small"></p>
            </div>
        </div>
    </form>
</body>
</html>