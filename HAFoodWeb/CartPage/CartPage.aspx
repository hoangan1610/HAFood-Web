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

    <!-- Hidden TextBox mirror cho validator -->
    <asp:TextBox ID="txtCitySel" runat="server" CssClass="invisible-input" />
    <asp:TextBox ID="txtWardSel" runat="server" CssClass="invisible-input" />

    <div class="page">
        <div class="page-grid">
            <!-- LEFT: CART -->
            <asp:UpdatePanel ID="updCart" runat="server" UpdateMode="Conditional" ChildrenAsTriggers="true">
                <ContentTemplate>
                    <div class="cart-box">
                        <div class="cart-header">
                            <div>
                                <asp:CheckBox ID="chkSelectAll" runat="server" AutoPostBack="true" OnCheckedChanged="chkSelectAll_CheckedChanged" />
                            </div>
                            <div></div><div>SẢN PHẨM</div><div>GIÁ</div><div>SL</div><div>SỐ TIỀN</div><div></div>
                        </div>

                        <asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="panel-body">
                            <p>Giỏ hàng bạn đang trống</p>
                        </asp:Panel>

                        <div class="cart-list">
                            <asp:Repeater ID="rptCart" runat="server"
                                OnItemCommand="rptCart_ItemCommand"
                                OnItemDataBound="rptCart_ItemDataBound">
                                <ItemTemplate>
                                    <uc:CartItem ID="CartItemControl" runat="server" />
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>

                        <div class="total-row">
                            <span>Tổng chọn:</span> <asp:Label ID="lblTotal" runat="server" Text="0 ₫"></asp:Label>
                        </div>
                    </div>
                </ContentTemplate>
            </asp:UpdatePanel>

            <!-- RIGHT: ADDRESS (ngoài UpdatePanel để không bị reset) + SUMMARY (UpdatePanel riêng) -->
            <div>
                <!-- ValidationSummary tổng -->
                <asp:ValidationSummary ID="valSummary" runat="server"
                    ValidationGroup="Checkout" ShowSummary="true"
                    DisplayMode="BulletList" CssClass="alert"
                    HeaderText="Vui lòng kiểm tra:" />

                <!-- ADDRESS (ngoài UpdatePanel) -->
                <div class="panel">
                    <div class="panel-title"><span class="pill">i</span> Thông tin địa chỉ nhận hàng</div>
                    <div class="panel-body">
                        <div class="form-row">
                            <label class="req">Tỉnh/Thành</label>
                            <select id="ddlCityV2" class="form-control"></select>
                            <asp:RequiredFieldValidator runat="server"
                                ControlToValidate="txtCitySel"
                                ErrorMessage="Vui lòng chọn Tỉnh/Thành."
                                Display="Dynamic" CssClass="fv"
                                ValidationGroup="Checkout" />
                        </div>
                        <div class="form-row">
                            <label class="req">Xã/Phường</label>
                            <select id="ddlWardV2" class="form-control"></select>
                            <asp:RequiredFieldValidator runat="server"
                                ControlToValidate="txtWardSel"
                                ErrorMessage="Vui lòng chọn Xã/Phường."
                                Display="Dynamic" CssClass="fv"
                                ValidationGroup="Checkout" />
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
                            <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control" />
                            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtPhone"
                                ErrorMessage="Vui lòng nhập số điện thoại."
                                Display="Dynamic" CssClass="fv" ValidationGroup="Checkout" />
                            <asp:RegularExpressionValidator runat="server" ControlToValidate="txtPhone"
                                ValidationExpression=^(?:0\d{9}|\+84\d{9})$
                                ErrorMessage="Số điện thoại không hợp lệ."
                                Display="Dynamic" CssClass="fv" ValidationGroup="Checkout" />
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

                <!-- SUMMARY (UpdatePanel riêng để cập nhật số tiền mà không reset form) -->
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
                                <asp:Button ID="btnCheckout" runat="server"
        CssClass="btn-primary"
        Text="Tiếp Tục Đặt Hàng"
        ValidationGroup="Checkout" CausesValidation="true"
        OnClick="btnCheckout_Click" />
                            </div>
                        </div>
                    </ContentTemplate>
                    <Triggers>
    <asp:PostBackTrigger ControlID="btnCheckout" />
  </Triggers>
                </asp:UpdatePanel>
            </div>
        </div>
    </div>

    <uc:Footer ID="Footer1" runat="server" />

    <!-- JS provinces.open-api.vn v2 + cache + mirror hidden textbox -->
    <script>
        (function () {
            const BASE_V2 = 'https://provinces.open-api.vn/api/v2';
            const TTL_DAYS = 7, ttlMs = TTL_DAYS * 24 * 60 * 60 * 1000;

            const ddlCity = document.getElementById('ddlCityV2');
            const ddlWard = document.getElementById('ddlWardV2');

            const txtCitySel = document.getElementById('<%= txtCitySel.ClientID %>');
            const txtWardSel = document.getElementById('<%= txtWardSel.ClientID %>');

            function cacheGet(key) {
                try {
                    const raw = localStorage.getItem(key);
                    if (!raw) return null;
                    const { ts, data } = JSON.parse(raw);
                    if (Date.now() - ts > ttlMs) { localStorage.removeItem(key); return null; }
                    return data;
                } catch (e) { return null; }
            }
            function cacheSet(key, data) {
                try { localStorage.setItem(key, JSON.stringify({ ts: Date.now(), data })); } catch (e) { }
            }
            async function fetchJson(url, cacheKey) {
                const cached = cacheGet(cacheKey);
                if (cached) return cached;
                const res = await fetch(url, { headers: { 'Accept': 'application/json' } });
                if (!res.ok) throw new Error('HTTP ' + res.status);
                const data = await res.json();
                cacheSet(cacheKey, data);
                return data;
            }
            function resetSelect(sel, ph) {
                sel.innerHTML = '';
                const o = document.createElement('option');
                o.value = ''; o.textContent = ph || '-- Chọn --';
                sel.appendChild(o);
            }

            async function loadCitiesV2() {
                resetSelect(ddlCity, '-- Chọn Tỉnh/Thành --');
                resetSelect(ddlWard, '-- Chọn Xã/Phường --');
                const data = await fetchJson(`${BASE_V2}/p/`, 'v2:p');
                (data || []).forEach(p => {
                    const o = document.createElement('option');
                    o.value = p.code; o.textContent = p.name;
                    ddlCity.appendChild(o);
                });
                // khôi phục nếu có mirror
                if (txtCitySel.value) {
                    for (let i = 0; i < ddlCity.options.length; i++) {
                        if (ddlCity.options[i].text === txtCitySel.value) { ddlCity.selectedIndex = i; break; }
                    }
                    if (ddlCity.value) await loadWardsByProvinceV2(ddlCity.value);
                }
            }

            async function loadWardsByProvinceV2(provinceCode) {
                resetSelect(ddlWard, '-- Chọn Xã/Phường --');
                if (!provinceCode) return;
                try {
                    const prov = await fetchJson(`${BASE_V2}/p/${provinceCode}?depth=2`, `v2:p:${provinceCode}:d2`);
                    const wards = (prov && prov.wards) || [];
                    wards.forEach(w => {
                        const o = document.createElement('option');
                        o.value = w.code; o.textContent = w.name;
                        ddlWard.appendChild(o);
                    });
                } catch (e) {
                    const all = await fetchJson(`${BASE_V2}/w/`, 'v2:w:all');
                    const wards = (all || []).filter(w => String(w.province_code) === String(provinceCode));
                    wards.forEach(w => {
                        const o = document.createElement('option');
                        o.value = w.code; o.textContent = w.name;
                        ddlWard.appendChild(o);
                    });
                }
                // khôi phục ward nếu có mirror
                if (txtWardSel.value) {
                    for (let i = 0; i < ddlWard.options.length; i++) {
                        if (ddlWard.options[i].text === txtWardSel.value) { ddlWard.selectedIndex = i; break; }
                    }
                }
            }

            ddlCity.addEventListener('change', async function () {
                const text = ddlCity.options[ddlCity.selectedIndex]?.text || '';
                txtCitySel.value = text;
                txtWardSel.value = '';
                await loadWardsByProvinceV2(ddlCity.value);
            });
            ddlWard.addEventListener('change', function () {
                const text = ddlWard.options[ddlWard.selectedIndex]?.text || '';
                txtWardSel.value = text;
            });

            // init
            loadCitiesV2().catch(console.error);
        })();
    </script>
</form>
</body>
</html>
