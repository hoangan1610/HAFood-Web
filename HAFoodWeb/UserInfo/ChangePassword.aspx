<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ChangePassword.aspx.cs" Inherits="HAFoodWeb.UserInfo.ChangePassword" Async="true" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Thay đổi mật khẩu</title>
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
        .error { color: red; font-size: 14px; margin-top: 5px; }
        .success { color: green; font-size: 14px; margin-top: 5px; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
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

            <asp:Label ID="lblMessage" runat="server" EnableViewState="false"></asp:Label>

            <asp:Button ID="btnSubmit" runat="server" Text="Xác nhận thay đổi" CssClass="aspNetButton" OnClick="btnSubmit_Click" />
        </div>
    </form>
</body>
</html>
