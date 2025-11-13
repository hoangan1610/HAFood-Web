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
        :root {
            --haf-primary: #ff7b32;
            --haf-primary-hover: #e8631d;
            --haf-bg: #f5f5f5;
            --haf-border: #e5e7eb;
            --haf-text-main: #111827;
            --haf-text-muted: #6b7280;
        }

        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
            background-color: var(--haf-bg);
            color: var(--haf-text-main);
        }

        .dashboard-outer {
            width: 100%;
            padding: 24px 0 32px;
        }

        /* SECTION lớn hơn một chút */
        .dashboard-container {
            display: flex;
            min-height: 82vh;
            width: 96%;              /* từ 94% -> 96% */
            max-width: 1360px;       /* từ 1280 -> 1360 */
            margin: 0 auto;
            background-color: #ffffff;
            border-radius: 18px;
            box-shadow: 0 12px 28px rgba(15, 23, 42, 0.12);
            overflow: hidden;
            border: 1px solid var(--haf-border);
        }

        /* sidebar rộng hơn để “Trung tâm cá nhân” không xuống dòng */
        .sidebar {
            width: 260px;            /* từ 230 -> 260 */
            background-color: #ffffff;
            border-right: 1px solid var(--haf-border);
            padding: 20px 18px 22px;
            display: flex;
            flex-direction: column;
            gap: 16px;
        }

        .sidebar-header {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 4px;
        }

        .sidebar-avatar {
            width: 40px;
            height: 40px;
            border-radius: 999px;
            background-color: rgba(255, 123, 50, 0.12);
            border: 1px solid rgba(255, 123, 50, 0.35);
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--haf-primary);
            font-size: 20px;
        }

        .sidebar-title {
            display: flex;
            flex-direction: column;
            gap: 2px;
        }

        .sidebar-title span:first-child {
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: .1em;
            font-weight: 600;
            color: var(--haf-text-muted);
        }

        .sidebar-title span:last-child {
            font-size: 19px;
            font-weight: 700;
            color: var(--haf-text-main);
        }

        .sidebar-subtext {
            font-size: 13px;
            color: var(--haf-text-muted);
            margin-bottom: 4px;
        }

        .sidebar-divider {
            height: 1px;
            background-color: var(--haf-border);
            margin: 6px 0 10px;
        }

        .sidebar-section-label {
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: .16em;
            color: var(--haf-text-muted);
            font-weight: 600;
            margin-bottom: 4px;
        }

        .menu-list {
            display: flex;
            flex-direction: column;
            gap: 6px;
            margin-bottom: 10px;
        }

        .menu-item {
            padding: 9px 12px;
            border-radius: 10px;
            font-weight: 500;
            cursor: pointer;
            transition: background-color .15s ease, color .15s ease, transform .08s ease, box-shadow .12s ease, border-color .15s ease;
            display: flex;
            align-items: center;
            text-decoration: none;
            color: var(--haf-text-main);
            font-size: 14px;
            border: 1px solid transparent;
            background-color: transparent;
        }

        .menu-item i {
            font-size: 17px;
            margin-right: 8px;
        }

        .menu-item span {
            flex: 1;
        }

        .menu-item.active {
            background-color: rgba(255, 123, 50, 0.1);
            border-color: rgba(255, 123, 50, 0.6);
            color: var(--haf-primary-hover);
            box-shadow: 0 10px 16px rgba(15, 23, 42, 0.08);
        }

        .menu-item.active i {
            color: var(--haf-primary-hover);
        }

        .menu-item:hover {
            background-color: #f9fafb;
            border-color: var(--haf-border);
            text-decoration: none;
        }

        .menu-item.logout {
            margin-top: auto;
            background-color: #ffffff;
            border-color: var(--haf-border);
            color: #b91c1c;
        }

        .menu-item.logout i {
            color: #b91c1c;
        }

        .menu-item.logout:hover {
            background-color: #fef2f2;
            border-color: #fecaca;
        }

        .content-area {
            flex: 1;
            padding: 18px 18px 20px;
            background: radial-gradient(circle at top left,
                        rgba(255, 123, 50, 0.35) 0,
                        #ffe9d4 18%,
                        #fafafa 45%,
                        #fafafa 100%);
            display: flex;
            flex-direction: column;
            gap: 14px;
        }

        .content-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
        }

        .content-header-title {
            display: flex;
            flex-direction: column;
            gap: 4px;
        }

        .content-header-title h2 {
            margin: 0;
            font-size: 20px;
            font-weight: 700;
            color: var(--haf-text-main);
        }

        .content-header-title p {
            margin: 0;
            font-size: 13px;
            color: var(--haf-text-muted);
        }

        .content-tag {
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: .15em;
            padding: 4px 10px;
            border-radius: 999px;
            border: 1px solid var(--haf-border);
            color: var(--haf-text-muted);
            background-color: #ffffff;
            white-space: nowrap;
        }

        .content-frame-wrapper {
            flex: 1;
            border-radius: 16px;
            background-color: #ffffff;
            box-shadow: 0 10px 18px rgba(15, 23, 42, 0.08);
            border: 1px solid var(--haf-border);
            overflow: hidden;
            height: 78vh;
        }

        .content-frame {
            width: 100%;
            height: 100%;
            border: none;
            display: block;
        }

        @media (max-width: 992px) {
            .dashboard-container {
                flex-direction: column;
                min-height: 0;
                width: 96%;
            }

            .sidebar {
                width: 100%;
                border-right: none;
                border-bottom: 1px solid var(--haf-border);
                padding: 16px;
            }

            .menu-list {
                flex-direction: row;
                flex-wrap: nowrap;
                overflow-x: auto;
                padding-bottom: 4px;
            }

            .menu-item {
                white-space: nowrap;
                font-size: 13px;
                padding: 7px 10px;
            }

            .menu-item.logout {
                margin-top: 0;
                margin-left: auto;
            }

            .content-area {
                padding: 16px;
            }

            .content-frame-wrapper {
                height: 70vh;
            }
        }

        @media (max-width: 575px) {
            .dashboard-container {
                width: 96%;
            }

            .content-header-title h2 {
                font-size: 18px;
            }

            .sidebar-title span:last-child {
                font-size: 17px;
            }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <uc:Header runat="server" ID="Header1" />

        <div class="dashboard-outer">
            <div class="dashboard-container">
                <aside class="sidebar">
                    <div class="sidebar-header">
                        <div class="sidebar-avatar">
                            <i class="bi bi-person-fill"></i>
                        </div>
                        <div class="sidebar-title">
                            <span>Tài khoản</span>
                            <span>Trung tâm cá nhân</span>
                        </div>
                    </div>
                    <div class="sidebar-subtext">
                        Quản lý hồ sơ, đơn hàng và địa chỉ giao hàng của bạn.
                    </div>

                    <div class="sidebar-divider"></div>
                    <div class="sidebar-section-label">Tổng quan</div>

                    <div class="menu-list">
                        <a id="mProfile" class="menu-item active" data-url="../UserInfo/UserProfile.aspx" href="javascript:void(0);">
                            <i class="bi bi-person-circle"></i>
                            <span>Hồ sơ của tôi</span>
                        </a>

                        <a id="mOrders" class="menu-item" data-url="../OrderPage/OrderPage.aspx" href="javascript:void(0);">
                            <i class="bi bi-basket2-fill"></i>
                            <span>Đơn hàng của tôi</span>
                        </a>

                        <a id="mAddresses" class="menu-item" data-url="../UserAddress/UserAddressList.aspx" href="javascript:void(0);">
                            <i class="bi bi-geo-alt-fill"></i>
                            <span>Địa chỉ của tôi</span>
                        </a>
                    </div>

                    <asp:LinkButton ID="lnkLogout" runat="server" CssClass="menu-item logout" OnClick="lnkLogout_Click" CausesValidation="false">
                        <i class="bi bi-box-arrow-right"></i>
                        <span>Đăng xuất</span>
                    </asp:LinkButton>
                </aside>

                <main class="content-area">
                    <div class="content-header">
                        <div class="content-header-title">
                            <h2>Thông tin tài khoản</h2>
                            <p>Xem và cập nhật thông tin cá nhân, lịch sử đơn hàng và địa chỉ giao hàng.</p>
                        </div>
                        <div class="content-tag">
                            Tài khoản HAFood
                        </div>
                    </div>

                    <div class="content-frame-wrapper">
                        <iframe id="contentFrame" class="content-frame" src="../UserInfo/UserProfile.aspx"></iframe>
                    </div>
                </main>
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
