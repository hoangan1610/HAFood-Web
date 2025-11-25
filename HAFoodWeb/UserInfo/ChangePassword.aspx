<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ChangePassword.aspx.cs" Inherits="HAFoodWeb.UserInfo.ChangePassword" Async="true" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Thay đổi mật khẩu</title>

    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" />
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f8f9fa;
            margin: 0;
            padding: 0;
        }
        .change-container {
            max-width: 400px;
            margin: 50px auto;
            background: white;
            padding: 20px;
            border-radius: 12px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        h2 { text-align: center; margin-bottom: 20px; }
        .form-group { margin-bottom: 15px; }
        label { display: block; font-weight: bold; margin-bottom: 5px; }
        input[type="password"] {
            width: 95%;
            padding: 10px;
            border: 1px solid #ccc;
            border-radius: 6px;
        }
        .aspNetButton {
            display: block;
            width: 60%;
            padding: 12px;
            border: none;
            border-radius: 20px;
            background-color: #e55a00;
            color: white;
            font-size: 16px;
            cursor: pointer;
            box-shadow: 0 4px 10px rgba(255, 123, 0, 0.3);
            transition: background-color 0.3s ease, transform 0.2s;
            margin: 18px auto 0; 
        }
        .aspNetButton:hover:not(:disabled) {
            background-color: #d14e00;
            transform: translateY(-2px);
        }

        /* Toast styles */
        .toast {
            position: fixed;
            top: 20px;
            right: 20px;
            min-width: 260px;
            max-width: 320px;
            padding: 12px 16px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            gap: 10px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
            opacity: 0;
            visibility: hidden;
            transform: translateY(-20px);
            transition: opacity 0.3s ease, transform 0.3s ease, visibility 0.3s;
            z-index: 9999;
            font-size: 14px;

            /* 🔥 chữ trắng & in đậm */
            color: #fff;
            font-weight: bold;
        }
        .toast.show {
            opacity: 1;
            visibility: visible;
            transform: translateY(0);
        }
        .toast.success {
            background-color: #28a745; /* xanh lá đậm hơn tí cho hợp màu trắng */
        }
        .toast.error {
            background-color: #dc3545; /* đỏ đậm cho chữ trắng rõ hơn */
        }
        .toast i {
            font-size: 18px;
        }
    </style>

    <script type="text/javascript">
        function showToast(message, type) {
            var toast = document.getElementById('toast');
            var icon = document.getElementById('toastIcon');
            var text = document.getElementById('toastMessage');

            if (!toast || !icon || !text) return;

            if (type === 'success') {
                icon.className = 'fa-solid fa-circle-check';
            } else if (type === 'error') {
                icon.className = 'fa-solid fa-circle-xmark';
            } else {
                icon.className = 'fa-solid fa-circle-info';
            }

            toast.classList.remove('success', 'error');
            if (type) {
                toast.classList.add(type);
            }

            text.textContent = message;

            toast.classList.add('show');

            setTimeout(function () {
                toast.classList.remove('show');
            }, 3000);
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <!-- Toast container -->
        <div id="toast" class="toast">
            <i id="toastIcon" class="fa-solid"></i>
            <span id="toastMessage"></span>
        </div>

        <div class="change-container">
            <h2>Thay đổi mật khẩu</h2>

            <div class="form-group">
                <label for="txtOldPassword">Mật khẩu cũ</label>
                <asp:TextBox ID="txtOldPassword" runat="server" TextMode="Password" />
            </div>

            <div class="form-group">
                <label for="txtNewPassword">Mật khẩu mới</label>
                <asp:TextBox ID="txtNewPassword" runat="server" TextMode="Password" />
            </div>

            <asp:Button ID="btnSubmit" runat="server" Text="Xác nhận thay đổi" CssClass="aspNetButton" OnClick="btnSubmit_Click" />
        </div>
    </form>
</body>
</html>
