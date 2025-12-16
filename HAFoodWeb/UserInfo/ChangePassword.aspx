<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ChangePassword.aspx.cs" Inherits="HAFoodWeb.UserInfo.ChangePassword" Async="true" %>

<!DOCTYPE html>
<html lang="vi">
<head runat="server">
    <title>Thay đổi mật khẩu</title>

    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" />

    <style>
        :root{
            --haf-primary:#ff7b32;
            --haf-border:#e5e7eb;
            --haf-text-main:#111827;
            --haf-text-muted:#6b7280;
            --haf-success:#16a34a;
            --haf-error:#dc2626;
        }

        *{ box-sizing:border-box; }

        html, body{
            margin:0;
            background:#ffffff;
            color:var(--haf-text-main);
            font-family:system-ui,-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif;
        }

        body{ padding:22px 14px 28px; }

        .account-page{ width:100%; max-width:980px; margin:0 auto; }

        .page-header{
            display:flex; align-items:flex-start; justify-content:space-between;
            gap:12px; margin-bottom:12px;
        }

        .btn-back{
            display:inline-flex; align-items:center; gap:.45rem;
            border-radius:999px; padding:.45rem 1rem;
            border:1px solid var(--haf-border);
            background:#f8f9fa;
            color:#495057; font-size:.9rem; font-weight:600;
            text-decoration:none; white-space:nowrap;
            transition:.12s ease;
        }
        .btn-back:hover{ background:#e9ecef; color:#212529; }

        .header-right{ text-align:right; }

        .title-badge{
            font-size:.75rem; letter-spacing:.08em; text-transform:uppercase; font-weight:700;
            color:#fd7e14; background:rgba(253,126,20,.08);
            padding:.26rem .7rem; border-radius:999px;
            display:inline-flex; align-items:center; gap:.4rem;
            margin-bottom:.3rem;
        }

        .page-title{
            margin:0;
            font-size:1.6rem;
            font-weight:700;
            color:#212529;
        }

        .page-sub{
            margin:.2rem 0 0;
            font-size:.92rem;
            color:var(--haf-text-muted);
        }

        .frame-card{
            background:#fff;
            border:none;
            border-radius:22px;
            box-shadow:0 16px 34px rgba(15, 23, 42, 0.10);
            padding:18px 18px 16px;
        }

        .form-grid{ max-width:520px; margin:6px auto 0; }
        .form-title{ text-align:center; font-weight:800; font-size:1.1rem; margin:2px 0 14px; }

        .form-group{ margin-bottom:12px; }
        label{ display:block; font-weight:700; margin-bottom:6px; font-size:13px; }

        .pw-input{
            width:100%;
            padding:10px 44px 10px 12px; /* chừa chỗ icon */
            border:1px solid var(--haf-border);
            border-radius:12px;
            outline:none;
            font-size:14px;
            transition:border-color .15s, box-shadow .15s, background-color .15s;
            background:#fff;
        }
        .pw-input:focus{
            border-color:rgba(255,123,50,.7);
            box-shadow:0 0 0 2px rgba(255,123,50,.18);
            background:#fff7ed;
        }

        .aspNetButton{
            display:block;
            width:100%;
            padding:12px 14px;
            border:none;
            border-radius:999px;
            background:linear-gradient(135deg, #ff7b32, #e8631d);
            color:#fff;
            font-weight:700;
            font-size:15px;
            cursor:pointer;
            box-shadow:0 14px 24px rgba(255,123,50,.28);
            transition:transform .12s ease, box-shadow .12s ease, filter .12s ease;
            margin-top:14px;
        }
        .aspNetButton:hover{ transform:translateY(-1px); box-shadow:0 18px 30px rgba(255,123,50,.35); }
        .aspNetButton:active{ transform:translateY(0); }

        .toast{
            position:fixed;
            top:16px; right:16px;
            min-width:260px; max-width:340px;
            padding:12px 14px;
            border-radius:14px;
            display:flex; align-items:center; gap:10px;
            box-shadow:0 10px 22px rgba(0,0,0,.18);
            opacity:0; visibility:hidden;
            transform:translateY(-14px);
            transition:.22s ease;
            z-index:9999;
            color:#fff;
            font-weight:500;
            font-size:14px;
        }
        .toast.show{ opacity:1; visibility:visible; transform:translateY(0); }
        .toast.success{ background:var(--haf-success); }
        .toast.error{ background:var(--haf-error); }
        .toast i{ font-size:18px; }

        /* ✅ Eye toggle */
        .pw-wrap{ position:relative; }
        .toggle-password{
            position:absolute;
            right:12px;
            top:50%;
            transform:translateY(-50%);
            border:none;
            background:transparent;
            padding:0;
            cursor:pointer;
            color:#6b7280;
            z-index:2;
        }
        .toggle-password:hover{ color: var(--haf-primary); }

        @media (max-width: 640px){
            body{ padding:16px 12px 22px; }
            .page-header{ flex-direction:column; align-items:stretch; }
            .header-right{ text-align:left; }
            .frame-card{ border-radius:18px; padding:14px; }
        }
    </style>

    <% if ("1".Equals(Request["embed"])) { %>
      <style>
        html, body{
          background:#ffffff !important;
          background-image:none !important;
          overflow:visible !important;
          min-height:auto !important;
          height:auto !important;
        }
      </style>
    <% } %>

    <script type="text/javascript">
        function showToast(message, type) {
            var toast = document.getElementById('toast');
            var icon = document.getElementById('toastIcon');
            var text = document.getElementById('toastMessage');
            if (!toast || !icon || !text) return;

            if (type === 'success') icon.className = 'fa-solid fa-circle-check';
            else if (type === 'error') icon.className = 'fa-solid fa-circle-xmark';
            else icon.className = 'fa-solid fa-circle-info';

            toast.classList.remove('success', 'error', 'show');
            toast.classList.add(type === 'success' ? 'success' : 'error');
            text.textContent = message || '';
            toast.classList.add('show');

            setTimeout(function(){ toast.classList.remove('show'); }, 3000);
        }

        function togglePassword(btn) {
            var targetId = btn.getAttribute('data-target');
            var input = document.getElementById(targetId);
            if (!input) return;

            var icon = btn.querySelector('i');
            var isHidden = (input.type === 'password');

            input.type = isHidden ? 'text' : 'password';
            if (icon) icon.className = isHidden ? 'fa-regular fa-eye-slash' : 'fa-regular fa-eye';
        }
    </script>
</head>

<body>
<form id="form1" runat="server">

    <div id="toast" class="toast">
        <i id="toastIcon" class="fa-solid"></i>
        <span id="toastMessage"></span>
    </div>

    <div class="account-page">

        <div class="page-header">
            <a class="btn-back" href="<%= ResolveUrl("~/UserInfo/UserProfile.aspx") %>">
                <i class="fa-solid fa-arrow-left"></i> Quay lại
            </a>

            <div class="header-right">
                <div class="title-badge">
                    <i class="fa-solid fa-shield-halved"></i>
                    HAFood - Bảo mật tài khoản
                </div>
                <h1 class="page-title">Thay đổi mật khẩu</h1>
                <p class="page-sub">Cập nhật mật khẩu để bảo vệ tài khoản của bạn.</p>
            </div>
        </div>

        <div class="frame-card">
            <div class="form-grid">
                <div class="form-title">Thông tin mật khẩu</div>

                <div class="form-group">
                    <label for="txtOldPassword">Mật khẩu cũ</label>
                    <div class="pw-wrap">
                        <asp:TextBox ID="txtOldPassword" runat="server" TextMode="Password" CssClass="pw-input" />
                        <button type="button" class="toggle-password"
                            data-target="<%= txtOldPassword.ClientID %>"
                            onclick="togglePassword(this)"
                            aria-label="Hiện/ẩn mật khẩu">
                            <i class="fa-regular fa-eye"></i>
                        </button>
                    </div>
                </div>

                <div class="form-group">
                    <label for="txtNewPassword">Mật khẩu mới</label>
                    <div class="pw-wrap">
                        <asp:TextBox ID="txtNewPassword" runat="server" TextMode="Password" CssClass="pw-input" />
                        <button type="button" class="toggle-password"
                            data-target="<%= txtNewPassword.ClientID %>"
                            onclick="togglePassword(this)"
                            aria-label="Hiện/ẩn mật khẩu">
                            <i class="fa-regular fa-eye"></i>
                        </button>
                    </div>
                </div>

                <asp:Button ID="btnSubmit" runat="server" Text="Xác nhận thay đổi"
                    CssClass="aspNetButton" OnClick="btnSubmit_Click" />
            </div>
        </div>

    </div>

</form>

<script>
    (function () {
        var isEmbed = /[?&]embed=1\b/.test(location.search) && window.parent && window.parent !== window;
        if (!isEmbed) return;

        function rewriteLinks() {
            try {
                document.querySelectorAll('a[href]').forEach(function (a) {
                    var href = a.getAttribute('href'); if (!href) return;
                    if (href.startsWith('#') || href.startsWith('javascript:') || href.startsWith('mailto:') || href.startsWith('tel:')) return;
                    var u = new URL(href, location.href);
                    if (u.origin !== location.origin) return;
                    u.searchParams.set('embed', '1');
                    a.setAttribute('href', u.pathname + u.search + u.hash);
                });
            } catch { }
        }

        function measure() {
            try {
                var d = document, b = d.body, e = d.documentElement;
                var h = Math.max(b.scrollHeight || 0, e.scrollHeight || 0, b.offsetHeight || 0, e.offsetHeight || 0);
                if (!h || h < 420) h = 420;
                window.parent.postMessage({ type: 'haf-embed-height', height: h }, '*');
            } catch (_) { }
        }

        window.addEventListener('message', function (ev) {
            var d = ev.data;
            if (d && d.type === 'haf-embed-request') measure();
        });

        document.addEventListener('DOMContentLoaded', function () { rewriteLinks(); setTimeout(measure, 0); });
        window.addEventListener('load', function () { rewriteLinks(); setTimeout(measure, 20); });
        if (document.fonts && document.fonts.ready) { document.fonts.ready.then(function () { setTimeout(measure, 20); }); }

        var ro = (typeof ResizeObserver !== 'undefined') ? new ResizeObserver(function () { measure(); }) : null;
        if (ro) { ro.observe(document.documentElement); ro.observe(document.body); }

        setTimeout(measure, 200); setTimeout(measure, 600); setTimeout(measure, 1200);
    })();
</script>

</body>
</html>
