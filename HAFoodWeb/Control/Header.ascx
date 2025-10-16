<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="Header.ascx.cs" Inherits="HAFoodWeb.Control.Header" %>

<!-- CSS -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet" />

<style>
    .navbar {
        width: 90%;
        margin: 20px auto;
        border-radius: 50px;
        background-color: #fff;
        padding: 15px 40px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.05);
        position: relative;
        z-index: 10000;
    }
    .navbar-brand img {
        height: 80px;
        width: 80px;
        border-radius: 50%;
        border: 2px solid #28a745;
        background: #fff;
        padding: 4px;
        object-fit: cover;
    }
    .nav-link {
        font-family: "Georgia", serif;
        font-weight: 600;
        font-size: 18px;
        color: #000 !important;
        margin: 0 15px;
    }
    .nav-link:hover { color: #28a745 !important; }
    .nav-icons i {
        font-size: 22px;
        color: #000;
        margin-left: 20px;
        cursor: pointer;
        transition: color 0.3s;
        position: relative;
    }
    .nav-icons i:hover { color: #28a745; }
    .search-dropdown {
        position: absolute;
        top: 110px;
        left: 80%;
        transform: translateX(-50%);
        width: 60%;
        max-width: 450px;
        display: none;
        justify-content: center;
        z-index: 10000;
    }
    .search-box {
        background: #fff;
        border-radius: 50px;
        padding: 10px 25px;
        width: 100%;
        display: flex;
        align-items: center;
        box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        border: 2px solid #28a745;
        animation: slideDown 0.3s ease forwards;
    }
    .search-box input {
        flex: 1;
        border: none;
        outline: none;
        font-size: 18px;
    }
    .search-box i {
        font-size: 22px;
        color: #28a745;
        cursor: pointer;
    }
    .page-overlay {
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0,0,0,0.4);
        backdrop-filter: blur(5px);
        display: none;
        z-index: 9000;
    }
    @keyframes slideDown {
        from { transform: translateY(-20px); opacity: 0; }
        to { transform: translateY(0); opacity: 1; }
    }
    .user-dropdown {
        position: absolute;
        top: 100%;
        right: 10px;
        background: #fff;
        border-radius: 10px;
        box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        padding: 10px 0;
        display: none;
        flex-direction: column;
        width: 180px;
        z-index: 11000;
        animation: fadeIn 0.2s ease;
    }
    .user-dropdown a, .user-dropdown asp\:LinkButton {
        text-decoration: none;
        color: #333;
        padding: 10px 20px;
        font-size: 16px;
        transition: background 0.3s;
        display: block;
        text-align: left;
    }
    .user-dropdown a:hover, .user-dropdown asp\:LinkButton:hover {
        background: #f4f4f4;
        color: #28a745;
    }
    @keyframes fadeIn {
        from {opacity: 0; transform: translateY(-10px);}
        to {opacity: 1; transform: translateY(0);}
    }
</style>

<!-- NAVBAR -->
<nav class="navbar navbar-expand-lg position-relative">
    <asp:HyperLink ID="lnkLogo" runat="server" NavigateUrl="~/HomePage/HomePage.aspx" CssClass="navbar-brand">
        <asp:Image ID="imgLogo" runat="server" ImageUrl="~/images/HAFood_logo.png" AlternateText="Logo" />
    </asp:HyperLink>

    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
        <span class="navbar-toggler-icon"></span>
    </button>

    <div class="collapse navbar-collapse" id="navbarNav">
        <ul class="navbar-nav mx-auto">
            <li class="nav-item">
                <asp:HyperLink ID="lnkHome" runat="server" NavigateUrl="~/HomePage/HomePage.aspx" CssClass="nav-link">Home</asp:HyperLink>
            </li>
            <li class="nav-item"><a class="nav-link" href="#">Catalog</a></li>
            <li class="nav-item"><a class="nav-link" href="#">Shop</a></li>
            <li class="nav-item"><a class="nav-link" href="#">Products</a></li>
            <li class="nav-item"><a class="nav-link" href="#">More</a></li>
        </ul>

        <div class="nav-icons d-flex align-items-center"
             id="headerRoot"
             data-guestid="<%# guestDropdown.ClientID %>"
             data-authid="<%# authDropdown.ClientID %>">

            <i class="bi bi-search" id="openSearch"></i>

            <!-- USER ICON -->
            <div class="position-relative">
                <i class="bi bi-person" id="userIcon"></i>

                <!-- GUEST DROPDOWN -->
                <div class="user-dropdown" id="guestDropdown" runat="server">
                    <asp:HyperLink runat="server" NavigateUrl="~/AuthPage/Login.aspx">
                        <i class="bi bi-box-arrow-in-right me-2"></i>Login
                    </asp:HyperLink>
                    <asp:HyperLink runat="server" NavigateUrl="~/AuthPage/Register.aspx">
                        <i class="bi bi-pencil-square me-2"></i>Register
                    </asp:HyperLink>
                </div>

                <!-- AUTH DROPDOWN -->
                <div class="user-dropdown" id="authDropdown" runat="server">
                    <asp:HyperLink ID="lnkProfile" runat="server" NavigateUrl="~/UserInfo/UserProfile.aspx" CssClass="d-flex align-items-center">
                        <i class="bi bi-person-circle me-2"></i>My Profile
                    </asp:HyperLink>
                    <span title="Trang danh sách đơn hàng (chưa có)">Danh sách đơn hàng</span>
                    <asp:LinkButton ID="btnLogout" runat="server" OnClick="btnLogout_Click">
                        <i class="bi bi-box-arrow-right me-2"></i>Logout
                    </asp:LinkButton>
                </div>
            </div>

            <i class="bi bi-basket"></i>
        </div>
    </div>
</nav>

<!-- SEARCH DROPDOWN + OVERLAY -->
<div class="search-dropdown" id="searchDropdown">
    <div class="search-box">
        <input type="text" placeholder="Search for products..." />
        <i class="bi bi-search"></i>
    </div>
</div>
<div class="page-overlay" id="pageOverlay"></div>

<!-- SCRIPT -->
<script>
    document.addEventListener('DOMContentLoaded', function () {
        const headerRoot = document.getElementById('headerRoot');
        const guestId = headerRoot?.dataset.guestid;
        const authId = headerRoot?.dataset.authid;

        const guestDropdownEl = guestId ? document.getElementById(guestId) : null;
        const authDropdownEl = authId ? document.getElementById(authId) : null;

        const userIcon = document.getElementById('userIcon');
        const openBtn = document.getElementById('openSearch');
        const searchDropdown = document.getElementById('searchDropdown');
        const overlay = document.getElementById('pageOverlay');

        function hideAllUserDropdowns() {
            if (guestDropdownEl) guestDropdownEl.style.display = 'none';
            if (authDropdownEl) authDropdownEl.style.display = 'none';
            if (overlay) overlay.style.display = 'none';
        }

        function toggleDropdown(el) {
            if (!el) return;
            const isHidden = window.getComputedStyle(el).display === 'none';
            hideAllUserDropdowns();
            el.style.display = isHidden ? 'flex' : 'none';
            overlay.style.display = isHidden ? 'block' : 'none';
        }

        if (userIcon) {
            userIcon.addEventListener('click', function (e) {
                e.stopPropagation();
                toggleDropdown(guestDropdownEl || authDropdownEl);
            });
        }

        document.addEventListener('click', function (e) {
            if (e.target.closest('a')) return;
            if (guestDropdownEl?.contains(e.target) || authDropdownEl?.contains(e.target) || userIcon?.contains(e.target)) return;
            hideAllUserDropdowns();
            if (searchDropdown) searchDropdown.style.display = 'none';
        });

        if (overlay) {
            overlay.addEventListener('click', function () {
                hideAllUserDropdowns();
                if (searchDropdown) searchDropdown.style.display = 'none';
            });
        }

        if (openBtn) {
            openBtn.addEventListener('click', function (ev) {
                ev.stopPropagation();
                const isVisible = window.getComputedStyle(searchDropdown).display === 'flex';
                searchDropdown.style.display = isVisible ? 'none' : 'flex';
                overlay.style.display = isVisible ? 'none' : 'block';
                if (!isVisible) searchDropdown.querySelector('input').focus();
            });
        }
    });
</script>