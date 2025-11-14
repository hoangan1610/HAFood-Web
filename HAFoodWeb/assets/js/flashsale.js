// /assets/js/flashsale.js (v3.3 - SSE + Poll, offset chỉ lấy từ HTTP)
(function () {
    "use strict";

    // ===== Config =====
    const API_BASE = (typeof window.__API_BASE === "string" && window.__API_BASE.length)
        ? window.__API_BASE
        : location.origin;

    const CHANNEL = 1;
    const TICK_MS = 1000;          // 1s countdown
    const POLL_BASE_MS = 15000;    // 15s
    const POLL_MAX_MS = 300000;    // 5 phút

    const urlActive = () => `${API_BASE}/api/flashsale/active?channel=${CHANNEL}`;
    const urlPrice = (variantId) => `${API_BASE}/api/variants/${variantId}/price?channel=${CHANNEL}`;
    const urlSse = () => `${API_BASE}/api/realtime/flashsale?channel=${CHANNEL}`;

    // ===== State =====
    let activeMap = new Map();     // variantId -> rec (đang có flash sale)
    let noSaleSet = new Set();     // variantId đã biết chắc không có flash sale (cache âm)
    let serverOffsetMs = 0;        // lệch giờ server - client

    let sse = null;                // EventSource
    let tickTimer = null;          // interval cho countdown
    let pollTimer = null;          // timeout cho poll fallback
    let pollDelayMs = POLL_BASE_MS;

    const boundSelects = new WeakSet(); // tránh add nhiều listener change

    // "sse" | "poll"
    let mode = "sse";

    // ===== Utils =====
    const vn = (n) => (Number(n) || 0).toLocaleString("vi-VN") + " ₫";

    function pct(base, eff) {
        base = Number(base); eff = Number(eff);
        if (!base || !eff || base <= eff) return null;
        const p = Math.round((1 - eff / base) * 100);
        return p > 0 ? p : null;
    }

    async function safeJson(r) {
        try { return await r.json(); } catch { return null; }
    }

    const nowWithOffset = () => new Date(Date.now() + serverOffsetMs);

    function updateServerOffset(serverNow) {
        if (!serverNow) return;
        const t = new Date(serverNow).getTime();
        if (!Number.isNaN(t)) {
            serverOffsetMs = t - Date.now();
        }
    }

    // ===== Cập nhật activeMap từ danh sách server trả về =====
    // updateOffset: mặc định true (HTTP), SSE truyền false
    function updateActiveFromList(list, serverNowHint, updateOffset = true) {
        const arr = Array.isArray(list) ? list : [];
        if (!arr.length) {
            activeMap.clear();
            return { ok: true, hasSale: false };
        }

        if (updateOffset) {
            let sv = serverNowHint;
            if (!sv) {
                const first = arr[0];
                sv = first && (first.server_Now || first.server_now || first.serverNow);
            }
            updateServerOffset(sv);
        }

        activeMap.clear();

        for (const it of arr) {
            const endRaw = it.end_At ?? it.end_at ?? it.endAt;
            const rec = {
                vpoId: it.vpo_Id ?? it.vpo_id ?? it.vpoId ?? null,
                variantId: it.variant_Id ?? it.variant_id ?? it.variantId ?? null,
                base: it.retail_Price ?? it.retail_price ?? it.base_Price ?? it.base_price ?? null,
                eff: it.effective_Price ?? it.effective_price ?? it.effectivePrice ?? null,
                salePrice: it.sale_Price ?? it.sale_price ?? it.campaign_Price ?? it.campaign_price ?? null,
                percentOff: it.percent_Off ?? it.percent_off ?? it.percentOff ?? null,
                endAt: endRaw ? new Date(endRaw) : null,
                cap: it.qty_Cap_Total ?? it.qty_cap_total ?? it.qtyCapTotal ?? null,
                sold: it.sold_Count ?? it.sold_count ?? it.soldCount ?? 0
            };
            if (rec.variantId != null) {
                const key = String(rec.variantId);
                activeMap.set(key, rec);
                if (noSaleSet.has(key)) noSaleSet.delete(key);
            }
        }

        return { ok: true, hasSale: activeMap.size > 0 };
    }

    // ===== Fallback: Fetch active qua HTTP (poll) =====
    async function fetchActiveOnce() {
        try {
            const r = await fetch(urlActive(), { cache: "no-store", credentials: "include" });
            if (!r.ok) {
                if (r.status === 404) {
                    console.warn("[flashsale] /active -> 404, clear activeMap.");
                    activeMap.clear();
                    return { ok: true, hasSale: false };
                }
                console.warn("[flashsale] active HTTP", r.status);
                return { ok: false, hasSale: false };
            }
            const list = await safeJson(r) || [];
            // HTTP => updateOffset = true
            return updateActiveFromList(list, null, true);
        } catch (e) {
            console.warn("[flashsale] fetchActiveOnce failed:", e);
            return { ok: false, hasSale: false };
        }
    }

    async function pollOnce() {
        const res = await fetchActiveOnce();
        applyAllCards();
        return res;
    }

    async function pollLoop() {
        pollTimer = null;
        const { ok, hasSale } = await pollOnce();

        if (!ok || !hasSale) {
            pollDelayMs = Math.min(pollDelayMs * 2, POLL_MAX_MS);
        } else {
            pollDelayMs = POLL_BASE_MS;
        }

        if (!sse && mode === "poll") {
            pollTimer = setTimeout(pollLoop, pollDelayMs);
        }
    }

    function startPollingFallback() {
        if (pollTimer || sse) return;
        mode = "poll";
        pollDelayMs = POLL_BASE_MS;
        pollTimer = setTimeout(pollLoop, 0);
    }

    function stopPolling() {
        if (pollTimer) {
            clearTimeout(pollTimer);
            pollTimer = null;
        }
    }

    // ===== Per-variant fallback (với cache âm) =====
    async function fetchVariantPrice(variantId) {
        const key = String(variantId);

        if (noSaleSet.has(key)) return null;

        try {
            const r = await fetch(urlPrice(variantId), { cache: "no-store", credentials: "include" });
            if (!r.ok) {
                noSaleSet.add(key);
                return null;
            }
            const row = await safeJson(r);
            if (!row) {
                noSaleSet.add(key);
                return null;
            }

            const endRaw = row.end_At ?? row.end_at ?? row.endAt;
            const rec = {
                vpoId: row.vpo_Id ?? row.vpo_id ?? row.vpoId ?? null,
                variantId: row.variant_Id ?? row.variant_id ?? variantId,
                base: row.base_Price ?? row.base_price ?? row.base ?? row.retail_Price ?? row.retail_price ?? null,
                eff: row.effective_Price ?? row.effective_price ?? row.effectivePrice ?? null,
                salePrice: row.campaign_Price ?? row.campaign_price ?? row.sale_Price ?? row.sale_price ?? null,
                percentOff: row.percent_Off ?? row.percent_off ?? row.percentOff ?? null,
                endAt: endRaw ? new Date(endRaw) : null,
                cap: row.qty_Cap_Total ?? row.qty_cap_total ?? row.qtyCapTotal ?? null,
                sold: row.sold_Count ?? row.sold_count ?? row.soldCount ?? 0,
                serverNow: row.server_Now ?? row.server_now ?? row.serverNow
            };

            if (rec.serverNow) updateServerOffset(rec.serverNow);

            const hasRealSale = Number(rec.base) > Number(rec.eff || 0);
            if (!hasRealSale) {
                noSaleSet.add(key);
                return null;
            }

            return rec;
        } catch (e) {
            console.warn("[flashsale] fetchVariantPrice error", e);
            noSaleSet.add(key);
            return null;
        }
    }

    // ===== Apply sale cho 1 card =====
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

        // ưu tiên biến thể có sale trong activeMap
        let chosen = null;
        for (const opt of sel.options) {
            const d = activeMap.get(String(opt.value));
            if (d) { chosen = d; break; }
        }

        // Fallback /variants/{id}/price: chỉ dùng khi đang poll
        if (!chosen) {
            if (mode === "poll") {
                const vFirst = sel.options[0]?.value;
                if (vFirst) {
                    const rec = await fetchVariantPrice(vFirst);
                    if (rec && rec.eff != null) {
                        chosen = rec;
                        activeMap.set(String(vFirst), rec); // cache dương
                    } else {
                        return; // không sale -> giữ nguyên giá SSR
                    }
                } else return;
            } else {
                // mode SSE: nếu không có trong activeMap thì coi như không sale
                return;
            }
        }

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

        const p1 = pct(chosen.base, chosen.eff);
        if (badge) {
            if (p1) {
                badge.textContent = `-${p1}%`;
                badge.style.display = "block";
            } else {
                badge.style.display = "none";
                badge.textContent = "";
            }
        }

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

        // ===== khi đổi biến thể =====
        if (!boundSelects.has(sel)) {
            sel.addEventListener("change", async function onChange() {
                const vid = String(this.value);
                let d = activeMap.get(vid);
                if (!d) {
                    // Đổi biến thể là action chủ động => chấp nhận gọi price
                    d = await fetchVariantPrice(vid);
                    if (d && d.eff != null) activeMap.set(vid, d);
                }

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
                    if (real2) {
                        priceOld.textContent = vn(d.base);
                        priceOld.style.display = "inline";
                    } else {
                        priceOld.style.display = "none";
                        priceOld.textContent = "";
                    }
                }

                const p2 = pct(d.base, d.eff);
                if (badge) {
                    if (p2) {
                        badge.textContent = `-${p2}%`;
                        badge.style.display = "block";
                    } else {
                        badge.style.display = "none";
                        badge.textContent = "";
                    }
                }

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
            });
            boundSelects.add(sel);
        }
    }

    function applyAllCards() {
        document.querySelectorAll(".js-product-card").forEach(c => { applyCard(c); });
    }

    // ===== Tick: countdown =====
    function tick() {
        const now = nowWithOffset();
        document.querySelectorAll(".js-product-card[data-end]").forEach(card => {
            const cdEl = card.querySelector(".js-countdown");
            if (!cdEl) return;
            const end = new Date(card.dataset.end);
            if (isNaN(end)) {
                card.removeAttribute("data-end");
                cdEl.textContent = "";
                return;
            }

            let secs = Math.floor((end - now) / 1000);
            if (secs <= 0) {
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

    function startTick() {
        if (!tickTimer) {
            tickTimer = setInterval(tick, TICK_MS);
        }
    }

    function stopTick() {
        if (tickTimer) {
            clearInterval(tickTimer);
            tickTimer = null;
        }
    }

    // ===== SSE: lắng nghe flashsale.updated từ BE =====
    function startSse() {
        if (typeof EventSource === "undefined") {
            console.warn("[flashsale] EventSource không hỗ trợ, dùng polling fallback.");
            mode = "poll";
            return false;
        }

        try {
            mode = "sse";
            const es = new EventSource(urlSse(), { withCredentials: true });
            sse = es;

            es.addEventListener("open", () => {
                console.info("[flashsale] SSE connected.");
                stopPolling();
            });

            es.addEventListener("flashsale.updated", (ev) => {
                try {
                    const msg = JSON.parse(ev.data);
                    const items = Array.isArray(msg.items) ? msg.items : [];
                    // serverNow từ SSE KHÔNG dùng để set offset nữa
                    const res = updateActiveFromList(items, null, false);
                    if (res.hasSale || activeMap.size === 0) {
                        applyAllCards();
                    }
                } catch (e) {
                    console.warn("[flashsale] parse SSE payload error:", e);
                }
            });

            es.addEventListener("error", (ev) => {
                console.warn("[flashsale] SSE error, fallback về polling.", ev);
                es.close();
                sse = null;
                mode = "poll";
                startPollingFallback();
            });

            return true;
        } catch (e) {
            console.warn("[flashsale] startSse error:", e);
            sse = null;
            mode = "poll";
            return false;
        }
    }

    // ===== Bootstrap =====
    document.addEventListener("DOMContentLoaded", function () {
        if (!API_BASE || /^https?:\/\//.test(API_BASE) === false) {
            console.warn("[flashsale] API_BASE không hợp lệ. Fallback:", location.origin);
        }

        // 1) Sync 1 lần với API /flashsale/active để lấy giờ server mới nhất
        (async () => {
            await pollOnce();   // cập nhật activeMap + applyAllCards lần đầu
            startTick();        // bắt đầu đếm ngược

            // 2) Kết nối SSE để nhận cập nhật realtime
            const okSse = startSse();
            if (!okSse) {
                startPollingFallback();
            }
        })();

        // 3) Xử lý ẩn/hiện tab
        document.addEventListener("visibilitychange", () => {
            if (document.visibilityState === "hidden") {
                stopTick();
                if (!sse && mode === "poll") stopPolling();
            } else if (document.visibilityState === "visible") {
                startTick();
                if (!sse && mode === "poll" && !pollTimer) {
                    startPollingFallback();
                }
            }
        });
    });
})();
