<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="NotificationPage.aspx.cs" Inherits="HAFoodWeb.NotificationPage.NotificationPage" Async="true" %>
<%@ Register Src="~/Control/Header.ascx" TagPrefix="uc" TagName="Header" %>
<%@ Register Src="~/Control/Footer.ascx" TagPrefix="uc" TagName="Footer" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Thông báo của bạn - HAFood</title>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />

    <style>
        :root{
            --ha-cream: #FFF7EA;
            --ha-ink: #111827;
            --ha-accent: #28a745;
            --ha-border: #E5E7EB;
            --ha-shadow: 0 .75rem 2rem rgba(0,0,0,.12);
        }

        body{
            margin:0;
            padding:0;
            font-family: "Inter", system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial, "Noto Sans", sans-serif;
            background:#ffffff; /* NỀN TRẮNG */
            color:var(--ha-ink);
        }

        .hf-notify-page{
            min-height:100vh;
            display:flex;
            flex-direction:column;
            background:#ffffff; /* trắng toàn trang */
        }

        .hf-notify-main{
            flex:1;
            padding:28px 0 40px;
            background:#ffffff;          /* bỏ gradient, chỉ màu trắng */
        }

        .hf-notify-container{
            max-width:960px;
            margin:0 auto;
            padding:0 16px;
        }

        .hf-notify-header{
            display:flex;
            flex-direction:column;
            gap:8px;
            margin-bottom:24px;
        }

        /* Nhãn tiêu đề giống hình (icon + text trong pill) */
        .hf-section-label{
            display:inline-flex;
            align-items:center;
            gap:6px;
            padding:4px 12px 4px 10px;
            border-radius:999px;
            background:#fff3e6;
            color:#f97316;
            font-size:11px;
            font-weight:700;
            letter-spacing:.14em;
            text-transform:uppercase;
            align-self:flex-start;
            width:auto;
            max-width:100%;
        }

        .hf-section-label i{
            font-size:20px;
        }

        .hf-notify-title{
            font-size:28px;
            font-weight:800;
            letter-spacing:.01em;
            margin-top:4px;
        }

        .hf-notify-subtitle{
            font-size:14px;
            color:#6b7280;
        }

        .hf-notify-summary{
            margin-top:2px;
            font-size:14px;
            color:#4b5563;
        }

        .hf-notify-card{
            background:#fff;
            border-radius:18px;
            box-shadow:0 12px 30px rgba(15,23,42,0.07);
            padding:16px 0 12px;
            border:1px solid #f3f4f6;
        }

        .hf-notify-list{
            display:flex;
            flex-direction:column;
        }

        .hf-notify-empty{
            padding:18px 20px 20px;
            font-size:14px;
            color:#6b7280;
        }

        .hf-notify-item{
            display:flex;
            gap:12px;
            padding:14px 20px;
            border-bottom:1px solid #f3f4f6;
            align-items:flex-start;
        }

        .hf-notify-item:last-child{
            border-bottom:none;
        }

        .hf-notify-item.unread{
            background:#ecfdf3;
        }

        .hf-notify-icon{
            width:34px;
            height:34px;
            border-radius:999px;
            display:flex;
            align-items:center;
            justify-content:center;
            background:#e5f9ed;
            color:#16a34a;
            flex-shrink:0;
            font-size:18px;
            margin-top:2px;
        }

        .hf-notify-content{
            flex:1;
            min-width:0;
        }

        .hf-notify-title-row{
            display:flex;
            align-items:center;
            justify-content:space-between;
            gap:8px;
            margin-bottom:4px;
        }

        .hf-notify-item-title{
            font-size:15px;
            font-weight:600;
            color:#111827;
            margin:0;
        }

        .hf-notify-badge{
            font-size:11px;
            padding:2px 8px;
            border-radius:999px;
            border:1px solid #d1d5db;
            color:#374151;
            background:#f9fafb;
            white-space:nowrap;
        }

        .hf-notify-badge.unread{
            background:#16a34a;
            color:#fff;
            border-color:#15803d;
        }

        .hf-notify-body{
            font-size:14px;
            color:#4b5563;
            margin-bottom:4px;
            word-wrap:break-word;
        }

        .hf-notify-meta{
            display:flex;
            align-items:center;
            gap:10px;
            font-size:12px;
            color:#9ca3af;
        }

        .hf-notify-time{
            display:inline-flex;
            align-items:center;
            gap:4px;
        }

        .hf-notify-status-dot{
            width:7px;
            height:7px;
            border-radius:999px;
            background:#16a34a;
        }

        .hf-notify-status-dot.read{
            background:#9ca3af;
        }

        .hf-notify-meta-label{
            font-size:12px;
            color:#6b7280;
        }

        /* Pager */
        .hf-notify-pager{
            padding:10px 20px 6px;
            border-top:1px solid #f3f4f6;
            margin-top:4px;
        }

        .hf-pagination{
            list-style:none;
            padding:0;
            margin:0;
            display:flex;
            flex-wrap:wrap;
            gap:6px;
            justify-content:center;
        }

        .hf-pagination .page-item a{
            display:inline-flex;
            align-items:center;
            justify-content:center;
            min-width:32px;
            padding:6px 10px;
            border-radius:999px;
            border:1px solid #e5e7eb;
            background:#fff;
            font-size:13px;
            color:#374151;
            text-decoration:none;
            transition:background .15s ease, color .15s ease, border-color .15s ease, transform .05s ease;
        }

        .hf-pagination .page-item a:hover{
            background:#f3f4f6;
            transform:translateY(-1px);
        }

        .hf-pagination .page-item.active a{
            background:#111827;
            color:#fff;
            border-color:#111827;
            font-weight:600;
        }

        .hf-pagination .page-item.prev a,
        .hf-pagination .page-item.next a{
            padding:6px 12px;
        }

        @media (max-width: 576px){
            .hf-notify-main{
                padding-top:20px;
            }

            .hf-notify-card{
                border-radius:14px;
            }

            .hf-notify-item{
                padding:12px 14px;
            }

            .hf-notify-title{
                font-size:24px;
            }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="hf-notify-page">
            <!-- Header chung -->
            <uc:Header ID="Header1" runat="server" />

            <!-- Nội dung chính -->
            <main class="hf-notify-main">
                <div class="hf-notify-container">
                    <div class="hf-notify-header">
                        <!-- Nhãn tiêu đề giống hình -->
                        <div class="hf-section-label">
                            <i class="bi bi-bell-fill"></i>
                            <span>HAFood - THÔNG BÁO</span>
                        </div>

                        <div class="hf-notify-title">Thông báo của tôi</div>

                        <div class="hf-notify-subtitle">
                            Tất cả các cập nhật về đơn hàng, khuyến mãi và hoạt động tài khoản sẽ hiển thị tại đây.
                        </div>
                        <asp:Label ID="lblSummary" runat="server" CssClass="hf-notify-summary"></asp:Label>
                    </div>

                    <div class="hf-notify-card">
                        <div class="hf-notify-list">
                            <!-- Khi không có dữ liệu -->
                            <asp:Panel ID="pnlNoData" runat="server" Visible="false">
                                <div class="hf-notify-empty">
                                    Hiện bạn chưa có thông báo nào.
                                </div>
                            </asp:Panel>

                            <!-- Danh sách thông báo -->
                            <asp:Repeater ID="rptAllNotifications" runat="server">
                                <ItemTemplate>
                                    <div class='hf-notify-item <%# !(bool)Eval("isRead") ? "unread" : "" %>'>
                                        <div class="hf-notify-icon">
                                            <i class="bi bi-bell-fill"></i>
                                        </div>
                                        <div class="hf-notify-content">
                                            <div class="hf-notify-title-row">
                                                <p class="hf-notify-item-title">
                                                    <%# Eval("title") %>
                                                </p>
                                                <span class='hf-notify-badge <%# !(bool)Eval("isRead") ? "unread" : "" %>'>
                                                    <%# !(bool)Eval("isRead") ? "Chưa đọc" : "Đã đọc" %>
                                                </span>
                                            </div>
                                            <div class="hf-notify-body">
                                                <%# Eval("body") %>
                                            </div>
                                            <div class="hf-notify-meta">
                                                <span class='hf-notify-status-dot <%# (bool)Eval("isRead") ? "read" : "" %>'></span>
                                                <span class="hf-notify-time">
                                                    <i class="bi bi-clock"></i>
                                                    <%# Eval("createdAt", "{0:HH:mm dd/MM/yyyy}") %>
                                                </span>
                                            </div>
                                        </div>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>

                        <!-- Phân trang -->
                        <asp:Panel ID="pnlPager" runat="server" CssClass="hf-notify-pager" Visible="false">
                            <asp:Literal ID="litPager" runat="server"></asp:Literal>
                        </asp:Panel>
                    </div>
                </div>
            </main>

            <!-- Footer chung -->
            <uc:Footer ID="Footer1" runat="server" />
        </div>
    </form>
</body>
</html>
