<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="UserDetail.aspx.cs" Inherits="HAFoodWeb.UserPage.UserDetail" Async="true" %>
<%@ Register Src="~/Control/Header.ascx" TagPrefix="uc" TagName="Header" %>
<%@ Register Src="~/Control/Footer.ascx" TagPrefix="uc" TagName="Footer" %>

<!DOCTYPE html>
<html lang="vi">
<head runat="server">
    <meta charset="utf-8" />
    <title>Tài khoản của tôi - HAFood</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <style>
        .dashboard-container {
            display: flex;
            min-height: 80vh;
            width: 90%;
            margin: 40px auto;
        }
        .sidebar {
            width: 250px;
            background: #fff;
            border-right: 1px solid #e5e5e5;
            padding: 20px;
        }
        .sidebar h3 {
            font-size: 22px;
            font-weight: 700;
            margin-bottom: 30px;
        }
        .menu-item {
            padding: 12px 15px;
            border-radius: 8px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.2s;
            display: block;
            margin-bottom: 8px;
            color: inherit;
            text-decoration: none;
        }
        .menu-item:hover { text-decoration: none; }
        .menu-item.active,
        .menu-item:hover {
            background-color: #28a745;
            color: white !important;
        }
        .content-area {
            flex: 1;
            padding: 30px;
            background: #fafafa;
        }
        .content-frame {
            width: 100%;
            height: 80vh;
            border: none;
            border-radius: 12px;
            background: #fff;
        }

        @media (max-width: 900px) {
            .dashboard-container { flex-direction: column; }
            .sidebar { width: 100%; margin-bottom: 18px; }
            .content-frame { height: 60vh; }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <uc:Header runat="server" ID="Header1" />

        <div class="dashboard-container">
            <div class="sidebar">
                <h3>Tài Khoản</h3>

                <!-- Hồ sơ -->
                <a id="mProfile" class="menu-item active" data-url="../UserInfo/UserProfile.aspx" href="javascript:void(0);">
                    <i class="bi bi-person-circle me-2"></i> Hồ sơ của tôi
                </a>

                <!-- Đơn hàng -->
                <a id="mOrders" class="menu-item" data-url="../OrderPage/OrderPage.aspx" href="javascript:void(0);">
                    <i class="bi bi-basket2-fill me-2"></i> Đơn hàng của tôi
                </a>

                <!-- Đăng xuất: server-side LinkButton -->
                <asp:LinkButton ID="lnkLogout" runat="server" CssClass="menu-item" OnClick="lnkLogout_Click" CausesValidation="false">
                    <i class="bi bi-box-arrow-right me-2"></i> Đăng xuất
                </asp:LinkButton>
            </div>

            <div class="content-area">
                <iframe id="contentFrame" class="content-frame" src="../UserInfo/UserProfile.aspx"></iframe>
            </div>
        </div>

        <uc:Footer runat="server" ID="Footer1" />
    </form>

    <script>
        (function () {
            const menuItems = document.querySelectorAll(".menu-item");
            const frame = document.getElementById("contentFrame");

            menuItems.forEach(item => {
                // Nếu là LinkButton (postback) nó vẫn có class menu-item và id; clicking sẽ postback
                item.addEventListener('click', function (e) {
                    // Nếu element là link với data-url -> tải vào iframe
                    const url = this.dataset?.url;
                    if (url) {
                        // prevent default only for anchors (we use href="javascript:void(0);")
                        e.preventDefault && e.preventDefault();
                        menuItems.forEach(i => i.classList.remove('active'));
                        this.classList.add('active');
                        frame.src = url;
                        return;
                    }

                    menuItems.forEach(i => i.classList.remove('active'));
                    this.classList.add('active');
                }, false);
            });
        })();
    </script>
</body>
</html>