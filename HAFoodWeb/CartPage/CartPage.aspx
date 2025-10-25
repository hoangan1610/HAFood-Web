<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CartPage.aspx.cs" Inherits="HAFoodWeb.CartPage" Async="true" %>
<%@ Register Src="~/Control/Header.ascx" TagPrefix="uc" TagName="Header" %>
<%@ Register Src="~/Control/Footer.ascx" TagPrefix="uc" TagName="Footer" %>
<%@ Register Src="~/CartPage/CartItem.ascx" TagPrefix="uc" TagName="CartItem" %>
<!DOCTYPE html>
<html lang="vi">
<head runat="server">
    <title>Giỏ hàng</title>
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
    </style>
</head>

<body>
<form id="form1" runat="server">
    <asp:ScriptManager ID="sm" runat="server" EnablePartialRendering="true" />
    <uc:Header ID="Header1" runat="server" />

    <!-- Flags/params cho JS -->
    <asp:HiddenField ID="hidDeviceUuid" runat="server" />
    <asp:HiddenField ID="hidApiBase" runat="server" />
    <asp:HiddenField ID="hidIsAuth" runat="server" />
    <asp:HiddenField ID="hidJwt" runat="server" />

    <!-- Hidden mirror cho validator (Tên hiển thị) -->
    <asp:TextBox ID="txtCitySel" runat="server" CssClass="invisible-input" />
    <asp:TextBox ID="txtWardSel" runat="server" CssClass="invisible-input" />
    <!-- Hidden giữ CODE để restore lựa chọn sau postback -->
    <asp:TextBox ID="txtCityCode" runat="server" CssClass="invisible-input" />
    <asp:TextBox ID="txtWardCode" runat="server" CssClass="invisible-input" />
    <!-- NEW: mirror line_id đã chọn -->
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

                        <asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="panel-body">
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
                        <div class="form-row">
                            <label class="req">Tỉnh/Thành</label>
                            <select id="ddlCityV2" class="form-control"></select>
                            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtCitySel"
                                ErrorMessage="Vui lòng chọn Tỉnh/Thành."
                                Display="Dynamic" CssClass="fv" ValidationGroup="Checkout" />
                            <asp:CustomValidator ID="cvCity" runat="server" ControlToValidate="txtCitySel"
                                ClientValidationFunction="validateCity"
                                OnServerValidate="cvCity_ServerValidate"
                                ValidateEmptyText="true"
                                ErrorMessage="Vui lòng chọn Tỉnh/Thành."
                                Display="Dynamic" CssClass="fv" ValidationGroup="Checkout" />
                        </div>
                        <div class="form-row">
                            <label class="req">Xã/Phường</label>
                            <select id="ddlWardV2" class="form-control"></select>
                            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtWardSel"
                                ErrorMessage="Vui lòng chọn Xã/Phường."
                                Display="Dynamic" CssClass="fv" ValidationGroup="Checkout" />
                            <asp:CustomValidator ID="cvWard" runat="server" ControlToValidate="txtWardSel"
                                ClientValidationFunction="validateWard"
                                OnServerValidate="cvWard_ServerValidate"
                                ValidateEmptyText="true"
                                ErrorMessage="Vui lòng chọn Xã/Phường."
                                Display="Dynamic" CssClass="fv" ValidationGroup="Checkout" />
                        </div>
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
                                <!-- Mirror & validate trước khi postback -->
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

    <!-- Provinces script -->
    <script>
        (function () {
            const citySel = document.getElementById('ddlCityV2');
            const wardSel = document.getElementById('ddlWardV2');

            const hidCityName = document.getElementById('<%= txtCitySel.ClientID %>');
            const hidWardName = document.getElementById('<%= txtWardSel.ClientID %>');
            const hidCityCode = document.getElementById('<%= txtCityCode.ClientID %>');
            const hidWardCode = document.getElementById('<%= txtWardCode.ClientID %>');

            const DATA_BASE = '<%= ResolveClientUrl("~/assets/vn-admin") %>';

            function clearOptions(sel, placeholder) {
                sel.innerHTML = '';
                const opt0 = document.createElement('option');
                opt0.value = '';
                opt0.textContent = placeholder;
                sel.appendChild(opt0);
            }
            function selectedText(sel) {
                return sel.options[sel.selectedIndex]?.text?.trim() || '';
            }
            function mirrorHidden() {
                hidCityName.value = selectedText(citySel);
                hidWardName.value = selectedText(wardSel);
                hidCityCode.value = citySel.value || '';
                hidWardCode.value = wardSel.value || '';
            }
            const rmDiacritics = (s) => (s || '')
                .normalize('NFD').replace(/[\u0300-\u036f]/g, '')
                .replace(/đ/g, 'd').replace(/Đ/g, 'D')
                .replace(/\s+/g, ' ').trim().toLowerCase();

            async function loadProvinces() {
                clearOptions(citySel, '— Chọn Tỉnh/Thành —');
                try {
                    const resp = await fetch(`${DATA_BASE}/provinces.json`, { cache: 'force-cache' });
                    const list = await resp.json();
                    for (const p of list) {
                        const opt = document.createElement('option');
                        opt.value = p.code;
                        opt.textContent = p.name;
                        citySel.appendChild(opt);
                    }
                    if (hidCityCode.value) {
                        citySel.value = hidCityCode.value;
                        if (citySel.value !== hidCityCode.value && hidCityName.value) {
                            const target = rmDiacritics(hidCityName.value);
                            for (const o of citySel.options) {
                                if (rmDiacritics(o.text) === target) { citySel.value = o.value; break; }
                            }
                        }
                    }
                } catch (e) { console.error('Load provinces.json failed:', e); }
                mirrorHidden();
            }

            async function loadWards(provSlug) {
                clearOptions(wardSel, '— Chọn Xã/Phường —');
                if (!provSlug) { mirrorHidden(); return; }
                try {
                    const resp = await fetch(`${DATA_BASE}/wards/${encodeURIComponent(provSlug)}.json`, { cache: 'force-cache' });
                    if (!resp.ok) { console.warn('Không có wards cho', provSlug); mirrorHidden(); return; }
                    const wards = await resp.json();
                    for (const w of wards) {
                        const opt = document.createElement('option');
                        opt.value = String(w.code);
                        opt.textContent = w.name;
                        wardSel.appendChild(opt);
                    }
                    if (hidWardCode.value) wardSel.value = hidWardCode.value;
                    if (!wardSel.value && hidWardName.value) {
                        const target = rmDiacritics(hidWardName.value);
                        for (const o of wardSel.options) {
                            if (rmDiacritics(o.text) === target) { wardSel.value = o.value; break; }
                        }
                    }
                } catch (e) { console.error('Load wards failed:', e); }
                mirrorHidden();
            }

            citySel.addEventListener('change', async () => {
                await loadWards(citySel.value);
                mirrorHidden();
            });
            wardSel.addEventListener('change', mirrorHidden);

            document.addEventListener('DOMContentLoaded', async () => {
                await loadProvinces();
                await loadWards(citySel.value);
            });

            // Expose cho beforeCheckoutSubmit()
            window.__mirrorLocationHidden = mirrorHidden;
        })();
    </script>

    <!-- Phone + City/Ward validators (client) -->
    <script>
        function normalizePhone(s) {
            if (!s) return '';
            s = String(s).replace(/[\s\.\-]/g, '').trim();
            s = s.replace(/^\+840/, '+84');
            return s;
        }
        function validatePhone(sender, args) {
            const s = normalizePhone(args.Value);
            args.IsValid = /^(0\d{9}|\+84\d{9})$/.test(s);
        }
        function validateCity(sender, args) {
            if (window.__mirrorLocationHidden) window.__mirrorLocationHidden();
            var citySel = document.getElementById('ddlCityV2');
            args.IsValid = !!(citySel && citySel.value);
        }
        function validateWard(sender, args) {
            if (window.__mirrorLocationHidden) window.__mirrorLocationHidden();
            var wardSel = document.getElementById('ddlWardV2');
            args.IsValid = !!(wardSel && wardSel.value);
        }
    </script>

    <!-- Submit guard -->
    <script>
        function beforeCheckoutSubmit() {
            if (window.__mirrorLocationHidden) window.__mirrorLocationHidden();

            if (typeof (Page_ClientValidate) === 'function') {
                if (!Page_ClientValidate('Checkout')) return false;
            }
            var citySel = document.getElementById('ddlCityV2');
            var wardSel = document.getElementById('ddlWardV2');
            if (!citySel.value || !wardSel.value) {
                alert('Vui lòng chọn Tỉnh/Thành và Xã/Phường.');
                return false;
            }
            return true;
        }
    </script>

    <!-- Cart JS: sync chọn item <-> hidden + SelectAll + 🔔 badge -->
    <!-- Cart JS: sync chọn item <-> hidden + SelectAll + 🔔 badge (có polyfill + delta) -->
