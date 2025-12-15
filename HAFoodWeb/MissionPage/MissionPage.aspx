<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MissionPage.aspx.cs" Inherits="HAFoodWeb.MissionPage.MissionPage" Async="true" %>

<%@ Register Src="~/Control/Header.ascx" TagPrefix="uc" TagName="Header" %>
<%@ Register Src="~/Control/Footer.ascx" TagPrefix="uc" TagName="Footer" %>

<!DOCTYPE html>
<html lang="vi">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1" />
    <title>Nhiệm vụ của bạn - HAFood</title>

    <meta name="api-base" content="<%: System.Configuration.ConfigurationManager.AppSettings["ApiBaseUrl"] ?? "" %>" />

    <script>
        window.__API_BASE = (document.querySelector('meta[name="api-base"]')?.content || '').replace(/\/+$/, '');
    </script>

    <!-- Bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet" />

    <!-- Fonts (giống HomePage) -->
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <link href="https://fonts.googleapis.com/css2?family=Great+Vibes&family=Playfair+Display:wght@600;700&family=Noto+Serif:wght@400;700&display=swap&subset=latin,vietnamese" rel="stylesheet" />

    <style>
        :root{
            --haf-primary:#2aa33b;
            --haf-accent:#f97316;
            --haf-radius-lg:24px;
            --haf-shadow-subtle:0 10px 30px rgba(15,23,42,.06);
        }

        /* nền chung giống HomePage */
        body{
            margin:0;
            background:radial-gradient(circle at top,#fff7e6 0,#fffaf3 40%,#ffffff 100%);
            color:#111827;
            font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
        }

        /* Khung trang nhiệm vụ dạng card lớn */
        .mission-page-wrap{
            max-width:960px;
            margin:2rem auto 3rem;
            padding:2.25rem 2rem 2.5rem;
            background:rgba(255,255,255,.96);
            border-radius:var(--haf-radius-lg);
            box-shadow:var(--haf-shadow-subtle);
        }
        @media (max-width: 575.98px){
            .mission-page-wrap{
                margin:1.25rem auto 2.25rem;
                padding:1.75rem 1.25rem 2rem;
            }
        }

        /* Font serif cho các phần chữ chính – đồng bộ với HomePage */
        .sec-title,
        .mission-group-title,
        .mission-title,
        .mission-desc,
        .mission-reward,
        .mission-meta{
            font-family:"Noto Serif","Times New Roman",Times,serif;
        }

        .sec-title{
            text-align:center;
            font-weight:700;
            font-style:italic;
            margin-bottom:.5rem;
            letter-spacing:.03em;
        }
        .sec-title::after{
            content:"";
            display:block;
            width:72px;
            height:3px;
            border-radius:999px;
            margin:.45rem auto 0;
            background:linear-gradient(90deg,var(--haf-primary),var(--haf-accent));
        }

        .mission-subtitle{
            font-size:.9rem;
            color:#6b7280;
            text-align:center;
            margin-bottom:1.5rem;
        }

        /* FILTER BAR */
        .mission-filter-bar{
            display:flex;
            flex-wrap:wrap;
            align-items:center;
            justify-content:space-between;
            gap:.75rem;
            margin-bottom:1.25rem;
        }

        .mission-filter-tabs{
            background:#f3f4f6;
            border-radius:999px;
            padding:3px;
        }
        .mission-filter-tabs .btn{
            border-radius:999px;
            border:0;
            font-size:.85rem;
            padding:.3rem .75rem;
            font-family:"Noto Serif","Times New Roman",Times,serif;
            color:#4b5563;
        }
        .mission-filter-tabs .btn:not(.active):hover{
            background:#e5e7eb;
        }
        .mission-filter-tabs .btn.active{
            background:var(--haf-primary);
            color:#fff;
            box-shadow:0 0 0 1px rgba(34,197,94,.3);
        }

        #mission_count_label{
            font-size:.85rem;
            color:#6b7280;
        }

        /* GROUP TITLE */
        .mission-group-title{
            font-weight:600;
            margin:1rem 0 .4rem;
            font-size:.95rem;
            color:#374151;
        }

        /* CARD */
        .mission-card{
            border-radius:16px;
            border:1px solid #e5e7eb;
            padding:12px 14px;
            margin-bottom:10px;
            background:#ffffff;
            box-shadow:var(--haf-shadow-subtle);
            display:flex;
            flex-direction:column;
            gap:4px;
        }
        .mission-card + .mission-card{
            margin-top:6px;
        }

        .mission-header{
            display:flex;
            align-items:center;
            justify-content:space-between;
            gap:.5rem;
            margin-bottom:2px;
        }
        .mission-title{
            font-weight:600;
            font-size:.95rem;
        }
        .mission-status{
            font-size:.75rem;
            padding:2px 10px;
            border-radius:999px;
            white-space:nowrap;
            background:#f3f4f6;
            color:#4b5563;
        }
        .mission-status.available{
            background:#ecfdf3;
            color:#15803d;
        }
        .mission-status.completed{
            background:#eff6ff;
            color:#1d4ed8;
        }
        .mission-status.maxed{
            background:#f3f4f6;
            color:#4b5563;
        }

        .mission-desc{
            font-size:.86rem;
            color:#4b5563;
        }

        .mission-reward{
            font-size:.86rem;
            color:#16a34a;
            display:flex;
            align-items:center;
            gap:.35rem;
            margin-top:2px;
        }
        .mission-reward span:last-child{
            font-weight:600;
        }

        .mission-meta{
            font-size:.78rem;
            color:#9ca3af;
            margin-top:2px;
        }

        /* PROGRESS */
        .mission-progress{
            margin-top:4px;
            height:6px;
            border-radius:999px;
            background:#f3f4f6;
            overflow:hidden;
        }
        .mission-progress-bar{
            height:100%;
            width:0;
            border-radius:999px;
            background:linear-gradient(90deg,#22c55e,#a3e635);
            transition:width .25s ease-out;
        }
        .mission-progress-label{
            font-size:.78rem;
            color:#6b7280;
            margin-top:2px;
        }

        /* text rỗng / lỗi */
        .mission-empty,
        .mission-error{
            font-size:.85rem;
            color:#6b7280;
            text-align:left;
        }
        .mission-error{
            color:#b91c1c;
        }

        @media (max-width: 575.98px){
            .mission-header{
                align-items:flex-start;
                flex-direction:column;
            }
            .mission-status{
                align-self:flex-start;
            }
        }
    </style>
</head>
<body>
    <form runat="server">
        <asp:ScriptManager ID="sm" runat="server" />

        <uc:Header ID="Header1" runat="server" />

        <main class="container mission-page-wrap">
            <h1 class="sec-title">Nhiệm vụ của bạn</h1>
            <p class="mission-subtitle">
                Hoàn thành nhiệm vụ để nhận lượt quay, điểm tích luỹ và nhiều ưu đãi khác.
            </p>

            <!-- Filter -->
            <div class="mission-filter-bar">
                <div class="mission-filter-tabs btn-group btn-group-sm" role="group" aria-label="Lọc nhiệm vụ">
                    <button type="button" class="btn active" data-status-filter="all">Tất cả</button>
                    <button type="button" class="btn" data-status-filter="available">Chưa hoàn thành</button>
                    <button type="button" class="btn" data-status-filter="completed">Đã hoàn thành</button>
                    <button type="button" class="btn" data-status-filter="maxed">Đã tối đa</button>
                </div>

                <small id="mission_count_label" class="text-muted"></small>
            </div>

            <div id="mission_list_full">
                <div class="mission-empty">Đang tải nhiệm vụ...</div>
            </div>
        </main>

        <uc:Footer ID="Footer1" runat="server" />

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

        <!-- MISSIONS PAGE JS (giữ nguyên logic, chỉ sửa class text rỗng / lỗi chút xíu) -->
        <script>
            (function () {
                const API_BASE = (window.__API_BASE || '').replace(/\/+$/, '');
                const MISSIONS_URL = (API_BASE ? API_BASE + '/api/missions/my' : '/api/missions/my');

                const TOKEN = '<%= Session["JwtToken"] as string ?? "" %>';

                const listEl = document.getElementById('mission_list_full');
                const countLabel = document.getElementById('mission_count_label');
                const filterButtons = document.querySelectorAll('[data-status-filter]');
                let allMissions = [];

                function safeInt(v, fallback) {
                    const n = Number(v);
                    return Number.isFinite(n) ? n : fallback;
                }

                function mapReward(m) {
                    const rt = m.rewardType ?? m.reward_type ?? m.RewardType ?? m.Reward_Type;
                    const val = m.rewardValue ?? m.reward_value ?? m.RewardValue ?? m.Reward_Value;

                    if (rt === 0) return { text: `+${val} lượt quay`, icon: '🎡' };
                    if (rt === 1) return { text: `+${val} điểm tích luỹ`, icon: '⭐' };
                    return { text: 'Phần thưởng khác', icon: '🎁' };
                }

                function getStatusRaw(m) {
                    return (m.status ?? m.Status ?? '').toString().toLowerCase();
                }

                function statusLabel(raw) {
                    switch (raw) {
                        case 'available': return { text: 'Chưa hoàn thành', className: 'available' };
                        case 'completed': return { text: 'Đã hoàn thành một phần', className: 'completed' };
                        case 'maxed': return { text: 'Đã hoàn thành tối đa', className: 'maxed' };
                        default: return { text: 'Nhiệm vụ', className: '' };
                    }
                }

                function statusRank(raw) {
                    switch (raw) {
                        case 'available': return 0;
                        case 'completed': return 1;
                        case 'maxed': return 2;
                        default: return 9;
                    }
                }

                function renderMissions(filterStatus) {
                    if (!Array.isArray(allMissions) || allMissions.length === 0) {
                        listEl.innerHTML = '<div class="mission-empty">Hiện chưa có nhiệm vụ nào.</div>';
                        if (countLabel) countLabel.textContent = '';
                        return;
                    }

                    let items = allMissions.map(m => {
                        const raw = getStatusRaw(m);
                        return {
                            raw,
                            rank: statusRank(raw),
                            item: m
                        };
                    });

                    if (filterStatus && filterStatus !== 'all') {
                        items = items.filter(x => x.raw === filterStatus);
                    }

                    items.sort((a, b) => {
                        if (a.rank !== b.rank) return a.rank - b.rank;
                        const va = Number(a.item.rewardValue ?? a.item.RewardValue ?? 0);
                        const vb = Number(b.item.rewardValue ?? b.item.RewardValue ?? 0);
                        return vb - va;
                    });

                    if (items.length === 0) {
                        listEl.innerHTML = '<div class="mission-empty">Không có nhiệm vụ phù hợp bộ lọc.</div>';
                        if (countLabel) countLabel.textContent = '';
                        return;
                    }

                    if (countLabel) {
                        countLabel.textContent = `Có ${items.length} nhiệm vụ`;
                    }

                    const groups = {
                        available: [],
                        completed: [],
                        maxed: [],
                        other: []
                    };

                    items.forEach(w => {
                        if (w.raw === 'available') groups.available.push(w);
                        else if (w.raw === 'completed') groups.completed.push(w);
                        else if (w.raw === 'maxed') groups.maxed.push(w);
                        else groups.other.push(w);
                    });

                    const order = [
                        { key: 'available', title: 'Nhiệm vụ đang mở' },
                        { key: 'completed', title: 'Nhiệm vụ đã tham gia' },
                        { key: 'maxed', title: 'Nhiệm vụ đã hoàn thành tối đa' },
                        { key: 'other', title: 'Khác' }
                    ];

                    listEl.innerHTML = '';

                    order.forEach(g => {
                        const arr = groups[g.key];
                        if (!arr || arr.length === 0) return;

                        const groupTitle = document.createElement('div');
                        groupTitle.className = 'mission-group-title';
                        groupTitle.textContent = g.title;
                        listEl.appendChild(groupTitle);

                        arr.forEach(w => {
                            const m = w.item;
                            const s = statusLabel(w.raw);
                            const reward = mapReward(m);
                            const timesCompleted = safeInt(m.timesCompleted ?? m.TimesCompleted, 0);
                            const maxPerUser = m.maxPerUser ?? m.MaxPerUser;

                            const max = Number(maxPerUser || 0);
                            let progressHtml = '';

                            if (max > 0) {
                                const doneClamped = Math.min(timesCompleted, max);
                                const percent = Math.max(0, Math.min(100, Math.round((doneClamped / max) * 100)));

                                progressHtml = `
                                    <div class="mission-progress" aria-hidden="true">
                                        <div class="mission-progress-bar" style="width:${percent}%;"></div>
                                    </div>
                                    <div class="mission-progress-label">
                                        Tiến độ: ${doneClamped} / ${max} lần
                                    </div>
                                `;
                            }

                            const card = document.createElement('div');
                            card.className = 'mission-card';

                            card.innerHTML = `
                                <div class="mission-header">
                                    <div class="mission-title">${m.name ?? m.Name ?? ''}</div>
                                    <div class="mission-status ${s.className}">
                                        ${s.text}
                                    </div>
                                </div>
                                <div class="mission-desc">
                                    ${(m.description ?? m.Description ?? '') || ''}
                                </div>
                                <div class="mission-reward">
                                    <span>${reward.icon}</span>
                                    <span>${reward.text}</span>
                                </div>
                                <div class="mission-meta">
                                    Đã hoàn thành: ${timesCompleted}${maxPerUser ? ' / ' + maxPerUser + ' lần' : ''}
                                </div>
                                ${progressHtml}
                            `;

                            listEl.appendChild(card);
                        });
                    });
                }

                async function loadMissions() {
                    if (!TOKEN) {
                        listEl.innerHTML =
                            '<div class="mission-empty">Vui lòng đăng nhập để xem nhiệm vụ của bạn.</div>';
                        if (countLabel) countLabel.textContent = '';
                        return;
                    }

                    listEl.innerHTML = '<div class="mission-empty">Đang tải nhiệm vụ...</div>';
                    if (countLabel) countLabel.textContent = '';

                    try {
                        const headers = { 'Accept': 'application/json' };
                        if (TOKEN) {
                            headers['Authorization'] = 'Bearer ' + TOKEN;
                        }

                        const resp = await fetch(MISSIONS_URL, {
                            method: 'GET',
                            headers,
                            credentials: 'include'
                        });

                        if (resp.status === 401) {
                            listEl.innerHTML =
                                '<div class="mission-empty">Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.</div>';
                            return;
                        }

                        if (!resp.ok) {
                            listEl.innerHTML =
                                `<div class="mission-error">Không tải được nhiệm vụ (HTTP ${resp.status}).</div>`;
                            return;
                        }

                        const data = await resp.json();
                        allMissions = Array.isArray(data) ? data : [];
                        renderMissions(getActiveFilter());
                    } catch (err) {
                        console.error('load missions error', err);
                        listEl.innerHTML =
                            '<div class="mission-error">Có lỗi khi tải nhiệm vụ, vui lòng thử lại.</div>';
                    }
                }

                function getActiveFilter() {
                    const btn = document.querySelector('[data-status-filter].active');
                    return btn ? btn.getAttribute('data-status-filter') : 'all';
                }

                function wireFilterButtons() {
                    filterButtons.forEach(btn => {
                        btn.addEventListener('click', function () {
                            filterButtons.forEach(b => b.classList.remove('active'));
                            this.classList.add('active');
                            renderMissions(this.getAttribute('data-status-filter'));
                        });
                    });
                }

                document.addEventListener('DOMContentLoaded', function () {
                    wireFilterButtons();
                    loadMissions();
                });
            })();
        </script>
    </form>
</body>
</html>
