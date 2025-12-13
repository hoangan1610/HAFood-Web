<%@ Page Language="C#" AutoEventWireup="true"
    CodeBehind="UserAddressList.aspx.cs"
    Inherits="HAFoodWeb.UserAddress.UserAddressList" Async="true" %>

<!DOCTYPE html>
<html lang="vi">
<head runat="server">
    <meta charset="utf-8" />
    <title>Địa chỉ của tôi</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet" />

    <style>
        :root{ --accent:#ff7a45; --border:#e5e7eb; --muted:#6b7280; }

        /* Khóa tràn ngang + bẻ chuỗi dài */
        html, body { width:100%; max-width:100%; overflow-x:hidden; }
        body{ word-break:break-word; overflow-wrap:anywhere; }

        body{
            font-family:'Segoe UI',system-ui,-apple-system,BlinkMacSystemFont,sans-serif;
            margin:0;
            min-height:100%;
            background:#ffffff; /* <-- NỀN TRẮNG */
        }

        .page-header{
            width:100%;
            max-width:100% !important;
            margin:16px 0 4px !important;
            padding:0 16px !important;
            background:transparent;
            box-shadow:none;
        }
        body { overflow-x: hidden; }

        .wrap{
            max-width:900px;
            margin:0 auto 20px;
            padding:0 16px 16px;
            width:100%;
            overflow-x:hidden;
        }
        .wrap-inner{
            background:#fff;
            border-radius:1.25rem;
            box-shadow:0 16px 34px rgba(15, 23, 42, 0.12);
            padding:1.1rem 1.25rem 1.3rem;
            max-width:100%;
            overflow-x:hidden;
        }
        .topbar{ display:flex; align-items:flex-start; gap:10px; padding:4px 0 12px; }

        .title-badge{
            font-size:.75rem; letter-spacing:.08em; text-transform:uppercase; font-weight:700;
            color:#fd7e14; background:rgba(253,126,20,.08); padding:.26rem .7rem; border-radius:999px;
            display:inline-flex; align-items:center; gap:.35rem; margin-bottom:.25rem;
        }
        .title-badge i{ font-size:.9rem; }
        .page-title{ font-weight:700; font-size:1.6rem; color:#212529; margin:0 0 .2rem; }

        .card{background:#fff;border-radius:12px;box-shadow:0 4px 10px rgba(0,0,0,.05);padding:12px}
        .addr-item{display:grid;grid-template-columns:1fr auto;gap:10px;padding:12px;border-bottom:1px solid #f0f0f0}
        .addr-item:last-child{border-bottom:none}
        .addr-name{font-weight:700}
        .addr-sep{color:#9ca3af;margin:0 6px}
        .addr-phone{color:#6b7280}
        .addr-detail{color:#374151;margin-top:4px}
        .badge-default{
            display:inline-flex;align-items:center;gap:.25rem;margin-top:8px;
            background:rgba(255,122,69,.08);color:var(--accent);border:1px solid var(--accent);
            border-radius:999px;padding:2px 8px;font-size:12px
        }
        .badge-default i{font-size:.85rem;}

        .btn{
            height:36px;min-width:120px;border:1px solid var(--border);border-radius:10px;padding:0 14px;
            font-weight:700;cursor:pointer;background:#f2f3f5;color:#111;text-decoration:none;
            display:inline-flex;align-items:center;justify-content:center;text-align:center
        }
        .btn-primary{background:var(--accent);border-color:var(--accent);color:#fff}
        .btn-ghost{background:#fff}
        .btn + .btn{margin-left:8px}

        .list-actions{display:flex;align-items:center;gap:8px}
        .empty{
            padding:20px;text-align:center;color:#6b7280;margin-top:12px;background:#fff;
            border-radius:12px;box-shadow:0 4px 10px rgba(0,0,0,.05)
        }
        .add-new{margin-left:auto;text-decoration:none}
        .add-new .btn{min-width:180px}

        .small-meta{ color:#6b7280; margin-top:4px; font-size:12.5px; }

        .toast-stack{ position:fixed; right:16px; top:16px; z-index:2300; display:flex; flex-direction:column; gap:10px; align-items:flex-end; }
        .toast{
          min-width:unset; width:fit-content; max-width:min(92vw, 560px);
          display:inline-flex; align-items:flex-start; gap:10px;
          border-radius:14px; padding:12px 14px; box-shadow:0 8px 20px rgba(0,0,0,.12);
          border:1px solid var(--border); background:#fff; color:#111; font-weight:600; font-size:15.5px; line-height:1.35;
          opacity:0; transform:translateY(-8px); transition:opacity .18s ease, transform .18s ease;
        }
        .toast.show{ opacity:1; transform:translateY(0); }
        .toast-icon{ flex:0 0 auto; font-size:1.1rem; margin-top:2px; }
        .toast-text{ display:inline-block; white-space:normal; overflow-wrap:anywhere; }
        .toast-success{ background:#22c55e !important; border-color:#16a34a !important; color:#fff !important; }
        .toast-success .toast-icon{ color:#fff !important; }
        .toast-error{ background:#ef4444 !important; border-color:#dc2626 !important; color:#fff !important; }
        .toast-error .toast-icon{ color:#fff !important; }

        /* PHÂN TRANG – tránh tràn ngang */
        .paging {
            display:flex; justify-content:center; align-items:center; gap:0.5rem;
            margin-top:1.0rem; overflow:hidden; width:100%;
        }
        .paging .btn{ min-width:40px; border-radius:999px; font-size:.86rem; }
        .paging .btn-warning{ border-radius:999px; font-weight:700; }
        .paging .btn-outline-secondary{ background:rgba(255,255,255,.85); }

        @media (max-width: 575.98px){
            .page-header{ margin:12px 0 6px !important; padding:0 16px !important; }
        }
    </style>

    <% if ("1".Equals(Request["embed"])) { %>
      <style>
        html, body{
          background:#ffffff !important;
          background-image:none !important;
          min-height:auto !important;
          height:auto !important;
          overflow:visible !important;
        }
      </style>
    <% } %>
</head>
<body>
<form id="form1" runat="server">

    <div class="page-header">
        <div class="title-badge">
            <i class="bi bi-geo-alt"></i>
            HAFood - Địa chỉ giao hàng
        </div>
        <h2 class="page-title">Địa chỉ của tôi</h2>
    </div>

    <div class="wrap">
        <div class="wrap-inner">
            <div class="topbar">
                <a href="CreateUserAddress.aspx" class="add-new">
                    <span class="btn btn-primary">
                        <i class="bi bi-plus-circle" style="margin-right:6px"></i>Thêm địa chỉ mới
                    </span>
                </a>
            </div>

            <asp:PlaceHolder ID="phEmpty" runat="server" Visible="false">
                <div class="card empty">Người dùng chưa có địa chỉ.</div>
            </asp:PlaceHolder>

            <asp:Panel ID="pnlList" runat="server">
                <div class="card">
                    <asp:Repeater ID="rptAddresses" runat="server" OnItemCommand="rptAddresses_ItemCommand">
                        <ItemTemplate>
                            <div class="addr-item">
                                <div>
                                    <div>
                                        <span class="addr-name"><%# Eval("fullName") %></span>
                                        <span class="addr-sep">|</span>
                                        <span class="addr-phone"><%# Eval("phone") %></span>
                                    </div>
                                    <div class="addr-detail"><%# Eval("fullAddress") %></div>
                                    <div class="small-meta">
                                        Loại:
                                        <%# (Eval("type") != null && Eval("type").ToString() == "1") ? "Văn phòng" : "Nhà riêng" %>
                                        <%# string.IsNullOrEmpty((string)Eval("label")) ? "" : " • " + Eval("label") %>
                                    </div>
                                    <asp:PlaceHolder ID="phDefault" runat="server" Visible='<%# Eval("isDefault") != null && (bool)Eval("isDefault") %>'>
                                        <span class="badge-default">
                                            <i class="bi bi-star-fill"></i>
                                            Mặc định
                                        </span>
                                    </asp:PlaceHolder>
                                </div>

                                <div class="list-actions">
                                    <a class="btn btn-ghost" href='<%# "UpdateUserAddress.aspx?id=" + Eval("id") %>'>Chỉnh sửa</a>
                                    <asp:LinkButton ID="btnSetDefault" runat="server"
                                        CssClass="btn"
                                        CommandName="setDefault"
                                        CommandArgument='<%# Eval("id") %>' Visible='<%# !(bool)Eval("isDefault") %>'>
                                        Đặt mặc định
                                    </asp:LinkButton>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>

                <!-- Phân trang -->
                <asp:Panel ID="pnlPagination" runat="server" CssClass="paging" Visible="false">
                    <asp:Button ID="btnPrev" runat="server"
                        CssClass="btn btn-outline-secondary btn-sm"
                        Text="← Trước" OnClick="btnPrev_Click" />
                    <asp:Repeater ID="rpPaging" runat="server" OnItemCommand="rpPaging_ItemCommand">
                        <ItemTemplate>
                            <asp:LinkButton ID="lnkPage" runat="server"
                                CssClass='<%# (int)Container.DataItem == CurrentPage ? "btn btn-sm btn-warning mx-1" : "btn btn-sm btn-outline-secondary mx-1" %>'
                                CommandName="ChangePage"
                                CommandArgument='<%# Container.DataItem %>'
                                Text='<%# Container.DataItem %>'>
                            </asp:LinkButton>
                        </ItemTemplate>
                    </asp:Repeater>
                    <asp:Button ID="btnNext" runat="server"
                        CssClass="btn btn-outline-secondary btn-sm"
                        Text="Sau →" OnClick="btnNext_Click" />
                </asp:Panel>
            </asp:Panel>

        </div>
    </div>

    <div class="toast-stack" id="toastStack" aria-live="polite"></div>
</form>

<script>
    function showToast(message, variant) {
        var stack = document.getElementById('toastStack'); if (!stack) return;
        var div = document.createElement('div');
        div.className = 'toast ' + (variant === 'success' ? 'toast-success' : (variant === 'danger' ? 'toast-error' : ''));
        div.setAttribute('role', 'alert');
        var icon = document.createElement('i');
        icon.className = 'bi ' + (variant === 'success' ? 'bi-check-circle-fill' : 'bi-exclamation-triangle-fill') + ' toast-icon';
        var text = document.createElement('span'); text.className = 'toast-text'; text.textContent = message || '';
        div.appendChild(icon); div.appendChild(text); stack.appendChild(div);
        div.offsetHeight; div.classList.add('show');
        var close = function () { div.classList.remove('show'); setTimeout(function () { div.remove(); }, 180); };
        var timer = setTimeout(close, 3000);
        div.addEventListener('click', function () { clearTimeout(timer); close(); });
    }

    (function () {
        var params = new URLSearchParams(location.search);
        var t = (params.get('toast') || '').toLowerCase();
        if (t) {
            var msg = t === 'created' ? 'Tạo địa chỉ thành công!'
                : t === 'updated' ? 'Cập nhật địa chỉ thành công!'
                    : t === 'deleted' ? 'Đã xóa địa chỉ' : null;
            if (msg) showToast(msg, 'success');
            params.delete('toast'); params.delete('ts');
            var clean = location.pathname + (params.toString() ? '?' + params.toString() : '');
            history.replaceState({}, '', clean);
        }
    })();
</script>

<!-- Dọn text-node rơi ra DOM -->
<script>
    (function () {
        try {
            var nodes = Array.from(document.body.childNodes);
            nodes.forEach(function (n) {
                if (n.nodeType === 3 && /ResizeObserver|ro\.observe|measure\(\)/.test(n.nodeValue || '')) {
                    n.remove();
                }
            });
        } catch (e) { }
    })();
</script>

<!-- ✅ embed=1: rewrite link + auto-height (robust) -->
<script>
    (function () {
        var isEmbed = /[?&]embed=1\b/.test(location.search) && window.parent && window.parent !== window;
        var params = new URLSearchParams(location.search);
        var TARGET = params.get('parentOrigin') || '*';

        // 1) rewrite tất cả link nội bộ -> luôn kèm embed=1
        if (isEmbed) {
            try {
                document.querySelectorAll('a[href]').forEach(function (a) {
                    var href = a.getAttribute('href'); if (!href) return;
                    if (href.startsWith('#') || href.startsWith('javascript:')) return;
                    var u = new URL(href, location.href);
                    if (u.origin !== location.origin) return;
                    u.searchParams.set('embed', '1');
                    a.setAttribute('href', u.pathname + u.search + u.hash);
                });
            } catch (e) { }
        }

        // 2) auto-height báo về parent
        if (!isEmbed) return;

        function measure() {
            try {
                var d = document, b = d.body, e = d.documentElement;
                var h = Math.max(
                    b.scrollHeight || 0, e.scrollHeight || 0,
                    b.offsetHeight || 0, e.offsetHeight || 0,
                    b.clientHeight || 0, e.clientHeight || 0
                );
                if (!h || h < 350) h = 350;
                window.parent.postMessage({ type: 'haf-embed-height', height: h }, TARGET);
            } catch (_) { }
        }

        function rafMeasure() { try { requestAnimationFrame(measure); } catch { measure(); } }

        document.addEventListener('DOMContentLoaded', function () { setTimeout(rafMeasure, 0); });
        window.addEventListener('load', function () { setTimeout(rafMeasure, 20); });
        if (document.fonts && document.fonts.ready) { document.fonts.ready.then(function () { setTimeout(rafMeasure, 20); }); }

        var ro = (typeof ResizeObserver !== 'undefined') ? new ResizeObserver(function () { rafMeasure(); }) : null;
        if (ro) { ro.observe(document.documentElement); ro.observe(document.body); }

        var mo = (typeof MutationObserver !== 'undefined') ? new MutationObserver(function () { rafMeasure(); }) : null;
        if (mo) { mo.observe(document.body, { childList: true, subtree: true, attributes: true, characterData: true }); }

        setTimeout(rafMeasure, 200);
        setTimeout(rafMeasure, 600);
        setTimeout(rafMeasure, 1200);
    })();
</script>

</body>
</html>
