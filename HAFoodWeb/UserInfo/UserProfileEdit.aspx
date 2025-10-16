<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="UserProfileEdit.aspx.cs" Inherits="HAFoodWeb.UserProfileEdit" Async="true" %>

<%@ Register Src="~/Control/Header.ascx" TagPrefix="uc" TagName="Header" %>
<%@ Register Src="~/Control/Footer.ascx" TagPrefix="uc" TagName="Footer" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Chỉnh sửa thông tin cá nhân</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" />

    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f8f9fa;
        }

        .edit-container {
            max-width: 500px;
            margin: 30px auto;
            background: white;
            padding: 20px;
            border-radius: 12px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }

        .edit-container h2 {
            text-align: center;
            margin-bottom: 20px;
        }

        .avatar-preview {
            display: block;
            width: 140px;
            height: 140px;
            border-radius: 50%;
            object-fit: cover;
            border: 2px solid #ddd;
            margin: 0 auto 15px;
        }

        .form-field {
            margin-bottom: 15px;
        }

        .form-field label {
            display: block;
            font-weight: bold;
            margin-bottom: 6px;
        }

        .form-field input[type="text"],
        .form-field input[type="email"] {
            width: 100%;
            padding: 10px;
            border: 1px solid #ccc;
            border-radius: 6px;
        }

        .form-field input[disabled] {
            background-color: #f1f1f1;
        }

        .aspNetButton {
            width: 100%;
            padding: 12px;
            margin-top: 10px;
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

        .success-message {
            color: green;
            text-align: center;
            margin-bottom: 15px;
            font-weight: bold;
        }

        .error-message {
            color: red;
            text-align: center;
            margin-bottom: 15px;
            font-weight: bold;
        }
    </style>
</head>

<body>
    <form id="form1" runat="server">
        <uc:Header ID="HeaderControl" runat="server" />

        <div class="edit-container">
            <h2>Chỉnh sửa thông tin</h2>

            <asp:Image ID="imgAvatar" runat="server" CssClass="avatar-preview" />

            <div class="form-field">
                <label for="fileAvatar">Thay đổi ảnh đại diện</label>
                <asp:FileUpload ID="fileAvatar" runat="server" />
            </div>

            <div class="form-field">
                <label for="txtFullName">Họ và tên</label>
                <asp:TextBox ID="txtFullName" runat="server"></asp:TextBox>
            </div>

            <div class="form-field">
                <label for="txtEmail">Email</label>
                <asp:TextBox ID="txtEmail" runat="server" Enabled="false"></asp:TextBox>
            </div>

            <div class="form-field">
                <label for="txtPhone">Số điện thoại</label>
                <asp:TextBox ID="txtPhone" runat="server"></asp:TextBox>
            </div>

                <asp:Label ID="lblMessage" runat="server" EnableViewState="false"></asp:Label>

            <asp:Button ID="btnSave" runat="server" Text="Lưu thay đổi" CssClass="aspNetButton" OnClick="btnSave_Click" />
        </div>

        <uc:Footer ID="FooterControl" runat="server" />
    </form>
</body>
</html>
