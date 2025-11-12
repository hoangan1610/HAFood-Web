// /assets/js/product-flashsale.js (v3)
(function () {
    "use strict";

    // ===== Config =====
    const CFG = (window.ProductFS || {});
    const API_BASE = (typeof window.__API_BASE === 'string' && window.__API_BASE)
        ? window.__API_BASE.replace(/\/+$/, '')
        : location.origin;

    const CHANNEL = Number(CFG.channel || 1);
    const ddlId = CFG.ddlId;
    const priceNowId = CFG.priceNowId || 'priceNow';
    const oldPriceId = CFG.oldPriceId;
    const countdownId = CFG.countdownId || 'fsCountdown';
    const remainId = CFG.remainId || 'fsRemain';

    const ddl = () => document.getElementById(ddlId);
    const priceNowEl = () => document.getElementById(priceNowId);
    const oldPriceEl = () => (oldPriceId ? document.getElementById(oldPriceId) : null);
    const countdownEl = () => document.getElementById(countdownId);
    const remainEl = () => document.getElementById(remainId);

    let serverOffsetMs = 0;
    let currentEndIso = null;
    let tickTimer = null;

    const vn = n => (Number(n) || 0).toLocaleString('vi-VN') + ' ₫';
    const nowWithOffset = () => new Date(Date.now() + serverOffsetMs);
    const hasRealSale = (base, eff) => {
        base = Number(base); eff = Number(eff);
        return !!(base && eff && base > eff);
    };

    function clearSaleUI() {
        const o = oldPriceEl(); if (o) { o.classList.add('d-none'); o.textContent = ''; }
        const c = countdownEl(); if (c) c.textContent = '';
        const r = remainEl(); if (r) r.textContent = '';
        currentEndIso = null;
    }

    function startTick() {
        if (tickTimer) return;
        tickTimer = setInterval(() => {
            if (!currentEndIso) return;
            const c = countdownEl(); if (!c) return;

            const end = new Date(currentEndIso);
            if (isNaN(end)) { c.textContent = ''; currentEndIso = null; return; }

            let secs = Math.floor((end - nowWithOffset()) / 1000);
            if (secs <= 0) { c.textContent = ''; currentEndIso = null; return; }

            const h = String(Math.floor(secs / 3600)).padStart(2, '0');
            const m = String(Math.floor((secs % 3600) / 60)).padStart(2, '0');
            const s = String(secs % 60).padStart(2, '0');
            c.textContent = `Kết thúc sau ${h}:${m}:${s}`;
        }, 1000);
    }

    // ---- API
    async function fetchVariantPrice(variantId) {
        try {
            const r = await fetch(`${API_BASE}/api/variants/${variantId}/price?channel=${CHANNEL}`, {
                cache: 'no-store', credentials: 'include'
            });
            if (!r.ok) return null;
            const j = await r.json().catch(() => null);
            if (!j) return null;

            // sync server time offset nếu có
            const sv = j.server_Now || j.server_now;
            if (sv) {
                const t = new Date(sv).getTime();
                if (!Number.isNaN(t)) serverOffsetMs = t - Date.now();
            }

            const base = j.base_Price ?? j.base_price ?? j.retail_Price ?? j.retail_price ?? null;
            const eff0 = j.effective_Price ?? j.effective_price;
            const campaign = j.campaign_Price ?? j.campaign_price ?? j.sale_Price ?? j.sale_price;
            const eff = (eff0 != null ? eff0 : campaign);     // <-- fallback giá sale

            return {
                base,
                eff,
                endAt: (j.end_At || j.end_at) ? new Date(j.end_At || j.end_at) : null,
                cap: j.qty_Cap_Total ?? j.qty_cap_total ?? null,
                sold: j.sold_Count ?? j.sold_count ?? 0
            };
        } catch { return null; }
    }

    async function applyVariant(variantId) {
        clearSaleUI();
        const data = await fetchVariantPrice(variantId);
        if (!data) return;

        const nowEl = priceNowEl();
        if (nowEl && data.eff != null) nowEl.textContent = vn(data.eff);

        const showCut = hasRealSale(data.base, data.eff);
        const o = oldPriceEl();
        if (o) {
            if (showCut) { o.textContent = vn(data.base); o.classList.remove('d-none'); }
            else { o.textContent = ''; o.classList.add('d-none'); }
        }

        if (showCut && data.endAt instanceof Date && !isNaN(data.endAt) && data.endAt > nowWithOffset()) {
            currentEndIso = data.endAt.toISOString();
            startTick();
        }

        const r = remainEl();
        if (r) {
            if (data.cap != null) {
                const rem = Math.max(0, Number(data.cap) - Number(data.sold || 0));
                r.textContent = `Còn ${rem} suất`;
            } else r.textContent = '';
        }
    }

    function init() {
        if (!ddlId || !priceNowId) return;
        const d = ddl(); if (!d) return;
        // load ngay biến thể đang chọn
        if (d.value) applyVariant(d.value);
        // cập nhật khi đổi biến thể
        d.addEventListener('change', () => { if (d.value) applyVariant(d.value); });
    }

    if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init);
    else init();
})();
