<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="Header.ascx.cs" Inherits="HAFoodWeb.Control.Header"  %>
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
        position: relative;
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
        width: 220px;
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

    /* ====== Suggest (scoped) ====== */
    .hf-suggest {
        position: absolute;
        left: 0; right: 0; top: calc(100% + 8px);
        background: #fff; border: 1px solid #ddd; border-radius: 12px;
        box-shadow: 0 .5rem 1rem rgba(0,0,0,.08);
        max-height: 280px; overflow: auto;
        z-index: 12000;
    }
    .hf-suggest-item { padding: .5rem .75rem; cursor: pointer; }
    .hf-suggest-item:hover, .hf-suggest-item.active { background: #f8f9fa; }
    .hf-hide { display: none !important; }

    /* ===== CART BADGE ===== */
    .cart-link {
        position: relative;
        display: inline-block;
    }
    .cart-link i { font-size: 22px; color: #000; transition: color 0.3s; }
    .cart-link i:hover { color: #28a745; }
    .cart-badge {
        position: absolute;
        top: -6px;
        right: -10px;
        background-color: #000;
        color: #fff;
        font-size: 12px;
        font-weight: bold;
        border-radius: 50%;
        width: 20px;
        height: 20px;
        display: none;           /* ẩn mặc định, JS sẽ bật khi >0 */
        align-items: center;
        justify-content: center;
        line-height: 1;
    }
</style>

<!-- NAVBAR -->
<nav class="navbar navbar-expand-lg position-relative">
    <asp:HyperLink ID="lnkLogo" runat="server" NavigateUrl="~/HomePage/HomePage.aspx" CssClass="navbar-brand" title="Trang chủ">
        <asp:Image ID="imgLogo" runat="server" ImageUrl="~/images/HAFood_logo.png" AlternateText="Logo" />
    </asp:HyperLink>

    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav" aria-label="Mở menu">
        <span class="navbar-toggler-icon"></span>
    </button>

    <div class="collapse navbar-collapse" id="navbarNav">
        <ul class="navbar-nav mx-auto">
            <li class="nav-item">
                <asp:HyperLink ID="lnkHome" runat="server" NavigateUrl="~/HomePage/HomePage.aspx" CssClass="nav-link">Trang chủ</asp:HyperLink>
            </li>
            <li class="nav-item"><a class="nav-link" href="#">Danh mục</a></li>
            <li class="nav-item"><a class="nav-link" href="#">Cửa hàng</a></li>
            <li class="nav-item"><a class="nav-link" href="#">Sản phẩm</a></li>
            <li class="nav-item"><a class="nav-link" href="#">Thêm</a></li>
        </ul>

        <div class="nav-icons d-flex align-items-center"
             id="headerRoot"
             data-guestid='<%= guestDropdown.ClientID %>'
             data-authid='<%= authDropdown.ClientID %>'>

            <i class="bi bi-search" id="openSearch" title="Tìm kiếm"></i>

            <!-- Hidden flag để JS biết trạng thái đăng nhập -->
            <asp:HiddenField ID="hfIsAuth" runat="server" />

            <!-- USER ICON -->
            <div class="position-relative">
                <i class="bi bi-person" id="userIcon" title="Tài khoản" style="cursor:pointer;"></i>

                <!-- GUEST DROPDOWN -->
                <div class="user-dropdown" id="guestDropdown" runat="server" aria-label="Tài khoản khách">
                    <asp:HyperLink runat="server" NavigateUrl="~/AuthPage/Login.aspx" CssClass="d-flex align-items-center">
                        <i class="bi bi-box-arrow-in-right me-2"></i>Đăng nhập
                    </asp:HyperLink>
                    <asp:HyperLink runat="server" NavigateUrl="~/AuthPage/Register.aspx" CssClass="d-flex align-items-center">
                        <i class="bi bi-pencil-square me-2"></i>Đăng ký
                    </asp:HyperLink>
                </div>

                <!-- AUTH DROPDOWN -->
                <div class="user-dropdown" id="authDropdown" runat="server" aria-label="Tài khoản đã đăng nhập">
                    <asp:HyperLink ID="lnkProfile" runat="server" NavigateUrl="~/UserInfo/UserProfile.aspx" CssClass="d-flex align-items-center">
                        <i class="bi bi-person-circle me-2"></i>Hồ sơ của tôi
                    </asp:HyperLink>

                    <asp:HyperLink ID="lnkOrders" runat="server" NavigateUrl="~/OrderPage/OrderPage.aspx" CssClass="d-flex align-items-center">
                        <i class="bi bi-basket2-fill me-2"></i>Đơn hàng của tôi
                    </asp:HyperLink>

                    <asp:LinkButton ID="btnLogout" runat="server" OnClick="btnLogout_Click" CssClass="d-flex align-items-center">
                        <i class="bi bi-box-arrow-right me-2"></i>Đăng xuất
                    </asp:LinkButton>
                </div>
            </div>

            <!-- CART  -->
            <div class="position-relative">
                <asp:HyperLink ID="lnkCart" runat="server" NavigateUrl="~/CartPage/CartPage.aspx" CssClass="cart-link" title="Giỏ hàng">
                    <i id="cartIcon" class="bi bi-basket" aria-label="Giỏ hàng"></i>
                    <span id="cartCountBadge" runat="server" class="cart-badge" data-cart-badge="true" aria-live="polite" aria-atomic="true">0</span>
                </asp:HyperLink>
            </div>

        </div>
    </div>
</nav>

<!-- SEARCH DROPDOWN + OVERLAY -->
<div class="search-dropdown" id="searchDropdown" aria-label="Tìm kiếm">
    <div class="search-box">
        <input id="headerSearch" type="text" placeholder="Tìm kiếm sản phẩm..." aria-label="Ô tìm kiếm" />
        <i class="bi bi-search" id="headerSearchBtn" title="Tìm"></i>

        <!-- Suggest box -->
        <div id="hfSuggest" class="hf-suggest hf-hide"></div>
    </div>
</div>
<div class="page-overlay" id="pageOverlay" aria-hidden="true"></div>

<!-- SCRIPT -->
<script>
    // ====== Cart badge helpers ======
    const CART_API = '<%= ResolveUrl("~/Ajax/Cart.ashx") %>';

    // hiển thị badge
    window.setCartBadge = function (n) {
        const b = document.querySelector('[data-cart-badge="true"]');
        if (!b) return;
        const v = Math.max(0, parseInt(n || 0, 10));
        b.textContent = v;
        b.style.display = v > 0 ? 'flex' : 'none';
    };

    // gọi count từ server
    window.refreshCartCount = async function () {
        try {
            const url = `${CART_API}?action=count&t=${Date.now()}`; // cache-buster
            const r = await fetch(url, { method: 'GET', credentials: 'include', cache: 'no-store' });
            if (!r.ok) throw new Error('HTTP ' + r.status);
            const j = await r.json();
            const c = Number(j && (j.count ?? j.item_Count));
            window.setCartBadge(Number.isFinite(c) ? c : 0);
        } catch (e) {
            console.error('Lỗi làm mới số lượng giỏ hàng', e);
        }
    };

    // tiện ích cho trang con sau khi add/update/remove xong
    window.cartSyncNow = () => window.refreshCartCount();

    // optimistic update (tuỳ trang con dispatch)
    window.addEventListener('cart:add', e => {
        const b = document.querySelector('[data-cart-badge="true"]');
        const cur = b ? (parseInt(b.textContent || '0', 10) || 0) : 0;
        window.setCartBadge(cur + (e.detail?.delta || 1));
        // sync lại để khớp server
        window.refreshCartCount();
    });
    window.addEventListener('cart:revert', e => {
        const b = document.querySelector('[data-cart-badge="true"]');
        const cur = b ? (parseInt(b.textContent || '0', 10) || 0) : 0;
        window.setCartBadge(Math.max(0, cur - (e.detail?.delta || 1)));
        window.refreshCartCount();
    });

    // refresh khi page load xong & khi quay lại tab
    document.addEventListener('DOMContentLoaded', () => { try { window.refreshCartCount(); } catch {} });
    document.addEventListener('visibilitychange', () => {
        if (document.visibilityState === 'visible') { window.refreshCartCount(); }
    });

    // Nếu có UpdatePanel (WebForms), refresh sau partial postback
    if (window.Sys && Sys.WebForms && Sys.WebForms.PageRequestManager) {
        try {
            var prm = Sys.WebForms.PageRequestManager.getInstance();
            prm.add_endRequest(function () { window.refreshCartCount(); });
        } catch {}
    }

    // ====== Header UI behaviors (search/user) ======
    document.addEventListener('DOMContentLoaded', function () {
        const headerRoot = document.getElementById('headerRoot');
        const guestId = headerRoot?.dataset.guestid;
        const authId = headerRoot?.dataset.authid;

        const guestDD = guestId ? document.getElementById(guestId) : null;
        const authDD = authId ? document.getElementById(authId) : null;

        const userIcon = document.getElementById('userIcon');
        const openBtn = document.getElementById('openSearch');
        const searchDropdown = document.getElementById('searchDropdown');
        const overlay = document.getElementById('pageOverlay');

        const input = document.getElementById('headerSearch');
        const btn = document.getElementById('headerSearchBtn');
        const box = document.getElementById('hfSuggest');

        const suggestUrl = '<%= ResolveUrl("~/Proxy/Suggest.ashx") %>';
        const searchUrl  = '<%= ResolveUrl("~/HomePage/Search.aspx") %>';

        const hfAuth = document.getElementById('<%= hfIsAuth.ClientID %>');
        const isAuth = hfAuth && hfAuth.value === '1';

        const visible = el => !!el && window.getComputedStyle(el).display !== 'none';
        const hideUser = () => { if (guestDD) guestDD.style.display = 'none'; if (authDD) authDD.style.display = 'none'; };
        const setOverlay = () => { overlay.style.display = (visible(searchDropdown) || visible(guestDD) || visible(authDD)) ? 'block' : 'none'; };

        const hideSearch = () => { if (searchDropdown) searchDropdown.style.display = 'none'; box?.classList.add('hf-hide'); setOverlay(); };
        const showSearch = () => { hideUser(); if (searchDropdown) searchDropdown.style.display = 'flex'; overlay.style.display = 'block'; };

        userIcon?.addEventListener('click', e => {
            e.stopPropagation();
            if (isAuth) {
                window.location.href = '<%= ResolveUrl("~/UserInfo/UserDetail.aspx") %>';
                return;
            }
            const willShow = !visible(guestDD);
            hideSearch();
            if (willShow && guestDD) guestDD.style.display = 'flex';
            setOverlay();
        });

        openBtn?.addEventListener('click', e => {
            e.stopPropagation();
            const willShow = !visible(searchDropdown);
            hideUser();
            if (willShow) showSearch(); else hideSearch();
        });

        document.addEventListener('click', e => {
            if (searchDropdown?.contains(e.target) || openBtn?.contains(e.target)) return;
            if (!userIcon?.contains(e.target) && !guestDD?.contains(e.target) && !authDD?.contains(e.target)) hideUser();
            hideSearch();
        });
        overlay?.addEventListener('click', () => { hideUser(); hideSearch(); });

        searchDropdown?.addEventListener('click', e => e.stopPropagation());
        input?.addEventListener('click', e => e.stopPropagation());
        input?.addEventListener('focus', e => e.stopPropagation());
        box?.addEventListener('click', e => e.stopPropagation());

        const debounce = (fn, ms) => { let t; return (...a) => { clearTimeout(t); t = setTimeout(() => fn(...a), ms); }; };
        let ctrl = null;

        function render(items) {
            if (!box) return;
            if (!items || !items.length) { box.classList.add('hf-hide'); box.innerHTML = ''; return; }
            box.innerHTML = items.map((s, i) =>
                `<div class="hf-suggest-item${i === 0 ? ' active' : ''}" data-v="${s}">${s}</div>`
            ).join('');
            box.classList.remove('hf-hide');
        }

        const doSuggest = debounce(async () => {
            const q = (input?.value || '').trim();
            if (q.length < 2) { render([]); return; }
            try {
                ctrl?.abort();
                ctrl = new AbortController();
                const r = await fetch(`${suggestUrl}?q=${encodeURIComponent(q)}`, { signal: ctrl.signal });
                if (!r.ok) { render([]); return; }
                const d = await r.json();
                render(d.items || []);
            } catch { render([]); }
        }, 220);

        function gotoSearch(q) {
            q = (q || '').trim();
            const url = q ? `${searchUrl}?q=${encodeURIComponent(q)}` : `${searchUrl}`;
            window.location.href = url;
        }

        input?.addEventListener('input', doSuggest);
        input?.addEventListener('keydown', e => {
            const isOpen = box && !box.classList.contains('hf-hide');
            if (!isOpen) {
                if (e.key === 'Enter') { e.preventDefault(); gotoSearch(input.value); }
                return;
            }
            const items = Array.from(box.querySelectorAll('.hf-suggest-item'));
            if (!items.length) return;
            let idx = items.findIndex(x => x.classList.contains('active'));
            if (e.key === 'ArrowDown') {
                e.preventDefault(); idx = (idx + 1) <= items.length - 1 ? (idx + 1) : 0;
                items.forEach(x => x.classList.remove('active')); items[idx].classList.add('active');
                input.value = items[idx].dataset.v;
            } else if (e.key === 'ArrowUp') {
                e.preventDefault(); idx = (idx - 1) >= 0 ? (idx - 1) : (items.length - 1);
                items.forEach(x => x.classList.remove('active')); items[idx].classList.add('active');
                input.value = items[idx].dataset.v;
            } else if (e.key === 'Enter') {
                e.preventDefault(); gotoSearch(input.value);
            } else if (e.key === 'Escape') {
                box.classList.add('hf-hide');
            }
        });

        btn?.addEventListener('click', () => gotoSearch(input?.value));
        box?.addEventListener('click', e => {
            const it = e.target.closest('.hf-suggest-item');
            if (it) { e.stopPropagation(); gotoSearch(it.dataset.v); }
        });
    });
</script>
