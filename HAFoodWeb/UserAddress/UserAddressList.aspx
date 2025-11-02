<%@ Page Language="C#" AutoEventWireup="true"
    CodeBehind="UserAddressList.aspx.cs"
    Inherits="HAFoodWeb.UserAddress.UserAddressList" Async="true" %>

<!DOCTYPE html>
<html lang="vi">
<head runat="server">
    <meta charset="utf-8" />
    <title>Địa chỉ của tôi</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet" />
    <style>
        :root{ --accent:#ff7a45; --border:#e5e7eb; --muted:#6b7280; }
        body{font-family:'Poppins',system-ui,-apple-system,Segoe UI,Roboto,Helvetica,Arial,sans-serif;margin:0;background:#fafafa}
        .wrap{max-width:900px;margin:0 auto;padding:12px 16px}
        .topbar{display:flex;align-items:center;gap:10px;padding:6px 0 12px}
        .title{font-weight:700;font-size:20px}

        .card{background:#fff;border-radius:12px;box-shadow:0 4px 10px rgba(0,0,0,.05);padding:12px}
        .addr-item{display:grid;grid-template-columns:1fr auto;gap:10px;padding:12px;border-bottom:1px solid #f0f0f0}
        .addr-item:last-child{border-bottom:none}
        .addr-name{font-weight:700}
        .addr-sep{color:#9ca3af;margin:0 6px}
        .addr-phone{color:#6b7280}
        .addr-detail{color:#374151;margin-top:4px}
        .badge-default{display:inline-block;margin-top:8px;background:rgba(255,122,69,.08);color:var(--accent);border:1px solid var(--accent);
                       border-radius:999px;padding:2px 8px;font-size:12px}

        /* Buttons: không gạch dưới + text căn giữa */
        .btn{height:36px;min-width:120px;border:1px solid var(--border);border-radius:10px;padding:0 14px;
             font-weight:700;cursor:pointer;background:#f2f3f5;color:#111;text-decoration:none;
             display:inline-flex;align-items:center;justify-content:center;text-align:center}
        .btn-primary{background:var(--accent);border-color:var(--accent);color:#fff}
        .btn-ghost{background:#fff}
        .btn + .btn{margin-left:8px}

        .list-actions{display:flex;align-items:center;gap:8px}
        .empty{padding:20px;text-align:center;color:#6b7280;margin-top:12px}
        .add-new{margin-left:auto;text-decoration:none}
        .add-new .btn{min-width:180px}
    </style>
</head>
<body>
<form id="form1" runat="server">
    <div class="wrap">
        <div class="topbar">
            <div class="title">Địa chỉ của tôi</div>
            <a href="CreateUserAddress.aspx" class="add-new">
                <span class="btn btn-primary"><i class="bi bi-plus-circle" style="margin-right:6px"></i>Thêm địa chỉ mới</span>
            </a>
        </div>

        <asp:PlaceHolder ID="phEmpty" runat="server" Visible="false">
            <div class="card empty">Người dùng chưa có địa chỉ.</div>
        </asp:PlaceHolder>

        <div class="card">
            <asp:Repeater ID="rptAddresses" runat="server" OnItemCommand="rptAddresses_ItemCommand">
                <ItemTemplate>
                    <div class="addr-item">
                        <div>
                            <div>
                                <span class="addr-name"><%# Eval("fullName") %></span>
                                <span class="addr-sep">|</span>
                                <span class="addr-phone"><%# Eval("phone") %></span>
                            </div>
                            <div class="addr-detail"><%# Eval("fullAddress") %></div>
                            <div class="small" style="color:#6b7280;margin-top:4px">
                                Loại:
                                <%# (Eval("type") != null && Eval("type").ToString() == "1") ? "Văn phòng" : "Nhà riêng" %>
                                <%# string.IsNullOrEmpty((string)Eval("label")) ? "" : " • " + Eval("label") %>
                            </div>
                            <asp:PlaceHolder ID="phDefault" runat="server" Visible='<%# Eval("isDefault") != null && (bool)Eval("isDefault") %>'>
                                <span class="badge-default">Mặc định</span>
                            </asp:PlaceHolder>
                        </div>

                        <div class="list-actions">
                            <a class="btn btn-ghost" href='<%# "UpdateUserAddress.aspx?id=" + Eval("id") %>'>Chỉnh sửa</a>
                            <asp:LinkButton ID="btnSetDefault" runat="server"
                                CssClass="btn"
                                CommandName="setDefault"
                                CommandArgument='<%# Eval("id") %>'
                                Visible='<%# !(bool)Eval("isDefault") %>'>
                                Đặt mặc định
                            </asp:LinkButton>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </div>
</form>
</body>
</html>
