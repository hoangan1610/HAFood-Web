<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="UserDetail.aspx.cs" Inherits="HAFoodWeb.UserPage.UserDetail" Async="true" %>
<%@ Register Src="~/Control/Header.ascx" TagPrefix="uc" TagName="Header" %>
<%@ Register Src="~/Control/Footer.ascx" TagPrefix="uc" TagName="Footer" %>

<!DOCTYPE html>
<html lang="vi">
<head runat="server">
    <meta charset="utf-8" />
    <title>Tài khoản của tôi - HAFood</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet" />

    <style>
        .dashboard-container { display:flex; min-height:80vh; width:90%; margin:40px auto; }
        .sidebar { width:250px; background:#fff; border-right:1px solid #e5e5e5; padding:20px; }
        .sidebar h3 { font-size:22px; font-weight:700; margin-bottom:30px; }
        .menu-item { padding:12px 15px; border-radius:8px; font-weight:500; cursor:pointer; transition:.2s; display:block; margin-bottom:8px; color:inherit; text-decoration:none; }
        .menu-item.active, .menu-item:hover { background:#28a745; color:#fff !important; }
        .content-area { flex:1; padding:30px; background:#fafafa; }
        .content-frame { width:100%; height:80vh; border:none; border-radius:12px; background:#fff; }
        @media (max-width:900px) { .dashboard-container{flex-direction:column;} .sidebar{width:100%; margin-bottom:18px;} .content-frame{height:60vh;} }
    </style>
</head>
<body>
<form id="form1" runat="server">
    <uc:Header runat="server" ID="Header1" />

    <div class="dashboard-container">
        <div class="sidebar">
            <h3>Tài Khoản</h3>

            <a id="mProfile" class="menu-item active" data-url="../UserInfo/UserProfile.aspx" href="javascript:void(0);">
                <i class="bi bi-person-circle me-2"></i> Hồ sơ của tôi
            </a>

            <a id="mOrders" class="menu-item" data-url="../OrderPage/OrderPage.aspx" href="javascript:void(0);">
                <i class="bi bi-basket2-fill me-2"></i> Đơn hàng của tôi
            </a>

            <a id="mAddresses" class="menu-item" data-url="../UserAddress/UserAddressList.aspx" href="javascript:void(0);">
                <i class="bi bi-geo-alt-fill me-2"></i> Địa chỉ của tôi
            </a>

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
        const mProfile = document.getElementById("mProfile");
        const mOrders = document.getElementById("mOrders");
        const mAddresses = document.getElementById("mAddresses");

        // Handle click
        menuItems.forEach(item => {
            item.addEventListener('click', function (e) {
                const url = this.dataset?.url;
                if (url) {
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

        // Deep link: ?tab=orders|addresses (&orderId / &addressId)
        try {
            const params = new URLSearchParams(window.location.search);
            const tab = (params.get('tab') || '').toLowerCase();

            if (tab === 'orders') {
                const orderId = params.get('orderId') || params.get('id');
                mProfile && mProfile.classList.remove('active');
                mOrders && mOrders.classList.add('active');
                frame.src = orderId
                    ? "../OrderPage/OrderDetail.aspx?id=" + encodeURIComponent(orderId)
                    : (mOrders.dataset.url || "../OrderPage/OrderPage.aspx");
            } else if (tab === 'addresses') {
                const addressId = params.get('addressId') || params.get('id');
                mProfile && mProfile.classList.remove('active');
                mAddresses && mAddresses.classList.add('active');
                frame.src = addressId
                    ? "../UserAddress/UpdateUserAddress.aspx?id=" + encodeURIComponent(addressId)
                    : (mAddresses.dataset.url || "../UserAddress/UserAddressList.aspx");
            }
        } catch (e) { /* ignore */ }
    })();
</script>
</body>
</html>
