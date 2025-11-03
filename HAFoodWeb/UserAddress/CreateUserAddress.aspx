<%@ Page Language="C#" AutoEventWireup="true"
    CodeBehind="CreateUserAddress.aspx.cs"
    Inherits="HAFoodWeb.UserAddress.CreateUserAddress" Async="true" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <meta charset="utf-8" />
    <title>Địa chỉ mới</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <style>
        :root{ --accent:#ff7a45; --border:#e5e7eb; --menu:#fff; --shadow:0 10px 25px rgba(0,0,0,.08); }
        body{font-family:'Poppins',system-ui,Arial,sans-serif}
        .section-card{ border-radius:12px; }
        .section-title{ font-weight:600; }

        /* ==== Searchable Select (Combo) ==== */
        .combo{ position:relative; }
        .combo .combo-input{
            width:100%; height:38px; border:1px solid var(--border); border-radius:.375rem;
            padding:.375rem 2rem .375rem .75rem; background:#fff;
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
            z-index:1000; display:none; max-height:330px; overflow:auto;  /* ~10 dòng, có cuộn */
        }
        .combo.open .combo-menu{ display:block; }
        .combo .combo-item{
            padding:.45rem .75rem; cursor:pointer; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;
        }
        .combo .combo-item:hover, .combo .combo-item.active{ background:#f1f5f9; }
        .rbl-chips input[type="radio"]{ position:absolute; opacity:0; width:0; height:0; }
        .rbl-chips label{
            display:inline-block; cursor:pointer; padding:.5rem .9rem; margin-right:.5rem; margin-bottom:.5rem;
            border-radius:9999px; border:1px solid var(--border); background:#f6f6f6; color:#222; font-weight:500; line-height:1;
        }
        .rbl-chips input[type="radio"]:checked + label{
            background:rgba(255,122,69,.08); border-color:var(--accent); color:var(--accent);
            box-shadow:0 0 0 2px rgba(255,122,69,.15) inset;
        }
    </style>
</head>
<body>
<form id="form1" runat="server">
    <div class="container py-4" style="max-width:720px;">
        <a href="UserAddressList.aspx" class="btn btn-outline-secondary mb-2">&larr; Quay lại danh sách</a>
        <h4 class="mb-3">Địa chỉ mới</h4>

        <!-- hidden mirrors (tên + code đã chọn) -->
        <asp:TextBox ID="txtCitySel" runat="server" CssClass="d-none" />
        <asp:TextBox ID="txtWardSel" runat="server" CssClass="d-none" />
        <asp:TextBox ID="txtCityCode" runat="server" CssClass="d-none" />
        <asp:TextBox ID="txtWardCode" runat="server" CssClass="d-none" />

        <div class="card shadow-sm border-0 mb-3 section-card">
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

        <div class="card shadow-sm border-0 mb-3 section-card">
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
                    <asp:ListItem Text="Văn Phòng" Value="1" Selected="True" />
                    <asp:ListItem Text="Nhà Riêng"  Value="0" />
                </asp:RadioButtonList>
            </div>
        </div>

        <div class="mt-3">
            <asp:Button ID="btnSave" runat="server" Text="Hoàn thành" CssClass="btn btn-success"
                OnClientClick="return validateCreate();" OnClick="btnSave_Click" />
        </div>
    </div>

    <!-- Toast -->
    <div class="position-fixed top-0 end-0 p-3" style="z-index:1080">
        <div id="appToast" class="toast align-items-center text-white bg-danger border-0" role="alert" aria-live="assertive" aria-atomic="true">
            <div class="d-flex">
                <div id="toastBody" class="toast-body">...</div>
                <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Đóng"></button>
            </div>
        </div>
    </div>
</form>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function showToast(message, variant) {
        var toastEl = document.getElementById('appToast');
        var bodyEl = document.getElementById('toastBody');
        bodyEl.textContent = message;
        toastEl.classList.remove('bg-danger', 'bg-success', 'bg-warning', 'bg-info');
        toastEl.classList.add('bg-' + (variant || 'danger'));
        new bootstrap.Toast(toastEl).show();
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
        return true;
    }
</script>

<!-- Searchable dropdown logic -->
<script>
    (function () {
        const DATA_BASE = '<%= ResolveClientUrl("~/assets/vn-admin") %>';

    const cityInput = document.getElementById('inpCityV3');
    const cityMenu = document.getElementById('menuCity');
    const cityCombo = document.getElementById('comboCity');

    const wardInput = document.getElementById('inpWardV3');
    const wardMenu = document.getElementById('menuWard');
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

        // City events
        cityInput.addEventListener('focus', () => { renderList(cityMenu, PROVINCES, cityInput.value, activeIndexCity = -1); openCombo(cityCombo); });
        cityInput.addEventListener('input', () => { setCityHidden('', ''); renderList(cityMenu, PROVINCES, cityInput.value, activeIndexCity = -1); openCombo(cityCombo); });
        cityCombo.querySelector('.combo-caret').addEventListener('click', () => {
            if (cityCombo.classList.contains('open')) closeCombo(cityCombo); else { renderList(cityMenu, PROVINCES, cityInput.value, activeIndexCity = -1); openCombo(cityCombo); }
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
            if (e.key === 'ArrowDown') { e.preventDefault(); activeIndexCity = Math.min(activeIndexCity + 1, items.length - 1); items.forEach(x => x.classList.remove('active')); items[activeIndexCity].classList.add('active'); items[activeIndexCity].scrollIntoView({ block: 'nearest' }); }
            else if (e.key === 'ArrowUp') { e.preventDefault(); activeIndexCity = Math.max(activeIndexCity - 1, 0); items.forEach(x => x.classList.remove('active')); items[activeIndexCity].classList.add('active'); items[activeIndexCity].scrollIntoView({ block: 'nearest' }); }
            else if (e.key === 'Enter') { e.preventDefault(); items[activeIndexCity >= 0 ? activeIndexCity : 0].click(); }
            else if (e.key === 'Escape') { closeCombo(cityCombo); }
        });
        cityInput.addEventListener('blur', () => {
            // nếu text không khớp lựa chọn => xoá code
            const text = cityInput.value.trim();
            const hit = PROVINCES.find(p => rm(p.name) === rm(text));
            if (hit) { setCityHidden(hit.name, String(hit.code)); } else { setCityHidden('', ''); wardInput.disabled = true; }
            setTimeout(() => closeCombo(cityCombo), 150);
        });

        // Ward events
        wardInput.addEventListener('focus', () => { if (!wardInput.disabled) { renderList(wardMenu, WARDS, wardInput.value, activeIndexWard = -1); openCombo(wardCombo); } });
        wardInput.addEventListener('input', () => { setWardHidden('', ''); if (!wardInput.disabled) { renderList(wardMenu, WARDS, wardInput.value, activeIndexWard = -1); openCombo(wardCombo); } });
        wardCombo.querySelector('.combo-caret').addEventListener('click', () => {
            if (wardInput.disabled) return;
            if (wardCombo.classList.contains('open')) closeCombo(wardCombo); else { renderList(wardMenu, WARDS, wardInput.value, activeIndexWard = -1); openCombo(wardCombo); }
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
            if (e.key === 'ArrowDown') { e.preventDefault(); activeIndexWard = Math.min(activeIndexWard + 1, items.length - 1); items.forEach(x => x.classList.remove('active')); items[activeIndexWard].classList.add('active'); items[activeIndexWard].scrollIntoView({ block: 'nearest' }); }
            else if (e.key === 'ArrowUp') { e.preventDefault(); activeIndexWard = Math.max(activeIndexWard - 1, 0); items.forEach(x => x.classList.remove('active')); items[activeIndexWard].classList.add('active'); items[activeIndexWard].scrollIntoView({ block: 'nearest' }); }
            else if (e.key === 'Enter') { e.preventDefault(); items[activeIndexWard >= 0 ? activeIndexWard : 0].click(); }
            else if (e.key === 'Escape') { closeCombo(wardCombo); }
        });
        wardInput.addEventListener('blur', () => {
            const text = wardInput.value.trim();
            const hit = WARDS.find(w => rm(w.name) === rm(text));
            if (hit) { setWardHidden(hit.name, String(hit.code)); } else { setWardHidden('', ''); }
            setTimeout(() => closeCombo(wardCombo), 150);
        });

        // outside click close
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
