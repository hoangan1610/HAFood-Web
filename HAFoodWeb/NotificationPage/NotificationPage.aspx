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
            --ha-ink:#111827;
            --ha-accent:#22c55e;   /* xanh chủ đạo */
            --ha-orange:#f97316;   /* cam HAFood */
        }

        /* ===== Layout & nền chung ===== */
        body{
            margin:0;
            padding:0;
            font-family:Inter,system-ui,-apple-system,"Segoe UI",sans-serif;
            background:radial-gradient(circle at top, #fef3c7 0, #f3f4f6 40%, #f9fafb 100%);
            color:var(--ha-ink);
        }

        .hf-notify-page{
            min-height:100vh;
            display:flex;
            flex-direction:column;
        }

        .hf-notify-main{
            flex:1;
            padding:32px 0 48px;
        }

        .hf-notify-container{
            max-width:960px;
            margin:0 auto;
            padding:0 16px;
        }

        .hf-notify-header{
            margin-bottom:6px;
        }

        /* ===== Header khu notification ===== */
        .hf-section-label{
            display:inline-flex;
            align-items:center;
            gap:6px;
            padding:5px 14px;
            border-radius:999px;
            background:rgba(249,115,22,0.05);
            color:var(--ha-orange);
            font-size:11px;
            font-weight:700;
            letter-spacing:.14em;
            text-transform:uppercase;
            border:1px solid rgba(249,115,22,0.25);
        }

        .hf-section-label i{
            font-size:14px;
        }

        .hf-notify-title{
            font-size:30px;
            font-weight:800;
            margin-top:8px;
            letter-spacing:-0.02em;
        }

        .hf-notify-subtitle{
            font-size:14px;
            color:#6b7280;
            margin-top:4px;
        }

        .hf-notify-summary{
            margin-top:6px;
            font-size:14px;
            color:#4b5563;
        }

        /* ===== Card danh sách thông báo ===== */
        .hf-notify-card{
            margin-top:20px;
            background:#ffffff;
            border-radius:22px;
            box-shadow:0 18px 45px rgba(15,23,42,.08);
            border:1px solid #e5e7eb;
            padding:4px 0 10px;
            position:relative;
            overflow:hidden;
        }

        /* viền gradient xanh-cam nhẹ */
        .hf-notify-card::before{
            content:"";
            position:absolute;
            inset:0;
            pointer-events:none;
            border-radius:inherit;
            padding:1px;
            background:linear-gradient(120deg, rgba(34,197,94,.25), rgba(249,115,22,.3));
            -webkit-mask:
                linear-gradient(#000 0 0) content-box,
                linear-gradient(#000 0 0);
            -webkit-mask-composite:xor;
                    mask-composite:exclude;
        }

        .hf-notify-list{
            position:relative;
        }

        /* ===== Trạng thái rỗng ===== */
        .hf-notify-empty{
            padding:24px 24px 26px;
            font-size:14px;
            color:#6b7280;
            display:flex;
            align-items:center;
            gap:8px;
        }

        .hf-notify-empty::before{
            content:"⚠️";
            font-size:16px;
        }

        /* ===== Item notification ===== */
        .hf-notify-link{
            display:block;
            color:inherit;
            text-decoration:none;
        }

        .hf-notify-item{
            display:flex;
            gap:12px;
            padding:14px 22px;
            border-bottom:1px solid #f3f4f6;
            align-items:flex-start;
            transition:
                background-color .18s ease,
                box-shadow .18s ease,
                transform .18s ease,
                border-color .18s ease;
        }

        .hf-notify-item:last-child{
            border-bottom:none;
        }

        /* Hover chung */
        .hf-notify-item:hover{
            background:#fff7ed; /* cam nhạt */
            transform:translateY(-1px);
        }

        /* Unread nổi bật hơn + viền cam */
        .hf-notify-item.unread{
            background:linear-gradient(90deg, #ecfdf3 0, #fff7ed 60%);
            border-left:3px solid var(--ha-orange);
        }

        /* Icon tròn bên trái – dùng cam làm accent */
        .hf-notify-icon{
            width:34px;
            height:34px;
            border-radius:999px;
            display:flex;
            align-items:center;
            justify-content:center;
            background:rgba(249,115,22,0.12);
            color:var(--ha-orange);
            font-size:18px;
            margin-top:2px;
            flex-shrink:0;
        }

        /* Nội dung bên phải */
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

        /* badge trạng thái – mix xanh & cam */
        .hf-notify-badge{
            font-size:11px;
            padding:3px 10px;
            border-radius:999px;
            border:1px solid #d1d5db;
            color:#374151;
            background:#f9fafb;
            white-space:nowrap;
        }

        .hf-notify-badge.unread{
            background:var(--ha-orange);
            color:#fff;
            border-color:#ea580c;
            box-shadow:0 0 0 1px rgba(248,250,252,0.9);
        }

        /* Nội dung body */
        .hf-notify-body{
            font-size:14px;
            color:#4b5563;
            margin-bottom:4px;
            word-wrap:break-word;
        }

        /* Meta: dot trạng thái + thời gian */
        .hf-notify-meta{
            display:flex;
            align-items:center;
            gap:10px;
            font-size:12px;
            color:#9ca3af;
        }

        .hf-notify-status-dot{
            width:7px;
            height:7px;
            border-radius:999px;
            background:var(--ha-accent);
        }

        .hf-notify-status-dot.read{
            background:#9ca3af;
        }

        .hf-notify-time i{
            margin-right:4px;
            color:var(--ha-orange);
        }

        /* ===== Phân trang ===== */
        .hf-notify-pager{
            padding:10px 20px 8px;
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
            transition:
                background-color .15s ease,
                color .15s ease,
                border-color .15s ease,
                transform .15s ease;
        }

        .hf-pagination .page-item a:hover{
            background:#fff7ed;
            border-color:var(--ha-orange);
            color:var(--ha-orange);
            transform:translateY(-0.5px);
        }

        .hf-pagination .page-item.active a{
            background:var(--ha-orange);
            color:#fff;
            border-color:var(--ha-orange);
            font-weight:600;
        }

        /* ===== Responsive ===== */
        @media (max-width:576px){
            .hf-notify-main{
                padding:20px 0 32px;
            }
            .hf-notify-item{
                padding:12px 14px;
            }
            .hf-notify-title{
                font-size:24px;
            }
            .hf-notify-card{
                border-radius:18px;
            }
        }
    </style>
</head>
<body>
<form id="form1" runat="server">
  <div class="hf-notify-page">
    <uc:Header ID="Header1" runat="server" />

    <main class="hf-notify-main">
      <div class="hf-notify-container">
        <div class="hf-notify-header">
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
            <asp:Panel ID="pnlNoData" runat="server" Visible="false">
              <div class="hf-notify-empty">Hiện bạn chưa có thông báo nào.</div>
            </asp:Panel>

            <asp:Repeater ID="rptAllNotifications" runat="server">
              <ItemTemplate>
                <a class="hf-notify-link" href='<%# BuildNotificationUrl(Container.DataItem) %>'>
                  <div class='hf-notify-item <%# !(bool)Eval("isRead") ? "unread" : "" %>'>
                    <div class="hf-notify-icon"><i class="bi bi-bell-fill"></i></div>
                    <div class="hf-notify-content">
                      <div class="hf-notify-title-row">
                        <p class="hf-notify-item-title"><%# Eval("title") %></p>
                        <span class='hf-notify-badge <%# !(bool)Eval("isRead") ? "unread" : "" %>'>
                          <%# !(bool)Eval("isRead") ? "Chưa đọc" : "Đã đọc" %>
                        </span>
                      </div>
                      <div class="hf-notify-body"><%# Eval("body") %></div>
                      <div class="hf-notify-meta">
                        <span class='hf-notify-status-dot <%# (bool)Eval("isRead") ? "read" : "" %>'></span>
                        <span class="hf-notify-time">
                            <i class="bi bi-clock"></i>
                            <%# Eval("createdAt", "{0:HH:mm dd/MM/yyyy}") %>
                        </span>
                      </div>
                    </div>
                  </div>
                </a>
              </ItemTemplate>
            </asp:Repeater>
          </div>

          <asp:Panel ID="pnlPager" runat="server" CssClass="hf-notify-pager" Visible="false">
            <asp:Literal ID="litPager" runat="server"></asp:Literal>
          </asp:Panel>
        </div>
      </div>
    </main>

    <uc:Footer ID="Footer1" runat="server" />
  </div>
</form>
</body>
</html>
