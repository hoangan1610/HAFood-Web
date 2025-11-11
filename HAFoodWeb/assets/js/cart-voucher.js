(function (global) {
    // ===== Utils =====
    const get = (o, ...paths) => { for (const p of paths) { const v = p.split('.').reduce((a, k) => (a && a[k] != null ? a[k] : undefined), o); if (v != null) return v; } return undefined; };
    function setText(sel, text) { const el = document.querySelector(sel); if (!el) return; if (el.tagName === 'INPUT' || el.tagName === 'TEXTAREA') el.value = text; else el.textContent = text; }
    function getNumberFromLabel(sel) { const el = document.querySelector(sel); if (!el) return 0; const s = (el.textContent || el.value || '').replace(/[^\d\-]/g, ''); const n = parseInt(s, 10); return Number.isFinite(n) ? n : 0; }
    const fmtVn = n => (Math.max(0, Number(n) || 0)).toLocaleString('vi-VN') + ' ₫';
    const readMoney = sel => { const el = document.querySelector(sel); if (!el) return 0; const s = (el.textContent || el.value || '').replace(/[^\d\-]/g, ''); const n = parseInt(s, 10); return Number.isFinite(n) ? n : 0; };

    // ===== State =====
    let currentOpts = null;
    let reservedState = { code: "", reserved: false };

    // ===== Applied chip helpers =====
    function getAppliedCode() { try { const hid = document.querySelector(currentOpts?.selectors?.hidPromoCode); return (hid?.value || '').trim(); } catch { return ''; } }
    function getAppliedMeta() { try { const s = document.querySelector(currentOpts?.selectors?.hidPromoMetaJson)?.value || ''; return s ? JSON.parse(s) : {}; } catch { return {}; } }
    function setAppliedCode(code, promoObj) {
        const prev = getAppliedCode();
        if (prev && code && prev.toUpperCase() !== code.toUpperCase()) {
            // đổi mã -> release mã cũ
            releaseVoucher('switch_code');
        }
        setText(currentOpts.selectors.hidPromoCode, code || '');
        setText(currentOpts.selectors.hidPromoMetaJson, code ? JSON.stringify(promoObj || {}) : '');
        updateAppliedChip();
    }
    function updateAppliedChip() {
        try {
            const chip = document.getElementById('voucherAppliedChip');
            if (!chip) return;
            const code = getAppliedCode();
            if (!code) { chip.style.display = 'none'; chip.innerHTML = ''; return; }
            const meta = getAppliedMeta();
            const name = meta.name || meta.Name || '';
            const label = (name || code) + (name && name.toUpperCase() !== code.toUpperCase() ? ` (${code})` : '');
            chip.innerHTML = `<span class="chip-text">Đang áp dụng: <b>${label}</b></span>
        <button type="button" class="chip-remove" aria-label="Gỡ mã">×</button>`;
            chip.style.display = 'inline-flex';
            chip.querySelector('.chip-remove')?.addEventListener('click', async (e) => { e.stopPropagation(); await clearVoucherAndRefresh(); });
        } catch { }
    }

    // ===== Collect cart items =====
    function collectSelectedItems(selectedLinesHiddenSelector) {
        const selected = new Set(); const hid = document.querySelector(selectedLinesHiddenSelector);
        if (hid && hid.value) { hid.value.split(',').forEach(s => { const id = parseInt(s, 10); if (Number.isFinite(id)) selected.add(id); }); }
        const usingCheckbox = selected.size === 0;
        const rows = Array.from(document.querySelectorAll('.cart-item'));
        const anyChecked = rows.some(r => r.querySelector('input[type="checkbox"]')?.checked);
        const selectAllFallback = usingCheckbox && !anyChecked;

        const items = []; let subtotal = 0;
        rows.forEach(row => {
            if (usingCheckbox && !selectAllFallback) { const cb = row.querySelector('input[type="checkbox"]'); if (cb && !cb.checked) return; }
            else if (!selectAllFallback) { const lineId = parseInt(row.getAttribute('data-line-id') || '0', 10) || 0; if (!selected.has(lineId)) return; }
            const variantId = parseInt(row.getAttribute('data-variant-id') || '0', 10) || 0;
            const price = Math.round(Number(row.getAttribute('data-price') || '0') || 0);
            const qty = Math.max(1, parseInt((row.querySelector('.qty-num')?.textContent || '1').trim(), 10) || 1);
            items.push({ productId: null, variantId: variantId || null, qty, unitPrice: price });
            subtotal += price * qty;
        });
        return { items, subtotal };
    }

    // ===== HTTP =====
    async function postJson(url, body, jwt, deviceUuid) {
        const headers = { 'Content-Type': 'application/json' }; if (jwt) headers['Authorization'] = 'Bearer ' + jwt; if (deviceUuid) headers['X-Device-Id'] = deviceUuid;
        const resp = await fetch(url, { method: 'POST', headers, credentials: 'include', body: JSON.stringify(body) });
        let json; try { json = await resp.json(); } catch { json = {}; }
        return { ok: resp.ok, status: resp.status, json };
    }
    function normalizePromotions(payload) {
        if (!payload) return []; const a = get(payload, 'data') ?? get(payload, 'promotions') ?? get(payload, 'list') ?? (Array.isArray(payload) ? payload : null);
        return Array.isArray(a) ? a : [];
    }

    // ===== Debounce =====
    function debounce(fn, wait) { let t; return (...args) => { clearTimeout(t); t = setTimeout(() => fn(...args), wait); }; }

    // ===== Reserve/Release =====
    async function reserveVoucher(code) {
        if (!code) return;
        if (reservedState.reserved && reservedState.code &&
            reservedState.code.toUpperCase() === code.toUpperCase()) return;

        const { items, subtotal } = collectSelectedItems(currentOpts.selectors.selectedLinesHidden);
        const ship = getNumberFromLabel(currentOpts.selectors.lblShipping) || 0;

        const url = (currentOpts.apiBase || '').replace(/\/+$/, '') + '/api/promotions/cart/reserve';
        const payload = {
            orderId: 0, promotionId: 0, code,
            userInfoId: 0, deviceUuid: currentOpts.deviceUuid || '',
            channel: currentOpts.channel || 1,
            orderSubtotal: subtotal, shippingFee: ship,
            discountAmount: Number(document.querySelector(currentOpts.selectors.hidPromoDiscount)?.value || 0) || 0,
            items: items.map(i => ({ productId: i.productId ?? 0, variantId: i.variantId ?? 0, qty: i.qty ?? 0, unitPrice: i.unitPrice ?? 0 })),
            ip: ''
        };
        try { await postJson(url, payload, currentOpts?.jwt, currentOpts?.deviceUuid); } catch { }
        reservedState = { code, reserved: true };
    }
    async function releaseVoucher(reason = 'user_clear_or_switch') {
        if (!reservedState.reserved) return;
        const url = (currentOpts.apiBase || '').replace(/\/+$/, '') + '/api/promotions/cart/release';
        try { await postJson(url, { orderId: 0, reason }, currentOpts?.jwt, currentOpts?.deviceUuid); } catch { }
        reservedState = { code: "", reserved: false };
    }

    // ===== Quote & totals =====
    async function quoteAndPatchTotals(opts, code) {
        const { items, subtotal } = collectSelectedItems(opts.selectors.selectedLinesHidden);
        const ship = getNumberFromLabel(opts.selectors.lblShipping) || 0;

        // ⬇️ Nếu không có mã => KHÔNG gọi BE, không auto-apply
        if (!code) {
            setText(opts.selectors.hidPromoDiscount, '0');
            setText(opts.selectors.lblDiscount, '0 ₫');

            const vat = readMoney(opts.selectors.lblVat);
            const grand = Math.max(0, subtotal + vat + ship);
            setText(opts.selectors.lblGrandTotal, fmtVn(grand));

            await releaseVoucher('no_code');   // an toàn (no-op nếu chưa reserve)
            updateAppliedChip();
            return;                            // <-- dừng tại đây
        }

        if (!items.length) {
            setText(opts.selectors.hidPromoDiscount, '0'); setText(opts.selectors.lblDiscount, '0 ₫');
            const vat = readMoney(opts.selectors.lblVat); const grand = Math.max(0, subtotal + vat + ship);
            setText(opts.selectors.lblGrandTotal, fmtVn(grand));
            await releaseVoucher('empty_items');
            updateAppliedChip(); return;
        }

        const url = (opts.apiBase || '').replace(/\/+$/, '') + '/api/promotions/cart/quote';
        const payload = { channel: opts.channel || 1, code: (code || '').trim() || null, items, subtotal, shippingFee: ship, nowUtc: new Date().toISOString() };
        const payloadFallback = {
            channel: payload.channel, code: payload.code,
            items_json: JSON.stringify(items.map(i => ({ product_id: i.productId ?? null, variant_id: i.variantId ?? null, qty: i.qty ?? 0, unit_price: i.unitPrice ?? 0 }))),
            subtotal: payload.subtotal, shipping_fee: ship, now_utc: payload.nowUtc
        };

        let r = await postJson(url, payload, opts.jwt, opts.deviceUuid);
        if (!r.ok && (r.status === 500 || r.json?.code === 'ERROR')) r = await postJson(url, payloadFallback, opts.jwt, opts.deviceUuid);
        if (!r.ok) {
            setText(opts.selectors.hidPromoDiscount, '0'); setText(opts.selectors.lblDiscount, '0 ₫');
            const vat = readMoney(opts.selectors.lblVat); const grand = Math.max(0, subtotal + vat + ship);
            setText(opts.selectors.lblGrandTotal, fmtVn(grand));
            await releaseVoucher('quote_failed');
            updateAppliedChip(); return;
        }

        const best = get(r.json, 'best') ?? get(r.json, 'Best') ?? {};
        const totalDiscount = get(best, 'total_discount') ?? get(best, 'totalDiscount') ?? 0;

        if ((payload.code && !totalDiscount && (r.json?.applied?.codeInvalid === true)) || (r.json?.applied === false)) {
            await releaseVoucher('invalid_code');
            setAppliedCode('', null);
        }

        const vat = readMoney(opts.selectors.lblVat);
        const grand = Math.max(0, subtotal + vat + ship - (Number(totalDiscount) || 0));
        setText(opts.selectors.hidPromoDiscount, String(totalDiscount || 0));
        setText(opts.selectors.lblDiscount, (totalDiscount ? '-' : '') + fmtVn(totalDiscount || 0));
        setText(opts.selectors.lblGrandTotal, fmtVn(grand));
        updateAppliedChip();

        if ((Number(totalDiscount) || 0) > 0 && payload.code) {
            await reserveVoucher(String(payload.code));
        } else {
            await releaseVoucher('no_discount');
        }
    }

    // ===== Inline renderer (giữ cho ARIA / fallback) =====
    function renderVouchers(listSel, promos) {
        const host = document.querySelector(listSel); if (!host) return;
        host.innerHTML = ''; const list = Array.isArray(promos) ? promos : [];
        if (!list.length) { host.innerHTML = '<div class="vouch-note">Hiện chưa có khuyến mãi phù hợp cho giỏ hàng này.</div>'; updateAppliedChip(); return; }
        const applied = getAppliedCode();

        for (const p of list) {
            const name = p.name ?? p.code ?? 'Khuyến mãi';
            const code = p.code ?? p.Code ?? '';
            const desc = p.status_text ?? p.statusText ?? p.description ?? 'Áp dụng theo điều kiện chương trình.';
            const disabled = (p.is_disabled === true) || (p.isDisabled === true) || (p.eligible === false) || (p.Eligible === false) || (p.can_apply === false) || (p.canApply === false) || (typeof desc === 'string' && /không|chưa|hết/i.test(desc));
            const isActive = applied && code && (applied.toUpperCase() === String(code).toUpperCase());
            const card = document.createElement('div'); card.className = 'voucher-card';
            card.innerHTML =
                '<div class="vouch-icon"><i class="bi bi-ticket-perforated"></i></div>' +
                '<div class="vouch-main">' +
                `<div class="vouch-name">${name}</div>` +
                (code ? `<div class="vouch-code">${code}</div>` : '') +
                `<div class="vouch-desc">${desc}</div>` +
                '</div>' +
                '<div class="vouch-cta"></div>';
            const cta = card.querySelector('.vouch-cta');

            if (isActive) {
                const btn = document.createElement('button'); btn.type = 'button'; btn.className = 'vouch-apply is-active'; btn.textContent = 'Đang áp dụng'; btn.disabled = true; cta.appendChild(btn);
                const rm = document.createElement('button'); rm.type = 'button'; rm.className = 'vouch-remove'; rm.textContent = 'Gỡ mã';
                rm.addEventListener('click', async (e) => { e.preventDefault(); await clearVoucherAndRefresh(); });
                cta.appendChild(rm);
            } else {
                const btn = document.createElement('button'); btn.type = 'button'; btn.className = 'vouch-apply'; btn.textContent = 'Áp dụng'; btn.disabled = !!disabled || !code;
                btn.addEventListener('click', async (e) => {
                    e.preventDefault(); e.stopPropagation();
                    setAppliedCode(code, p || {});
                    setText(currentOpts.selectors.hidPromoDiscount, '0');
                    setText(currentOpts.selectors.txtPromo, code);
                    setText(currentOpts.selectors.lblDiscount, '(sẽ tính ở bước xác nhận)');
                    await quoteAndPatchTotals(currentOpts, code);
                    renderVouchers(listSel, list);
                });
                cta.appendChild(btn);
            }
            host.appendChild(card);
        }
        updateAppliedChip();
    }

    async function clearVoucherAndRefresh() {
        const had = getAppliedCode();
        setAppliedCode('', null);
        setText(currentOpts.selectors.hidPromoDiscount, '0');
        setText(currentOpts.selectors.lblDiscount, '0 ₫');
        setText(currentOpts.selectors.txtPromo, '');
        setText(currentOpts.selectors.hidPromoMetaJson, '');
        await quoteAndPatchTotals(currentOpts, '');
        if (had) await releaseVoucher('user_clear');
        renderVouchers(currentOpts.selectors.listEl, []); // sync aria
    }

    // ===== Refresh list =====
    async function refreshList(opts) {
        const { items } = collectSelectedItems(opts.selectors.selectedLinesHidden);
        if (!items || items.length === 0) { renderVouchers(opts.selectors.listEl, [], null); updateAppliedChip(); return; }

        const baseUrl = (opts.apiBase || '').replace(/\/+$/, '') + '/api/promotions/cart/list';
        const payload = { channel: opts.channel || 1, items, subtotal: items.reduce((s, it) => s + (it.unitPrice || 0) * (it.qty || 0), 0), shippingFee: getNumberFromLabel(opts.selectors.lblShipping) || 0, nowUtc: new Date().toISOString(), limit: 50 };
        const payloadFallback = {
            channel: payload.channel,
            items_json: JSON.stringify(items.map(i => ({ product_id: i.productId ?? null, variant_id: i.variantId ?? null, qty: i.qty ?? 0, unit_price: i.unitPrice ?? 0 }))),
            subtotal: payload.subtotal, shipping_fee: payload.shippingFee, now_utc: payload.nowUtc, limit: payload.limit
        };

        try {
            let r = await postJson(baseUrl, payload, currentOpts?.jwt, currentOpts?.deviceUuid);
            if (!r.ok && (r.status === 500 || r.json?.code === 'ERROR')) r = await postJson(baseUrl, payloadFallback, currentOpts?.jwt, currentOpts?.deviceUuid);
            if (!r.ok) { if (r.status === 400 && r.json?.errors?.Items) { renderVouchers(opts.selectors.listEl, [], null); return; } throw r.json || { message: 'Fetch failed' }; }
            const promos = normalizePromotions(r.json);
            renderVouchers(opts.selectors.listEl, promos);
            const code = getAppliedCode(); if (code) { quoteAndPatchTotals(opts, code); }
            updateAppliedChip();
        } catch {
            renderVouchers(opts.selectors.listEl, [], null); updateAppliedChip();
        }
    }

    // ===== Wiring =====
    function wireManualCodeSync(opts) {
        const txt = document.querySelector(opts.selectors.txtPromo); if (!txt) return;
        txt.addEventListener('input', () => {
            const code = (txt.value || '').trim();
            if (!code) { setText(opts.selectors.hidPromoCode, ''); setText(opts.selectors.hidPromoMetaJson, ''); setText(opts.selectors.hidPromoDiscount, '0'); setText(opts.selectors.lblDiscount, '0 ₫'); }
            else { setText(opts.selectors.hidPromoCode, code); setText(opts.selectors.hidPromoMetaJson, ''); setText(opts.selectors.hidPromoDiscount, '0'); setText(opts.selectors.lblDiscount, '(sẽ tính ở bước xác nhận)'); }
            updateAppliedChip();
        });
    }
    function hookFormSubmit(opts) {
        if (!opts.formSelector) return; const form = document.querySelector(opts.formSelector); if (!form) return;
        form.addEventListener('submit', () => {
            try { const code = document.querySelector(opts.selectors.hidPromoCode)?.value || ''; const box = document.querySelector(opts.selectors.txtPromo); if (code && box && !box.value) box.value = code; } catch { }
        });
    }
    function hookCartChanges(opts) {
        const doRequote = debounce(() => { const code = getAppliedCode(); if (code) quoteAndPatchTotals(opts, code); }, 150);
        document.addEventListener('change', (e) => { if (e.target.matches('.cart-item input[type="checkbox"]')) { refreshList(opts); doRequote(); } });
        document.addEventListener('click', (e) => { const inc = e.target.closest('.qty-btn[data-inc]'); const dec = e.target.closest('.qty-btn[data-dec]'); if (inc || dec) { setTimeout(() => { refreshList(opts); doRequote(); }, 50); } });
    }

    function initCartVouchers(opts) {
        if (!opts || !opts.apiBase) return;
        currentOpts = opts; hookFormSubmit(opts); wireManualCodeSync(opts); hookCartChanges(opts);

        const ready = () => {
            const hasItems = document.querySelectorAll('.cart-item').length > 0;
            const hid = document.querySelector(opts.selectors.selectedLinesHidden);
            const hiddenHasValue = !!(hid && hid.value && hid.value.trim());
            if (hasItems || hiddenHasValue) { refreshList(opts); return true; } return false;
        };
        if (!ready()) {
            if (document.readyState === 'loading') { document.addEventListener('DOMContentLoaded', () => { if (!ready()) setTimeout(ready, 120); }); }
            else { setTimeout(ready, 120); }
        }

        // ===== Modal wiring (delegation) =====
        // ===== Modal wiring (delegation) =====
        (function modalWiring() {
            let loading = false;
            let lastOpener = null;   

            // Tự tạo modal nếu thiếu
            function ensureModalExists() {
                if (document.querySelector('#voucherModal')) return;
                const tpl = document.createElement('template');
                tpl.innerHTML = `
      <div id="voucherModalBk" class="vouch-bk" aria-hidden="true"></div>
      <div id="voucherModal" class="vouch-modal" role="dialog" aria-modal="true" aria-hidden="true">
        <div class="vouch-sheet">
          <div class="vouch-hd">
            <div class="vouch-title"><i class="bi bi-ticket-perforated"></i> Chọn khuyến mãi</div>
            <button id="voucherCloseBtn" class="vouch-x" aria-label="Đóng">×</button>
          </div>
          <div class="vouch-subhd">
            <input id="voucherManualInput" class="vouch-input" type="text" placeholder="Nhập mã khuyến mãi">
            <button id="voucherManualApply" class="vouch-apply2" type="button">Áp dụng</button>
          </div>
          <div id="voucherModalList" class="vouch-list" tabindex="0"></div>
          <div class="vouch-ft">
            <button id="voucherBackBtn" class="vouch-btn ghost" type="button">Trở lại</button>
            <button id="voucherOkBtn" class="vouch-btn primary" type="button">Xác nhận</button>
          </div>
        </div>
      </div>
    `.trim();
                document.body.appendChild(tpl.content);
            }

            function queryModalEls() {
                const md = document.querySelector('#voucherModal');
                if (!md) return null;
                return {
                    md,
                    bk: document.querySelector('#voucherModalBk'),
                    listHost: document.querySelector('#voucherModalList'),
                    btnOk: document.querySelector('#voucherOkBtn'),
                    btnX: document.querySelector('#voucherCloseBtn'),
                    btnBack: document.querySelector('#voucherBackBtn'),
                    txtManual: document.querySelector('#voucherManualInput'),
                    btnManual: document.querySelector('#voucherManualApply'),
                };
            }
            function open(mdEls, openerEl) {
                lastOpener = openerEl || lastOpener || document.querySelector('#lnkOpenVoucher');

                // đảm bảo hiển thị trước khi animate
                if (mdEls.bk) { mdEls.bk.style.display = 'block'; }
                mdEls.md.style.display = 'grid';        // <- show modal container

                mdEls.bk?.classList.add('open');
                mdEls.md.classList.add('open');
                mdEls.md.removeAttribute('inert');
                mdEls.md.setAttribute('aria-hidden', 'false');

                // chuyển focus vào modal
                (mdEls.txtManual || mdEls.listHost || mdEls.btnX || mdEls.btnOk)?.focus?.();
            }

            function close(mdEls) {
                // blur phần tử đang focus trong modal để tránh cảnh báo aria-hidden
                const ae = document.activeElement;
                if (ae && mdEls.md.contains(ae)) ae.blur();

                mdEls.md.classList.remove('open');
                mdEls.bk?.classList.remove('open');
                mdEls.md.setAttribute('inert', '');
                mdEls.md.setAttribute('aria-hidden', 'true');

                // Ẩn hẳn sau khi kết thúc transition (200ms). Fallback bằng setTimeout.
                const HIDE_MS = 200;
                const hideNow = () => {
                    mdEls.md.style.display = 'none';
                    if (mdEls.bk) mdEls.bk.style.display = 'none';
                    lastOpener?.focus?.();     // trả focus về nút mở
                };
                let done = false;
                const onEnd = () => { if (done) return; done = true; mdEls.md.removeEventListener('transitionend', onEnd); hideNow(); };
                mdEls.md.addEventListener('transitionend', onEnd, { once: true });
                setTimeout(onEnd, HIDE_MS + 50); // fallback nếu transitionend không bắn
            }



            async function loadListInto(mdEls) {
                const { listHost, btnOk, txtManual, btnManual } = mdEls;
                if (listHost) listHost.innerHTML = '<div class="vouch-note">Đang tải…</div>';
                try {
                    const baseUrl = (currentOpts.apiBase || '').replace(/\/+$/, '') + '/api/promotions/cart/list';
                    const { items } = collectSelectedItems(currentOpts.selectors.selectedLinesHidden);
                    const payload = {
                        channel: currentOpts.channel || 1, items,
                        subtotal: items.reduce((s, it) => s + (it.unitPrice || 0) * (it.qty || 0), 0),
                        shippingFee: getNumberFromLabel(currentOpts.selectors.lblShipping) || 0,
                        nowUtc: new Date().toISOString(), limit: 100
                    };
                    const payloadFallback = {
                        channel: payload.channel,
                        items_json: JSON.stringify(items.map(i => ({ product_id: i.productId ?? null, variant_id: i.variantId ?? null, qty: i.qty ?? 0, unit_price: i.unitPrice ?? 0 }))),
                        subtotal: payload.subtotal, shipping_fee: payload.shippingFee, now_utc: payload.nowUtc, limit: payload.limit
                    };
                    let r = await postJson(baseUrl, payload, currentOpts?.jwt, currentOpts?.deviceUuid);
                    if (!r.ok && (r.status === 500 || r.json?.code === 'ERROR')) r = await postJson(baseUrl, payloadFallback, currentOpts?.jwt, currentOpts?.deviceUuid);
                    const promos = r.ok ? normalizePromotions(r.json) : [];

                    function rowTpl(p, appliedCode) {
                        const name = p.name ?? p.code ?? 'Khuyến mãi';
                        const code = p.code ?? p.Code ?? '';
                        const desc = p.status_text ?? p.statusText ?? p.description ?? 'Áp dụng theo điều kiện chương trình.';
                        const disabled = (p.is_disabled === true) || (p.isDisabled === true) ||
                            (p.eligible === false) || (p.Eligible === false) ||
                            (p.can_apply === false) || (p.canApply === false) ||
                            (typeof desc === 'string' && /không|chưa|hết/i.test(desc));
                        const isActive = appliedCode && code && (appliedCode.toUpperCase() === String(code).toUpperCase());
                        const row = document.createElement('label'); row.className = 'vouch-row';
                        row.innerHTML = `
          <div class="v-lhs">VOUCHER</div>
          <div class="v-mid">
            <div class="v-name">${name} ${p.for_you ? '<span class="voucher-tag">Dành riêng cho bạn</span>' : ''}</div>
            ${code ? `<div class="v-code">${code}</div>` : ''}
            <div class="v-desc">${desc}</div>
          </div>
          <div class="v-cta">
            <input type="radio" name="vsel" class="voucher-radio" ${isActive ? 'checked' : ''} ${disabled ? 'disabled' : ''} data-code="${code}">
          </div>`;
                        return row;
                    }

                    if (listHost) {
                        listHost.innerHTML = '';
                        const applied = getAppliedCode();
                        if (!promos.length) listHost.innerHTML = '<div class="vouch-note">Chưa có voucher phù hợp.</div>';
                        else promos.forEach(p => listHost.appendChild(rowTpl(p, applied)));
                    }

                    btnOk && (btnOk.onclick = async () => {
                        const sel = listHost?.querySelector('.voucher-radio:checked');
                        const code = sel?.dataset.code || '';
                        close(mdEls);                     // đóng ngay để không kẹt aria-hidden
                        if (code) {
                            setAppliedCode(code, { code });
                            setText(currentOpts.selectors.hidPromoDiscount, '0');
                            setText(currentOpts.selectors.lblDiscount, '(sẽ tính ở bước xác nhận)');
                            setText(currentOpts.selectors.txtPromo, code);
                            await quoteAndPatchTotals(currentOpts, code);
                        }
                        refreshList(currentOpts);
                    });


                    btnManual && (btnManual.onclick = async () => {
                        const code = (txtManual?.value || '').trim(); if (!code) return;
                        close(mdEls);
                        setAppliedCode(code, { code });
                        setText(currentOpts.selectors.hidPromoDiscount, '0');
                        setText(currentOpts.selectors.lblDiscount, '(sẽ tính ở bước xác nhận)');
                        setText(currentOpts.selectors.txtPromo, code);
                        await quoteAndPatchTotals(currentOpts, code);
                        refreshList(currentOpts);
                    });

                } catch {
                    if (listHost) listHost.innerHTML = '<div class="vouch-note">Không tải được danh sách voucher.</div>';
                } finally { loading = false; }
            }

            // Click mở modal (delegation)
            document.addEventListener('click', (e) => {
                const a = e.target.closest('#lnkOpenVoucher');
                if (!a) return;
                e.preventDefault();
                ensureModalExists();                 // <- đảm bảo có modal
                const mdEls = queryModalEls();
                if (!mdEls) return;
                open(mdEls, a);

                if (!loading) { loading = true; loadListInto(mdEls); }
                mdEls.btnX && mdEls.btnX.addEventListener('click', () => close(mdEls), { once: true });
                mdEls.btnBack && mdEls.btnBack.addEventListener('click', () => close(mdEls), { once: true });
                mdEls.bk && mdEls.bk.addEventListener('click', () => close(mdEls), { once: true });
            });

            // Nếu sau này DOM thay đổi thì vẫn ok (đã injection + delegation)
            const mo = new MutationObserver(() => { });
            mo.observe(document.documentElement, { childList: true, subtree: true });
        })();

    }

    global.initCartVouchers = initCartVouchers;
})(window);
