<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="Header.ascx.cs" Inherits="HAFoodWeb.Control.Header"  %>

<!-- CSS & fonts -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet" />
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet" />

<style>
  :root{
    --ha-cream: #FFF7EA;
    --ha-ink: #111827;
    --ha-accent: #28a745;
    --ha-border: #E5E7EB;
    --ha-shadow: 0 .75rem 2rem rgba(0,0,0,.12);
    --border: #E5E7EB;
  }

  .ha-header-wrap {
    background: linear-gradient(135deg, var(--ha-cream) 0%, #ffe5c3 100%);
    padding: 16px 0;
    position: relative;
    z-index: 900;
    display: flex;
    justify-content: center;
  }

  .navbar{
    width: 100%;
    max-width: 1200px;
    margin: 0 16px;
    border-radius: 999px;
    background: #fff;
    padding: 12px 24px;
    box-shadow: 0 2px 12px rgba(0,0,0,.06);
    position: relative;
    z-index: 901;
    display: flex;
    align-items: center;
    gap: 16px;
    justify-content: space-between;
  }

  .navbar,
  .navbar *{
    font-family: "Inter", system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial, "Noto Sans", sans-serif;
    color: var(--ha-ink);
  }

  .navbar-brand{
    display: flex;
    align-items: center;
    justify-content: flex-start;
    gap: 10px;
  }

  .navbar-brand img,
  .brand-logo-img{
    height: 72px;
    width: 72px;
    border-radius: 50%;
    border: 2px solid var(--ha-accent);
    background: #fff;
    padding: 4px;
    object-fit: cover;
    box-shadow: 0 6px 18px rgba(40,167,69,0.18);
  }

  .brand-text{
    display: flex;
    flex-direction: column;
    align-items: flex-start;
    line-height: 1.2;
  }

  .brand-title{
    font-size: 20px;
    font-weight: 700;
    letter-spacing: .04em;
    text-transform: uppercase;
  }

  .brand-tagline{
    margin-top: 2px;
    font-size: 11px;
    font-weight: 500;
    letter-spacing: .12em;
    text-transform: uppercase;
    color: #6b7280;
  }

  .ha-search{
    flex: 1 1 0;
    max-width: 620px;
    padding: 0;
    position: relative;
    margin: 0 auto;
  }

  .search-box{
    background: #fff;
    border-radius: 16px;
    padding: 10px 16px;
    width: 100%;
    display: flex;
    align-items: center;
    gap: 10px;
    box-shadow: 0 4px 16px rgba(0,0,0,0.06);
    border: 2px solid var(--ha-accent);
    transition: box-shadow .2s, transform .1s;
  }

  .search-box:focus-within{
    box-shadow: 0 8px 24px rgba(40,167,69,0.18);
    transform: translateY(-1px);
  }

  .search-box input{
    flex: 1;
    border: 0;
    outline: 0;
    font-size: 16px;
    background: transparent;
  }

  .search-box i{
    font-size: 20px;
    color: var(--ha-accent);
    cursor: pointer;
  }

  .hf-suggest{
    position: absolute;
    left: 0;
    right: 0;
    top: calc(100% + 8px);
    background: #fff;
    border: 1px solid var(--ha-border);
    border-radius: 12px;
    box-shadow: 0 .5rem 1rem rgba(0,0,0,.08);
    max-height: 280px;
    overflow: auto;
    z-index: 1001;
  }

  .hf-suggest-item{
    padding: .5rem .75rem;
    cursor: pointer;
  }

  .hf-suggest-item:hover,
  .hf-suggest-item.active{
    background: #f8f9fa;
  }

  .hf-hide{
    display: none !important;
  }

  .nav-icons{
    display: flex;
    align-items: center;
    gap: 30px;
    margin-left: 16px;
  }

  .nav-icons i{
    font-size: 20px;
    color: var(--ha-ink);
    cursor: pointer;
    transition: color .2s, background-color .2s, transform .1s;
    position: relative;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 38px;
    height: 38px;
    border-radius: 999px;
    background: #f3f4f6;
  }

  .nav-icons i:hover{
    color: var(--ha-accent);
    background: rgba(40,167,69,0.08);
    transform: translateY(-1px);
  }

  .notify-wrapper{
    position: relative;
    display: inline-flex;
    align-items: center;
    justify-content: center;
  }

  .notify-dot{
    position: absolute;
    top: 4px;
    right: 4px;
    width: 10px;
    height: 10px;
    border-radius: 50%;
    background: #ef4444;
    border: 2px solid #ffffff;
    display: flex;
    box-shadow: 0 0 0 2px rgba(255,255,255,.6);
  }

  /* Dropdown thông báo */
  .notify-dropdown{
    position: absolute;
    top: 150%;
    right: 0;
    left: auto;
    margin-left: 0;
    background: #fff;
    border-radius: 14px;
    box-shadow: 0 18px 45px rgba(15,23,42,.15);
    padding: 0;
    display: none;
    flex-direction: column;
    width: 360px;
    max-width: min(360px, 95vw);
    max-height: 400px;
    z-index: 1001;
    border: 1px solid #e5e7eb;
  }

  .notify-header{
    padding: 12px 18px;
    font-weight: 600;
    border-bottom: 1px solid #f3f4f6;
    display: flex;
    align-items: center;
    justify-content: space-between;
    font-size: 15px;
    background: #ffffff;
    flex: 0 0 auto;
  }

  .notify-header span:first-child{
    color: #111827;
    font-size: 15px;
    font-weight: 700;
  }

  .notify-header a,
  .notify-header button{
    font-size: 15px;
    font-weight: 600;
    color: var(--ha-accent);
    text-decoration: none;
    background: none;
    border: 0;
    padding: 0;
    cursor: pointer;
  }

  .notify-header a:hover,
  .notify-header button:hover{
    text-decoration: underline;
  }

  .notify-items{
    flex: 1 1 auto;
    overflow-y: auto;
  }

  .notify-item{
    padding: 10px 16px;
    font-size: 14px;
    cursor: pointer;
    text-align: left;
    border-bottom: 1px solid #f3f4f6;
    display: block;
    text-decoration: none;
    color: #111827;
    background-color: #fff;
    transition: background .15s ease, border-color .15s ease;
  }

  .notify-item:last-child{
    border-bottom: none;
  }

  .notify-item.unread{
    background: #f0fdf4;
    border-left: 3px solid var(--ha-accent);
    padding-left: 13px;
  }

  .notify-item:hover{
    background: #f9fafb;
  }

  .notify-item-title{
    margin-bottom: 2px;
    font-weight: 600;
  }

  .notify-item-body{
    font-size: 13px;
    color: #6b7280;
  }

  .notify-item-time{
    font-size: 11px;
    color: #9ca3af;
    margin-top: 4px;
  }

  .notify-empty{
    padding: 12px 16px 14px;
    font-size: 13px;
    color: #6b7280;
  }

  .notify-footer{
    border-top: 1px solid #f3f4f6;
    padding: 10px 16px;
    display: flex;
    justify-content: center;
    align-items: center;
    background: #ffffff;
    border-radius: 0 0 14px 14px;
    flex: 0 0 auto;
  }

  .notify-footer button,
  .notify-footer a{
    border: none;
    background: none;
    padding: 4px 8px;
    font-size: 15px;
    font-weight: 700;
    cursor: pointer;
    color: #111827;
    text-decoration: none;
  }

  .notify-footer button:hover,
  .notify-footer a:hover{
    text-decoration: underline;
  }

  @media (max-width: 576px){
    .notify-dropdown{
      left: auto;
      right: 0;
      width: min(320px, 90vw);
    }
  }

  .user-dropdown{
    position: absolute;
    top: 150%;
    right: 0;
    background: #fff;
    border-radius: 10px;
    box-shadow: 0 4px 15px rgba(0,0,0,0.1);
    padding: 10px 0;
    display: none;
    flex-direction: column;
    width: 220px;
    z-index: 1001;
  }

  .user-dropdown a,
  .user-dropdown asp\:LinkButton{
    text-decoration: none;
    color: #333;
    padding: 10px 20px;
    font-size: 16px;
    transition: background .3s, color .3s;
    display: block;
    text-align: left;
  }

  .user-dropdown a:hover,
  .user-dropdown asp\:LinkButton:hover{
    background: #f4f4f4;
    color: var(--ha-accent);
  }

  .cart-link{
    position: relative;
    display: inline-block;
  }

  .cart-badge{
    position: absolute;
    top: -6px;
    right: -6px;
    background: #000;
    color: #fff;
    font-size: 12px;
    font-weight: 700;
    border-radius: 50%;
    width: 20px;
    height: 20px;
    display: flex;
    align-items: center;
    justify-content: center;
    line-height: 1;
  }

  @media (max-width: 992px){
    .ha-header-wrap{
      padding: 12px 0;
    }

    .navbar{
      margin: 0 12px;
      padding: 10px 14px;
      border-radius: 24px;
      flex-direction: column;
      align-items: stretch;
      gap: 12px;
    }

    .navbar-brand{
      justify-content: center;
    }

    .navbar-brand img,
    .brand-logo-img{
      height: 64px;
      width: 64px;
    }

    .brand-title{
      font-size: 18px;
    }

    .brand-tagline{
      font-size: 10px;
    }

    .ha-search{
      order: 3;
      max-width: none;
      width: 100%;
    }

    .nav-icons{
      order: 2;
      justify-content: flex-end;
    }
  }

  @media (max-width: 576px){
    .navbar{
      margin: 0 8px;
      padding: 8px 10px;
    }

    .nav-icons{
      gap: 6px;
    }

    .nav-icons i{
      width: 34px;
      height: 34px;
      font-size: 18px;
    }

    .search-box{
      padding: 8px 12px;
    }

    .search-box input{
      font-size: 14px;
    }

    .navbar-brand{
      flex-direction: column;
      text-align: center;
    }

    .brand-text{
      align-items: center;
    }

    .brand-tagline{
      display: none;
    }
  }

  /* ===== Toast thông báo góc phải ===== */
  .ha-toast-container{
    position: fixed;
    top: 12px;
    right: 12px;
    z-index: 1200;
    display: flex;
    flex-direction: column;
    gap: 8px;
    pointer-events: none;
  }

  .ha-toast{
    min-width: 220px;
    max-width: 320px;
    background:#111827;
    color:#f9fafb;
    border-radius: 999px;
    padding: 8px 14px;
    font-size: 13px;
    display: flex;
    align-items: center;
    gap: 8px;
    opacity: 0;
    transform: translateY(-6px);
    transition: opacity .2s ease, transform .2s ease;
    box-shadow: 0 10px 25px rgba(15,23,42,.35);
    pointer-events: auto;
  }

  .ha-toast-show{
    opacity: 1;
    transform: translateY(0);
  }

  .ha-toast i{
    font-size: 16px;
    color:#22c55e;
  }
</style>

<div class="ha-header-wrap">
  <nav class="navbar">
    <!-- Logo + Brand -->
    <asp:HyperLink ID="lnkLogo" runat="server" NavigateUrl="~/HomePage/HomePage.aspx" CssClass="navbar-brand" title="Trang chủ">
      <asp:Image ID="imgLogo" runat="server" ImageUrl="~/images/HAFood_logo.png" AlternateText="Logo" CssClass="brand-logo-img" />
      <div class="brand-text">
        <span class="brand-title">HAFood</span>
        <span class="brand-tagline">Đồ ăn vặt chất lượng</span>
      </div>
    </asp:HyperLink>

    <!-- SEARCH -->
    <div class="ha-search" id="searchInline" aria-label="Tìm kiếm">
      <div class="search-box w-100">
        <input id="headerSearch" type="text" placeholder="Tìm kiếm sản phẩm..." aria-label="Ô tìm kiếm" />
        <i class="bi bi-search" id="headerSearchBtn" title="Tìm"></i>
        <div id="hfSuggest" class="hf-suggest hf-hide"></div>
      </div>
    </div>

    <!-- ICONS -->
    <div
      class="nav-icons d-flex align-items-center ms-auto"
      id="headerRoot"
      data-guestid='<%= guestDropdown.ClientID %>'
      data-authid='<%= authDropdown.ClientID %>'>

      <asp:HiddenField ID="hfIsAuth" runat="server" />
      <!-- NEW: hidden lưu unread ban đầu -->
      <asp:HiddenField ID="hfNotifyUnread" runat="server" />

      <!-- Notification -->
      <div class="position-relative notify-wrapper" id="notifyWrapper">
        <i class="bi bi-bell" id="notifyIcon" title="Thông báo"></i>
        <%-- DOT chỉ là HTML, không runat="server" --%>
        <span class="notify-dot" id="notifyDot"></span>

        <!-- [NOTIFY] dropdown -->
        <div class="notify-dropdown" id="notifyDropdown" runat="server" aria-label="Thông báo mới">
          <!-- Header -->
          <div class="notify-header">
            <span>Thông báo</span>
            <asp:LinkButton
              ID="btnMarkAllRead"
              runat="server"
              CssClass="text-decoration-none small"
              OnClick="btnMarkAllRead_Click">
              Đánh dấu tất cả đã đọc
            </asp:LinkButton>
          </div>

          <!-- Danh sách cuộn -->
          <div class="notify-items" id="notifyItems">
            <asp:Label ID="lblNotifyEmpty" runat="server" CssClass="notify-empty" Visible="false"></asp:Label>

            <asp:Repeater ID="rptNotifications" runat="server" OnItemCommand="rptNotifications_ItemCommand">
              <ItemTemplate>
                <asp:LinkButton
                  runat="server"
                  CommandName="Open"
                  CommandArgument='<%# BuildNotifyCommandArg(Container.DataItem) %>'
                  CssClass='<%# "notify-item " + (!(bool)Eval("isRead") ? "unread" : "") %>'>
                  <div class="notify-item-title"><%# Eval("title") %></div>
                  <div class="notify-item-body"><%# Eval("body") %></div>
                  <div class="notify-item-time"><%# Eval("createdAt", "{0:dd/MM/yyyy HH:mm}") %></div>
                </asp:LinkButton>
              </ItemTemplate>
            </asp:Repeater>
          </div>

          <!-- Footer cố định -->
          <div class="notify-footer">
            <asp:HyperLink
              ID="lnkAllNotifications"
              runat="server"
              NavigateUrl="~/NotificationPage/NotificationPage.aspx">
              Xem tất cả
            </asp:HyperLink>
          </div>
        </div>
        <!-- [END NOTIFY] dropdown -->
      </div>

      <!-- User -->
      <div class="position-relative">
        <i class="bi bi-person" id="userIcon" title="Tài khoản" style="cursor:pointer;"></i>

        <!-- Guest -->
        <div class="user-dropdown" id="guestDropdown" runat="server" aria-label="Tài khoản khách">
          <asp:HyperLink runat="server" NavigateUrl="~/AuthPage/Login.aspx" CssClass="d-flex align-items-center">
            <i class="bi bi-box-arrow-in-right me-2"></i>Đăng nhập
          </asp:HyperLink>
          <asp:HyperLink runat="server" NavigateUrl="~/AuthPage/Register.aspx" CssClass="d-flex align-items-center">
            <i class="bi bi-pencil-square me-2"></i>Đăng ký
          </asp:HyperLink>
        </div>

        <!-- Auth -->
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

      <!-- Cart -->
      <div class="position-relative">
        <asp:HyperLink ID="lnkCart" runat="server" NavigateUrl="~/CartPage/CartPage.aspx" CssClass="cart-link" title="Giỏ hàng">
          <i id="cartIcon" class="bi bi-basket" aria-label="Giỏ hàng"></i>
          <span id="cartCountBadge" runat="server" class="cart-badge" data-cart-badge="true" aria-live="polite" aria-atomic="true">0</span>
        </asp:HyperLink>
      </div>
    </div>
  </nav>
</div>

<!-- Âm thanh notify -->
<audio id="notifySound" preload="auto" src="<%= ResolveUrl("~/assets/sounds/notify-1.mp3") %>"></audio>

<!-- SCRIPT CART -->
<script>
    (function () {
        window.CART_API = window.CART_API || '<%= ResolveUrl("~/Ajax/Cart.ashx") %>';

        let __cartCount = 0;

        window.setCartBadge = function (n) {
            const b = document.querySelector('[data-cart-badge="true"]');
            if (!b) return;
            const v = Math.max(0, parseInt(n ?? 0, 10) || 0);
            __cartCount = v;
            b.textContent = String(v);
            b.style.display = 'flex';
        };

        window.getCartBadgeCount = function () {
            return __cartCount;
        };

        window.refreshCartCount = async function () {
            try {
                const url = `${window.CART_API}?action=count&t=${Date.now()}`;
                const r = await fetch(url, {
                    method: 'GET',
                    credentials: 'include',
                    cache: 'no-store'
                });
                if (!r.ok) throw new Error('HTTP ' + r.status);
                const j = await r.json();
                const c = Number(j && (j.count ?? j.item_Count));
                if (Number.isFinite(c)) window.setCartBadge(c);
            } catch (e) {
                console.error('Lỗi làm mới số lượng giỏ hàng', e);
            }
        };

        window.cartSyncNow = () => window.refreshCartCount();

        window.addEventListener('cart:add', function (e) {
            const delta = Number(e.detail?.delta ?? 1);
            if (!Number.isFinite(delta)) return;
            const current = window.getCartBadgeCount();
            window.setCartBadge(current + delta);
        });

        window.addEventListener('cart:revert', function (e) {
            const delta = Number(e.detail?.delta ?? 1);
            if (!Number.isFinite(delta)) return;
            const current = window.getCartBadgeCount();
            window.setCartBadge(Math.max(0, current - delta));
        });

        window.addEventListener('cart:set', function (e) {
            const c = Number(e.detail?.count);
            if (Number.isFinite(c)) window.setCartBadge(c);
        });

        window.addEventListener('DOMContentLoaded', function () {
            try {
                const b = document.querySelector('[data-cart-badge="true"]');
                if (b) {
                    const initial = parseInt(b.textContent || '0', 10);
                    if (Number.isFinite(initial)) __cartCount = initial;
                }
                window.refreshCartCount();
            } catch { }
        });

        document.addEventListener('visibilitychange', function () {
            if (document.visibilityState === 'visible') window.refreshCartCount();
        });

        if (window.Sys && Sys.WebForms && Sys.WebForms.PageRequestManager) {
            try {
                var prm = Sys.WebForms.PageRequestManager.getInstance();
                prm.add_endRequest(function () { window.refreshCartCount(); });
            } catch { }
        }
    })();
</script>

<!-- SCRIPT HEADER (search + user + notify + SSE) -->
<script>
  document.addEventListener('DOMContentLoaded', function () {
    const headerRoot = document.getElementById('headerRoot');
    const guestId = headerRoot?.dataset.guestid;
    const authId = headerRoot?.dataset.authid;

    const guestDD = guestId ? document.getElementById(guestId) : null;
    const authDD = authId ? document.getElementById(authId) : null;

    const userIcon = document.getElementById('userIcon');
    const openBtn = document.getElementById('openSearch');

    const input = document.getElementById('headerSearch');
    const btn = document.getElementById('headerSearchBtn');
    const box = document.getElementById('hfSuggest');
    const searchWrap = document.getElementById('searchInline');

    const suggestUrl = '<%= ResolveUrl("~/Proxy/Suggest.ashx") %>';
    const searchUrl  = '<%= ResolveUrl("~/HomePage/Search.aspx") %>';

    const hfAuth = document.getElementById('<%= hfIsAuth.ClientID %>');
    const hfUnread = document.getElementById('<%= hfNotifyUnread.ClientID %>');
    const isAuth = hfAuth && hfAuth.value === '1';

    // [NOTIFY]
    const notifyIcon = document.getElementById('notifyIcon');
    const notifyWrapper = document.getElementById('notifyWrapper');
    const notifyDropdown = document.getElementById('<%= notifyDropdown.ClientID %>');
    const notifyDot = document.getElementById('notifyDot');
    const notifyItems = document.getElementById('notifyItems');

    // SSE + list + mark-read URL
    const notifySseUrl  = '<%= ResolveUrl("~/Proxy/NotificationStream.ashx") %>';
    const notifyListUrl = '<%= ResolveUrl("~/Proxy/NotificationList.ashx") %>';
    const notifyMarkUrl = '<%= ResolveUrl("~/Proxy/NotificationMarkRead.ashx") %>';

    let notifyEs = null;
    let lastUnread = null;

    // Ẩn notify hoàn toàn với khách
    if (!isAuth && notifyWrapper) {
      notifyWrapper.style.display = 'none';
    }

    function updateNotifyDot(unread) {
      if (!notifyDot) return;
      const v = Number(unread) || 0;
      notifyDot.style.display = v > 0 ? 'flex' : 'none';
    }

    function playNotifySound() {
      try {
        const audio = document.getElementById('notifySound');
        if (!audio) return;
        audio.currentTime = 0;
        audio.play().catch(function(){});
      } catch { }
    }

    function showNotifyToast(unread) {
      const count = Number(unread) || 0;
      if (count <= 0) return;

      const msg = count === 1
        ? 'Bạn có 1 thông báo mới'
        : `Bạn có ${count} thông báo mới`;

      let container = document.querySelector('.ha-toast-container');
      if (!container) {
        container = document.createElement('div');
        container.className = 'ha-toast-container';
        document.body.appendChild(container);
      }

      const toast = document.createElement('div');
      toast.className = 'ha-toast';
      toast.innerHTML =
        '<i class="bi bi-bell-fill"></i>' +
        '<span>' + msg + '</span>';

      container.appendChild(toast);

      requestAnimationFrame(function() {
        toast.classList.add('ha-toast-show');
      });

      setTimeout(function () {
        toast.classList.remove('ha-toast-show');
        setTimeout(function () {
          toast.remove();
          if (!container.hasChildNodes()) {
            container.remove();
          }
        }, 200);
      }, 4000);
    }

    // Load HTML list từ NotificationList.ashx
    async function reloadNotifyList() {
      if (!isAuth || !notifyItems) return;
      try {
        notifyItems.innerHTML = '<div class="notify-empty">Đang tải...</div>';
        const r = await fetch(notifyListUrl, {
          method: 'GET',
          credentials: 'include',
          cache: 'no-store'
        });
        if (!r.ok) throw new Error('HTTP ' + r.status);
        const html = await r.text();
        notifyItems.innerHTML = html;
      } catch (e) {
        console.warn('[notify] load list error:', e);
        notifyItems.innerHTML = '<div class="notify-empty">Không tải được thông báo.</div>';
      }
    }

    // 🔴 Bắt click vào item trong dropdown để mark-read (và vẫn cho phép chuyển trang)
    if (notifyItems) {
      notifyItems.addEventListener('click', function (e) {
        const item = e.target.closest('.notify-item');
        if (!item) return;

        const id = item.getAttribute('data-id');
        if (!id) return;

        // Fire-and-forget: gọi handler đánh dấu đã đọc
        try {
          fetch(`${notifyMarkUrl}?id=${encodeURIComponent(id)}`, {
            method: 'POST',
            credentials: 'include',
            cache: 'no-store'
          }).catch(() => {});
        } catch { }

        // Update UI local
        item.classList.remove('unread');

        // Nếu không còn item nào unread -> tắt dot đỏ
        const anyUnread = notifyItems.querySelector('.notify-item.unread');
        if (!anyUnread && notifyDot) {
          notifyDot.style.display = 'none';
        }
      });
    }

    function startNotifySse() {
      if (!isAuth) {
        updateNotifyDot(0);
        return;
      }

      // Init lastUnread từ server (hidden field)
      if (hfUnread && hfUnread.value !== '') {
        const init = Number(hfUnread.value || 0);
        if (Number.isFinite(init)) {
          lastUnread = init;
          updateNotifyDot(init);
        }
      }

      if (typeof EventSource === 'undefined') {
        console.warn('[notify] EventSource không hỗ trợ.');
        return;
      }

      try {
        notifyEs = new EventSource(notifySseUrl);
        let firstEvent = (lastUnread === null);

        notifyEs.addEventListener('open', function () {
          console.info('[notify] SSE connected.');
        });

        notifyEs.addEventListener('notifications.badge', function (ev) {
          try {
            const data = JSON.parse(ev.data);
            const unread = Number(data.totalUnread || 0);

            if (firstEvent) {
              firstEvent = false;
              lastUnread = unread;
              updateNotifyDot(unread);
              return;
            }

            if (lastUnread == null || unread !== lastUnread) {
              const increased = lastUnread != null && unread > lastUnread;
              lastUnread = unread;
              updateNotifyDot(unread);

              if (increased) {
                playNotifySound();
                showNotifyToast(unread);
              }
            }
          } catch (e) {
            console.warn('[notify] parse SSE data error', e);
          }
        });

        notifyEs.addEventListener('error', function (ev) {
          console.warn('[notify] SSE error:', ev);
        });
      } catch (e) {
        console.warn('[notify] startNotifySse error:', e);
      }
    }

    const hideUser = () => {
      if (guestDD) guestDD.style.display = 'none';
      if (authDD) authDD.style.display = 'none';
    };

    const hideSuggest = () => {
      box?.classList.add('hf-hide');
    };

    const hideNotify = () => {
      if (notifyDropdown) notifyDropdown.style.display = 'none';
    };

    userIcon?.addEventListener('click', e => {
      e.stopPropagation();
      if (isAuth) {
        window.location.href = '<%= ResolveUrl("~/UserInfo/UserDetail.aspx") %>';
            return;
        }
        const willShow = !(guestDD && window.getComputedStyle(guestDD).display !== 'none');
        hideSuggest();
        hideNotify();
        if (willShow && guestDD) {
            guestDD.style.display = 'flex';
        } else if (guestDD) {
            guestDD.style.display = 'none';
        }
    });

      notifyIcon?.addEventListener('click', e => {
          e.stopPropagation();
          if (!isAuth) return;
          const isVisible = notifyDropdown && window.getComputedStyle(notifyDropdown).display !== 'none';
          hideUser();
          hideSuggest();
          if (!notifyDropdown) return;

          if (isVisible) {
              notifyDropdown.style.display = 'none';
          } else {
              notifyDropdown.style.display = 'flex';
              // mỗi lần mở chuông → reload list từ server
              reloadNotifyList();
          }
      });

      notifyWrapper?.addEventListener('click', e => e.stopPropagation());

      openBtn?.addEventListener('click', e => {
          e.stopPropagation();
          input?.focus();
      });

      document.addEventListener('click', e => {
          if (!(searchWrap?.contains(e.target) || openBtn?.contains(e.target))) {
              hideSuggest();
          }
          if (!userIcon?.contains(e.target) && !guestDD?.contains(e.target) && !authDD?.contains(e.target)) {
              hideUser();
          }
          if (!notifyWrapper?.contains(e.target)) {
              hideNotify();
          }
      });

      searchWrap?.addEventListener('click', e => e.stopPropagation());
      input?.addEventListener('click', e => e.stopPropagation());
      input?.addEventListener('focus', e => e.stopPropagation());
      box?.addEventListener('click', e => e.stopPropagation());

      const debounce = (fn, ms) => {
          let t;
          return (...a) => {
              clearTimeout(t);
              t = setTimeout(() => fn(...a), ms);
          };
      };

      function render(items) {
          if (!box) return;
          if (!items || !items.length) {
              box.classList.add('hf-hide');
              box.innerHTML = '';
              return;
          }
          box.innerHTML = items
              .map((s, i) => `<div class="hf-suggest-item${i === 0 ? ' active' : ''}" data-v="${s}">${s}</div>`)
              .join('');
          box.classList.remove('hf-hide');
          box.querySelectorAll('.hf-suggest-item').forEach(el => {
              el.addEventListener('click', () => gotoSearch(el.dataset.v || ''));
          });
      }

      const doSuggest = debounce(async () => {
          const q = (input?.value || '').trim();
          if (q.length < 2) {
              render([]);
              return;
          }
          try {
              const r = await fetch(`${suggestUrl}?q=${encodeURIComponent(q)}`);
              if (!r.ok) {
                  render([]);
                  return;
              }
              const d = await r.json();
              render(d.items || []);
          } catch {
              render([]);
          }
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
              if (e.key === 'Enter') {
                  e.preventDefault();
                  gotoSearch(input.value);
              }
              return;
          }

          const items = Array.from(box.querySelectorAll('.hf-suggest-item'));
          if (!items.length) return;
          let idx = items.findIndex(x => x.classList.contains('active'));

          if (e.key === 'ArrowDown') {
              e.preventDefault();
              idx = (idx + 1) <= items.length - 1 ? (idx + 1) : 0;
              items.forEach(x => x.classList.remove('active'));
              items[idx].classList.add('active');
              input.value = items[idx].dataset.v;
          } else if (e.key === 'ArrowUp') {
              e.preventDefault();
              idx = (idx - 1) >= 0 ? (idx - 1) : (items.length - 1);
              items.forEach(x => x.classList.remove('active'));
              items[idx].classList.add('active');
              input.value = items[idx].dataset.v;
          } else if (e.key === 'Enter') {
              e.preventDefault();
              gotoSearch(input.value);
          } else if (e.key === 'Escape') {
              hideSuggest();
          }
      });

      btn?.addEventListener('click', () => gotoSearch(input?.value));

      // Khởi động SSE thông báo
      if (isAuth) {
          startNotifySse();
      } else if (notifyDot) {
          notifyDot.style.display = 'none';
      }
  });
</script>
