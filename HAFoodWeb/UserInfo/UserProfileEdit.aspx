<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="UserProfileEdit.aspx.cs" Inherits="HAFoodWeb.UserProfileEdit" Async="true" %>

<!DOCTYPE html>
<html lang="vi">
<head runat="server">
    <title>Chỉnh sửa thông tin cá nhân</title>

    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" />

    <style>
        :root {
            --haf-primary: #ff7b32;
            --haf-primary-hover: #e8631d;
            --haf-border: #e5e7eb;
            --haf-text-main: #111827;
            --haf-text-muted: #6b7280;
            --haf-error: #dc2626;
            --haf-success: #16a34a;
        }

        * { box-sizing: border-box; }

        /* ✅ NỀN TRẮNG THẬT - KHÔNG GRADIENT */
        html, body {
            margin: 0;
            padding: 0;
            background: #ffffff;
            color: var(--haf-text-main);
            font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
        }

        body { padding: 20px 10px 30px; }

        .account-page { width: 100%; max-width: 100%; margin: 0 auto; }
        .account-page-header { margin-bottom: 8px; }

        .page-title {
            font-weight: 700; font-size: 1.7rem; color: #212529; margin: 0.12rem 0 0;
        }
        .page-subtitle { font-size: .9rem; color: #6c757d; }

        .title-badge {
            font-size: .75rem; letter-spacing: .08em; text-transform: uppercase; font-weight: 700;
            color: #fd7e14; background: rgba(253, 126, 20, .08); padding: .26rem .7rem; border-radius: 999px;
            display: inline-flex; align-items: center; gap: .35rem; margin-bottom: 0;
        }
        .title-badge i { font-size: .9rem; }

        /* CARD EDIT */
        .edit-container {
            position: relative; max-width: 720px; margin: 0 auto; background-color: #ffffff;
            padding: 26px; border-radius: 18px; box-shadow: 0 12px 26px rgba(15, 23, 42, 0.14);
            border: 1px solid var(--haf-border); overflow: hidden;
        }
        .edit-header { display: flex; flex-direction: column; gap: 6px; text-align: center; margin-bottom: 16px; }
        .edit-container h2 { margin: 0; font-size: 20px; font-weight: 700; color: var(--haf-text-main); }

        .backButton {
            position: absolute; top: 14px; left: 14px; display: inline-flex; align-items: center; gap: 7px;
            padding: 7px 11px; border-radius: 999px; border: 1px solid var(--haf-border); background-color: #ffffff;
            color: var(--haf-text-muted); font-size: 13px; text-decoration: none; cursor: pointer;
            box-shadow: 0 6px 14px rgba(15, 23, 42, 0.15); transition: background-color .12s, color .12s, transform .08s, box-shadow .12s;
            z-index: 10;
        }
        .backButton i { font-size: 13px; }
        .backButton:hover { background-color: #f9fafb; color: var(--haf-text-main); transform: translateY(-1px); box-shadow: 0 10px 18px rgba(15,23,42,.2); }

        .avatar-preview-wrapper { display: flex; flex-direction: column; align-items: center; margin: 8px 0 14px; }
        .avatar-preview-ring {
            position: relative; width: 112px; height: 112px; border-radius: 50%; padding: 3px;
            background-color: rgba(255, 123, 50, 0.18); border: 1px solid rgba(255, 123, 50, 0.5);
            display: flex; align-items: center; justify-content: center;
        }
        .avatar-preview { display: block; width: 102px; height: 102px; border-radius: 50%; object-fit: cover; border: 2px solid #ffffff; background-color: #ffffff; }

        .form-grid { display: grid; grid-template-columns: 1.1fr 1.4fr; gap: 14px 20px; margin-top: 8px; }
        .form-grid-full { grid-column: 1 / -1; }

        .form-field { margin-bottom: 0; }
        .form-field label { display: block; font-weight: 600; margin-bottom: 5px; font-size: 13px; color: var(--haf-text-main); }

        .form-field input[type="text"],
        .form-field input[type="email"],
        .form-field input[type="file"]{
            width: 100%; padding: 9px 10px; border: 1px solid var(--haf-border); border-radius: 10px; box-sizing: border-box;
            font-size: 14px; outline: none; transition: border-color .15s ease, box-shadow .15s ease, background-color .15s ease; background-color: #ffffff;
        }
        .form-field input[type="file"] { padding: 5px 8px; font-size: 13px; }
        .form-field input[type="text"]:focus, .form-field input[type="email"]:focus {
            border-color: rgba(255, 123, 50, 0.7); box-shadow: 0 0 0 1px rgba(255, 123, 50, 0.45); background-color: #fff7ed;
        }
        .form-field input[disabled] { background-color: #f3f4f6; color: var(--haf-text-muted); }

        .field-error { color: var(--haf-error); font-size: 12px; margin-top: 6px; display: none; }

        .aspNetButton{
            width: 60%; max-width: 260px; padding: 11px 16px; margin-top: 16px; border: none; border-radius: 999px;
            background: linear-gradient(135deg, var(--haf-primary), var(--haf-primary-hover)); color: white; font-size: 14px; font-weight: 600;
            cursor: pointer; box-shadow: 0 14px 24px rgba(255, 123, 50, 0.35); transition: background-color .18s, transform .12s, box-shadow .16s;
            display: block; margin-left: auto; margin-right: auto; text-align: center; text-decoration: none; line-height: normal;
        }
        .aspNetButton:hover:not(:disabled){ background-color: var(--haf-primary-hover); transform: translateY(-1px); box-shadow: 0 18px 30px rgba(255,123,50,.45); }
        .aspNetButton:active:not(:disabled){ transform: translateY(0); box-shadow: 0 12px 22px rgba(255,123,50,.36); }

        /* Toast */
        .toast{
            position: fixed; top: 16px; right: 16px; background-color: var(--haf-success); color: #fff; padding: 8px 14px; border-radius: 999px;
            font-size: 13px; font-weight: 600; display: flex; align-items: center; gap: 7px; box-shadow: 0 10px 20px rgba(0,0,0,.22);
            opacity: 0; transform: translateY(-15px) translateX(10px); transition: all .35s ease; z-index: 99999; pointer-events: none;
        }
        .toast.show{ opacity: 1; transform: translateY(0) translateX(0); }
        .toast.success{ background-color: var(--haf-success); }
        .toast.error{ background-color: var(--haf-error); }
        .toast i{ font-size: 15px; }

        @media (max-width: 640px){
            body{ padding: 16px 10px 24px; }
            .edit-container{ padding: 18px 14px 20px; border-radius: 14px; }
            .edit-container h2{ font-size: 18px; }
            .form-grid{ grid-template-columns: 1fr; }
            .form-grid-full{ grid-column: auto; }
            .aspNetButton{ width: 100%; max-width: none; }
            .backButton{ top: 10px; left: 10px; }
        }
    </style>

    <%-- ✅ embed=1: nền trắng chắc chắn + auto height chuẩn --%>
    <% if ("1".Equals(Request["embed"])) { %>
      <style>
        html, body {
          background:#ffffff !important;
          background-image:none !important;
          background-color:#ffffff !important;
          overflow:visible !important;
          min-height:auto !important;
          height:auto !important;
        }
      </style>
    <% } %>
</head>

<body>
    <form id="form1" runat="server">

        <div class="account-page my-3 px-3 px-md-4">
            <div class="account-page-header">
                <div class="title-badge">
                    <i class="fa-solid fa-pen-to-square"></i>
                    HAFood - Chỉnh sửa hồ sơ
                </div>
                <h2 class="page-title">Chỉnh sửa thông tin</h2>
            </div>

            <div class="edit-container">
                <a id="btnBack" class="backButton" href="<%= ResolveUrl("~/UserInfo/UserProfile.aspx") %>" aria-label="Quay lại Hồ sơ của tôi">
                    <i class="fa-solid fa-arrow-left"></i>
                    <span>Quay lại</span>
                </a>

                <div class="edit-header">
                    <h2>Thông tin cá nhân</h2>
                </div>

                <div class="avatar-preview-wrapper">
                    <div class="avatar-preview-ring">
                        <asp:Image ID="imgAvatar" runat="server" CssClass="avatar-preview" />
                    </div>
                </div>

                <div class="form-grid">
                    <div class="form-field form-grid-full">
                        <label for="fileAvatar">Thay đổi ảnh đại diện</label>
                        <asp:FileUpload ID="fileAvatar" runat="server" />
                    </div>

                    <div class="form-field">
                        <label for="txtFullName">Họ và tên</label>
                        <asp:TextBox ID="txtFullName" runat="server" />
                        <div id="fullNameError" class="field-error">Thông báo lỗi tên</div>
                    </div>

                    <div class="form-field">
                        <label for="txtEmail">Email</label>
                        <asp:TextBox ID="txtEmail" runat="server" Enabled="false" />
                    </div>

                    <div class="form-field">
                        <label for="txtPhone">Số điện thoại</label>
                        <asp:TextBox ID="txtPhone" runat="server" MaxLength="10" />
                        <div id="phoneError" class="field-error">Thông báo lỗi số điện thoại</div>
                    </div>
                </div>

                <asp:Label ID="lblMessage" runat="server" EnableViewState="false"></asp:Label>

                <asp:Button ID="btnSave" runat="server" Text="Lưu thay đổi" CssClass="aspNetButton"
                            OnClick="btnSave_Click" OnClientClick="return validateForm();" />
            </div>
        </div>

        <div id="toast" class="toast">
            <i id="toastIcon" class="fa-solid fa-circle-check"></i>
            <span id="toastMessage"></span>
        </div>

        <script>
            var nameRegex = /^\p{L}[\p{L}\s]*$/u;
            var phoneRegex = /^0\d{9}$/;

            var fullNameInput = document.getElementById('<%= txtFullName.ClientID %>');
            var phoneInput = document.getElementById('<%= txtPhone.ClientID %>');
            var fullNameError = document.getElementById('fullNameError');
            var phoneError = document.getElementById('phoneError');
            var lblMessageClientId = '<%= lblMessage.ClientID %>';

            function validateFullName() {
                var val = fullNameInput.value.trim();
                if (!val) { fullNameError.innerText = '❌ Vui lòng nhập họ và tên.'; fullNameError.style.display = 'block'; return false; }
                try {
                    if (!nameRegex.test(val)) { fullNameError.innerText = '❌ Tên không được chứa ký tự đặc biệt hoặc số.'; fullNameError.style.display = 'block'; return false; }
                } catch (e) {
                    var fallback = /^[A-Za-zÀ-ỹ\s]+$/u;
                    if (!fallback.test(val)) { fullNameError.innerText = '❌ Tên không được chứa ký tự đặc biệt hoặc số.'; fullNameError.style.display = 'block'; return false; }
                }
                fullNameError.style.display = 'none'; return true;
            }

            function validatePhone() {
                var val = phoneInput.value.trim();
                if (!val) { phoneError.innerText = '❌ Vui lòng nhập số điện thoại.'; phoneError.style.display = 'block'; return false; }
                if (!phoneRegex.test(val)) { phoneError.innerText = '❌ Số điện thoại phải gồm 10 chữ số và bắt đầu bằng số 0.'; phoneError.style.display = 'block'; return false; }
                phoneError.style.display = 'none'; return true;
            }

            function validateForm() {
                var lbl = document.getElementById(lblMessageClientId);
                if (lbl) lbl.innerText = '';
                var okName = validateFullName();
                var okPhone = validatePhone();
                return okName && okPhone;
            }

            fullNameInput.addEventListener('input', function () {
                var lbl = document.getElementById(lblMessageClientId); if (lbl) lbl.innerText = '';
                validateFullName();
            });
            fullNameInput.addEventListener('blur', validateFullName);

            phoneInput.addEventListener('input', function () {
                var lbl = document.getElementById(lblMessageClientId); if (lbl) lbl.innerText = '';
                validatePhone();
            });
            phoneInput.addEventListener('blur', validatePhone);

            function showToast(message, type) {
                var toast = document.getElementById("toast");
                var toastMsg = document.getElementById("toastMessage");
                var toastIcon = document.getElementById("toastIcon");
                toast.classList.remove('success', 'error', 'show');
                if (type === 'success') { toast.classList.add('success'); toastIcon.className = 'fa-solid fa-circle-check'; }
                else { toast.classList.add('error'); toastIcon.className = 'fa-solid fa-triangle-exclamation'; }
                toastMsg.innerText = message; toast.classList.add("show");
                setTimeout(function () { toast.classList.remove("show"); }, 3000);
            }
        </script>

        <%-- ✅ embed=1: rewrite link nội bộ + auto-height + nghe request resize --%>
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
                    if (!d || d.type !== 'haf-embed-request') return;
                    measure();
                });

                document.addEventListener('DOMContentLoaded', function () { rewriteLinks(); setTimeout(measure, 0); });
                window.addEventListener('load', function () { rewriteLinks(); setTimeout(measure, 20); });
                if (document.fonts && document.fonts.ready) { document.fonts.ready.then(function () { setTimeout(measure, 20); }); }

                var ro = (typeof ResizeObserver !== 'undefined') ? new ResizeObserver(function () { measure(); }) : null;
                if (ro) { ro.observe(document.documentElement); ro.observe(document.body); }

                setTimeout(measure, 200); setTimeout(measure, 600); setTimeout(measure, 1200);
            })();
        </script>
    </form>
</body>
</html>