<script>
    (function () {
        const API = document.getElementById('<%= hidApiBase.ClientID %>').value || '';
    const UUID = document.getElementById('<%= hidDeviceUuid.ClientID %>').value || '';
    const JWT = (document.getElementById('<%= hidJwt.ClientID %>')?.value || '').trim();

    let sameOrigin = false; try { sameOrigin = new URL(API).host === location.host; } catch { }
    const HAS_JWT = !!JWT;
    const USE_USER = HAS_JWT || sameOrigin;
    const USE_GUEST = !USE_USER;

    const fmt = n => (n || 0).toLocaleString('vi-VN') + ' ₫';

    const selectAll = document.getElementById('<%= chkSelectAll.ClientID %>');
    const hidSelected = document.getElementById('<%= hidSelectedLines.ClientID %>');

    /* ========== 🔔 POLYFILL BADGE + HELPERS ========== */
    function badgeEl() { return document.querySelector('[data-cart-badge="true"]'); }
    function readBadge() {
        const el = badgeEl(); if (!el) return 0;
        const n = parseInt((el.textContent || '0').trim(), 10);
        return Number.isFinite(n) ? n : 0;
    }
    function writeBadge(n) {
        const el = badgeEl(); if (!el) return;
        const v = Math.max(0, parseInt(n || 0, 10));
        el.textContent = v;
        el.style.display = v > 0 ? 'flex' : 'none';
    }
    function bumpBadge(delta) {
        writeBadge(readBadge() + (parseInt(delta || 0, 10)));
    }
    // Nếu Header chưa gắn các hàm toàn cục thì polyfill tại chỗ
    if (typeof window.setCartBadge !== 'function') {
        window.setCartBadge = writeBadge;
    }
    if (typeof window.refreshCartCount !== 'function') {
        // Fallback đơn giản: tính từ DOM hiện tại (không gọi server)
        window.refreshCartCount = function () {
            let sum = 0;
            document.querySelectorAll('.cart-item .qty-num').forEach(el => {
                sum += parseInt((el.textContent || '0').trim(), 10) || 0;
            });
            writeBadge(sum);
        };
    }

    /* ========== Request helpers ========== */
    function withAuthQuery(url) {
        if (USE_GUEST && UUID) return url + (url.includes('?') ? '&' : '?') + 'device_uuid=' + encodeURIComponent(UUID);
        return url;
    }
    function ensure(opts) {
        const headers = { 'Content-Type': 'application/json' };
        if (HAS_JWT) headers['Authorization'] = 'Bearer ' + JWT;
        return Object.assign({ credentials: 'include', headers }, opts || {});
    }
    async function safeJson(resp) { try { return await resp.json(); } catch { return {}; } }

    /* ========== UI helpers ========== */
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

    // Bắt cả totals + header.item_Count (nếu API trả), nếu không có thì giữ im
    function patchTotals(payload) {
        if (payload && payload.totals) {
            const t = payload.totals;
            document.getElementById('<%= lblSubtotal.ClientID %>').textContent = fmt(t.subtotal);
        document.getElementById('<%= lblVat.ClientID %>').textContent = fmt(t.vat);
        document.getElementById('<%= lblShipping.ClientID %>').textContent = fmt(t.shipping);
        document.getElementById('<%= lblGrandTotal.ClientID %>').textContent  = fmt(t.grand);
      document.getElementById('<%= lblTotal.ClientID %>').textContent       = fmt(t.subtotal);
    }
    if (payload?.header?.item_Count != null){
      window.setCartBadge(payload.header.item_Count);
    }
  }

  function recalcTotals(){
    let subtotal=0, sumItems=0;
    document.querySelectorAll('.cart-item').forEach(row=>{
      const cb = row.querySelector('input[type="checkbox"]');
      if (!cb || !cb.checked) return;
      const price = Number(row.getAttribute('data-price')) || 0;
      const qtyEl = row.querySelector('.qty-num');
      const qty   = Number(qtyEl?.textContent.trim() || '1') || 1;
      subtotal += price * qty; sumItems += qty;
    });
    const vat = Math.round(subtotal * 0.08), ship=0, grand=subtotal+vat+ship;
    document.getElementById('<%= lblSubtotal.ClientID %>').textContent    = fmt(subtotal);
    document.getElementById('<%= lblVat.ClientID %>').textContent         = fmt(vat);
    document.getElementById('<%= lblShipping.ClientID %>').textContent    = fmt(ship);
    document.getElementById('<%= lblGrandTotal.ClientID %>').textContent  = fmt(grand);
    document.getElementById('<%= lblTotal.ClientID %>').textContent       = fmt(subtotal);
    document.getElementById('<%= lblSumItems.ClientID %>').textContent    = String(sumItems);
  }
  window.__cartAfterMutate = () => { recalcTotals(); updateSelectAllUI(); syncSelectedHidden(); };

  /* ========== Events ========== */
  document.addEventListener('change', (e)=>{
    if (e.target.matches('.cart-item input[type="checkbox"]')){
      recalcTotals(); updateSelectAllUI(); syncSelectedHidden();
    }
    if (selectAll && e.target.id === '<%= chkSelectAll.ClientID %>'){
      const checked = e.target.checked;
      document.querySelectorAll('.cart-item input[type="checkbox"]').forEach(cb=>cb.checked=checked);
      selectAll.indeterminate = false;
      recalcTotals(); syncSelectedHidden();
    }
  });

  document.addEventListener('click', async (e)=>{
    const inc = e.target.closest('.qty-btn[data-inc]');
    const dec = e.target.closest('.qty-btn[data-dec]');
    const rm  = e.target.closest('[data-remove]');
    if (!inc && !dec && !rm) return;

    const row = (inc || dec || rm).closest('.cart-item');
    if (!row) return;

    const lineId = Number(row.getAttribute('data-line-id'));
    const price  = Number(row.getAttribute('data-price')) || 0;

    /* ====== XOÁ DÒNG ====== */
    if (rm){
      try{
        const qtyBefore = Number(row.querySelector('.qty-num')?.textContent.trim() || '1') || 1;

        let url  = withAuthQuery(`${API}/api/cart/lines/${lineId}`);
        let resp = await fetch(url, ensure({ method:'DELETE' }));
        let json = await safeJson(resp);

        if (!resp.ok && json?.code === 'MISSING_USER_OR_DEVICE' && UUID){
          url  = `${API}/api/cart/lines/${lineId}?device_uuid=${encodeURIComponent(UUID)}`;
          resp = await fetch(url, ensure({ method:'DELETE' }));
          json = await safeJson(resp);
        }
        if (!resp.ok){
          if (json?.code === 'CART_LINE_NOT_FOUND') location.reload();
          console.error('Delete failed', json); return;
        }

        row.remove();
        if (json?.totals || json?.header) patchTotals(json);

        // 🔔 Badge: ưu tiên số từ server; nếu không có → giảm theo delta
        if (json?.header?.item_Count != null){
          window.setCartBadge(json.header.item_Count);
        } else {
          bumpBadge(-qtyBefore);
        }

        recalcTotals(); updateSelectAllUI(); syncSelectedHidden();
      } catch(err){ console.error(err); }
      return;
    }

    /* ====== TĂNG / GIẢM SỐ LƯỢNG ====== */
    const qtyEl = row.querySelector('.qty-num');
    const qOld  = Number(qtyEl.textContent.trim()) || 1;
    const q     = inc ? qOld + 1 : Math.max(1, qOld - 1);
    const delta = q - qOld;

    // Optimistic UI
    qtyEl.textContent = q;
    const totalEl = row.querySelector('.cart-item-total');
    if (totalEl) totalEl.textContent = fmt(price * q);

    try{
      const url  = withAuthQuery(`${API}/api/cart/lines/batch?compact=1`);
      let body   = USE_USER ? { changes:[{ line_id: lineId, quantity: q }] }
                            : { device_uuid: UUID || null, changes:[{ line_id: lineId, quantity: q }] };

      let resp = await fetch(url, ensure({ method:'PUT', body: JSON.stringify(body) }));
      let json = await safeJson(resp);

      if (!resp.ok && json?.code === 'MISSING_USER_OR_DEVICE' && UUID){
        body = { device_uuid: UUID, changes:[{ line_id: lineId, quantity: q }] };
        resp = await fetch(`${API}/api/cart/lines/batch?compact=1`, ensure({ method:'PUT', body: JSON.stringify(body) }));
        json = await safeJson(resp);
      }
      if (!resp.ok){
        if (json?.code === 'CART_LINE_NOT_FOUND') location.reload();
        console.error('Update qty failed', json); return;
      }

      if (json?.totals || json?.header) patchTotals(json);

      // 🔔 Badge: nếu server không trả tổng, ta cộng theo delta
      if (json?.header?.item_Count != null){
        window.setCartBadge(json.header.item_Count);
      } else if (delta !== 0){
        bumpBadge(delta);
      }

      recalcTotals(); updateSelectAllUI(); syncSelectedHidden();
    } catch(err){ console.error(err); }
  });

  window.addEventListener('DOMContentLoaded', ()=>{
    // Mobile keyboard cho phone
    var phone = document.getElementById('<%= txtPhone.ClientID %>');
      if (phone) { phone.setAttribute('type', 'tel'); phone.setAttribute('inputmode', 'tel'); phone.setAttribute('autocomplete', 'tel'); }

      // Mặc định chọn tất cả
      if (selectAll) {
          selectAll.checked = true;
          document.querySelectorAll('.cart-item input[type="checkbox"]').forEach(cb => cb.checked = true);
      }
      recalcTotals(); updateSelectAllUI(); syncSelectedHidden();

      // Đồng bộ badge lần đầu (nếu Header chưa gắn)
      try { window.refreshCartCount(); } catch { }
  });
    })();
</script>


</form>
</body>
</html>
