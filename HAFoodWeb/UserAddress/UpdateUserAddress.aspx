<%@ Page Language="C#" AutoEventWireup="true"
    CodeBehind="UpdateUserAddress.aspx.cs"
    Inherits="HAFoodWeb.UserAddress.UpdateUserAddress" Async="true" %>

<!DOCTYPE html>
<html lang="vi">
<head runat="server">
    <meta charset="utf-8" />
    <title>Sửa địa chỉ</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <style>
        :root{ --accent:#ff7a45; --border:#e5e7eb; --menu:#fff; --shadow:0 10px 25px rgba(0,0,0,.08); }
        .section-card{ border-radius:12px; }
        .section-title{ font-weight:600; }
        .rbl-chips input[type="radio"]{ position:absolute; opacity:0; width:0; height:0; }
        .rbl-chips label{
            display:inline-block; cursor:pointer; padding:.5rem .9rem; margin-right:.5rem; margin-bottom:.5rem;
            border-radius:9999px; border:1px solid var(--border); background:#f6f6f6; color:#222; font-weight:500; line-height:1;
        }
        .rbl-chips input[type="radio"]:checked + label{
            background:rgba(255,122,69,.08); border-color:var(--accent); color:var(--accent);
            box-shadow:0 0 0 2px rgba(255,122,69,.15) inset;
        }
        /* combo */
        .combo{ position:relative; }
        .combo .combo-input{ width:100%; height:38px; border:1px solid var(--border); border-radius:.375rem; padding:.375rem 2rem .375rem .75rem; background:#fff; }
        .combo .combo-input[disabled]{ background:#f5f5f5; cursor:not-allowed; }
        .combo .combo-caret{ position:absolute; right:.35rem; top:50%; transform:translateY(-50%); width:28px; height:28px; border:1px solid transparent; background:transparent; border-radius:6px; cursor:pointer; }
        .combo .combo-caret:after{ content:"▾"; font-size:14px; color:#6b7280; }
        .combo .combo-menu{ position:absolute; left:0; right:0; top:calc(100% + 4px); background:#fff; border:1px solid var(--border); border-radius:.5rem; box-shadow:var(--shadow); z-index:1000; display:none; max-height:330px; overflow:auto; }
        .combo.open .combo-menu{ display:block; }
        .combo .combo-item{ padding:.45rem .75rem; cursor:pointer; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
        .combo .combo-item:hover, .combo .combo-item.active{ background:#f1f5f9; }
    </style>
</head>
<body>
<form id="form1" runat="server">
    <div class="container py-4" style="max-width:720px;">
        <a href="UserAddressList.aspx" class="btn btn-outline-secondary mb-2 text-decoration-none d-inline-flex align-items-center justify-content-center" style="height:40px;border-radius:10px;">&larr; Quay lại danh sách</a>
        <h4 class="mb-3">Sửa địa chỉ</h4>

        <asp:HiddenField ID="hfId" runat="server" />

        <!-- hidden mirrors -->
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
                        <div class="combo" id="comboCityU">
                            <input id="inpCityU" type="text" class="combo-input" placeholder="Gõ để tìm Tỉnh/Thành" autocomplete="off"/>
                            <button type="button" class="combo-caret" tabindex="-1"></button>
                            <div class="combo-menu" id="menuCityU"></div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Xã/Phường <span class="text-danger">*</span></label>
                        <div class="combo" id="comboWardU">
                            <input id="inpWardU" type="text" class="combo-input" placeholder="Chọn sau khi chọn Tỉnh/Thành" autocomplete="off" disabled/>
                            <button type="button" class="combo-caret" tabindex="-1"></button>
                            <div class="combo-menu" id="menuWardU"></div>
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
                    <asp:ListItem Text="Văn Phòng" Value="1" />
                    <asp:ListItem Text="Nhà Riêng"  Value="0" />
                </asp:RadioButtonList>
            </div>
        </div>

        <div class="mt-3 d-flex justify-content-between align-items-center">
            <asp:Button ID="btnSave" runat="server" Text="Hoàn thành" CssClass="btn btn-success"
                OnClientClick="return validateUpdate();" OnClick="btnSave_Click" />
            <div>
                <button type="button" class="btn btn-danger text-white" data-bs-toggle="modal" data-bs-target="#confirmDeleteModal">Xóa địa chỉ</button>
                <asp:Button ID="btnDelete" runat="server" CssClass="d-none" UseSubmitBehavior="false" OnClick="btnDelete_Click" />
            </div>
        </div>
    </div>

    <!-- Modal xóa -->
    <div class="modal fade" id="confirmDeleteModal" tabindex="-1" aria-labelledby="confirmDeleteLabel" aria-hidden="true">
      <div class="modal-dialog modal-dialog-centered"><div class="modal-content">
        <div class="modal-header"><h5 class="modal-title" id="confirmDeleteLabel">Xóa địa chỉ?</h5><button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Đóng"></button></div>
        <div class="modal-body">Bạn có chắc chắn muốn xóa địa chỉ này? Thao tác không thể hoàn tác.</div>
        <div class="modal-footer"><button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
          <button type="button" class="btn btn-danger" onclick="document.getElementById('<%= btnDelete.ClientID %>').click();">Xóa</button></div>
      </div></div>
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
    function validateUpdate() {
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

<!-- Searchable dropdown logic (prefill từ server) -->
<script>
    (function () {
        const DATA_BASE = '<%= ResolveClientUrl("~/assets/vn-admin") %>';

    const cityInput = document.getElementById('inpCityU');
    const cityMenu  = document.getElementById('menuCityU');
    const cityCombo = document.getElementById('comboCityU');

    const wardInput = document.getElementById('inpWardU');
    const wardMenu  = document.getElementById('menuWardU');
    const wardCombo = document.getElementById('comboWardU');

    const hidCityName = document.getElementById('<%= txtCitySel.ClientID %>');
    const hidWardName = document.getElementById('<%= txtWardSel.ClientID %>');
    const hidCityCode = document.getElementById('<%= txtCityCode.ClientID %>');
    const hidWardCode = document.getElementById('<%= txtWardCode.ClientID %>');

        let PROVINCES = [];
        let WARDS = [];
        let activeIndexCity = -1, activeIndexWard = -1;

        const rm = s => (s || '').normalize('NFD').replace(/[\u0300-\u036f]/g, '').replace(/đ/g, 'd').replace(/Đ/g, 'D').replace(/\s+/g, ' ').trim().toLowerCase();
        // Loại tiền tố thông dụng: Phường/Xã/Thị trấn/P./X./TT.
        const baseName = s => rm(String(s || '').replace(/^(phường|xã|thị trấn|p\.|x\.|tt\.)\s*/i, ''));

        function openC(c) { c.classList.add('open'); }
        function closeC(c) { c.classList.remove('open'); }
        function setCityHidden(n, c) { hidCityName.value = n || ''; hidCityCode.value = c || ''; }
        function setWardHidden(n, c) { hidWardName.value = n || ''; hidWardCode.value = c || ''; }
        function render(menu, arr, q, idx) {
            const f = rm(q); menu.innerHTML = '';
            arr.forEach((x, i) => {
                if (!f || rm(x.name).includes(f)) {
                    const d = document.createElement('div');
                    d.className = 'combo-item' + (i === idx ? ' active' : '');
                    d.textContent = x.name;
                    d.dataset.code = String(x.code);
                    menu.appendChild(d);
                }
            });
        }

        async function loadProvinces() {
            const resp = await fetch(`${DATA_BASE}/provinces.json`, { cache: 'force-cache' });
            PROVINCES = await resp.json();
            render(cityMenu, PROVINCES, cityInput.value, -1);

            // map tên city -> chọn sẵn
            const cityName = hidCityName.value.trim();
            if (cityName) {
                const hit = PROVINCES.find(p => rm(p.name) === rm(cityName));
                if (hit) {
                    cityInput.value = hit.name; setCityHidden(hit.name, String(hit.code));
                    await loadWards(String(hit.code));

                    // map ward theo tên (nếu chưa có code)
                    const wardName = hidWardName.value.trim();
                    if (wardName) {
                        const w = WARDS.find(x => baseName(x.name) === baseName(wardName));
                        if (w) { wardInput.value = w.name; setWardHidden(w.name, String(w.code)); }
                    }
                }
            } else {
                wardInput.disabled = true;
            }
        }

        async function loadWards(cityCode) {
            WARDS = []; wardMenu.innerHTML = ''; wardInput.value = ''; setWardHidden('', '');
            wardInput.disabled = !cityCode; if (!cityCode) return;
            const resp = await fetch(`${DATA_BASE}/wards/${encodeURIComponent(cityCode)}.json`, { cache: 'force-cache' });
            if (!resp.ok) return;
            WARDS = await resp.json();
            render(wardMenu, WARDS, wardInput.value, -1);
        }

        // City events
        cityInput.addEventListener('focus', () => { render(cityMenu, PROVINCES, cityInput.value, activeIndexCity = -1); openC(cityCombo); });
        cityInput.addEventListener('input', () => { setCityHidden('', ''); render(cityMenu, PROVINCES, cityInput.value, activeIndexCity = -1); openC(cityCombo); });
        cityCombo.querySelector('.combo-caret').addEventListener('click', () => { cityCombo.classList.contains('open') ? closeC(cityCombo) : (render(cityMenu, PROVINCES, cityInput.value, activeIndexCity = -1), openC(cityCombo)); });
        cityMenu.addEventListener('click', async (e) => {
            const it = e.target.closest('.combo-item'); if (!it) return;
            cityInput.value = it.textContent.trim(); setCityHidden(it.textContent.trim(), it.dataset.code);
            closeC(cityCombo); await loadWards(it.dataset.code);
        });
        cityInput.addEventListener('keydown', async (e) => {
            const items = Array.from(cityMenu.querySelectorAll('.combo-item')); if (!items.length) return;
            if (e.key === 'ArrowDown') { e.preventDefault(); activeIndexCity = Math.min(activeIndexCity + 1, items.length - 1); items.forEach(x => x.classList.remove('active')); items[activeIndexCity].classList.add('active'); items[activeIndexCity].scrollIntoView({ block: 'nearest' }); }
            else if (e.key === 'ArrowUp') { e.preventDefault(); activeIndexCity = Math.max(activeIndexCity - 1, 0); items.forEach(x => x.classList.remove('active')); items[activeIndexCity].classList.add('active'); items[activeIndexCity].scrollIntoView({ block: 'nearest' }); }
            else if (e.key === 'Enter') { e.preventDefault(); items[activeIndexCity >= 0 ? activeIndexCity : 0].click(); }
            else if (e.key === 'Escape') { closeC(cityCombo); }
        });
        cityInput.addEventListener('blur', () => {
            const text = cityInput.value.trim(); const hit = PROVINCES.find(p => rm(p.name) === rm(text));
            if (hit) { setCityHidden(hit.name, String(hit.code)); } else { setCityHidden('', ''); wardInput.disabled = true; }
            setTimeout(() => closeC(cityCombo), 150);
        });

        // Ward events
        wardInput.addEventListener('focus', () => { if (!wardInput.disabled) { render(wardMenu, WARDS, wardInput.value, activeIndexWard = -1); openC(wardCombo); } });
        wardInput.addEventListener('input', () => { setWardHidden('', ''); if (!wardInput.disabled) { render(wardMenu, WARDS, wardInput.value, activeIndexWard = -1); openC(wardCombo); } });
        wardCombo.querySelector('.combo-caret').addEventListener('click', () => { if (wardInput.disabled) return; wardCombo.classList.contains('open') ? closeC(wardCombo) : (render(wardMenu, WARDS, wardInput.value, activeIndexWard = -1), openC(wardCombo)); });
        wardMenu.addEventListener('click', (e) => { const it = e.target.closest('.combo-item'); if (!it) return; wardInput.value = it.textContent.trim(); setWardHidden(it.textContent.trim(), it.dataset.code); closeC(wardCombo); });
        wardInput.addEventListener('keydown', (e) => {
            const items = Array.from(wardMenu.querySelectorAll('.combo-item')); if (!items.length) return;
            if (e.key === 'ArrowDown') { e.preventDefault(); activeIndexWard = Math.min(activeIndexWard + 1, items.length - 1); items.forEach(x => x.classList.remove('active')); items[activeIndexWard].classList.add('active'); items[activeIndexWard].scrollIntoView({ block: 'nearest' }); }
            else if (e.key === 'ArrowUp') { e.preventDefault(); activeIndexWard = Math.max(activeIndexWard - 1, 0); items.forEach(x => x.classList.remove('active')); items[activeIndexWard].classList.add('active'); items[activeIndexWard].scrollIntoView({ block: 'nearest' }); }
            else if (e.key === 'Enter') { e.preventDefault(); items[activeIndexWard >= 0 ? activeIndexWard : 0].click(); }
            else if (e.key === 'Escape') { closeC(wardCombo); }
        });
        wardInput.addEventListener('blur', () => {
            const text = wardInput.value.trim();
            const hit = WARDS.find(w => baseName(w.name) === baseName(text));
            if (hit) { setWardHidden(hit.name, String(hit.code)); } else { setWardHidden('', ''); }
            setTimeout(() => closeC(wardCombo), 150);
        });

        document.addEventListener('mousedown', (e) => { if (!cityCombo.contains(e.target)) closeC(cityCombo); if (!wardCombo.contains(e.target)) closeC(wardCombo); });

        document.addEventListener('DOMContentLoaded', loadProvinces);
    })();
</script>
</body>
</html>
