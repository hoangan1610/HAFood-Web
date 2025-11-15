<%@ Page Language="C#" AutoEventWireup="true"     CodeBehind="CreateUserAddress.aspx.cs"     Inherits="HAFoodWeb.UserAddress.CreateUserAddress" Async="true" %>

<!DOCTYPE html>
<html lang="vi">
<head runat="server">
    <meta charset="utf-8" />
    <title>Địa chỉ mới</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />

    <!-- Bootstrap + Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet" />

    <style>
        :root{
            --accent:#ff7a45;
            --border:#e5e7eb;
            --menu:#fff;
            --shadow:0 10px 25px rgba(0,0,0,.08);
        }

        body{
            font-family:'Segoe UI',system-ui,-apple-system,BlinkMacSystemFont,sans-serif;
            margin:0;
            background:radial-gradient(circle at top left,#ffe8cc 0,#f8f9fa 40%,#e9ecef 100%);
            min-height:100vh;
        }

        .page-header{
            width:100%;
            max-width:100% !important;
            margin:24px 0 8px !important;
            padding:0 24px !important;
            background:transparent;
            box-shadow:none;
        }

        .title-badge{
            font-size:.75rem;
            letter-spacing:.08em;
            text-transform:uppercase;
            font-weight:700;
            color:#fd7e14;
            background:rgba(253,126,20,.08);
            padding:.26rem .7rem;
            border-radius:999px;
            display:inline-flex;
            align-items:center;
            gap:.35rem;
            margin-bottom:.25rem;
        }
        .title-badge i{ font-size:.9rem; }
        .page-title{ font-weight:700; font-size:1.6rem; color:#212529; margin:0 0 .15rem; }
        .page-subtitle{ font-size:.9rem; color:#6c757d; margin:0; }

        .page-shell{
            max-width:720px;
            margin:0 auto 2.5rem;
            background:#fff;
            border-radius:1.25rem;
            box-shadow:0 .75rem 1.8rem rgba(15,23,42,.14);
            padding:1.4rem 1.6rem 1.7rem;
        }

        .page-anim{ opacity:0; transform:translateY(6px); transition:opacity .18s ease, transform .18s ease; }
        .page-anim.ready{ opacity:1; transform:none; }

        .btn-back{
            display:inline-flex; align-items:center; gap:.35rem;
            border-radius:999px; padding:.45rem 1rem;
            border:1px solid #dee2e6; background:#f8f9fa;
            color:#495057; font-size:.88rem; font-weight:500; text-decoration:none; white-space:nowrap;
        }
        .btn-back:hover{ background:#e9ecef; color:#212529; text-decoration:none; }

        .section-card{ border-radius:12px; border:1px solid #e9ecef; background:#fff; margin-bottom:1rem; }
        .section-card .card-body{ padding:1.1rem 1.1rem 1rem; }
        .section-title{ font-weight:600; font-size:.96rem; }

        .rbl-chips input[type="radio"]{ position:absolute; opacity:0; width:0; height:0; }
        .rbl-chips label{
            display:inline-block; cursor:pointer; padding:.5rem .9rem; margin-right:.5rem; margin-bottom:.5rem;
            border-radius:9999px; border:1px solid var(--border); background:#f6f6f6; color:#222; font-weight:500; line-height:1; font-size:.9rem;
        }
        .rbl-chips input[type="radio"]:checked + label{
            background:rgba(255,122,69,.08); border-color:var(--accent); color:var(--accent);
            box-shadow:0 0 0 2px rgba(255,122,69,.15) inset;
        }

        .combo{ position:relative; }
        .combo .combo-input{
            width:100%; height:38px; border:1px solid var(--border); border-radius:.375rem;
            padding:.375rem 2rem .375rem .75rem; background:#fff; font-size:.95rem;
        }
        .combo .combo-input[disabled]{ background:#f5f5f5; cursor:not-allowed; }
        .combo .combo-caret{
            position:absolute; right:.35rem; top:50%; transform:translateY(-50%);
            width:28px; height:28px; border:1px solid transparent; background:transparent; border-radius:6px; cursor:pointer;
        }
        .combo .combo-caret:after{ content:"▾"; font-size:14px; color:#6b7280; }
        .combo .combo-menu{
            position:absolute; left:0; right:0; top:calc(100% + 4px);
            background:var(--menu); border:1px solid var(--border); border-radius:.5rem; box-shadow:var(--shadow);
            z-index:1000; display:none; max-height:330px; overflow:auto;
        }
        .combo.open .combo-menu{ display:block; }
        .combo .combo-item{
            padding:.45rem .75rem; cursor:pointer; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;
            font-size:.94rem;
        }
        .combo .combo-item:hover, .combo .combo-item.active{ background:#f1f5f9; }

        /* Toast */
        .toast-stack{ position:fixed; right:16px; top:16px; z-index:2300; display:flex; flex-direction:column; gap:10px; align-items:flex-end; }
        .toast{
          min-width:unset; width:fit-content; max-width:min(92vw, 560px);
          display:inline-flex; align-items:flex-start; gap:10px;
          border-radius:14px; padding:12px 14px; box-shadow:0 8px 20px rgba(0,0,0,.12);
          border:1px solid var(--border); background:#fff; color:#111; font-weight:600; font-size:15.5px; line-height:1.35;
          opacity:0; transform:translateY(-8px); transition:opacity .18s ease, transform .18s ease;
        }
        .toast.show{ opacity:1; transform:translateY(0); }
        .toast-icon{ flex:0 0 auto; }
        .toast-text{
            display:inline-block;
            white-space:pre-line; /* 🔧 Cho phép xuống dòng khi gộp nhiều lỗi */
            overflow-wrap:anywhere;
        }
        .toast-success{ background:#22c55e !important; border-color:#16a34a !important; color:#fff !important; }
        .toast-success .toast-icon{ color:#fff !important; }
        .toast-error{ background:#ef4444 !important; border-color:#dc2626 !important; color:#fff !important; }
        .toast-error .toast-icon{ color:#fff !important; }

        @media (max-width: 575.98px){
            .page-header{ margin:12px 0 8px !important; padding:0 16px !important; }
        }
    </style>

    <%-- Ẩn nút "Quay lại danh sách" khi chạy embed trong popup --%>
    <% if ("1".Equals(Request["embed"])) { %>
      <style>
        a[href$="UserAddressList.aspx"]{display:none!important}
        body{background:#fafafa}
      </style>
    <% } %>
</head>
<body>
<form id="form1" runat="server">

    <div class="page-header">
        <div class="title-badge"><i class="bi bi-geo-alt"></i> HAFood - Địa chỉ giao hàng</div>
        <h2 class="page-title">Địa chỉ mới</h2>
        <p class="page-subtitle">Thêm địa chỉ nhận hàng để thanh toán nhanh hơn.</p>
    </div>

    <div class="page-shell page-anim">
        <div class="d-flex justify-content-end mb-2">
            <a href="UserAddressList.aspx" class="btn-back"><i class="bi bi-arrow-left-short"></i> Danh sách địa chỉ</a>
        </div>

        <!-- hidden mirrors -->
        <asp:TextBox ID="txtCitySel" runat="server" CssClass="d-none" />
        <asp:TextBox ID="txtWardSel" runat="server" CssClass="d-none" />
        <asp:TextBox ID="txtCityCode" runat="server" CssClass="d-none" />
        <asp:TextBox ID="txtWardCode" runat="server" CssClass="d-none" />

        <div class="card border-0 section-card">
            <div class="card-body">
                <div class="section-title mb-3">Địa chỉ</div>

                <div class="mb-3">
                    <label class="form-label">Họ và tên <span class="text-danger">*</span></label>
                    <asp:TextBox ID="txtFullName" runat="server" CssClass="form-control" ClientIDMode="Static" />
                </div>

                <div class="mb-3">
                    <label class="form-label">Số điện thoại <span class="text-danger">*</span></label>
                    <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control" ClientIDMode="Static" />
                </div>

                <div class="row g-3">
                    <div class="col-md-6">
                        <label class="form-label">Tỉnh/Thành <span class="text-danger">*</span></label>
                        <div class="combo" id="comboCity">
                            <input id="inpCityV3" type="text" class="combo-input" placeholder="Nhập chữ để tìm Tỉnh/Thành" autocomplete="off"/>
                            <button type="button" class="combo-caret" tabindex="-1"></button>
                            <div class="combo-menu" id="menuCity"></div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Xã/Phường <span class="text-danger">*</span></label>
                        <div class="combo" id="comboWard">
                            <input id="inpWardV3" type="text" class="combo-input" placeholder="Nhập chữ để tìm Xã/Phường" autocomplete="off" disabled/>
                            <button type="button" class="combo-caret" tabindex="-1"></button>
                            <div class="combo-menu" id="menuWard"></div>
                        </div>
                    </div>
                </div>

                <div class="mb-1 mt-3">
                    <label class="form-label">Địa chỉ nhận hàng <span class="text-danger">*</span></label>
                    <asp:TextBox ID="txtAddress" runat="server" CssClass="form-control" placeholder="VD: 12 Quang Trung, hẻm 5, tầng 2" ClientIDMode="Static" />
                </div>
            </div>
        </div>

        <div class="card border-0 section-card">
            <div class="card-body">
                <div class="d-flex justify-content-between align-items-center mb-2">
                    <div class="section-title">Đặt làm địa chỉ mặc định</div>
                    <div class="form-check form-switch m-0">
                        <input id="swDefault" runat="server" type="checkbox" class="form-check-input" role="switch" ClientIDMode="Static" />
                    </div>
                </div>
                <hr class="my-3" />
                <div class="section-title mb-2">Loại địa chỉ</div>
                <asp:RadioButtonList ID="rblType" runat="server" RepeatLayout="Flow" RepeatDirection="Horizontal" CssClass="rbl-chips" ClientIDMode="Static">
                    <asp:ListItem Text="Văn Phòng" Value="1" />
                    <asp:ListItem Text="Nhà Riêng"  Value="0" />
                </asp:RadioButtonList>
            </div>
        </div>

        <!-- Actions -->
        <div class="mt-3 d-flex align-items-center">
            <div class="d-flex align-items-center gap-2">
                <asp:Button ID="btnSave" runat="server" Text="Hoàn thành" CssClass="btn btn-success"
                    OnClientClick="return validateCreate();" OnClick="btnSave_Click" />
            </div>
            <button type="button" id="btnCancelCreate" class="btn btn-danger text-white ms-auto">Hủy</button>
        </div>
    </div>

    <div class="toast-stack" id="toastStack" aria-live="polite"></div>
</form>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<script>
    document.addEventListener('DOMContentLoaded', function () {
        document.querySelector('.page-shell')?.classList.add('ready');
        document.querySelector('.page-anim')?.classList.add('ready');
    });

    document.getElementById('btnCancelCreate')?.addEventListener('click', function () {
        if (history.length > 1) history.back();
        else window.location.href = '/UserAddress/UserAddressList.aspx';
    });

    function showToast(message, variant) {
        var stack = document.getElementById('toastStack'); if (!stack) return;
        var div = document.createElement('div');
        div.className = 'toast ' + (variant === 'success' ? 'toast-success' : (variant === 'danger' ? 'toast-error' : ''));
        div.setAttribute('role', 'alert');
        var icon = document.createElement('i');
        icon.className = 'bi ' + (variant === 'success' ? 'bi-check-circle-fill' : 'bi-exclamation-triangle-fill') + ' toast-icon';
        var text = document.createElement('span');
        text.className = 'toast-text';
        text.textContent = message || '';
        div.appendChild(icon); div.appendChild(text); stack.appendChild(div);
        div.offsetHeight; div.classList.add('show');
        var close = function () { div.classList.remove('show'); setTimeout(function () { div.remove(); }, 180); };
        var timer = setTimeout(close, 3500);
        div.addEventListener('click', function () { clearTimeout(timer); close(); });
    }

    function validateCreate() {
        var missing = [];
        if (!document.getElementById('txtFullName').value.trim()) missing.push('Họ và tên');
        if (!document.getElementById('txtPhone').value.trim()) missing.push('Số điện thoại');
        var cityCode = document.getElementById('<%= txtCityCode.ClientID %>').value.trim();
        var wardCode = document.getElementById('<%= txtWardCode.ClientID %>').value.trim();
        if (!cityCode) missing.push('Tỉnh/Thành (chọn từ danh sách)');
        if (!wardCode) missing.push('Phường/Xã (chọn từ danh sách)');
        if (!document.getElementById('txtAddress').value.trim()) missing.push('Địa chỉ nhận hàng');
        if (!document.querySelector('#rblType input[type=radio]:checked')) missing.push('Loại địa chỉ');
        if (missing.length) { showToast('Vui lòng điền: ' + missing.join(', '), 'danger'); return false; }

        // ====== Kiểm tra ĐỊNH DẠNG (gồm nhiều lỗi sẽ gộp) ======
        var errs = [];

        // Họ tên: chỉ chữ + khoảng trắng
        var fullName = document.getElementById('txtFullName').value.trim();
        var reName = /^[\p{L}\s]+$/u;
        if (!reName.test(fullName)) {
            errs.push('Họ và tên không được chứa ký tự đặc biệt');
        }

        // SĐT: đúng 10 chữ số
        var phone = document.getElementById('txtPhone').value.trim();
        if (!/^\d{10}$/.test(phone)) {
            errs.push('Số điện thoại phải gồm đúng 10 chữ số');
        }
        // SĐT: bắt đầu bằng 0
        if (!/^0/.test(phone)) {
            errs.push('Số điện thoại phải bắt đầu bằng số 0');
        }

        // Địa chỉ: chỉ cho phép chữ, số, khoảng trắng và , . - /
        var address = document.getElementById('txtAddress').value.trim();
        var reAddress = /^[\p{L}\d\s,.\-\/]+$/u;
        if (!reAddress.test(address)) {
            errs.push('Địa chỉ nhận hàng không được chứa ký tự đặc biệt');
        }

        if (errs.length) {
            showToast('Vui lòng kiểm tra:\n• ' + errs.join('\n• '), 'danger');
            return false;
        }
        // ==========================================
        return true;
    }
</script>

<!-- Searchable dropdown logic (giữ nguyên chức năng) -->
<script>
    (function () {
        const DATA_BASE = '<%= ResolveClientUrl("~/assets/vn-admin") %>';

        const cityInput = document.getElementById('inpCityV3');
        const cityMenu  = document.getElementById('menuCity');
        const cityCombo = document.getElementById('comboCity');

        const wardInput = document.getElementById('inpWardV3');
        const wardMenu  = document.getElementById('menuWard');
        const wardCombo = document.getElementById('comboWard');

        const hidCityName = document.getElementById('<%= txtCitySel.ClientID %>');
        const hidWardName = document.getElementById('<%= txtWardSel.ClientID %>');
        const hidCityCode = document.getElementById('<%= txtCityCode.ClientID %>');
        const hidWardCode = document.getElementById('<%= txtWardCode.ClientID %>');

        let PROVINCES = [];
        let WARDS = [];
        let activeIndexCity = -1;
        let activeIndexWard = -1;

        const rm = s => (s || '').normalize('NFD').replace(/[\u0300-\u036f]/g, '')
            .replace(/đ/g, 'd').replace(/Đ/g, 'D').replace(/\s+/g, ' ').trim().toLowerCase();

        function openCombo(combo) { combo.classList.add('open'); }
        function closeCombo(combo) { combo.classList.remove('open'); }
        function setCityHidden(name, code) { hidCityName.value = name || ''; hidCityCode.value = code || ''; }
        function setWardHidden(name, code) { hidWardName.value = name || ''; hidWardCode.value = code || ''; }

        function renderList(menu, arr, q, activeIndex) {
            const f = rm(q);
            menu.innerHTML = '';
            arr.forEach((x, i) => {
                if (!f || rm(x.name).includes(f)) {
                    const div = document.createElement('div');
                    div.className = 'combo-item' + (i === activeIndex ? ' active' : '');
                    div.textContent = x.name;
                    div.dataset.code = String(x.code);
                    menu.appendChild(div);
                }
            });
        }

        async function loadProvinces() {
            const resp = await fetch(`${DATA_BASE}/provinces.json`, { cache: 'force-cache' });
            PROVINCES = await resp.json();
            renderList(cityMenu, PROVINCES, cityInput.value, -1);
        }

        async function loadWards(cityCode) {
            WARDS = [];
            wardInput.value = '';
            setWardHidden('', '');
            wardInput.disabled = !cityCode;
            wardMenu.innerHTML = '';
            if (!cityCode) return;
            const resp = await fetch(`${DATA_BASE}/wards/${encodeURIComponent(cityCode)}.json`, { cache: 'force-cache' });
            if (!resp.ok) return;
            WARDS = await resp.json();
            renderList(wardMenu, WARDS, wardInput.value, -1);
        }

        cityInput.addEventListener('focus', () => {
            renderList(cityMenu, PROVINCES, cityInput.value, activeIndexCity = -1);
            openCombo(cityCombo);
        });
        cityInput.addEventListener('input', () => {
            setCityHidden('', '');
            renderList(cityMenu, PROVINCES, cityInput.value, activeIndexCity = -1);
            openCombo(cityCombo);
        });
        cityCombo.querySelector('.combo-caret').addEventListener('click', () => {
            if (cityCombo.classList.contains('open')) closeCombo(cityCombo);
            else { renderList(cityMenu, PROVINCES, cityInput.value, activeIndexCity = -1); openCombo(cityCombo); }
        });
        cityMenu.addEventListener('click', async (e) => {
            const item = e.target.closest('.combo-item'); if (!item) return;
            cityInput.value = item.textContent.trim();
            setCityHidden(item.textContent.trim(), item.dataset.code);
            closeCombo(cityCombo);
            await loadWards(item.dataset.code);
        });
        cityInput.addEventListener('keydown', async (e) => {
            const items = Array.from(cityMenu.querySelectorAll('.combo-item'));
            if (!items.length) return;
            if (e.key === 'ArrowDown') { e.preventDefault(); activeIndexCity = Math.min(activeIndexCity + 1, items.length - 1); }
            else if (e.key === 'ArrowUp') { e.preventDefault(); activeIndexCity = Math.max(activeIndexCity - 1, 0); }
            else if (e.key === 'Enter') { e.preventDefault(); items[activeIndexCity >= 0 ? activeIndexCity : 0].click(); }
            else if (e.key === 'Escape') { closeCombo(cityCombo); }
            items.forEach(x => x.classList.remove('active'));
            if (items[activeIndexCity]) {
                items[activeIndexCity].classList.add('active');
                items[activeIndexCity].scrollIntoView({ block: 'nearest' });
            }
        });
        cityInput.addEventListener('blur', () => {
            const text = cityInput.value.trim();
            const hit = PROVINCES.find(p => rm(p.name) === rm(text));
            if (hit) { setCityHidden(hit.name, String(hit.code)); } else { setCityHidden('', ''); wardInput.disabled = true; }
            setTimeout(() => closeCombo(cityCombo), 150);
        });

        wardInput.addEventListener('focus', () => {
            if (!wardInput.disabled) { renderList(wardMenu, WARDS, wardInput.value, activeIndexWard = -1); openCombo(wardCombo); }
        });
        wardInput.addEventListener('input', () => {
            setWardHidden('', '');
            if (!wardInput.disabled) { renderList(wardMenu, WARDS, wardInput.value, activeIndexWard = -1); openCombo(wardCombo); }
        });
        wardCombo.querySelector('.combo-caret').addEventListener('click', () => {
            if (wardInput.disabled) return;
            if (wardCombo.classList.contains('open')) closeCombo(wardCombo);
            else { renderList(wardMenu, WARDS, wardInput.value, activeIndexWard = -1); openCombo(wardCombo); }
        });
        wardMenu.addEventListener('click', (e) => {
            const item = e.target.closest('.combo-item'); if (!item) return;
            wardInput.value = item.textContent.trim();
            setWardHidden(item.textContent.trim(), item.dataset.code);
            closeCombo(wardCombo);
        });
        wardInput.addEventListener('keydown', (e) => {
            const items = Array.from(wardMenu.querySelectorAll('.combo-item'));
            if (!items.length) return;
            if (e.key === 'ArrowDown') { e.preventDefault(); activeIndexWard = Math.min(activeIndexWard + 1, items.length - 1); }
            else if (e.key === 'ArrowUp') { e.preventDefault(); activeIndexWard = Math.max(activeIndexWard - 1, 0); }
            else if (e.key === 'Enter') { e.preventDefault(); items[activeIndexWard >= 0 ? activeIndexWard : 0].click(); }
            else if (e.key === 'Escape') { closeCombo(wardCombo); }
            items.forEach(x => x.classList.remove('active'));
            if (items[activeIndexWard]) {
                items[activeIndexWard].classList.add('active');
                items[activeIndexWard].scrollIntoView({ block: 'nearest' });
            }
        });
        wardInput.addEventListener('blur', () => {
            const text = wardInput.value.trim();
            const hit = WARDS.find(w => rm(w.name) === rm(text));
            if (hit) { setWardHidden(hit.name, String(hit.code)); } else { setWardHidden('', ''); }
            setTimeout(() => closeCombo(wardCombo), 150);
        });

        document.addEventListener('mousedown', (e) => {
            if (!cityCombo.contains(e.target)) closeCombo(cityCombo);
            if (!wardCombo.contains(e.target)) closeCombo(wardCombo);
        });

        document.addEventListener('DOMContentLoaded', async () => {
            await loadProvinces();
            wardInput.disabled = true;
        });
    })();
</script>
</body>
</html>
