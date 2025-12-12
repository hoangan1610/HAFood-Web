<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="UserDetail.aspx.cs" Inherits="HAFoodWeb.UserPage.UserDetail" Async="true" %>
<%@ Register Src="~/Control/Header.ascx" TagPrefix="uc" TagName="Header" %>
<%@ Register Src="~/Control/Footer.ascx" TagPrefix="uc" TagName="Footer" %>

<!DOCTYPE html>
<html lang="vi">
<head runat="server">
    <meta charset="utf-8" />
    <title>Tài khoản của tôi - HAFood</title>

    <meta name="viewport" content="width=device-width, initial-scale=1" />

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet" />

    <style>
        :root{
            --haf-primary:#ff7b32;
            --haf-border:#e5e7eb;
            --haf-text-main:#111827;
            --haf-text-muted:#6b7280;
        }
        *{box-sizing:border-box}
        html{scrollbar-gutter:stable}
        html,body{
            margin:0; min-height:100vh;
            font-family:system-ui,-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif;
            background:#ffffff !important; color:var(--haf-text-main);
        }

        .page{ max-width:1280px; margin:24px auto; padding:0 16px; }
        .user-grid{ display:grid; grid-template-columns:260px 1fr; gap:0; align-items:start; min-height:80vh; }

        .sidebar{
            border-right:1px solid var(--haf-border);
            padding:20px 18px 22px 0;
            display:flex; flex-direction:column; gap:16px;
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
        .menu-item.active{
            background:rgba(255,123,50,.1); border-color:rgba(255,123,50,.6); color:#e8631d;
            box-shadow:0 10px 16px rgba(15,23,42,.08)
        }
        .menu-item:hover{background:#f9fafb;border-color:#e5e7eb}
        .menu-item.logout{margin-top:auto;background:#fff;border:1px solid #e5e7eb;color:#b91c1c}
        .menu-item.logout i{color:#b91c1c}
        .menu-item.logout:hover{background:#fef2f2;border-color:#fecaca}

        .content-area{padding:0 0 0 24px}

        /* Iframe: không còn cố định 2000px, chỉ đặt min-height */
        .content-frame{
            width:100%; border:0; display:block; background:#ffffff;
            min-height:700px;
        }

        @media (max-width:992px){
            .user-grid{grid-template-columns:1fr}
            .sidebar{border-right:none;border-bottom:1px solid #e5e7eb;padding:16px 0 14px}
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
                <!-- Luôn kèm ?embed=1 -->
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
            try {
                const url = new URL(u, location.origin);
                url.searchParams.set('embed', '1');
                return url.pathname + url.search + url.hash;
            }
            catch {
                return u + (u.indexOf('?') >= 0 ? '&' : '?') + 'embed=1';
            }
        }

        // Fallback: tự đo chiều cao trang con nếu không nhận được postMessage
        function resizeFrameToContent() {
            if (!frame) return;
            try {
                const doc = frame.contentDocument || frame.contentWindow.document;
                if (!doc) return;
                const body = doc.body;
                const html = doc.documentElement;

                let h = 0;
                if (body) {
                    h = Math.max(h, body.scrollHeight, body.offsetHeight);
                }
                if (html) {
                    h = Math.max(h, html.scrollHeight, html.offsetHeight);
                }

                if (!h || h < 700) {
                    h = 700; // chiều cao tối thiểu
                }
                frame.style.height = h + 'px';
            } catch (e) {
                console.warn('resizeFrameToContent error', e);
            }
        }

        // Tiêm CSS nền trắng cho trang con (phòng page con quên xử lý embed=1)
        function injectWhite(iframe) {
            try {
                const d = iframe.contentDocument || iframe.contentWindow.document;
                if (!d) return;
                const head = d.head || d.getElementsByTagName('head')[0];
                if (!head || d.getElementById('__haf_force_white')) return;
                const st = d.createElement('style');
                st.id = '__haf_force_white';
                st.textContent = `
                    html,body{
                        background:#ffffff !important;
                        background-image:none !important;
                        min-height:auto !important;
                    }
                `;
                head.appendChild(st);
            } catch { }
        }

        if (frame) {
            frame.addEventListener('load', function () {
                injectWhite(frame);
                resizeFrameToContent();
                setTimeout(resizeFrameToContent, 200);
                setTimeout(resizeFrameToContent, 800);
            });
        }

        // Nhận postMessage từ các trang con để set height chính xác
        window.addEventListener('message', function (ev) {
            const d = ev && ev.data;
            if (!d || d.type !== 'haf-embed-height') return;
            if (frame && ev.source !== frame.contentWindow) return;

            let h = Number(d.height || d.h || d.value || 0);
            if (!h || h < 700) h = 700;
            frame.style.height = h + 'px';
        });

        // Chuyển tab: đổi src (luôn kèm embed=1)
        menuItems.forEach(it => {
            it.addEventListener('click', e => {
                const url = it.dataset?.url;
                if (!url) return;
                e.preventDefault();
                menuItems.forEach(i => i.classList.remove('active'));
                it.classList.add('active');
                frame.src = withEmbed(url);
            }, false);
        });

        // Hỗ trợ ?tab=orders / ?tab=addresses
        try {
            const params = new URLSearchParams(location.search);
            const tab = (params.get('tab') || '').toLowerCase();

            if (tab === 'orders') {
                const orderId = params.get('orderId') || params.get('id');
                mProfile && mProfile.classList.remove('active');
                mOrders && mOrders.classList.add('active');
                const u = orderId
                    ? '../OrderPage/OrderDetail.aspx?id=' + encodeURIComponent(orderId)
                    : (mOrders.dataset.url || '../OrderPage/OrderPage.aspx');
                frame.src = withEmbed(u);
            } else if (tab === 'addresses') {
                const addressId = params.get('addressId') || params.get('id');
                mProfile && mProfile.classList.remove('active');
                mAddresses && mAddresses.classList.add('active');
                const u = addressId
                    ? '../UserAddress/UpdateUserAddress.aspx?id=' + encodeURIComponent(addressId)
                    : (mAddresses.dataset.url || '../UserAddress/UserAddressList.aspx');
                frame.src = withEmbed(u);
            }
        } catch { }
    })();
</script>

</body>
</html>
