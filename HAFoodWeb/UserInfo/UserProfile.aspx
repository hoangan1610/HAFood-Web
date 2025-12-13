<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="UserProfile.aspx.cs" Inherits="HAFoodWeb.UserProfile" Async="true" %>

<!DOCTYPE html>
<html lang="vi">
<head runat="server">
    <meta charset="utf-8" />
    <title>Thông tin cá nhân</title>

    <meta name="viewport" content="width=device-width, initial-scale=1" />

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" />

    <style>
        :root {
            --haf-primary: #ff7b32;
            --haf-primary-hover: #e8631d;
            --haf-bg: #f5f5f5;
            --haf-border: #e5e7eb;
            --haf-text-main: #111827;
            --haf-text-muted: #6b7280;
        }

        * { box-sizing: border-box; }

        body {
            font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
            margin: 0;
            padding: 20px 10px 30px;
            background:
              radial-gradient(circle at top left,
                               #ffe8cc 0,
                               #ffe0bd 20%,
                               #fdf5ee 40%,
                               #f5f5f5 70%,
                               #f5f5f5 100%);
            background-color: var(--haf-bg);
        }

        .account-page { width: 100%; max-width: 100%; margin: 0 auto; }

        .account-page-header { margin-bottom: 8px; }

        .page-title {
            font-weight: 700;
            font-size: 1.7rem;
            color: #212529;
            margin: 0.12rem 0 0;
        }

        .page-subtitle { font-size: .9rem; color: #6c757d; }

        .title-badge {
            font-size: .75rem;
            letter-spacing: .08em;
            text-transform: uppercase;
            font-weight: 700;
            color: #fd7e14;
            background: rgba(253, 126, 20, .08);
            padding: .26rem .7rem;
            border-radius: 999px;
            display: inline-flex;
            align-items: center;
            gap: .35rem;
            margin-bottom: 0;
        }

        .title-badge i { font-size: .9rem; }

        .profile-container {
            max-width: 720px;
            margin: 0 auto;
            background-color: #ffffff;
            padding: 26px 26px 26px;
            border-radius: 18px;
            box-shadow: 0 12px 26px rgba(15, 23, 42, 0.12);
            text-align: left;
            border: 1px solid var(--haf-border);
            position: relative;
        }

        .profile-header {
            display: flex; align-items: center; gap: 18px; margin-bottom: 18px;
        }

        .avatar-wrapper {
            position: relative;
            width: 90px; height: 90px; border-radius: 50%;
            padding: 3px;
            background-color: rgba(255, 123, 50, 0.16);
            border: 1px solid rgba(255, 123, 50, 0.35);
            display: flex; align-items: center; justify-content: center;
        }

        .avatar {
            width: 82px; height: 82px; border-radius: 50%;
            object-fit: cover; border: 2px solid #ffffff; background-color: #ffffff;
        }

        .profile-text { flex: 1; display: flex; flex-direction: column; gap: 4px; }

        .profile-title-row { display: flex; align-items: center; gap: 8px; }

        .profile-title-row h1 { margin: 0; font-size: 20px; font-weight: 700; color: var(--haf-text-main); }

        .profile-badge {
            font-size: 11px; padding: 3px 8px; border-radius: 999px;
            background-color: rgba(255, 123, 50, 0.08);
            color: var(--haf-primary-hover);
            border: 1px solid rgba(255, 123, 50, 0.5);
            display: inline-flex; align-items: center; gap: 4px;
        }

        .profile-badge i { font-size: 12px; }

        .profile-memberpoints { font-size: 13px; color: var(--haf-text-muted); margin-top: 4px; }

        .profile-divider { height: 1px; background-color: var(--haf-border); margin: 16px 0 12px; }

        .info-list { display: flex; flex-direction: column; gap: 10px; }

        .info-field {
            display: flex; align-items: center; justify-content: space-between; gap: 10px; padding: 8px 0;
        }

        .info-field + .info-field { border-top: 1px dashed var(--haf-border); }

        .info-label-wrapper { display: flex; align-items: center; gap: 8px; }

        .info-icon {
            width: 26px; height: 26px; border-radius: 999px;
            display: inline-flex; align-items: center; justify-content: center;
            font-size: 13px; color: var(--haf-primary); background-color: rgba(255, 123, 50, 0.1);
        }

        .info-label { font-weight: 600; font-size: 14px; color: var(--haf-text-main); }

        .info-value { font-size: 14px; color: #374151; text-align: right; max-width: 70%; word-break: break-word; }

        .info-value.muted { color: var(--haf-text-muted); }

        .actions { margin-top: 22px; display: flex; flex-direction: column; gap: 10px; }

        .aspNetButton {
            width: 60%; padding: 11px 16px; border: none; border-radius: 999px;
            background: linear-gradient(135deg, var(--haf-primary), var(--haf-primary-hover));
            color: #ffffff; font-size: 14px; font-weight: 600; cursor: pointer;
            box-shadow: 0 12px 20px rgba(255, 123, 50, 0.35);
            transition: transform 0.12s ease, box-shadow 0.16s ease, filter 0.18s ease;
            text-align: center; margin-left: auto; margin-right: auto;
        }

        .aspNetButton:hover:not(:disabled) {
            transform: translateY(-1px);
            box-shadow: 0 16px 26px rgba(255, 123, 50, 0.45);
            filter: brightness(1.02);
        }

        .aspNetButton + .aspNetButton {
            background: #ffffff; color: var(--haf-primary-hover);
            border: 1px solid rgba(255, 123, 50, 0.6);
            box-shadow: 0 8px 16px rgba(15, 23, 42, 0.06);
        }

        .aspNetButton + .aspNetButton:hover:not(:disabled) { background-color: #fef2e8; }

        @media (max-width: 575px) {
            body { padding: 16px 10px 24px; }
            .profile-container { padding: 18px 16px 20px; border-radius: 14px; }
            .avatar-wrapper { width: 78px; height: 78px; }
            .avatar { width: 70px; height: 70px; }
            .profile-title-row h1 { font-size: 18px; }
            .info-field { flex-direction: column; align-items: flex-start; }
            .info-value { max-width: 100%; text-align: left; }
            .actions { margin-top: 16px; }
        }
    </style>

    <% if (Request["embed"] == "1") { %>
    <style>
        html, body {
            background: #ffffff !important;
            background-image: none !important;
            min-height: auto !important;
            height: auto !important;
        }
    </style>
    <% } %>

</head>

<body>
    <form id="form1" runat="server">

        <div class="account-page my-3 px-3 px-md-4">
            <div class="account-page-header">
                <div class="title-badge">
                    <i class="fa-solid fa-user"></i>
                    HAFood - Hồ sơ tài khoản
                </div>
                <h2 class="page-title">Hồ sơ của tôi</h2>
            </div>

            <div class="profile-container">
                <div class="profile-header">
                    <div class="avatar-wrapper">
                        <asp:Image ID="imgAvatar" runat="server" CssClass="avatar" />
                    </div>
                    <div class="profile-text">
                        <div class="profile-title-row">
                            <h1>Thông tin cá nhân</h1>
                            <div class="profile-badge">
                                <i class="fa-solid fa-user-check"></i> Tài khoản HAFood
                            </div>
                        </div>

                        <div class="profile-memberpoints">
                            <asp:Label ID="lblMemberPoints" runat="server" />
                            <a href='<%= ResolveUrl("~/UserInfo/Loyalty.aspx") %>'
                               style="margin-left:8px;font-size:13px;color:#ff7b32;text-decoration:none;font-weight:600;">
                                Xem ưu đãi &amp; đổi điểm &rsaquo;
                            </a>
                        </div>

                    </div>
                </div>

                <div class="profile-divider"></div>

                <div class="info-list">
                    <div class="info-field">
                        <div class="info-label-wrapper">
                            <div class="info-icon"><i class="fa-regular fa-user"></i></div>
                            <span class="info-label">Họ và tên</span>
                        </div>
                        <span class="info-value"><asp:Label ID="lblFullName" runat="server" /></span>
                    </div>

                    <div class="info-field">
                        <div class="info-label-wrapper">
                            <div class="info-icon"><i class="fa-regular fa-envelope"></i></div>
                            <span class="info-label">Email</span>
                        </div>
                        <span class="info-value muted"><asp:Label ID="lblEmail" runat="server" /></span>
                    </div>

                    <div class="info-field">
                        <div class="info-label-wrapper">
                            <div class="info-icon"><i class="fa-solid fa-phone"></i></div>
                            <span class="info-label">Số điện thoại</span>
                        </div>
                        <span class="info-value"><asp:Label ID="lblPhone" runat="server" /></span>
                    </div>
                </div>

                <div class="actions">
                    <asp:Button ID="btnEdit" runat="server"
                                Text="Chỉnh sửa thông tin"
                                CssClass="aspNetButton"
                                OnClick="btnEdit_Click" />
                    <asp:Button ID="btnChangePassword" runat="server"
                                Text="Thay đổi mật khẩu"
                                CssClass="aspNetButton"
                                OnClick="btnChangePassword_Click" />
                </div>
            </div>
        </div>

    </form>

    <!-- ✅ Embed helper: rewrite link + auto height -->
    <script>
        (function () {
            var params = new URLSearchParams(location.search);
            var isEmbed = (params.get('embed') === '1') && window.parent && window.parent !== window;
            if (!isEmbed) return;

            function rewriteLinks() {
                try {
                    document.querySelectorAll('a[href]').forEach(function (a) {
                        var href = a.getAttribute('href'); if (!href) return;
                        if (href.startsWith('#') || href.startsWith('javascript:')) return;
                        var u = new URL(href, location.href);
                        if (u.origin !== location.origin) return;
                        u.searchParams.set('embed', '1');
                        a.setAttribute('href', u.pathname + u.search + u.hash);
                    });
                } catch { }
            }

            function getHeight() {
                var b = document.body, e = document.documentElement;
                var h = Math.max(
                    b ? b.scrollHeight : 0,
                    e ? e.scrollHeight : 0,
                    b ? b.offsetHeight : 0,
                    e ? e.offsetHeight : 0,
                    e ? Math.ceil(e.getBoundingClientRect().height) : 0
                );
                return h;
            }

            var raf = 0;
            function post() {
                cancelAnimationFrame(raf);
                raf = requestAnimationFrame(function () {
                    var h = getHeight();
                    if (!h || h < 350) h = 350;
                    window.parent.postMessage({ type: 'haf-embed-height', height: h }, '*');
                });
            }

            rewriteLinks();
            document.addEventListener('DOMContentLoaded', function () { post(); setTimeout(post, 200); });
            window.addEventListener('load', function () { post(); setTimeout(post, 200); });
            window.addEventListener('pageshow', function () { post(); });

            if (document.fonts && document.fonts.ready) {
                document.fonts.ready.then(function () { post(); });
            }

            if (typeof ResizeObserver !== 'undefined') {
                var ro = new ResizeObserver(function () { post(); });
                ro.observe(document.documentElement);
                if (document.body) ro.observe(document.body);
            }

            if (typeof MutationObserver !== 'undefined') {
                var mo = new MutationObserver(function () { post(); });
                mo.observe(document.documentElement, { subtree: true, childList: true, attributes: true, characterData: true });
            }

            window.addEventListener('message', function (ev) {
                if (ev && ev.data && ev.data.type === 'haf-embed-request') post();
            });
        })();
    </script>
</body>
</html>
