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
        position: relative; /* giữ hộp suggest bám theo */
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
             data-guestid="<%= guestDropdown.ClientID %>"
             data-authid="<%= authDropdown.ClientID %>">

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
        <input id="headerSearch" type="text" placeholder="Search for products..." />
        <i class="bi bi-search" id="headerSearchBtn"></i>

        <!-- Suggest box -->
        <div id="hfSuggest" class="hf-suggest hf-hide"></div>
    </div>
</div>
<div class="page-overlay" id="pageOverlay"></div>

<!-- SCRIPT -->
<script>
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

    /* ---------- helpers ---------- */
    const visible = el => !!el && window.getComputedStyle(el).display !== 'none';
    const hideUser = () => { if (guestDD) guestDD.style.display = 'none'; if (authDD) authDD.style.display = 'none'; };
    const setOverlay = () => { overlay.style.display = (visible(searchDropdown) || visible(guestDD) || visible(authDD)) ? 'block' : 'none'; };

    const hideSearch = () => {
        if (searchDropdown) searchDropdown.style.display = 'none';
        box?.classList.add('hf-hide');
        setOverlay();
    };
    const showSearch = () => {
        hideUser();                          // luôn đóng user trước
        if (searchDropdown) searchDropdown.style.display = 'flex';
        overlay.style.display = 'block';
    };

    /* ---------- user icon ---------- */
    userIcon?.addEventListener('click', e => {
        e.stopPropagation();
        const target = guestDD || authDD;
        const willShow = !visible(target);
        hideSearch();                         // đóng search trước
        hideUser();
        if (willShow && target) target.style.display = 'flex';
        setOverlay();
    });

    /* ---------- open search icon ---------- */
    openBtn?.addEventListener('click', e => {
        e.stopPropagation();
        const willShow = !visible(searchDropdown);
        hideUser();                           // đóng user trước
        if (willShow) showSearch(); else hideSearch();
    });

    /* ---------- click ngoài ---------- */
    document.addEventListener('click', e => {
        // bỏ qua nếu click trong vùng search
        if (searchDropdown?.contains(e.target) || openBtn?.contains(e.target)) return;
        // đóng user nếu click ngoài
        if (!userIcon?.contains(e.target) && !guestDD?.contains(e.target) && !authDD?.contains(e.target)) {
            hideUser();
        }
        hideSearch();
    });
    overlay?.addEventListener('click', () => { hideUser(); hideSearch(); });

    // chặn nổi bọt trong vùng search/suggest
    searchDropdown?.addEventListener('click', e => e.stopPropagation());
    input?.addEventListener('click', e => e.stopPropagation());
    input?.addEventListener('focus', e => e.stopPropagation());
    box?.addEventListener('click', e => e.stopPropagation());

    /* =================== AUTOCOMPLETE SUGGEST =================== */
    const debounce = (fn, ms) => { let t; return (...a) => { clearTimeout(t); t = setTimeout(() => fn(...a), ms); } };
    let ctrl = null;

    function render(items) {
        if (!box) return;
        if (!items || !items.length) { box.classList.add('hf-hide'); box.innerHTML = ''; return; }
        box.innerHTML = items.map((s, i) => `<div class="hf-suggest-item${i === 0 ? ' active' : ''}" data-v="${s}">${s}</div>`).join('');
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
            e.preventDefault(); idx = (idx + 1) % items.length;
            items.forEach(x => x.classList.remove('active')); items[idx].classList.add('active');
            input.value = items[idx].dataset.v;
        } else if (e.key === 'ArrowUp') {
            e.preventDefault(); idx = (idx - 1 + items.length) % items.length;
            items.forEach(x => x.classList.remove('active')); items[idx].classList.add('active');
            input.value = items[idx].dataset.v;
        } else if (e.key === 'Enter') {
            e.preventDefault(); gotoSearch(input.value);
        } else if (e.key === 'Escape') {
            box.classList.add('hf-hide');
        }
    });

    btn?.addEventListener('click', () => gotoSearch(input?.value));
    box?.addEventListener('click', e => { const it = e.target.closest('.hf-suggest-item'); if (it) { e.stopPropagation(); gotoSearch(it.dataset.v); } });

    if (input && input.form) {
        input.form.addEventListener('submit', e => { e.preventDefault(); gotoSearch(input.value); });
    }
});
</script>

