<%@ Page Language="C#" AutoEventWireup="true"
    CodeBehind="Loyalty.aspx.cs"
    Inherits="HAFoodWeb.UserInfo.Loyalty"
    Async="true" %>

<!DOCTYPE html>
<html lang="vi">
<head runat="server">
    <meta charset="utf-8" />
    <title>Điểm thưởng &amp; Ưu đãi - HAFood</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />

    <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" />

    <style>
        :root {
            --haf-primary: #ff7b32;
            --haf-primary-hover: #e8631d;
            --haf-bg: #f5f5f5;
            --haf-border: #e5e7eb;
            --haf-text-main: #111827;
            --haf-text-muted: #6b7280;
            --haf-success: #22c55e;
            --haf-danger: #ef4444;
        }

        * { box-sizing: border-box; }

        body {
            font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
            margin: 0;
            padding: 20px 10px 30px;
            background:
              radial-gradient(circle at top left,
                               #ffe8cc 0,
                               #ffe0bd 20%,
                               #fdf5ee 40%,
                               #f5f5f5 70%,
                               #f5f5f5 100%);
        }

        .loyalty-page {
            width: 100%;
            max-width: 960px;
            margin: 0 auto;
        }

        .loyalty-header {
            margin-bottom: 10px;
        }

        .title-badge {
            font-size: .75rem;
            letter-spacing: .08em;
            text-transform: uppercase;
            font-weight: 700;
            color: #fd7e14;
            background: rgba(253, 126, 20, .08);
            padding: .26rem .7rem;
            border-radius: 999px;
            display: inline-flex;
            align-items: center;
            gap: .35rem;
            margin-bottom: 0;
        }

        .title-badge i { font-size: .9rem; }

        .page-title {
            font-weight: 700;
            font-size: 1.7rem;
            color: #212529;
            margin: 0.2rem 0 0.1rem;
        }

        .page-subtitle {
            font-size: .9rem;
            color: #6c757d;
            margin: 0;
        }

        .loyalty-layout {
            display: grid;
            grid-template-columns: minmax(0, 2fr) minmax(0, 1.5fr);
            gap: 18px;
            margin-top: 14px;
        }

        @media (max-width: 768px) {
            body { padding: 16px 10px 24px; }
            .loyalty-layout { grid-template-columns: 1fr; }
        }

        .card {
            background-color: #ffffff;
            border-radius: 18px;
            padding: 18px 18px 20px;
            box-shadow: 0 12px 26px rgba(15, 23, 42, 0.12);
            border: 1px solid var(--haf-border);
        }

        .card-header-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 8px;
            margin-bottom: 10px;
        }

        .card-title {
            font-weight: 700;
            font-size: 1.05rem;
            color: var(--haf-text-main);
            margin: 0;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .card-title i {
            color: var(--haf-primary);
        }

        .tag-pill {
            font-size: .7rem;
            padding: 3px 8px;
            border-radius: 999px;
            background-color: rgba(15, 23, 42, .04);
            color: #4b5563;
        }

        /* summary card */
        .summary-main-points {
            font-size: 2rem;
            font-weight: 800;
            color: var(--haf-primary-hover);
        }

        .summary-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            font-size: .9rem;
            margin-top: 4px;
            color: var(--haf-text-muted);
        }

        .tier-label {
            font-weight: 600;
            color: #111827;
        }

        .streak-row {
            margin-top: 10px;
            font-size: 0.9rem;
            color: var(--haf-text-muted);
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .streak-dot {
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background-color: var(--haf-success);
        }

        /* messages */
        .alert {
            margin-bottom: 10px;
            padding: 8px 10px;
            border-radius: 10px;
            font-size: .9rem;
        }
        .alert-info {
            background: #e0f2fe;
            color: #0f172a;
            border: 1px solid #bfdbfe;
        }
        .alert-success {
            background: #dcfce7;
            color: #166534;
            border: 1px solid #bbf7d0;
        }
        .alert-danger {
            background: #fee2e2;
            color: #b91c1c;
            border: 1px solid #fecaca;
        }

        /* reward list */
        .reward-list {
            display: flex;
            flex-direction: column;
            gap: 10px;
            margin-top: 4px;
        }

        .reward-card {
            border-radius: 14px;
            border: 1px solid var(--haf-border);
            padding: 12px 12px 10px;
            display: grid;
            grid-template-columns: minmax(0, 3fr) minmax(0, 2.2fr);
            gap: 8px;
            align-items: center;
        }

        @media (max-width: 575px) {
            .reward-card { grid-template-columns: 1fr; align-items: flex-start; }
        }

        .reward-main-title {
            font-weight: 600;
            font-size: 0.98rem;
            color: var(--haf-text-main);
            margin-bottom: 2px;
        }

        .reward-desc {
            font-size: 0.86rem;
            color: var(--haf-text-muted);
        }

        .reward-meta {
            display: flex;
            flex-wrap: wrap;
            gap: 6px;
            margin-top: 4px;
            font-size: 0.8rem;
        }

        .reward-chip {
            padding: 3px 7px;
            border-radius: 999px;
            border: 1px solid rgba(148, 163, 184, 0.6);
            color: #4b5563;
            background-color: #f9fafb;
        }

        .reward-points-chip {
            border-color: rgba(248, 113, 113, .6);
            background-color: #fef2f2;
            color: #b91c1c;
            font-weight: 600;
        }

        .reward-actions {
            display: flex;
            flex-direction: column;
            align-items: flex-end;
            gap: 8px;
        }

        .reward-cost {
            font-size: 0.9rem;
            color: #374151;
        }

        .reward-cost strong {
            font-size: 1rem;
            color: var(--haf-primary-hover);
        }

        .reward-qty-row {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: .85rem;
            color: var(--haf-text-muted);
        }

        .qty-input {
            width: 60px;
            padding: 4px 6px;
            border-radius: 10px;
            border: 1px solid var(--haf-border);
            text-align: center;
            font: inherit;
        }

        .btn-redeem {
            padding: 7px 14px;
            border-radius: 999px;
            border: none;
            background: linear-gradient(135deg, var(--haf-primary), var(--haf-primary-hover));
            color: #fff;
            font-size: 0.9rem;
            font-weight: 600;
            cursor: pointer;
            box-shadow: 0 10px 20px rgba(255, 123, 50, 0.35);
            transition: transform 0.1s ease, box-shadow 0.14s ease, filter 0.14s ease;
        }

        .btn-redeem:disabled {
            opacity: 0.6;
            cursor: not-allowed;
            box-shadow: none;
            filter: grayscale(0.2);
        }

        .btn-redeem:not(:disabled):hover {
            transform: translateY(-1px);
            box-shadow: 0 14px 24px rgba(255, 123, 50, 0.45);
            filter: brightness(1.02);
        }

        .inline-badge {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            font-size: 0.8rem;
            padding: 3px 7px;
            border-radius: 999px;
            border: 1px solid rgba(16, 185, 129, 0.5);
            background-color: #ecfdf5;
            color: #047857;
        }

        .note-small {
            font-size: 0.8rem;
            color: var(--haf-text-muted);
            margin-top: 4px;
        }

        /* mini checkin block */
        .checkin-block {
            margin-top: 10px;
            padding: 8px 10px;
            border-radius: 12px;
            border: 1px dashed #fecaca;
            background: #fff7ed;
            font-size: 0.85rem;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 8px;
        }

        .btn-checkin {
            padding: 6px 10px;
            border-radius: 999px;
            border: none;
            background: #f97316;
            color: #fff;
            font-size: 0.82rem;
            font-weight: 600;
            cursor: pointer;
        }

        .btn-checkin:disabled {
            opacity: 0.6;
            cursor: not-allowed;
        }
    </style>
</head>

<body>
    <form id="form1" runat="server">
        <div class="loyalty-page">
            <!-- HEADER -->
            <div class="loyalty-header">
                <div class="title-badge">
                    <i class="fa-solid fa-gift"></i>
                    HAFood - Điểm thưởng &amp; ưu đãi
                </div>
                <h2 class="page-title">Điểm thành viên &amp; đổi quà</h2>
                <p class="page-subtitle">
                    Tích điểm khi mua hàng, điểm danh và tham gia mini game. Đổi điểm để nhận lượt quay may mắn
                    hoặc ưu đãi đặc biệt.
                </p>
            </div>

            <!-- MESSAGES -->
            <asp:PlaceHolder ID="phMessage" runat="server" Visible="false">
                <div id="msgBox" runat="server" class="alert"></div>
            </asp:PlaceHolder>

            <div class="loyalty-layout">
                <!-- LEFT: SUMMARY -->
                <div class="card">
                    <div class="card-header-row">
                        <h3 class="card-title">
                            <i class="fa-solid fa-coins"></i>
                            Tổng quan điểm thành viên
                        </h3>
                        <span class="tag-pill">
                            <asp:Label ID="lblTierName" runat="server" Text="Thành viên"></asp:Label>
                        </span>
                    </div>

                    <div>
                        <div class="summary-main-points">
                            <asp:Label ID="lblTotalPoints" runat="server" Text="0"></asp:Label>
                            <span style="font-size:0.95rem;font-weight:500;color:#4b5563;">điểm</span>
                        </div>

                        <div class="summary-row">
                            <span>Tổng điểm đã tích lũy:</span>
                            <span>
                                <asp:Label ID="lblLifetimePoints" runat="server" Text="0"></asp:Label> điểm
                            </span>
                        </div>

                        <div class="summary-row">
                            <span>Chuỗi ngày điểm danh:</span>
                            <span>
                                <asp:Label ID="lblStreakDays" runat="server" Text="0"></asp:Label> ngày
                                (<asp:Label ID="lblMaxStreak" runat="server" Text="0"></asp:Label> max)
                            </span>
                        </div>

                        <div class="streak-row">
                            <span class="streak-dot"></span>
                            <span>
                                Lần điểm danh gần nhất:
                                <asp:Label ID="lblLastCheckin" runat="server" Text="Chưa có"></asp:Label>
                            </span>
                        </div>

                        <!-- mini checkin -->
                        <div class="checkin-block">
                            <div>
                                <strong>Điểm danh mỗi ngày</strong>
                                <div class="note-small">
                                    Mỗi ngày vào HAFood điểm danh để nhận thêm điểm và lượt quay may mắn.
                                </div>
                            </div>
                            <asp:Button ID="btnCheckin" runat="server"
                                        Text="Điểm danh"
                                        CssClass="btn-checkin"
                                        OnClick="btnCheckin_Click" />
                        </div>

                        <div class="note-small" style="margin-top:10px;">
                            Quy tắc tạm thời: dùng điểm để đổi lượt quay / ưu đãi. Vòng quay &amp; ưu đãi có thể giới hạn theo thời gian.
                        </div>
                    </div>
                </div>

                <!-- RIGHT: REWARDS -->
                <div class="card">
                    <div class="card-header-row">
                        <h3 class="card-title">
                            <i class="fa-solid fa-gifts"></i>
                            Đổi điểm lấy quà / lượt quay
                        </h3>
                        <span class="tag-pill">
                            Còn
                            <asp:Label ID="lblRemainingSpins" runat="server" Text="0"></asp:Label>
                            lượt quay
                        </span>
                    </div>

                    <asp:PlaceHolder ID="phNoReward" runat="server" Visible="false">
                        <div class="alert alert-info">
                            Hiện chưa có phần thưởng nào khả dụng. Hãy quay lại sau hoặc theo dõi các chương trình mới trên HAFood.
                        </div>
                    </asp:PlaceHolder>

                    <asp:Repeater ID="rptRewards" runat="server" OnItemCommand="rptRewards_ItemCommand">
                        <ItemTemplate>
                            <div class="reward-card">
                                <div>
                                    <div class="reward-main-title">
                                        <%# Eval("name") %>
                                    </div>
                                    <div class="reward-desc">
                                        <%# Eval("description") %>
                                    </div>
                                    <div class="reward-meta">
                                        <span class="reward-chip reward-points-chip">
                                            <i class="fa-solid fa-coins"></i>
                                            <%# Eval("points_cost") %> điểm / lượt
                                        </span>
                                        <asp:Literal ID="litRewardType" runat="server"
                                                     Text='<%# Eval("reward_type_text") %>' />
                                    </div>
                                </div>

                                <div class="reward-actions">
                                    <div class="reward-cost">
                                        Dùng <strong><%# Eval("points_cost") %></strong> điểm
                                        <span style="font-size:0.82rem;color:#6b7280;">mỗi lượt</span>
                                    </div>

                                    <div class="reward-qty-row">
                                        Số lượt đổi:
                                        <asp:TextBox ID="txtQty" runat="server"
                                                     CssClass="qty-input"
                                                     Text="1"
                                                     TextMode="Number" />
                                    </div>

                                    <asp:LinkButton ID="btnRedeem" runat="server"
                                                    CommandName="Redeem"
                                                    CommandArgument='<%# Eval("id") %>'
                                                    CssClass="btn-redeem">
                                        Đổi điểm ngay
                                    </asp:LinkButton>

                                    <asp:HiddenField ID="hidRewardType" runat="server"
                                                     Value='<%# Eval("reward_type") %>' />
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>

                    <div class="note-small" style="margin-top:8px;">
                        Sau khi đổi điểm thành lượt quay, bạn có thể vào trang <span style="font-weight:600;">Vòng quay may mắn</span>
                        để sử dụng. Các mã khuyến mãi (nếu có) sẽ xuất hiện ở mục ưu đãi / giỏ hàng.
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
