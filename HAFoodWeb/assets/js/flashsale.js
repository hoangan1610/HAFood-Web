// /assets/js/flashsale.js (v2.1)
(function () {
    "use strict";

    // ===== Config =====
    const API_BASE = (typeof window.__API_BASE === "string" && window.__API_BASE.length)
        ? window.__API_BASE
        : location.origin;

    const CHANNEL = 1;
    const POLL_MS = 15000;   // 15s
    const TICK_MS = 1000;    // 1s

    const urlActive = () => `${API_BASE}/api/flashsale/active?channel=${CHANNEL}`;
    const urlPrice = (variantId) => `${API_BASE}/api/variants/${variantId}/price?channel=${CHANNEL}`;

    // ===== State =====
    let activeMap = new Map();      // variantId -> rec
    let serverOffsetMs = 0;

    // ===== Utils =====
    const vn = (n) => (Number(n) || 0).toLocaleString("vi-VN") + " ₫";
    function pct(base, eff) {
        base = Number(base); eff = Number(eff);
        if (!base || !eff || base <= eff) return null;
        const p = Math.round((1 - eff / base) * 100);
        return p > 0 ? p : null;
    }
    async function safeJson(r) { try { return await r.json(); } catch { return null; } }
    const nowWithOffset = () => new Date(Date.now() + serverOffsetMs);

    // ===== Fetch active flash sale list =====
    async function fetchActive() {
        try {
            const r = await fetch(urlActive(), { cache: "no-store", credentials: "include" });
            if (!r.ok) {
                if (r.status === 404) {
                    console.warn("[flashsale] /api/flashsale/active -> 404. Dùng fallback per-variant.");
                } else {
                    console.warn("[flashsale] active HTTP", r.status);
                }
                activeMap.clear();
                return;
            }
            const list = await safeJson(r) || [];

            // chỉnh lệch giờ
            if (Array.isArray(list) && list.length > 0 && (list[0].server_Now || list[0].server_now)) {
                const sv = new Date(list[0].server_Now || list[0].server_now).getTime();
                if (!Number.isNaN(sv)) serverOffsetMs = sv - Date.now();
            }

            activeMap.clear();
            for (const it of list) {
                const endRaw = it.end_At ?? it.end_at;
                const rec = {
                    vpoId: it.vpo_Id ?? it.vpo_id ?? null,
                    variantId: it.variant_Id ?? it.variant_id ?? null,
                    base: it.retail_Price ?? it.base_Price ?? it.base_price ?? null,
                    eff: it.effective_Price ?? it.effective_price ?? null,
                    salePrice: it.sale_Price ?? it.campaign_Price ?? it.campaign_price ?? null,
                    percentOff: it.percent_Off ?? it.percent_off ?? null,
                    endAt: endRaw ? new Date(endRaw) : null,                      // <-- KHÔNG ép 0
                    cap: it.qty_Cap_Total ?? it.qty_cap_total ?? null,
                    sold: it.sold_Count ?? it.sold_count ?? 0
                };
                if (rec.variantId != null) activeMap.set(String(rec.variantId), rec);
            }
        } catch (e) {
            console.warn("[flashsale] fetchActive failed:", e);
            activeMap.clear();
        }
    }

    // ===== Per-variant fallback =====
    async function fetchVariantPrice(variantId) {
        try {
            const r = await fetch(urlPrice(variantId), { cache: "no-store", credentials: "include" });
            if (!r.ok) return null;
            const row = await safeJson(r);
            if (!row) return null;

            const endRaw = row.end_At ?? row.end_at;
            const rec = {
                vpoId: row.vpo_Id ?? row.vpo_id ?? row.vpoId ?? null,
                variantId: row.variant_Id ?? row.variant_id ?? variantId,
                base: row.base_Price ?? row.base_price ?? row.base ?? row.retail_Price ?? row.retail_price ?? null,
                eff: row.effective_Price ?? row.effective_price ?? null,
                salePrice: row.campaign_Price ?? row.campaign_price ?? null,
                percentOff: row.percent_Off ?? row.percent_off ?? null,
                endAt: endRaw ? new Date(endRaw) : null,                        // <-- KHÔNG ép 0
                cap: row.qty_Cap_Total ?? row.qty_cap_total ?? null,
                sold: row.sold_Count ?? row.sold_count ?? 0,
                serverNow: row.server_Now ?? row.server_now
            };

            if (rec.serverNow) {
                const sv = new Date(rec.serverNow).getTime();
                if (!Number.isNaN(sv)) serverOffsetMs = sv - Date.now();
            }
            return rec;
        } catch {
            return null;
        }
    }

    // ===== Apply sale to one card =====
    async function applyCard(card) {
        const sel = card.querySelector(".js-variant-select");
        const priceNow = card.querySelector(".js-price-now");
        const priceOld = card.querySelector(".js-price-old");
        const badge = card.querySelector(".js-badge-off");
        const cdEl = card.querySelector(".js-countdown");
        const remainEl = card.querySelector(".js-remaining");

        // reset UI
        if (priceOld) { priceOld.style.display = "none"; priceOld.textContent = ""; }
        if (badge) { badge.style.display = "none"; badge.textContent = ""; }
        if (cdEl) { cdEl.textContent = ""; }
        card.removeAttribute("data-end");
        card.removeAttribute("data-remaining");
        if (remainEl) remainEl.textContent = "";

        if (!sel || sel.options.length === 0) return;

        // pick variant có sale từ activeMap trước
        let chosen = null;
        for (const opt of sel.options) {
            const d = activeMap.get(String(opt.value));
            if (d) { chosen = d; break; }
        }
        // fallback: hỏi giá 1 biến thể đầu
        if (!chosen) {
            const vFirst = sel.options[0]?.value;
            if (vFirst) {
                const rec = await fetchVariantPrice(vFirst);
                if (rec && rec.eff != null) {
                    chosen = rec;
                    activeMap.set(String(vFirst), rec);
                } else {
                    return; // không sale -> giữ nguyên giá server render
                }
            } else return;
        }

        // áp sale
        if (priceNow && chosen.eff != null) priceNow.textContent = vn(chosen.eff);

        const hasRealSale = Number(chosen.base) > Number(chosen.eff || 0);

        if (priceOld) {
            if (hasRealSale) {
                priceOld.textContent = vn(chosen.base);
                priceOld.style.display = "inline";
            } else {
                priceOld.style.display = "none";
                priceOld.textContent = "";
            }
        }

        const p = pct(chosen.base, chosen.eff);
        if (badge) {
            if (p) { badge.textContent = `-${p}%`; badge.style.display = "block"; }
            else { badge.style.display = "none"; badge.textContent = ""; }
        }

        // chỉ set countdown nếu có sale & endAt hợp lệ & còn tương lai
        if (hasRealSale && chosen.endAt instanceof Date && !isNaN(chosen.endAt) && chosen.endAt > nowWithOffset()) {
            card.dataset.end = chosen.endAt.toISOString();
        } else {
            card.removeAttribute("data-end");
            if (cdEl) cdEl.textContent = "";
        }

        if (remainEl) {
            if (chosen.cap != null) {
                const rem = Math.max(0, Number(chosen.cap) - Number(chosen.sold || 0));
                remainEl.textContent = `Còn ${rem} suất`;
                card.dataset.remaining = String(rem);
            } else {
                remainEl.textContent = "";
                card.removeAttribute("data-remaining");
            }
        }

        // khi đổi biến thể
        sel.addEventListener("change", async function onChange() {
            const vid = String(this.value);
            let d = activeMap.get(vid);
            if (!d) {
                d = await fetchVariantPrice(vid);
                if (d) activeMap.set(vid, d);
            }
            // reset
            if (priceOld) { priceOld.style.display = "none"; priceOld.textContent = ""; }
            if (badge) { badge.style.display = "none"; badge.textContent = ""; }
            if (cdEl) { cdEl.textContent = ""; }
            card.removeAttribute("data-end");
            card.removeAttribute("data-remaining");
            if (remainEl) remainEl.textContent = "";

            if (!d) return;

            if (priceNow && d.eff != null) priceNow.textContent = vn(d.eff);

            const real2 = Number(d.base) > Number(d.eff || 0);
            if (priceOld) {
                if (real2) { priceOld.textContent = vn(d.base); priceOld.style.display = "inline"; }
                else { priceOld.style.display = "none"; priceOld.textContent = ""; }
            }

            const p2 = pct(d.base, d.eff);
            if (badge) { if (p2) { badge.textContent = `-${p2}%`; badge.style.display = "block"; } else { badge.style.display = "none"; } }

            if (real2 && d.endAt instanceof Date && !isNaN(d.endAt) && d.endAt > nowWithOffset()) {
                card.dataset.end = d.endAt.toISOString();
            } else {
                card.removeAttribute("data-end");
                if (cdEl) cdEl.textContent = "";
            }

            if (remainEl) {
                if (d.cap != null) {
                    const rem2 = Math.max(0, Number(d.cap) - Number(d.sold || 0));
                    remainEl.textContent = `Còn ${rem2} suất`;
                    card.dataset.remaining = String(rem2);
                } else {
                    remainEl.textContent = "";
                    card.removeAttribute("data-remaining");
                }
            }
        }, { once: true });
    }

    function applyAllCards() {
        document.querySelectorAll(".js-product-card").forEach(c => { applyCard(c); });
    }

    function tick() {
        const now = nowWithOffset();
        document.querySelectorAll(".js-product-card[data-end]").forEach(card => {
            const cdEl = card.querySelector(".js-countdown");
            if (!cdEl) return;
            const end = new Date(card.dataset.end);
            if (isNaN(end)) { card.removeAttribute("data-end"); cdEl.textContent = ""; return; }

            let secs = Math.floor((end - now) / 1000);
            if (secs <= 0) { // hết hạn -> ẩn countdown
                card.removeAttribute("data-end");
                cdEl.textContent = "";
                return;
            }
            const h = String(Math.floor(secs / 3600)).padStart(2, "0");
            const m = String(Math.floor((secs % 3600) / 60)).padStart(2, "0");
            const s = String(secs % 60).padStart(2, "0");
            cdEl.textContent = `Kết thúc sau ${h}:${m}:${s}`;
        });
    }

    async function poll() {
        await fetchActive();   // 404 -> clear map; applyCard sẽ fallback per-variant
        applyAllCards();
    }

    document.addEventListener("DOMContentLoaded", async function () {
        if (!API_BASE || /^https?:\/\//.test(API_BASE) === false) {
            console.warn("[flashsale] API_BASE không hợp lệ. Fallback:", location.origin);
        } else if (new URL(API_BASE, location.href).origin !== location.origin) {
            // nhớ bật CORS phía API
        }

        await poll();
        setInterval(tick, TICK_MS);
        setInterval(poll, POLL_MS);
    });
})();
