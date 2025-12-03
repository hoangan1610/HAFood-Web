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

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet" />

    <style>
        :root{
            --haf-primary:#2aa33b;
            --haf-accent:#f97316;
            --haf-radius-lg:24px;
            --haf-shadow-subtle:0 10px 30px rgba(15,23,42,.06);
        }
        body{
            background:radial-gradient(circle at top,#fff7e6 0,#fffaf3 40%,#ffffff 100%);
        }

        .mission-page-wrap{
            max-width:960px;
            margin:1.5rem auto 3rem;
        }

        .sec-title{
            text-align:center;
            font-family:"Georgia","Times New Roman",Times,serif;
            font-weight:700;
            font-style:italic;
            margin-bottom:.5rem;
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

        .mission-filter-bar{
            display:flex;
            flex-wrap:wrap;
            align-items:center;
            justify-content:space-between;
            gap:.75rem;
            margin-bottom:1rem;
        }

        .mission-filter-tabs .btn{
            border-radius:999px;
        }
        .mission-filter-tabs .btn.active{
            background:var(--haf-primary);
            border-color:var(--haf-primary);
            color:#fff;
        }

        .mission-group-title{
            font-weight:600;
            margin:.75rem 0 .35rem;
            font-size:.95rem;
            color:#374151;
        }

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
            padding:2px 8px;
            border-radius:999px;
            white-space:nowrap;
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
            font-size:.85rem;
            color:#4b5563;
        }
        .mission-reward{
            font-size:.85rem;
            color:#16a34a;
            display:flex;
            align-items:center;
            gap:.35rem;
        }
        .mission-meta{
            font-size:.78rem;
            color:#9ca3af;
        }

                /* ==== PROGRESS CHO NHIỆM VỤ ==== */
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

    </style>
</head>
<body>
    <form runat="server">
        <asp:ScriptManager ID="sm" runat="server" />

        <uc:Header ID="Header1" runat="server" />

        <main class="container mission-page-wrap">
            <h1 class="sec-title">Nhiệm vụ của bạn</h1>
            <p class="text-center text-muted mb-3">
                Hoàn thành nhiệm vụ để nhận lượt quay, điểm tích luỹ và nhiều ưu đãi khác.
            </p>

            <!-- Filter -->
            <div class="mission-filter-bar">
                <div class="mission-filter-tabs btn-group btn-group-sm" role="group" aria-label="Lọc nhiệm vụ">
                    <button type="button" class="btn btn-outline-secondary active" data-status-filter="all">Tất cả</button>
                    <button type="button" class="btn btn-outline-secondary" data-status-filter="available">Chưa hoàn thành</button>
                    <button type="button" class="btn btn-outline-secondary" data-status-filter="completed">Đã hoàn thành</button>
                    <button type="button" class="btn btn-outline-secondary" data-status-filter="maxed">Đã tối đa</button>
                </div>

                <small id="mission_count_label" class="text-muted"></small>
            </div>

            <div id="mission_list_full">
                <div class="text-muted small">Đang tải nhiệm vụ...</div>
            </div>
        </main>

        <uc:Footer ID="Footer1" runat="server" />

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

        <!-- MISSIONS PAGE JS -->
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
                        case 'maxed':     return { text: 'Đã hoàn thành tối đa', className: 'maxed' };
                        default:          return { text: 'Nhiệm vụ', className: '' };
                    }
                }

                function statusRank(raw) {
                    switch (raw) {
                        case 'available': return 0;
                        case 'completed': return 1;
                        case 'maxed':     return 2;
                        default:          return 9;
                    }
                }

                function renderMissions(filterStatus) {
                    if (!Array.isArray(allMissions) || allMissions.length === 0) {
                        listEl.innerHTML = '<div class="text-muted small">Hiện chưa có nhiệm vụ nào.</div>';
                        if (countLabel) countLabel.textContent = '';
                        return;
                    }

                    // chuẩn hoá + sort
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
                        listEl.innerHTML = '<div class="text-muted small">Không có nhiệm vụ phù hợp bộ lọc.</div>';
                        if (countLabel) countLabel.textContent = '';
                        return;
                    }

                    if (countLabel) {
                        countLabel.textContent = `Có ${items.length} nhiệm vụ`;
                    }

                    // group theo status để người dùng dễ nhìn
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
                    // chưa login
                    if (!TOKEN) {
                        listEl.innerHTML =
                            '<div class="text-muted small">Vui lòng đăng nhập để xem nhiệm vụ của bạn.</div>';
                        if (countLabel) countLabel.textContent = '';
                        return;
                    }

                    listEl.innerHTML = '<div class="text-muted small">Đang tải nhiệm vụ...</div>';
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
                                '<div class="text-muted small">Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.</div>';
                            return;
                        }

                        if (!resp.ok) {
                            listEl.innerHTML =
                                `<div class="text-danger small">Không tải được nhiệm vụ (HTTP ${resp.status}).</div>`;
                            return;
                        }

                        const data = await resp.json();
                        allMissions = Array.isArray(data) ? data : [];
                        renderMissions(getActiveFilter());
                    } catch (err) {
                        console.error('load missions error', err);
                        listEl.innerHTML =
                            '<div class="text-danger small">Có lỗi khi tải nhiệm vụ, vui lòng thử lại.</div>';
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
