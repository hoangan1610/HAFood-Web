<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AddressSelect.aspx.cs" Inherits="HAFoodWeb.AddressSelect" Async="true" %>

<!DOCTYPE html>
<html lang="vi">
<head runat="server">
    <meta charset="utf-8" />
    <title>Chọn địa chỉ nhận hàng</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet" />
    <style>
        :root{ --accent:#ff7a45; --border:#e5e7eb; --muted:#6b7280; }
        body{font-family:'Poppins',system-ui,-apple-system,Segoe UI,Roboto,Helvetica,Arial,sans-serif;margin:0;background:#fafafa}
        .wrap{max-width:900px;margin:0 auto;padding:12px 16px 80px}
        .topbar{display:flex;align-items:center;gap:10px;padding:10px 4px}
        /* KHÔNG có nút quay lại */
        .title{font-weight:700;font-size:20px}

        .card{background:#fff;border-radius:12px;box-shadow:0 4px 10px rgba(0,0,0,.05);padding:12px}
        .addr-item{display:grid;grid-template-columns:28px 1fr;gap:10px;padding:12px;border-bottom:1px solid #f0f0f0}
        .addr-item:last-child{border-bottom:none}
        .addr-radio{width:18px;height:18px;cursor:pointer;margin-top:3px}
        .addr-name{font-weight:700}
        .addr-sep{color:#9ca3af;margin:0 6px}
        .addr-phone{color:#6b7280}
        .addr-detail{color:#374151;margin-top:4px}
        .badge-default{display:inline-block;margin-top:8px;background:rgba(255,122,69,.08);color:var(--accent);border:1px solid var(--accent);
                       border-radius:999px;padding:2px 8px;font-size:12px}
        .empty{padding:20px;text-align:center;color:#6b7280}

        .sticky-actions{position:fixed;left:0;right:0;bottom:0;background:#fff;border-top:1px solid #eee;padding:12px}
        .actions{max-width:900px;margin:0 auto;display:flex;gap:12px;justify-content:center}
        .btn{height:44px;min-width:140px;border:1px solid var(--border);border-radius:10px;padding:0 18px;
             font-weight:700;cursor:pointer;background:#f2f3f5;color:#111;text-decoration:none;
             display:inline-flex;align-items:center;justify-content:center;text-align:center}
        .btn-secondary{background:#f2f3f5;color:#111}
        .btn-primary{background:var(--accent);border-color:var(--accent);color:#fff}
    </style>
</head>
<body>
<form id="form1" runat="server">
    <asp:HiddenField ID="hfSelectedId" runat="server" />

    <div class="wrap">
        <div class="topbar">
            <div class="title">Chọn địa chỉ nhận hàng</div>
        </div>

        <div class="card">
            <asp:Repeater ID="rptAddresses" runat="server" OnItemDataBound="rptAddresses_ItemDataBound">
                <ItemTemplate>
                    <div class="addr-item">
                        <asp:Literal ID="litRadio" runat="server"></asp:Literal>
                        <div>
                            <div>
                                <span class="addr-name"><%# Eval("fullName") %></span>
                                <span class="addr-sep">|</span>
                                <span class="addr-phone"><%# Eval("phone") %></span>
                            </div>
                            <div class="addr-detail"><%# Eval("fullAddress") %></div>
                            <asp:PlaceHolder ID="phDefault" runat="server" Visible='<%# Eval("isDefault") != null && (bool)Eval("isDefault") %>'>
                                <span class="badge-default">Mặc định</span>
                            </asp:PlaceHolder>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>

            <asp:Panel ID="pnlEmpty" runat="server" CssClass="empty" Visible="false">
                Chưa có địa chỉ nào.
            </asp:Panel>
        </div>
    </div>

    <div class="sticky-actions">
        <div class="actions">
            <button type="button" id="btnCancel" class="btn btn-secondary">Hủy</button>
            <asp:Button ID="btnConfirm" runat="server" CssClass="btn btn-primary" Text="Xác nhận"
                        OnClick="btnConfirm_Click" UseSubmitBehavior="false" />
        </div>
    </div>
</form>

<script>
    // Click cả dòng để chọn radio
    document.addEventListener('click', function (e) {
        const row = e.target.closest('.addr-item');
        if (!row) return;
        const radio = row.querySelector('input[type=radio]');
        if (!radio) return;
        radio.checked = true;
    });

    // Hủy -> báo parent đóng popup
    document.getElementById('btnCancel').addEventListener('click', function () {
        try { window.parent && window.parent.postMessage({ type: 'HAFood.AddressCancel' }, '*'); } catch (_) { }
    });
</script>
</body>
</html>
