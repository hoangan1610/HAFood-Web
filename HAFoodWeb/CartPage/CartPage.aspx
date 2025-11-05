<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CartPage.aspx.cs" Inherits="HAFoodWeb.CartPage" Async="true" %>
<%@ Register Src="~/Control/Header.ascx" TagPrefix="uc" TagName="Header" %>
<%@ Register Src="~/Control/Footer.ascx" TagPrefix="uc" TagName="Footer" %>
<%@ Register Src="~/CartPage/CartItem.ascx" TagPrefix="uc" TagName="CartItem" %>
<!DOCTYPE html>
<html lang="vi">
<head runat="server">
    <title>Giỏ hàng - HAFood</title>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet" />
    <style>
        :root{ --border:#e9ecef; --muted:#666; --bg:#f8f9fa; --pill:#ef5350; --radius:10px; }
        body{font-family:'Poppins',sans-serif;background:var(--bg);margin:0}
        .page{max-width:1280px;margin:24px auto;padding:0 16px}
        .page-grid{display:grid;grid-template-columns: 2fr 1fr;gap:16px;align-items:start}
        @media (max-width: 992px){.page-grid{grid-template-columns:1fr}}
        .cart-box{background:#fff;border-radius:var(--radius);box-shadow:0 4px 10px rgba(0,0,0,.05)}
        .cart-header{display:grid;grid-template-columns: 40px 120px 1fr 120px 160px 120px 60px;gap:12px;align-items:center;padding:14px 16px;border-bottom:2px solid #e9ecef}
        .cart-header > div:nth-child(3){ text-align:left; padding-left:20px; }
        .cart-header > div:nth-child(4),
        .cart-header > div:nth-child(5),
        .cart-header > div:nth-child(6),
        .cart-header > div:nth-child(7){ text-align:center; }
        .cart-list{padding:0 8px 8px}
        .total-row{padding:16px;border-top:2px solid var(--border);display:flex;gap:8px;justify-content:flex-end;font-weight:700}

        .panel{background:#fff;border-radius:var(--radius);box-shadow:0 4px 10px rgba(0,0,0,.05)}
        .panel-title{padding:14px 16px;border-bottom:2px solid var(--border);font-weight:700;display:flex;align-items:center;gap:8px}
        .panel-body{padding:16px}
        .form-row{display:flex;flex-direction:column;gap:6px;margin-bottom:12px}
        .form-row label{font-weight:600}
        .form-row .req::before{content:'* ';color:#e53935}
        .form-control{width:100%;height:40px;border:1px solid var(--border);border-radius:8px;padding:0 12px;font-family:inherit}
        .fv{margin-top:4px;color:#dc3545;font-size:13px}

        .summary{background:#fff;border-radius:var(--radius);margin-top:16px;box-shadow:0 4px 10px rgba(0,0,0,.05)}
        .summary-row{display:flex;justify-content:space-between;padding:10px 16px;border-bottom:1px dashed var(--border)}
        .summary-row:last-child{border-bottom:none}
        .grand{color:#e53935;font-size:20px;font-weight:800;text-align:center;padding:16px}
        .btn-primary{display:block;width:100%;height:48px;border:none;border-radius:999px;font-weight:700;cursor:pointer;background:#ff7a00;color:#fff}
        .pill{background:var(--pill);color:#fff;border-radius:999px;padding:4px 10px;font-size:12px}
        .alert{margin:12px 0 0 0;padding:10px 12px;border-radius:10px;background:#ffe6e9;color:#9f2a37;border:1px solid #f5c2c7}
        .invisible-input{position:absolute;left:-9999px;top:auto;width:1px;height:1px;opacity:0;pointer-events:none}

        /* ==== Combo searchable ==== */
        .combo{position:relative}
        .combo-input{display:flex;align-items:center;height:40px;border:1px solid var(--border);border-radius:8px;background:#fff;padding:0 10px;cursor:text}
        .combo-text{flex:1 1 auto;border:none;outline:none;height:100%;font:inherit}
        .combo-caret{margin-left:8px}
        .combo-menu{position:absolute;left:0;right:0;top:calc(100% + 4px);background:#fff;border:1px solid var(--border);
                    border-radius:8px;box-shadow:0 6px 16px rgba(0,0,0,.08);max-height:320px;overflow:auto;display:none;z-index:1000}
        .combo.open .combo-menu{display:block}
        .combo-item{padding:8px 10px;cursor:pointer}
        .combo-item:hover{background:#f5f5f5}

        /* Address session (panel phải) */
        .addr-session{margin-bottom:12px}
        .addr-link{display:block;width:100%;text-decoration:none;color:inherit;background:transparent;border:0;padding:0;cursor:pointer}
        .addr-card{display:flex;gap:12px;align-items:center;background:#fff;border:1px solid var(--border);
                   border-radius:12px;padding:12px;text-align:left}
        .addr-icon{color:#ff7a45;font-size:20px;line-height:1}
        .addr-main{flex:1 1 auto}
        .addr-name{font-weight:700}
        .addr-phone{color:#6b7280;margin-left:8px}
        .addr-detail{color:#374151;margin-top:2px}
        .addr-chevron{color:#9ca3af}

        /* ===== Modal popup ===== */
        .modal-backdrop{
          position:fixed; inset:0;
          background: rgba(0,0,0,.38) !important; 
          -webkit-backdrop-filter: none !important;
          backdrop-filter: none !important;        
          display:none; z-index:2000;
        }
        .modal{
          position:fixed; inset:0;
          display:none; align-items:center; justify-content:center;
          z-index:2001;
        }
        .modal.open, .modal-backdrop.open{ display:flex; }

        .modal-card{
          width:min(1000px,96vw);
          height:min(680px,92vh);
          background:#fff; border-radius:16px;
          box-shadow:0 20px 50px rgba(0,0,0,.25);
          display:flex; flex-direction:column; overflow:hidden;
        }
        .modal-head{display:flex;align-items:center;justify-content:space-between;padding:10px 14px;border-bottom:1px solid var(--border)}
        .modal-title{font-weight:700}
        .modal-close{background:transparent;border:0;font-size:22px;cursor:pointer;line-height:1}
        .modal-body{flex:1 1 auto}
        .modal-body iframe{width:100%;height:100%;border:0}

    </style>
</head>

<body>
<form id="form1" runat="server">
    <asp:ScriptManager ID="sm" runat="server" EnablePartialRendering="true" EnablePageMethods="true" />
    <uc:Header ID="Header1" runat="server" />

    <!-- Flags/params cho JS -->
    <asp:HiddenField ID="hidDeviceUuid" runat="server" />
    <asp:HiddenField ID="hidApiBase" runat="server" />
    <asp:HiddenField ID="hidIsAuth" runat="server" />
    <asp:HiddenField ID="hidJwt" runat="server" />

    <!-- Hidden mirror cho validators/submit -->
    <asp:TextBox ID="txtCitySel" runat="server" CssClass="invisible-input" />
    <asp:TextBox ID="txtWardSel" runat="server" CssClass="invisible-input" />
    <asp:TextBox ID="txtCityCode" runat="server" CssClass="invisible-input" />
    <asp:TextBox ID="txtWardCode" runat="server" CssClass="invisible-input" />
    <asp:HiddenField ID="hidSelectedLines" runat="server" />

    <div class="page">
        <div class="page-grid">
            <!-- LEFT -->
            <asp:UpdatePanel ID="updCart" runat="server" UpdateMode="Conditional" ChildrenAsTriggers="true">
                <ContentTemplate>
                    <div class="cart-box">
                        <div class="cart-header">
                            <div><asp:CheckBox ID="chkSelectAll" runat="server" /></div>
                            <div></div><div>SẢN PHẨM</div><div>GIÁ</div><div>SL</div><div>SỐ TIỀN</div><div></div>
                        </div>

                        <asp:Panel ID="pnlEmpty" runat="server" CssClass="panel-body" style="display:none">
                            <p>Giỏ hàng bạn đang trống</p>
                        </asp:Panel>

                        <div class="cart-list">
                            <asp:Repeater ID="rptCart" runat="server" OnItemDataBound="rptCart_ItemDataBound">
                                <ItemTemplate><uc:CartItem ID="CartItemControl" runat="server" /></ItemTemplate>
                            </asp:Repeater>
                        </div>

                        <div class="total-row">
                            <span>Tổng chọn:</span> <asp:Label ID="lblTotal" runat="server" Text="0 ₫"></asp:Label>
                        </div>
                    </div>
                </ContentTemplate>
            </asp:UpdatePanel>

            <!-- RIGHT -->
            <div>
                <asp:ValidationSummary ID="valSummary" runat="server" ValidationGroup="Checkout" ShowSummary="true"
                    DisplayMode="BulletList" CssClass="alert" HeaderText="Vui lòng kiểm tra:" />

                <div class="panel">
                    <div class="panel-title"><span class="pill">i</span> Thông tin địa chỉ nhận hàng</div>
                    <div class="panel-body">

                        <!-- Session địa chỉ hiển thị -->
                        <asp:Panel ID="pnlAddrSession" runat="server" CssClass="addr-session" style="display:none">
                          <button type="button" class="addr-link" id="btnChooseAddr1">
                            <div class="addr-card">
                              <div class="addr-icon"><i class="bi bi-geo-alt-fill"></i></div>
                              <div class="addr-main">
                                <div>
                                  <span class="addr-name"><asp:Label ID="lblAddrName" runat="server" /></span>
                                  <span class="addr-phone">(<asp:Label ID="lblAddrPhone" runat="server" />)</span>
                                </div>
                                <div class="addr-detail"><asp:Label ID="lblAddrDetail" runat="server" /></div>
                              </div>
                              <div class="addr-chevron"><i class="bi bi-chevron-right"></i></div>
                            </div>
                          </button>
                        </asp:Panel>

                        <asp:Panel ID="pnlNoAddr" runat="server" CssClass="addr-session" style="display:none">
                          <button type="button" class="addr-link" id="btnChooseAddr2">
                            <div class="addr-card">
                              <div class="addr-icon"><i class="bi bi-geo-alt"></i></div>
                              <div class="addr-main">
                                <div class="text-muted">Chưa có địa chỉ — bấm để chọn</div>
                              </div>
                              <div class="addr-chevron"><i class="bi bi-chevron-right"></i></div>
                            </div>
                          </button>
                        </asp:Panel>

                        <!-- ====== Combobox searchable ====== -->
                        <div class="form-row">
                            <label class="req">Tỉnh/Thành</label>
                            <div id="cmbCity" class="combo"></div>
                            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtCitySel"
                                ErrorMessage="Vui lòng chọn Tỉnh/Thành." Display="Dynamic" CssClass="fv" ValidationGroup="Checkout" />
                            <asp:CustomValidator ID="cvCity" runat="server" ControlToValidate="txtCitySel"
                                ClientValidationFunction="validateCityCode"
                                OnServerValidate="cvCity_ServerValidate"
                                ValidateEmptyText="true"
                                ErrorMessage="Vui lòng chọn Tỉnh/Thành từ danh sách."
                                Display="Dynamic" CssClass="fv" ValidationGroup="Checkout" />
                        </div>

                        <div class="form-row">
                            <label class="req">Xã/Phường</label>
                            <div id="cmbWard" class="combo"></div>
                            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtWardSel"
                                ErrorMessage="Vui lòng chọn Xã/Phường." Display="Dynamic" CssClass="fv" ValidationGroup="Checkout" />
                            <asp:CustomValidator ID="cvWard" runat="server" ControlToValidate="txtWardSel"
                                ClientValidationFunction="validateWardCode"
                                OnServerValidate="cvWard_ServerValidate"
                                ValidateEmptyText="true"
                                ErrorMessage="Vui lòng chọn Xã/Phường từ danh sách."
                                Display="Dynamic" CssClass="fv" ValidationGroup="Checkout" />
                        </div>
                        <!-- ================================= -->

                        <div class="form-row">
                            <label class="req">Địa chỉ nhận hàng</label>
                            <asp:TextBox ID="txtAddress" runat="server" CssClass="form-control" />
                            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtAddress"
                                ErrorMessage="Vui lòng nhập địa chỉ nhận hàng."
                                Display="Dynamic" CssClass="fv" ValidationGroup="Checkout" />
                        </div>

                        <div class="form-row">
                            <label class="req">Số điện thoại liên lạc</label>
                            <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control" TextMode="SingleLine" MaxLength="20" />
                            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtPhone"
                                ErrorMessage="Vui lòng nhập số điện thoại."
                                Display="Dynamic" CssClass="fv" ValidationGroup="Checkout" />
                            <asp:CustomValidator ID="cvPhone" runat="server" ControlToValidate="txtPhone"
                                ClientValidationFunction="validatePhone"
                                OnServerValidate="cvPhone_ServerValidate"
                                ErrorMessage="Số điện thoại không hợp lệ."
                                Display="Dynamic" CssClass="fv" ValidationGroup="Checkout" SetFocusOnError="true" />
                        </div>

                        <div class="form-row">
                            <label class="req">Tên người nhận hàng</label>
                            <asp:TextBox ID="txtReceiver" runat="server" CssClass="form-control" />
                            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtReceiver"
                                ErrorMessage="Vui lòng nhập tên người nhận."
                                Display="Dynamic" CssClass="fv" ValidationGroup="Checkout" />
                        </div>

                        <div class="form-row"><label>Ghi chú cho đơn hàng</label><asp:TextBox ID="txtNote" runat="server" CssClass="form-control" /></div>
                        <div class="form-row"><label>Mã khuyến mãi</label><asp:TextBox ID="txtPromo" runat="server" CssClass="form-control" /></div>
                    </div>
                </div>

                <asp:UpdatePanel ID="updSummary" runat="server" UpdateMode="Conditional">
                    <ContentTemplate>
                        <div class="summary">
                            <div class="summary-row"><span>Tổng số sản phẩm:</span><asp:Label ID="lblSumItems" runat="server" Text="0" /></div>
                            <div class="summary-row"><span>Trọng lượng hàng:</span><asp:Label ID="lblTotalWeight" runat="server" Text="0" /></div>
                            <div class="summary-row"><span>Tổng tiền hàng:</span><asp:Label ID="lblSubtotal" runat="server" Text="0 ₫" /></div>
                            <div class="summary-row"><span>Phí vận chuyển:</span><asp:Label ID="lblShipping" runat="server" Text="0 ₫" /></div>
                            <div class="summary-row"><span>VAT (8%):</span><asp:Label ID="lblVat" runat="server" Text="0 ₫" /></div>
                            <div class="grand">Tổng thanh toán: <asp:Label ID="lblGrandTotal" runat="server" Text="0 ₫" /></div>
                            <div style="padding:0 16px 16px">
                                <asp:Button ID="btnCheckout" runat="server" CssClass="btn-primary" Text="Tiếp Tục Đặt Hàng"
                                    ValidationGroup="Checkout" CausesValidation="true" OnClick="btnCheckout_Click"
                                    OnClientClick="return beforeCheckoutSubmit();" />
                            </div>
                        </div>
                    </ContentTemplate>
                    <Triggers><asp:PostBackTrigger ControlID="btnCheckout" /></Triggers>
                </asp:UpdatePanel>
            </div>
        </div>
    </div>

    <uc:Footer ID="Footer1" runat="server" />

    <!-- ===== MODAL POPUP chọn địa chỉ ===== -->
    <div class="modal-backdrop" id="addrModalBk"></div>
    <div class="modal" id="addrModal" aria-hidden="true" role="dialog" aria-label="Chọn địa chỉ">
        <div class="modal-card">
            <div class="modal-head">
                <div class="modal-title">Chọn địa chỉ</div>
                <button type="button" class="modal-close" id="addrCloseBtn" aria-label="Close">&times;</button>
            </div>
            <div class="modal-body">
                <iframe id="addrFrame" src="about:blank" title="Address Select"></iframe>
            </div>
        </div>
    </div>

    <!-- Phone validator -->
    <script>
        function normalizePhone(s) { if (!s) return ''; s = String(s).replace(/[\s\.\-]/g, '').trim(); s = s.replace(/^\+840/, '+84'); return s; }
        function validatePhone(sender, args) { const s = normalizePhone(args.Value); args.IsValid = /^(0\d{9}|\+84\d{9})$/.test(s); }
    </script>

    <!-- Combobox searchable + expose cityWardAPI (CÓ PROMISE) -->
    <script>
        (function () {
            const DATA_BASE = '<%= ResolveClientUrl("~/assets/vn-admin") %>';

            const cityBox = document.getElementById('cmbCity');
            const wardBox = document.getElementById('cmbWard');

            const hidCityName = document.getElementById('<%= txtCitySel.ClientID %>');
            const hidWardName = document.getElementById('<%= txtWardSel.ClientID %>');
            const hidCityCode = document.getElementById('<%= txtCityCode.ClientID %>');
            const hidWardCode = document.getElementById('<%= txtWardCode.ClientID %>');

            const rm = (s) => (s || '').normalize('NFD').replace(/[\u0300-\u036f]/g, '').replace(/đ/g, 'd').replace(/Đ/g, 'D').replace(/\s+/g, ' ').trim().toLowerCase();
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
                    + '</div><div class="combo-menu"></div>';
                const input = el.querySelector('.combo-text'); const menu = el.querySelector('.combo-menu');
                let all = []; let open = false;
                function render(list) { menu.innerHTML = ''; for (const opt of list) { const div = document.createElement('div'); div.className = 'combo-item'; div.textContent = opt.label; div.dataset.value = opt.value; div.addEventListener('mousedown', () => pick(opt)); menu.appendChild(div); } }
                function openMenu() { if (open) return; el.classList.add('open'); open = true; }
                function closeMenu() { if (!open) return; el.classList.remove('open'); open = false; }
                function filter() { const q = rm(input.value); render(!q ? all : all.filter(o => rm(o.label).includes(q))); openMenu(); }
                function pick(opt) { input.value = opt.label; el.dataset.value = opt.value; closeMenu(); el.dispatchEvent(new CustomEvent('combochange', { detail: opt })); }
                input.addEventListener('input', () => { el.dataset.value = ''; filter(); });
                input.addEventListener('keydown', (e) => { if (e.key === 'ArrowDown') { openMenu(); e.preventDefault(); } if (e.key === 'Escape') { closeMenu(); } if (e.key === 'Enter') { const first = menu.querySelector('.combo-item'); if (first) { first.dispatchEvent(new MouseEvent('mousedown')); e.preventDefault(); } } });
                el.addEventListener('click', () => { filter(); input.focus(); }); document.addEventListener('click', (e) => { if (!el.contains(e.target)) closeMenu(); });
                return { setData(arr) { all = arr || []; render(all); }, setSelected(val, label) { el.dataset.value = val || ''; input.value = label || ''; }, get value() { return el.dataset.value || ''; }, get label() { return input.value || ''; }, clear() { this.setSelected('', ''); } };
            }

            const cityCombo = createCombo(cityBox, '— Chọn Tỉnh/Thành —');
            const wardCombo = createCombo(wardBox, '— Chọn Xã/Phường —');

            function extractWardNumber(base) { const m = (base || '').match(/\b(\d{1,3})\b/); return m ? m[1] : null; }
            function findWardMatch(name, wards) {
                if (!name || !wards || !wards.length) return null;
                const tgt = baseWard(name); if (!tgt) return null;
                let w = wards.find(x => baseWard(x.name) === tgt); if (w) return w;
                w = wards.find(x => { const bx = baseWard(x.name); return bx.includes(tgt) || tgt.includes(bx); }); if (w) return w;
                const num = extractWardNumber(tgt); if (num) { const re = new RegExp(`\\b${num}\\b`); w = wards.find(x => re.test(baseWard(x.name))); if (w) return w; }
                w = wards.find(x => { const bx = baseWard(x.name); return bx.startsWith(tgt) || tgt.startsWith(bx) || bx.endsWith(tgt) || tgt.endsWith(bx); });
                return w || null;
            }

            let provinces = []; let wardsOfCurrent = [];

            /* === Ready promises === */
            let provincesReadyResolve; const provincesReady = new Promise(r => provincesReadyResolve = r);
            let wardsReadyResolve; let wardsReady = Promise.resolve();

            function prefillWardText() { wardCombo && wardCombo.setSelected('', hidWardName.value || ''); }

            async function loadWards(provCode) {
                wardCombo && wardCombo.clear(); hidWardCode.value = ''; wardsOfCurrent = [];
                wardsReady = new Promise(r => wardsReadyResolve = r);
                if (!provCode) { prefillWardText(); wardsReadyResolve && wardsReadyResolve(); return; }
                try {
                    const resp = await fetch(DATA_BASE + '/wards/' + encodeURIComponent(provCode) + '.json', { cache: 'force-cache' });
                    const wards = resp.ok ? await resp.json() : [];
                    wardsOfCurrent = wards || [];
                    wardCombo && wardCombo.setData(wardsOfCurrent.map(w => ({ value: String(w.code), label: w.name, raw: w })));

                    if (hidWardCode.value) {
                        const w = wardsOfCurrent.find(x => String(x.code) === hidWardCode.value); if (w) { pickWard(w); wardsReadyResolve && wardsReadyResolve(); return; }
                    }
                    if (hidWardName.value) {
                        const w = findWardMatch(hidWardName.value, wardsOfCurrent); if (w) { pickWard(w); wardsReadyResolve && wardsReadyResolve(); return; }
                    }
                    prefillWardText();
                } catch (e) { console.error(e); prefillWardText(); }
                wardsReadyResolve && wardsReadyResolve();
            }

            function setCity(p) {
                if (!cityCombo) return;
                cityCombo.setSelected(String(p.code), p.name);
                hidCityName.value = p.name; hidCityCode.value = String(p.code);
                loadWards(String(p.code));
            }
            function pickWard(w) {
                if (!wardCombo) return;
                wardCombo.setSelected(String(w.code), w.name);
                hidWardName.value = w.name; hidWardCode.value = String(w.code);
            }

            // fetch provinces
            fetch(DATA_BASE + '/provinces.json', { cache: 'force-cache' })
                .then(r => r.json())
                .then(list => {
                    provinces = list || [];
                    cityCombo && cityCombo.setData(provinces.map(p => ({ value: String(p.code), label: p.name, raw: p })));
                    let p = null;
                    if (hidCityCode.value) { p = provinces.find(x => String(x.code) === hidCityCode.value); }
                    if (!p && hidCityName.value) { p = provinces.find(x => baseCity(x.name) === baseCity(hidCityName.value)); }
                    if (p) setCity(p); else { cityCombo && cityCombo.setSelected('', hidCityName.value || ''); prefillWardText(); }
                    provincesReadyResolve && provincesReadyResolve();
                });

            cityBox && cityBox.addEventListener('combochange', (e) => setCity(e.detail.raw));
            wardBox && wardBox.addEventListener('combochange', (e) => pickWard(e.detail.raw));

            if (cityBox) cityBox.querySelector('.combo-text').addEventListener('blur', () => {
                const lb = cityCombo?.label || '';
                if (rm(lb) !== rm(hidCityName.value)) { hidCityName.value = lb; hidCityCode.value = ''; wardCombo && wardCombo.clear(); hidWardName.value = ''; hidWardCode.value = ''; }
            });
            if (wardBox) wardBox.querySelector('.combo-text').addEventListener('blur', () => {
                const lb = wardCombo?.label || '';
                if (rm(lb) !== rm(hidWardName.value)) { hidWardName.value = lb; hidWardCode.value = ''; }
            });

            // Validators + submit guard
            window.validateCityCode = function (sender, args) { args.IsValid = !!hidCityCode.value; }
            window.validateWardCode = function (sender, args) { args.IsValid = !!hidWardCode.value; }

            // === Public API: trả Promise để có thể chờ map xong ===
            window.cityWardAPI = {
                async setByNames(cityName, wardName) {
                    await provincesReady;
                    if (cityName) {
                        const p = provinces.find(x => baseCity(x.name) === baseCity(cityName));
                        if (p) setCity(p);
                    }
                    await wardsReady;
                    if (wardName) {
                        const w = findWardMatch(wardName, wardsOfCurrent);
                        if (w) pickWard(w);
                    }
                    return true;
                },
                async setByCodes(cityCode, cityName, wardCode, wardName) {
                    await provincesReady;
                    if (cityCode) {
                        let p = provinces.find(x => String(x.code) === String(cityCode));
                        if (!p && cityName) p = provinces.find(x => baseCity(x.name) === baseCity(cityName));
                        if (p) setCity(p);
                    } else if (cityName) {
                        const p = provinces.find(x => baseCity(x.name) === baseCity(cityName));
                        if (p) setCity(p);
                    }
                    await wardsReady;
                    if (wardCode) {
                        let w = wardsOfCurrent.find(x => String(x.code) === String(wardCode));
                        if (!w && wardName) w = findWardMatch(wardName, wardsOfCurrent);
                        if (w) pickWard(w);
                    } else if (wardName) {
                        const w = findWardMatch(wardName, wardsOfCurrent);
                        if (w) pickWard(w);
                    }
                    return true;
                },
                whenReady() { return provincesReady.then(() => wardsReady); }
            };
        })();
    </script>

    <!-- Cart JS + Popup Address -->
    <script>
        (function () {
            const API = document.getElementById('<%= hidApiBase.ClientID %>').value || '';
            const UUID = document.getElementById('<%= hidDeviceUuid.ClientID %>').value || '';
            const JWT = (document.getElementById('<%= hidJwt.ClientID %>')?.value || '').trim();

            let sameOrigin = false; try { sameOrigin = new URL(API).host === location.host; } catch { }
            const HAS_JWT = !!JWT;
            const USE_USER = HAS_JWT || sameOrigin;

            const fmt = n => (n || 0).toLocaleString('vi-VN') + ' ₫';

            const selectAll = document.getElementById('<%= chkSelectAll.ClientID %>');
            const hidSelected = document.getElementById('<%= hidSelectedLines.ClientID %>');
            const pnlEmptyEl = document.getElementById('<%= pnlEmpty.ClientID %>');

            function writeBadge(n) {
                const el = document.querySelector('[data-cart-badge="true"]');
                if (!el) return;
                const v = Math.max(0, parseInt(n || 0, 10));
                el.textContent = v; el.style.display = v > 0 ? 'flex' : 'none';
            }

            function syncSelectedHidden() {
                const selected = [];
                document.querySelectorAll('.cart-item').forEach(row => {
                    const cb = row.querySelector('input[type="checkbox"]');
                    if (cb && cb.checked) {
                        const id = row.getAttribute('data-line-id');
                        if (id) selected.push(id);
                    }
                });
                hidSelected.value = selected.join(',');
            }

            function updateSelectAllUI() {
                const cbs = Array.from(document.querySelectorAll('.cart-item input[type="checkbox"]'));
                if (!selectAll) return;
                if (cbs.length === 0) { selectAll.checked = false; selectAll.indeterminate = false; return; }
                const checkedCount = cbs.filter(x => x.checked).length;
                selectAll.checked = (checkedCount === cbs.length);
                selectAll.indeterminate = (checkedCount > 0 && checkedCount < cbs.length);
            }

            function recalcTotals() {
                let subtotal = 0, sumItems = 0;
                document.querySelectorAll('.cart-item').forEach(row => {
                    const cb = row.querySelector('input[type="checkbox"]');
                    if (!cb || !cb.checked) return;
                    const price = Number(row.getAttribute('data-price')) || 0;
                    const qtyEl = row.querySelector('.qty-num');
                    const qty = Number(qtyEl?.textContent.trim() || '1') || 1;
                    subtotal += price * qty; sumItems += qty;
                });
                const vat = Math.round(subtotal * 0.08), ship = 0, grand = subtotal + vat + ship;
                document.getElementById('<%= lblSubtotal.ClientID %>').textContent = fmt(subtotal);
                document.getElementById('<%= lblVat.ClientID %>').textContent = fmt(vat);
                document.getElementById('<%= lblShipping.ClientID %>').textContent = fmt(ship);
                document.getElementById('<%= lblGrandTotal.ClientID %>').textContent  = fmt(grand);
                document.getElementById('<%= lblTotal.ClientID %>').textContent       = fmt(subtotal);
                document.getElementById('<%= lblSumItems.ClientID %>').textContent    = String(sumItems);
            }
            window.__cartAfterMutate = () => { recalcTotals(); updateSelectAllUI(); syncSelectedHidden(); };

            // ====== POPUP chọn địa chỉ ======
            const modal = document.getElementById('addrModal');
            const backdrop = document.getElementById('addrModalBk');
            const iframe = document.getElementById('addrFrame');
            const openBtns = [document.getElementById('btnChooseAddr1'), document.getElementById('btnChooseAddr2')].filter(Boolean);
            const closeBtn = document.getElementById('addrCloseBtn');

            const IS_AUTH   = (document.getElementById('<%= hidIsAuth.ClientID %>').value === '1');
            const LOGIN_URL = '<%= ResolveUrl("~/AuthPage/Login.aspx") %>';
            const addressSelectUrl = '<%= ResolveUrl("~/CartPage/AddressSelect.aspx") %>'; // popup-only

            function openModal() {
                iframe.src = addressSelectUrl;
                modal.classList.add('open');
                backdrop.classList.add('open');
                modal.setAttribute('aria-hidden', 'false');
            }
            function closeModal() {
                iframe.src = 'about:blank';
                modal.classList.remove('open');
                backdrop.classList.remove('open');
                modal.setAttribute('aria-hidden', 'true');
            }

            openBtns.forEach(b => b.addEventListener('click', (e) => {
                e.preventDefault();
                if (!IS_AUTH) {
                    const ret = encodeURIComponent(window.location.pathname + window.location.search);
                    window.location.href = `${LOGIN_URL}?returnUrl=${ret}`;
                    return;
                }
                openModal();
            }));
            closeBtn.addEventListener('click', closeModal);
            backdrop.addEventListener('click', closeModal);

            // Nhận tín hiệu từ AddressSelect (trong iframe)
            window.addEventListener('message', function (ev) {
                try {
                    if (ev.source !== iframe.contentWindow) return; // chỉ nhận từ popup này
                    const data = ev.data || {};
                    if (data.type === 'HAFood.AddressPicked') {
                        if (data.address) {
                            // CHỜ map xong rồi mới đóng
                            applyAddressToUI(data.address).finally(closeModal);
                            return;
                        }
                        if (typeof PageMethods !== 'undefined' && PageMethods.GetSelectedAddress) {
                            PageMethods.GetSelectedAddress(function (dto) {
                                if (!dto) { closeModal(); return; }
                                applyAddressToUI(dto).finally(closeModal);
                            }, function () { closeModal(); });
                        } else {
                            closeModal();
                        }
                    } else if (data.type === 'HAFood.AddressCancel') {
                        closeModal();
                    }
                } catch (e) { console.error(e); }
            });

            function applyAddressToUI(dto) {
                const pnlHas  = document.getElementById('<%= pnlAddrSession.ClientID %>');
                const pnlNone = document.getElementById('<%= pnlNoAddr.ClientID %>');
                if (pnlHas) pnlHas.style.display = 'block';
                if (pnlNone) pnlNone.style.display = 'none';

                const nameEl   = document.getElementById('<%= lblAddrName.ClientID %>');
                const phoneEl  = document.getElementById('<%= lblAddrPhone.ClientID %>');
                const detailEl = document.getElementById('<%= lblAddrDetail.ClientID %>');

                if (nameEl) nameEl.textContent   = dto.fullName || '';
                if (phoneEl) phoneEl.textContent = dto.phone || '';
                if (detailEl) detailEl.textContent = dto.fullAddress || '';

                const street = parseStreet(dto.fullAddress || '');
                document.getElementById('<%= txtAddress.ClientID %>').value  = street;
                document.getElementById('<%= txtReceiver.ClientID %>').value = dto.fullName || '';
                document.getElementById('<%= txtPhone.ClientID %>').value    = dto.phone || '';

                const cityName = extractCity(dto.fullAddress || '');
                const wardName = extractWard(dto.fullAddress || '');

                // TRẢ PROMISE để caller .finally(closeModal)
                if (window.cityWardAPI && window.cityWardAPI.setByNames) {
                    return window.cityWardAPI.setByNames(cityName, wardName);
                }
                return Promise.resolve();
            }

            function parseStreet(full) {
                const parts = (full || '').split(',').map(s => s.trim()).filter(Boolean);
                if (parts.length <= 1) return full || '';
                if (parts.length >= 4) return parts.slice(0, parts.length - 3).join(', ');
                return parts[0] || '';
            }
            function extractCity(full) {
                const parts = (full || '').split(',').map(s => s.trim()).filter(Boolean);
                return parts.length ? parts[parts.length - 1] : '';
            }
            function extractWard(full) {
                const parts = (full || '').split(',').map(s => s.trim()).filter(Boolean);
                if (parts.length >= 3) return parts[parts.length - 2];
                if (parts.length === 2) return parts[1];
                return '';
            }

            // ======== init
            window.addEventListener('DOMContentLoaded', () => {
                const hasItems = document.querySelectorAll('.cart-item').length > 0;
                if (pnlEmptyEl) pnlEmptyEl.style.display = hasItems ? 'none' : 'block';

                var phone = document.getElementById('<%= txtPhone.ClientID %>');
                if (phone) { phone.setAttribute('type', 'tel'); phone.setAttribute('inputmode', 'tel'); phone.setAttribute('autocomplete', 'tel'); }

                if (selectAll) {
                    selectAll.checked = true;
                    document.querySelectorAll('.cart-item input[type="checkbox"]').forEach(cb => cb.checked = true);
                }
                recalcTotals(); updateSelectAllUI(); syncSelectedHidden();

                try {
                    const sum = Array.from(document.querySelectorAll('.cart-item .qty-num')).reduce((s, el) => s + (parseInt(el.textContent.trim(), 10) || 0), 0);
                    writeBadge(sum);
                } catch { }
            });
        })();
    </script>

</form>
</body>
</html>
