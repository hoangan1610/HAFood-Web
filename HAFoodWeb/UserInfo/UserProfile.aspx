<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="UserProfile.aspx.cs" Inherits="HAFoodWeb.UserProfile" Async="true" %>

<%@ Register Src="~/Control/Header.ascx" TagPrefix="uc" TagName="Header" %>
<%@ Register Src="~/Control/Footer.ascx" TagPrefix="uc" TagName="Footer" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Thông tin cá nhân</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" />

    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f8f9fa;
        }

        .profile-container {
            max-width: 500px;
            margin: 30px auto;
            background: white;
            padding: 20px;
            border-radius: 12px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
            text-align: center;
        }

        .avatar {
            width: 140px;
            height: 140px;
            border-radius: 50%;
            object-fit: cover;
            border: 2px solid #ddd;
            margin-bottom: 15px;
        }

        .info-field {
            text-align: left;
            margin-top: 12px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            border-bottom: 1px solid #f0f0f0;
            padding: 8px 4px;
        }

        .info-label {
            font-weight: bold;
            width: 140px;
        }

        /* Nút cam giống yêu cầu */
        .aspNetButton {
            width: 100%;
            padding: 12px;
            margin-top: 18px;
            border: none;
            border-radius: 20px;
            background-color: #e55a00;
            color: white;
            font-size: 16px;
            cursor: pointer;
            box-shadow: 0 4px 10px rgba(255, 123, 0, 0.3);
            transition: background-color 0.3s ease, transform 0.2s;
        }

        .aspNetButton:hover:not(:disabled) {
            background-color: #d14e00;
            transform: translateY(-2px);
        }
    </style>
</head>

<body>
    <form id="form1" runat="server">
        <!-- Header -->
        <uc:Header ID="HeaderControl" runat="server" />

        <!-- Nội dung -->
        <div class="profile-container">
            <asp:Image ID="imgAvatar" runat="server" CssClass="avatar" />

            <div class="info-field">
                <span class="info-label">Họ và tên:</span>
                <asp:Label ID="lblFullName" runat="server" />
            </div>

            <div class="info-field">
                <span class="info-label">Email:</span>
                <asp:Label ID="lblEmail" runat="server" />
            </div>

            <div class="info-field">
                <span class="info-label">Số điện thoại:</span>
                <asp:Label ID="lblPhone" runat="server" />
            </div>

            <asp:Button ID="btnEdit" runat="server"
                        Text="Chỉnh sửa thông tin"
                        CssClass="aspNetButton"
                        OnClick="btnEdit_Click" />
        </div>

        <!-- Footer -->
        <uc:Footer ID="FooterControl" runat="server" />
    </form>
</body>
</html>