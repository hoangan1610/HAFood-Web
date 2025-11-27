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
        :root{ --ha-ink:#111827; --ha-accent:#28a745; }
        body{ margin:0; padding:0; font-family:Inter,system-ui,-apple-system,"Segoe UI",sans-serif; background:#fff; color:var(--ha-ink); }
        .hf-notify-main{ flex:1; padding:28px 0 40px; }
        .hf-notify-container{ max-width:960px; margin:0 auto; padding:0 16px; }
        .hf-section-label{ display:inline-flex; gap:6px; padding:4px 12px; border-radius:999px; background:#fff3e6; color:#f97316; font-size:11px; font-weight:700; letter-spacing:.14em; text-transform:uppercase; }
        .hf-notify-title{ font-size:28px; font-weight:800; margin-top:4px; }
        .hf-notify-subtitle{ font-size:14px; color:#6b7280; }
        .hf-notify-summary{ margin-top:2px; font-size:14px; color:#4b5563; }
        .hf-notify-card{ background:#fff; border-radius:18px; box-shadow:0 12px 30px rgba(15,23,42,.07); padding:16px 0 12px; border:1px solid #f3f4f6; }
        .hf-notify-empty{ padding:18px 20px 20px; font-size:14px; color:#6b7280; }
        .hf-notify-item{ display:flex; gap:12px; padding:14px 20px; border-bottom:1px solid #f3f4f6; align-items:flex-start; }
        .hf-notify-item:last-child{ border-bottom:none; }
        .hf-notify-item.unread{ background:#ecfdf3; }
        .hf-notify-icon{ width:34px; height:34px; border-radius:999px; display:flex; align-items:center; justify-content:center; background:#e5f9ed; color:#16a34a; font-size:18px; margin-top:2px; }
        .hf-notify-title-row{ display:flex; align-items:center; justify-content:space-between; gap:8px; margin-bottom:4px; }
        .hf-notify-item-title{ font-size:15px; font-weight:600; color:#111827; margin:0; }
        .hf-notify-badge{ font-size:11px; padding:2px 8px; border-radius:999px; border:1px solid #d1d5db; color:#374151; background:#f9fafb; white-space:nowrap; }
        .hf-notify-badge.unread{ background:#16a34a; color:#fff; border-color:#15803d; }
        .hf-notify-body{ font-size:14px; color:#4b5563; margin-bottom:4px; word-wrap:break-word; }
        .hf-notify-meta{ display:flex; align-items:center; gap:10px; font-size:12px; color:#9ca3af; }
        .hf-notify-status-dot{ width:7px; height:7px; border-radius:999px; background:#16a34a; }
        .hf-notify-status-dot.read{ background:#9ca3af; }
        .hf-notify-pager{ padding:10px 20px 6px; border-top:1px solid #f3f4f6; margin-top:4px; }
        .hf-pagination{ list-style:none; padding:0; margin:0; display:flex; flex-wrap:wrap; gap:6px; justify-content:center; }
        .hf-pagination .page-item a{ display:inline-flex; align-items:center; justify-content:center; min-width:32px; padding:6px 10px; border-radius:999px; border:1px solid #e5e7eb; background:#fff; font-size:13px; color:#374151; text-decoration:none; }
        .hf-pagination .page-item.active a{ background:#111827; color:#fff; border-color:#111827; font-weight:600; }
        .hf-notify-link{ display:block; color:inherit; text-decoration:none; }
        @media (max-width:576px){ .hf-notify-item{ padding:12px 14px; } .hf-notify-title{ font-size:24px; } }
    </style>
</head>
<body>
<form id="form1" runat="server">
  <div class="hf-notify-page">
    <uc:Header ID="Header1" runat="server" />

    <main class="hf-notify-main">
      <div class="hf-notify-container">
        <div class="hf-notify-header">
          <div class="hf-section-label"><i class="bi bi-bell-fill"></i><span>HAFood - THÔNG BÁO</span></div>
          <div class="hf-notify-title">Thông báo của tôi</div>
          <div class="hf-notify-subtitle">Tất cả các cập nhật về đơn hàng, khuyến mãi và hoạt động tài khoản sẽ hiển thị tại đây.</div>
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
                        <span class="hf-notify-time"><i class="bi bi-clock"></i> <%# Eval("createdAt", "{0:HH:mm dd/MM/yyyy}") %></span>
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
