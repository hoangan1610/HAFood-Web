<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CheckoutConfirm.aspx.cs" Inherits="HAFoodWeb.CheckoutConfirm" Async="true" %>
<%@ Register Src="~/Control/Header.ascx" TagPrefix="uc" TagName="Header" %>
<%@ Register Src="~/Control/Footer.ascx" TagPrefix="uc" TagName="Footer" %>
<!DOCTYPE html>
<html lang="vi">
<head runat="server">
    <title>Xác nhận & Chọn thanh toán</title>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet" />
    <style>
        :root{ --border:#e9ecef; --muted:#666; --bg:#f8f9fa; --radius:10px; }
        body{font-family:system-ui,-apple-system,Segoe UI,Roboto,Arial;background:var(--bg);margin:0}
        .page{max-width:1280px;margin:24px auto;padding:0 16px}
        .grid{display:grid;grid-template-columns:1.2fr 1fr;gap:16px}
        @media (max-width: 992px){.grid{grid-template-columns:1fr}}
        .card{background:#fff;border-radius:var(--radius);box-shadow:0 4px 10px rgba(0,0,0,.05);overflow:hidden}
        .card-h{padding:14px 16px;border-bottom:1px solid var(--border);font-weight:700}
        .card-b{padding:16px}
        .muted{color:var(--muted)}
        .addr{background:#fafafa;border:1px dashed var(--border);border-radius:10px;padding:12px;margin-top:8px}
        .list{display:flex;flex-direction:column;gap:12px}
        .item{display:grid;grid-template-columns:64px 1fr auto;gap:10px;align-items:center}
        .item img{width:64px;height:64px;object-fit:cover;border-radius:8px;border:1px solid var(--border)}
        .sum-row{display:flex;justify-content:space-between;margin:6px 0}
        .grand{font-size:20px;font-weight:800;color:#e53935}
        .btn{display:block;width:100%;height:48px;border:none;border-radius:999px;font-weight:700;cursor:pointer}
        .btn-primary{background:#ff7a00;color:#fff}
        .fv{color:#dc3545;font-size:13px;margin-top:6px}
        .alert{margin:0 0 12px 0;padding:10px 12px;border-radius:10px;background:#ffe6e9;color:#9f2a37;border:1px solid #f5c2c7}

        /* Alert đẹp mắt */
        .alertx{display:flex;gap:10px;padding:12px 14px;border-radius:12px;align-items:flex-start;border:1px solid #f5c2c7;background:#fff1f3;color:#9f2a37;margin:0 0 12px 0}
        .alertx i{font-size:20px;line-height:1;margin-top:2px}
        .alertx .ax-body{flex:1}
        .alertx .ax-title{font-weight:800;margin-bottom:4px}
        .alertx .ax-msg{margin:0}
        .ax-actions{margin-top:8px;display:flex;gap:8px;flex-wrap:wrap}
        .btn-link{background:transparent;border:none;color:#c62828;cursor:pointer;text-decoration:underline;padding:0;font-weight:700}
        .btn-soft{background:#ffe4e8;border:1px solid #ffcdd2;border-radius:999px;padding:6px 12px;cursor:pointer;font-weight:600}
    </style>
</head>
<body>
<form id="form1" runat="server">
    <asp:ScriptManager ID="sm" runat="server" EnablePartialRendering="true" />
    <uc:Header ID="Header1" runat="server" />

    <div class="page">
        <asp:ValidationSummary ID="valSummary" runat="server"
            ValidationGroup="PlaceOrder" ShowSummary="true" DisplayMode="BulletList"
            CssClass="alert" HeaderText="Vui lòng kiểm tra:" />

        <div class="grid">
            <!-- LEFT: SUMMARY -->
            <asp:UpdatePanel ID="updSummary" runat="server" UpdateMode="Conditional">
                <ContentTemplate>
                    <div>
                        <div class="card">
                            <div class="card-h">Thông tin nhận hàng</div>
                            <div class="card-b">
                                <div><strong><asp:Label ID="lblShipName" runat="server" /></strong> · <asp:Label ID="lblShipPhone" runat="server" /></div>
                                <div class="addr"><asp:Label ID="lblShipAddress" runat="server" /></div>
                            </div>
                        </div>

                        <div class="card" style="margin-top:16px">
                            <div class="card-h">Sản phẩm & Tạm tính</div>
                            <div class="card-b">
                                <asp:Repeater ID="rptItems" runat="server">
                                    <ItemTemplate>
                                        <div class="item">
                                            <img src='<%# Eval("ImageUrl") %>' alt="">
                                            <div>
                                                <div><strong><%# Eval("ProductName") %></strong></div>
                                                <div class="muted">Phân loại: <%# Eval("VariantName") %> · SL: <%# Eval("Quantity") %></div>
                                            </div>
                                            <div><%# Eval("LineTotal") %></div>
                                        </div>
                                    </ItemTemplate>
                                </asp:Repeater>

                                <hr />
                                <div class="sum-row"><span>Tổng tiền hàng</span><asp:Label ID="lblSubtotal" runat="server" Text="0 ₫" /></div>
                                <div class="sum-row"><span>Phí vận chuyển</span><asp:Label ID="lblShipping" runat="server" Text="0 ₫" /></div>
                                <div class="sum-row"><span>VAT (8%)</span><asp:Label ID="lblVat" runat="server" Text="0 ₫" /></div>
                                <div class="sum-row grand"><span>Tổng thanh toán</span><asp:Label ID="lblGrandTotal" runat="server" Text="0 ₫" /></div>
                                <div class="muted" style="text-align:right"><small>Mã KM: <asp:Label ID="lblPromo" runat="server" Text="(không)"/></small></div>
                            </div>
                        </div>
                    </div>
                </ContentTemplate>
            </asp:UpdatePanel>

            <!-- RIGHT: PAYMENT METHODS -->
            <div class="card">
                <div class="card-h">Chọn phương thức thanh toán</div>
                <div class="card-b">
                    <!-- Alert lỗi đẹp mắt -->
                    <asp:Literal ID="litError" runat="server" Visible="false" />

                    <asp:RadioButtonList ID="rblPayment" runat="server" RepeatDirection="Vertical" CssClass="list">
    <asp:ListItem Value="0" Selected="True">
        <div class="pay-item"><i class="bi bi-truck"></i> Thanh toán khi nhận hàng (COD)</div>
    </asp:ListItem>

    <%-- Đổi MoMo -> ZaloPay, GIỮ Value=1 --%>
    <asp:ListItem Value="1">
        <div class="pay-item"><img alt="" src="https://img.icons8.com/fluency/24/wallet.png" /> ZaloPay</div>
    </asp:ListItem>

    <asp:ListItem Value="2">
        <div class="pay-item"><img alt="" src="https://img.icons8.com/color/24/vnpay.png" /> VNPAY</div>
    </asp:ListItem>
</asp:RadioButtonList>


                    <asp:RequiredFieldValidator runat="server" ControlToValidate="rblPayment"
                        InitialValue="" ErrorMessage="Vui lòng chọn phương thức thanh toán."
                        Display="Dynamic" CssClass="fv" ValidationGroup="PlaceOrder" />

                    <div style="margin-top:16px">
                        <asp:Button ID="btnPlaceOrder" runat="server" Text="Đặt hàng"
                            CssClass="btn btn-primary"
                            OnClick="btnPlaceOrder_Click"
                            CausesValidation="true" ValidationGroup="PlaceOrder" />
                    </div>
                </div>
            </div>
        </div>
    </div>

    <uc:Footer ID="Footer1" runat="server" />

    <script>
  // Nếu trang được restore từ bfcache, reload để đồng bộ session/state
  window.addEventListener('pageshow', function (e) {
    if (e.persisted) location.reload();
  });
    </script>

</form>
</body>
</html>
