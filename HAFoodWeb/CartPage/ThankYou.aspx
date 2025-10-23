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
        :root{ --border:#e9ecef; --muted:#666; --bg:#f8f9fa; --ok:#16a34a; }
        body{font-family:system-ui,-apple-system,Segoe UI,Roboto,Arial;background:var(--bg);margin:0}
        .page{max-width:960px;margin:32px auto;padding:0 16px}
        .card{background:#fff;border-radius:12px;box-shadow:0 8px 24px rgba(0,0,0,.06);padding:24px;text-align:center}
        .title{font-size:24px;font-weight:800;margin:4px 0 8px 0;color:#111}
        .muted{color:var(--muted)}
        .code{display:inline-block;margin:12px 0 0 0;font-size:20px;font-weight:800;padding:8px 14px;
              border:1px dashed var(--border);border-radius:10px;background:#fafafa}
        .ok{display:inline-flex;align-items:center;justify-content:center;width:56px;height:56px;border-radius:50%;
            background:#e8f5e9;color:#16a34a;font-size:30px;margin-bottom:8px}
        .btn{display:inline-block;margin-top:18px;padding:12px 18px;border-radius:999px;border:none;
             background:#ff7a00;color:#fff;font-weight:700;text-decoration:none}
        .small{margin-top:8px;color:#muted}
    </style>
</head>
<body>
<form id="form1" runat="server">
    <uc:Header ID="Header1" runat="server" />

    <div class="page">
        <div class="card">
            <div class="ok">✓</div>
            <div class="title">Đặt hàng thành công!</div>
            <div class="muted">Cảm ơn bạn đã mua sắm tại HAFood.</div>

            <asp:PlaceHolder ID="phCode" runat="server" Visible="false">
                <div class="code">Mã đơn: <asp:Label ID="lblCode" runat="server" /></div>
            </asp:PlaceHolder>

            <a id="btnHome" runat="server" class="btn">Về trang chủ</a>

            <div class="small">Tự động chuyển sau <span id="countdown">10</span>s…</div>
        </div>
    </div>

    <uc:Footer ID="Footer1" runat="server" />
</form>

<script type="text/javascript">
    (function () {
        var sec = 10;
        var el = document.getElementById('countdown');
        var to = setInterval(function () {
            sec--;
            if (sec < 0) {
                clearInterval(to);
                window.location.href = '<%= ResolveUrl("~/HomePage/HomePage.aspx") %>';
                return;
            }
            if (el) el.textContent = sec;
        }, 1000);
    })();
</script>
</body>
</html>
