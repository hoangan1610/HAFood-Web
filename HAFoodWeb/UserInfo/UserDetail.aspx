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
        :root{
            --haf-primary:#ff7b32;
            --haf-border:#e5e7eb;
            --haf-bg:#ffffff;          /* 🔧 NỀN TRẮNG của trang ngoài */
            --haf-text-main:#111827;
            --haf-text-muted:#6b7280;
        }
        *{box-sizing:border-box}
        html { scrollbar-gutter: stable; } /* ✅ Giữ chỗ cho scrollbar để không “nhảy” layout khi khóa cuộn */
        body{
            margin:0;
            font-family:system-ui,-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif;
            background:var(--haf-bg);
            color:var(--haf-text-main);
        }
        /* ✅ Khi khóa cuộn trang ngoài (hover vào iframe) */
        html.host-lock-scroll, body.host-lock-scroll {
            overflow: hidden;
            overscroll-behavior: contain;
        }
        /* ✅ Bù lại độ rộng scrollbar bị ẩn để không lệch layout */
        body.host-lock-scroll { padding-right: var(--sbw, 0px); }

        /* ====== Bố cục full-page ====== */
        .page{
            max-width:1280px;
            margin:24px auto;
            padding:0 16px
        }
        .user-grid{
            display:grid;
            grid-template-columns:260px 1fr; /* 🔧 Muốn rộng/hẹp sidebar đổi 260px */
            gap:0;
            align-items:start;
            min-height:72vh;
        }

        .sidebar{
            border-right:1px solid var(--haf-border);
            padding:20px 18px 22px 0;
            display:flex;flex-direction:column;gap:16px;background:transparent;
        }
        .sidebar-header{display:flex;align-items:center;gap:12px;margin-bottom:4px;padding-right:18px}
        .sidebar-avatar{
            width:40px;height:40px;border-radius:999px;
            background:rgba(255,123,50,.12);border:1px solid rgba(255,123,50,.35);
            color:var(--haf-primary);display:flex;align-items:center;justify-content:center;font-size:20px;
        }
        .sidebar-title{display:flex;flex-direction:column;gap:2px}
        .sidebar-title span:first-child{font-size:11px;text-transform:uppercase;letter-spacing:.1em;font-weight:600;color:var(--haf-text-muted)}
        .sidebar-title span:last-child{font-size:19px;font-weight:700}
        .sidebar-subtext{font-size:13px;color:var(--haf-text-muted);margin:0 18px 4px 0}
        .sidebar-section-label{font-size:11px;text-transform:uppercase;letter-spacing:.16em;color:var(--haf-text-muted);font-weight:600;margin:2px 18px 6px 0}

        .menu-list{display:flex;flex-direction:column;gap:6px;margin:0 18px 10px 0}
        .menu-item{
            padding:9px 12px;border-radius:10px;font-weight:500;cursor:pointer;
            transition:.15s;display:flex;align-items:center;text-decoration:none;color:var(--haf-text-main);
            font-size:14px;border:1px solid transparent;background:transparent;
        }
        .menu-item i{font-size:17px;margin-right:8px}
        .menu-item.active{background:rgba(255,123,50,.1);border-color:rgba(255,123,50,.6);color:#e8631d;box-shadow:0 10px 16px rgba(15,23,42,.08)}
        .menu-item:hover{background:#f9fafb;border-color:var(--haf-border)}
        .menu-item.logout{margin-top:auto;background:#fff;border-color:var(--haf-border);color:#b91c1c}
        .menu-item.logout i{color:#b91c1c}
        .menu-item.logout:hover{background:#fef2f2;border-color:#fecaca}

        /* ====== Content ====== */
        .content-area{padding:0 0 0 24px;background:transparent}

        /* Iframe: ẩn scrollbar UI + fallback chiều cao + nền trắng */
        .content-frame{
            width:100%;
            border:0;
            display:block;
            background:#ffffff;         /* 🔧 NỀN KHUNG NỘI DUNG: trắng */
            height:64vh;                /* 🔧 Fallback CHIỀU CAO (giảm nhẹ). Có JS tính lại theo viewport phía dưới */
            overflow:auto;              /* Cho phép khung tự cuộn khi nội dung cao hơn */
            scrollbar-width:none;       /* Ẩn thanh cuộn UI (Firefox) */
            -ms-overflow-style:none;    /* Ẩn thanh cuộn UI (IE/Legacy Edge) */
        }
        .content-frame::-webkit-scrollbar{width:0;height:0} /* Ẩn thanh cuộn UI (Chrome/Edge/WebKit) */

        @media (max-width:992px){
            .user-grid{grid-template-columns:1fr}
            .sidebar{border-right:none;border-bottom:1px solid var(--haf-border);padding:16px 0 14px}
            .menu-list{flex-direction:row;flex-wrap:nowrap;overflow-x:auto;padding-bottom:4px;gap:8px}
            .menu-item{white-space:nowrap;font-size:13px;padding:7px 10px}
            .menu-item.logout{margin-top:0;margin-left:auto}
            .content-area{padding-left:0}
        }
    </style>
</head>
<body>
<form id="form1" runat="server">
    <uc:Header runat="server" ID="Header1" />

    <div class="page">
        <div class="user-grid">
            <aside class="sidebar">
                <div class="sidebar-header">
                    <div class="sidebar-avatar"><i class="bi bi-person-fill"></i></div>
                    <div class="sidebar-title"><span>Tài khoản</span><span>Trung tâm cá nhân</span></div>
                </div>
                <div class="sidebar-subtext">Quản lý hồ sơ, đơn hàng và địa chỉ giao hàng của bạn.</div>

                <div class="sidebar-section-label">Tổng quan</div>
                <div class="menu-list">
                    <a id="mProfile"   class="menu-item active" data-url="../UserInfo/UserProfile.aspx" href="javascript:void(0);">
                        <i class="bi bi-person-circle"></i><span>Hồ sơ của tôi</span>
                    </a>
                    <a id="mOrders"    class="menu-item" data-url="../OrderPage/OrderPage.aspx" href="javascript:void(0);">
                        <i class="bi bi-basket2-fill"></i><span>Đơn hàng của tôi</span>
                    </a>
                    <a id="mAddresses" class="menu-item" data-url="../UserAddress/UserAddressList.aspx" href="javascript:void(0);">
                        <i class="bi bi-geo-alt-fill"></i><span>Địa chỉ của tôi</span>
                    </a>
                </div>

                <asp:LinkButton ID="lnkLogout" runat="server" CssClass="menu-item logout" OnClick="lnkLogout_Click" CausesValidation="false">
                    <i class="bi bi-box-arrow-right"></i><span>Đăng xuất</span>
                </asp:LinkButton>
            </aside>

            <main class="content-area">
                <iframe id="contentFrame" class="content-frame" src="../UserInfo/UserProfile.aspx?embed=1" title="Nội dung tài khoản"></iframe>
            </main>
        </div>
    </div>

    <uc:Footer runat="server" ID="Footer1" />
</form>

<script>
    (function () {
        const frame = document.getElementById('contentFrame');
        const menuItems = document.querySelectorAll('.menu-item');
        const mProfile = document.getElementById('mProfile');
        const mOrders = document.getElementById('mOrders');
        const mAddresses = document.getElementById('mAddresses');

        function withEmbed(u) {
            try { const url = new URL(u, location.origin); url.searchParams.set('embed', '1'); return url.pathname + url.search + url.hash; }
            catch { return u + (u.indexOf('?') >= 0 ? '&' : '?') + 'embed=1'; }
        }

        /* ====== THAM SỐ CHIỀU CAO (dễ chỉnh) ======
           HEIGHT_EXTRA_PX : cộng thêm (px) để khung dài hơn một chút.
           MIN_H_PX        : chiều cao tối thiểu.
           BOTTOM_GAP_PX   : khoảng cách chừa đáy để tránh dính footer. */
        const HEIGHT_EXTRA_PX = 40;   // 🔧 tăng/giảm “độ dài” khung
        const MIN_H_PX = 520;         // 🔧 min-height
        const BOTTOM_GAP_PX = 12;     // 🔧 chừa đáy

        /* Tính chiều cao khung theo viewport – không đo nội dung để tránh “nở” */
        function sizeToViewport() {
            const rect = frame.getBoundingClientRect();
            const space = Math.max(
                MIN_H_PX,
                Math.floor(window.innerHeight - rect.top - BOTTOM_GAP_PX + HEIGHT_EXTRA_PX)
            );
            frame.style.height = space + 'px';
        }

        /* Dọn nền + ẨN SCROLLBARS trong trang con và ép nền trắng */
        function beautifyAndHideScrollbars() {
            try {
                const doc = frame.contentDocument || frame.contentWindow.document;
                const head = doc.head || doc.getElementsByTagName('head')[0];
                if (!head) return;

                const id = '__haf_hide_scrollbars_and_clean';
                if (!doc.getElementById(id)) {
                    const st = doc.createElement('style');
                    st.id = id;
                    st.textContent = `
                      /* Ẩn thanh cuộn UI trong toàn bộ trang con nhưng vẫn cuộn được */
                      * { scrollbar-width: none !important; -ms-overflow-style: none !important; }
                      *::-webkit-scrollbar { width: 0 !important; height: 0 !important; }

                      /* Không cho cuộn “chaining” ra ngoài */
                      html, body { overscroll-behavior-y: contain !important; }

                      /* Gỡ hero/breadcrumb/gradient và ép nền trắng */
                      .page-hero,.hero,.section-hero,.account-hero,.breadcrumb,[data-breadcrumb],.banner,.page-banner{display:none !important}
                      html,body{
                        background:#ffffff !important;
                        background-image:none !important;
                      }
                      body,main,#main,.page,.container,.container-fluid,.wrapper,.layout,.content,.content-area,.account-page,.account-layout,.account-wrapper{
                        background-image:none !important;
                      }
                    `;
                    head.appendChild(st);
                }
            } catch (e) { }
        }

        /* ====== Khóa/Mở cuộn TRANG NGOÀI khi trỏ chuột vào/ra iframe ====== */
        function getScrollbarWidth() {
            return window.innerWidth - document.documentElement.clientWidth;
        }
        function lockOuterScroll() {
            const sbw = getScrollbarWidth();                       // đo trước khi khóa
            document.documentElement.style.setProperty('--sbw', sbw + 'px');
            document.body.style.setProperty('--sbw', sbw + 'px');
            document.documentElement.classList.add('host-lock-scroll');
            document.body.classList.add('host-lock-scroll');
        }
        function unlockOuterScroll() {
            document.documentElement.classList.remove('host-lock-scroll');
            document.body.classList.remove('host-lock-scroll');
            document.documentElement.style.removeProperty('--sbw');
            document.body.style.removeProperty('--sbw');
        }

        /* Gắn sự kiện cho iframe */
        ['mouseenter', 'pointerenter', 'focus', 'touchstart'].forEach(ev => {
            frame.addEventListener(ev, lockOuterScroll, { passive: true });
        });
        ['mouseleave', 'pointerleave', 'blur', 'touchend', 'touchcancel'].forEach(ev => {
            frame.addEventListener(ev, unlockOuterScroll, { passive: true });
        });

        // click menu -> đổi src + set chiều cao
        menuItems.forEach(it => {
            it.addEventListener('click', e => {
                const url = it.dataset?.url;
                if (!url) return;
                e.preventDefault();
                menuItems.forEach(i => i.classList.remove('active'));
                it.classList.add('active');
                frame.src = withEmbed(url);
                sizeToViewport(); // giữ ổn định theo viewport
            }, false);
        });

        // nhận ?tab= từ query
        try {
            const params = new URLSearchParams(location.search);
            const tab = (params.get('tab') || '').toLowerCase();
            if (tab === 'orders') {
                const orderId = params.get('orderId') || params.get('id');
                mProfile && mProfile.classList.remove('active');
                mOrders && mOrders.classList.add('active');
                const u = orderId ? '../OrderPage/OrderDetail.aspx?id=' + encodeURIComponent(orderId)
                    : (mOrders.dataset.url || '../OrderPage/OrderPage.aspx');
                frame.src = withEmbed(u);
            } else if (tab === 'addresses') {
                const addressId = params.get('addressId') || params.get('id');
                mProfile && mProfile.classList.remove('active');
                mAddresses && mAddresses.classList.add('active');
                const u = addressId ? '../UserAddress/UpdateUserAddress.aspx?id=' + encodeURIComponent(addressId)
                    : (mAddresses.dataset.url || '../UserAddress/UserAddressList.aspx');
                frame.src = withEmbed(u);
            }
        } catch { }

        frame.addEventListener('load', function () {
            beautifyAndHideScrollbars();
            sizeToViewport();
        });

        window.addEventListener('load', sizeToViewport);
        window.addEventListener('resize', sizeToViewport);
    })();
</script>
</body>
</html>
