<%@ Page Language="C#" AutoEventWireup="true"
    CodeBehind="UpdateUserAddress.aspx.cs"
    Inherits="HAFoodWeb.UserAddress.UpdateUserAddress" Async="true" %>

<!DOCTYPE html>
<html lang="vi">
<head runat="server">
    <meta charset="utf-8" />
    <title>Sửa địa chỉ</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet" />
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

        /* Combo searchable (builder sẽ render vào container) */
        .combo{position:relative}
        .combo-input{display:flex;align-items:center;height:38px;border:1px solid var(--border);border-radius:.375rem;background:#fff;padding:0 .75rem;cursor:text}
        .combo-text{flex:1 1 auto;border:none;outline:none;height:100%;font:inherit}
        .combo-caret{margin-left:8px}
        .combo-menu{position:absolute;left:0;right:0;top:calc(100% + 4px);background:#fff;border:1px solid var(--border);
                    border-radius:.5rem;box-shadow:var(--shadow);max-height:330px;overflow:auto;display:none;z-index:1000}
        .combo.open .combo-menu{display:block}
        .combo-item{padding:.45rem .75rem;cursor:pointer;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
        .combo-item:hover{background:#f1f5f9}

        /* ===== Toast (xanh lá) ===== */
        .toast-stack{
          position:fixed; right:16px; top:16px; z-index:2300;
          display:flex; flex-direction:column; gap:10px;
          align-items:flex-end;              
        }

        .toast{
          min-width:unset;                   
          width:fit-content;                 
          max-width:min(92vw, 560px);        

          display:inline-flex;               
          align-items:flex-start; gap:10px;

          border-radius:14px;
          padding:12px 14px;
          box-shadow:0 8px 20px rgba(0,0,0,.12);
          border:1px solid var(--border);
          background:#fff; color:#111; font-weight:600;
          font-size:15.5px; line-height:1.35;

          opacity:0; transform:translateY(-8px);
          transition:opacity .18s ease, transform .18s ease;
        }

        .toast.show{ opacity:1; transform:translateY(0); }

        .toast-icon{ flex:0 0 auto; }
        .toast-text{
          display:inline-block;
          white-space:normal;                
          overflow-wrap:anywhere;            
        }

        .toast-success{
          background:#22c55e !important;
          border-color:#16a34a !important;
          color:#fff !important;
        }
        .toast-success .toast-icon{ color:#fff !important; }

        .toast-error{
          background:#ef4444 !important;
          border-color:#dc2626 !important;
          color:#fff !important;
        }
        .toast-error .toast-icon{ color:#fff !important; }

    </style>
</head>
<body>
<form id="form1" runat="server">
    <div class="container py-4" style="max-width:720px;">
        <a href="UserAddressList.aspx"
           class="btn btn-outline-secondary mb-2 text-decoration-none d-inline-flex align-items-center justify-content-center"
           style="height:40px;border-radius:10px;">&larr; Quay lại danh sách</a>
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
                        <div id="comboCityU" class="combo"></div>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Xã/Phường <span class="text-danger">*</span></label>
                        <div id="comboWardU" class="combo"></div>
                    </div>
                </div>

                <div class="mb-1 mt-3">
                    <label class="form-label">Địa chỉ nhận hàng <span class="text-danger">*</span></label>
                    <asp:TextBox ID="txtAddress" runat="server" CssClass="form-control"
                                 placeholder="VD: 12 Quang Trung, hẻm 5, tầng 2" ClientIDMode="Static" />
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

    <!-- Toast Stack -->
    <div class="toast-stack" id="toastStack" aria-live="polite"></div>
</form>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
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
        var timer = setTimeout(close, 3000);
        div.addEventListener('click', function () { clearTimeout(timer); close(); });
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

<!-- Combo Searchable + fuzzy-restore City/Ward -->
<script>
    (function () {
        const DATA_BASE = '<%= ResolveClientUrl("~/assets/vn-admin") %>';

        const cityBox = document.getElementById('comboCityU');
        const wardBox = document.getElementById('comboWardU');

        const hidCityName = document.getElementById('<%= txtCitySel.ClientID %>');
        const hidWardName = document.getElementById('<%= txtWardSel.ClientID %>');
        const hidCityCode = document.getElementById('<%= txtCityCode.ClientID %>');
        const hidWardCode = document.getElementById('<%= txtWardCode.ClientID %>');

        const rm = (s) => (s || '').normalize('NFD').replace(/[\u0300-\u036f]/g, '')
            .replace(/đ/g, 'd').replace(/Đ/g, 'D')
            .replace(/\s+/g, ' ').trim().toLowerCase();

        const baseCity = s => rm(String(s || '').replace(/^(tinh|thanh pho|tp\.?|tp)\s*/i, ''));
        const baseWard = s => rm(String(s || '')
            .replace(/^(phường|xã|thị\s*trấn|p\.|x\.|tt\.)\s*/i, '')
            .replace(/\s*(?:-|,|–)\s*(quận|huyện|thị\s*xã|thành\s*phố|q\.|h\.|tx\.|tp\.).*$/i, '')
            .replace(/\(.*?\)/g, '')
            .replace(/\b0+(\d)\b/g, '$1')
        );

        function createCombo(el, placeholder) {
            if (!el) return null;
            el.classList.add('combo');
            el.innerHTML = '<div class="combo-input" role="combobox" aria-expanded="false">'
                + '  <input type="text" class="combo-text" placeholder="' + placeholder + '"/>'
                + '  <i class="bi bi-chevron-down combo-caret"></i>'
                + '</div>'
                + '<div class="combo-menu"></div>';

            const input = el.querySelector('.combo-text');
            const menu = el.querySelector('.combo-menu');
            let all = []; let open = false;

            function render(list) {
                menu.innerHTML = '';
                for (const opt of list) {
                    const div = document.createElement('div');
                    div.className = 'combo-item';
                    div.textContent = opt.label;
                    div.dataset.value = opt.value;
                    div.addEventListener('mousedown', function () { pick(opt); });
                    menu.appendChild(div);
                }
            }
            function openMenu() { if (open) return; el.classList.add('open'); open = true; }
            function closeMenu() { if (!open) return; el.classList.remove('open'); open = false; }
            function filter() {
                const q = rm(input.value);
                const filtered = !q ? all : all.filter(o => rm(o.label).includes(q));
                render(filtered); openMenu();
            }
            function pick(opt) {
                input.value = opt.label;
                el.dataset.value = opt.value;
                closeMenu();
                el.dispatchEvent(new CustomEvent('combochange', { detail: opt }));
            }

            input.addEventListener('input', () => { el.dataset.value = ''; filter(); });
            input.addEventListener('keydown', (e) => {
                if (e.key === 'ArrowDown') { openMenu(); e.preventDefault(); }
                if (e.key === 'Escape') { closeMenu(); }
                if (e.key === 'Enter') {
                    const first = menu.querySelector('.combo-item');
                    if (first) { first.dispatchEvent(new MouseEvent('mousedown')); e.preventDefault(); }
                }
            });
            el.addEventListener('click', () => { filter(); input.focus(); });
            document.addEventListener('click', (e) => { if (!el.contains(e.target)) closeMenu(); });

            return {
                setData(arr) { all = arr || []; render(all); },
                setSelected(val, label) { el.dataset.value = val || ''; input.value = label || ''; },
                get value() { return el.dataset.value || ''; },
                get label() { return input.value || ''; },
                clear() { this.setSelected('', ''); }
            };
        }

        const cityCombo = createCombo(cityBox, '— Chọn Tỉnh/Thành —');
        const wardCombo = createCombo(wardBox, '— Chọn Xã/Phường —');

        function extractWardNumber(base) {
            const m = (base || '').match(/\b(\d{1,3})\b/);
            return m ? m[1] : null;
        }
        function findWardMatch(name, wards) {
            if (!name || !wards || !wards.length) return null;
            const tgt = baseWard(name);
            if (!tgt) return null;

            let w = wards.find(x => baseWard(x.name) === tgt);
            if (w) return w;

            w = wards.find(x => {
                const bx = baseWard(x.name);
                return bx.includes(tgt) || tgt.includes(bx);
            });
            if (w) return w;

            const num = extractWardNumber(tgt);
            if (num) {
                const re = new RegExp(`\\b${num}\\b`);
                w = wards.find(x => re.test(baseWard(x.name)));
                if (w) return w;
            }

            w = wards.find(x => {
                const bx = baseWard(x.name);
                return bx.startsWith(tgt) || tgt.startsWith(bx) || bx.endsWith(tgt) || tgt.endsWith(bx);
            });
            if (w) return w;

            return null;
        }

        let provinces = [];
        fetch(DATA_BASE + '/provinces.json', { cache: 'force-cache' })
            .then(r => r.json())
            .then(list => {
                provinces = list || [];
                cityCombo && cityCombo.setData(provinces.map(p => ({ value: String(p.code), label: p.name, raw: p })));

                let p = null;
                if (hidCityCode.value) {
                    p = provinces.find(x => String(x.code) === hidCityCode.value);
                }
                if (!p && hidCityName.value) {
                    p = provinces.find(x => baseCity(x.name) === baseCity(hidCityName.value));
                }
                if (p) setCity(p);
                else {
                    cityCombo && cityCombo.setSelected('', hidCityName.value || '');
                    prefillWardText();
                }
            });

        function prefillWardText() {
            wardCombo && wardCombo.setSelected('', hidWardName.value || '');
        }

        async function loadWards(provCode) {
            wardCombo && wardCombo.clear();
            hidWardCode.value = '';
            if (!provCode) { prefillWardText(); return; }

            try {
                const resp = await fetch(DATA_BASE + '/wards/' + encodeURIComponent(provCode) + '.json', { cache: 'force-cache' });
                if (!resp.ok) { prefillWardText(); return; }
                const wards = await resp.json();
                wardCombo && wardCombo.setData((wards || []).map(w => ({ value: String(w.code), label: w.name, raw: w })));

                if (hidWardCode.value) {
                    const w = wards.find(x => String(x.code) === hidWardCode.value);
                    if (w) return pickWard(w);
                }
                if (hidWardName.value) {
                    const w = findWardMatch(hidWardName.value, wards);
                    if (w) return pickWard(w);
                }
                prefillWardText();
            } catch (e) { console.error(e); prefillWardText(); }
        }

        function setCity(p) {
            if (!cityCombo) return;
            cityCombo.setSelected(String(p.code), p.name);
            hidCityName.value = p.name;
            hidCityCode.value = String(p.code);
            loadWards(String(p.code));
        }

        function pickWard(w) {
            if (!wardCombo) return;
            wardCombo.setSelected(String(w.code), w.name);
            hidWardName.value = w.name;
            hidWardCode.value = String(w.code);
        }

        cityBox && cityBox.addEventListener('combochange', (e) => setCity(e.detail.raw));
        wardBox && wardBox.addEventListener('combochange', (e) => pickWard(e.detail.raw));

        if (cityBox) cityBox.querySelector('.combo-text').addEventListener('blur', () => {
            if (rm(cityCombo.label) !== rm(hidCityName.value)) {
                hidCityName.value = cityCombo.label;
                hidCityCode.value = '';
                wardCombo && wardCombo.clear();
                hidWardName.value = ''; hidWardCode.value = '';
            }
        });
        if (wardBox) wardBox.querySelector('.combo-text').addEventListener('blur', () => {
            if (rm(wardCombo.label) !== rm(hidWardName.value)) {
                hidWardName.value = wardCombo.label;
                hidWardCode.value = '';
            }
        });

        prefillWardText();
    })();
</script>
</body>
</html>
