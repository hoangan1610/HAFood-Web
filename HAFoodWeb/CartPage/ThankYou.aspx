<%@ Page Language="C#" AutoEventWireup="true"
    CodeBehind="ThankYou.aspx.cs"
    Inherits="HAFoodWeb.Pages.ThankYou"
    Async="true" %>

<%@ Register Src="~/Control/Header.ascx" TagPrefix="uc" TagName="Header" %>
<%@ Register Src="~/Control/Footer.ascx" TagPrefix="uc" TagName="Footer" %>

<!DOCTYPE html>
<html lang="vi">
<head runat="server">
    <title>Đặt hàng thành công</title>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1" />
    <style>
        :root{ --muted:#666; --bg:#f8f9fa; --border:#e9ecef; }
        body{font-family:system-ui,-apple-system,Segoe UI,Roboto,Arial;background:var(--bg);margin:0}
        .page{max-width:960px;margin:32px auto;padding:0 16px}
        .card{background:#fff;border-radius:12px;box-shadow:0 8px 24px rgba(0,0,0,.06);padding:24px;text-align:center}
        .title{font-size:22px;font-weight:800;margin-bottom:6px}
        .muted{color:var(--muted)}
        .code{display:inline-block;margin:12px 0 0 0;font-size:18px;font-weight:800;padding:8px 14px;
              border:1px dashed var(--border);border-radius:10px;background:#fafafa}
        .btn{display:inline-block;margin-top:12px;padding:12px 18px;border-radius:999px;border:none;
             background:#ff7a00;color:#fff;font-weight:700;text-decoration:none}
    </style>
</head>
<body>
<form id="form1" runat="server">
    <uc:Header ID="Header1" runat="server" />

    <div class="page">
        <div class="card">
            <div class="title">Đặt hàng thành công!</div>
            <div class="muted">Cảm ơn bạn đã mua sắm tại HAFood.</div>

            <!-- Hiển thị mã đơn -->
            <asp:PlaceHolder ID="phCode" runat="server" Visible="false">
                <div class="code">Mã đơn: <asp:Label ID="lblCode" runat="server" /></div>
            </asp:PlaceHolder>

            <div class="muted" style="margin-top:8px">
                Đang chuyển tới chi tiết đơn hàng trong <span id="countdown">5</span>s…
            </div>

            <!-- Fallback nếu thiếu id -->
            <asp:PlaceHolder ID="phFallback" runat="server" Visible="false">
                <div class="muted" style="margin-top:10px">Không tìm thấy đơn hàng hợp lệ.</div>
                <a id="btnOrders" runat="server" class="btn">Xem lịch sử đơn hàng</a>
            </asp:PlaceHolder>
        </div>
    </div>

    <uc:Footer ID="Footer1" runat="server" />
</form>

<script type="text/javascript">
    (function () {
        var target = '<%= RedirectDetailUrl %>';   // set ở code-behind
  var sec = <%= CountdownSeconds %>;         // 5
        if (!target) return;

        var el = document.getElementById('countdown');
        if (el) el.textContent = sec;
        var to = setInterval(function () {
            sec--;
            if (el) el.textContent = sec;
            if (sec <= 0) {
                clearInterval(to);
                window.location.href = target;         // 👉 sang UserDetail (tab Orders + OrderDetail)
            }
        }, 1000);
    })();
</script>
</body>
</html>
