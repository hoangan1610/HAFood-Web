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
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700;800&display=swap" rel="stylesheet" />
    <style>
        :root{--border:#e9ecef;--muted:#6b7280;--bg:#f6f7fb;--radius:14px;--brand:#ff7a00;--brand-700:#ff6b00;--danger:#e53935;--ink:#111827}
        *{box-sizing:border-box}
        html,body{height:100%}
        body{font-family:'Inter',system-ui,-apple-system,Segoe UI,Roboto,Arial;background:var(--bg);margin:0;color:var(--ink)}
        .page{max-width:1280px;margin:20px auto;padding:0 16px 32px}
        .grid{display:grid;grid-template-columns:1.25fr 0.95fr;gap:18px}
        @media (max-width: 992px){.grid{grid-template-columns:1fr}}

        .card{background:#fff;border-radius:var(--radius);box-shadow:0 8px 24px rgba(12,16,24,.06);overflow:hidden;border:1px solid #eef0f5}
        .card-h{padding:14px 16px;border-bottom:1px solid var(--border);font-weight:800;display:flex;align-items:center;gap:8px}
        .card-b{padding:16px}

        .muted{color:var(--muted)}

        /* Danh sách sản phẩm */
        .item{display:grid;grid-template-columns:72px 1fr auto;gap:12px;align-items:center;padding:10px;border-radius:12px;border:1px solid #f1f5f9;background:#fff}
        .item:hover{box-shadow:0 6px 18px rgba(17,24,39,.06)}
        .item img{width:72px;height:72px;object-fit:cover;border-radius:10px;border:1px solid #eef0f5;background:#fff}
        .price{font-weight:800}
        .meta{font-size:13px;color:var(--muted)}

        /* Tổng kết tiền */
        .sum{display:flex;flex-direction:column;gap:6px}
        .sum-row{display:flex;justify-content:space-between;align-items:center}
        .sum-row .label{color:#4b5563}
        .sum-row .value{font-variant-numeric:tabular-nums}
        .grand{font-size:20px;font-weight:900;color:var(--danger)}

        /* Nút & căn giữa */
        .btn{display:inline-flex;align-items:center;justify-content:center;height:44px;border:none;border-radius:9999px;font-weight:800;cursor:pointer;letter-spacing:.2px;padding:0 20px;font-size:18px}
        .btn-primary{background:linear-gradient(135deg,var(--brand) 0%,var(--brand-700) 100%);color:#fff;box-shadow:0 8px 20px rgba(255,122,0,.25)}
        .btn-primary:hover{filter:brightness(1.04)}
        .btn:disabled{opacity:.6;cursor:not-allowed}
        .btn-80-center{width:80%;max-width:420px;display:block}
        .btn-row{display:flex;justify-content:center}
        input[type="submit"].btn{border-radius:9999px!important;-webkit-appearance:none;appearance:none;font-weight:800!important;font-size:18px!important}

        .fv{color:#dc3545;font-size:13px;margin-top:6px}
        .alert{margin:0 0 12px 0;padding:10px 12px;border-radius:12px;background:#fff1f2;color:#9f2a37;border:1px solid #ffcdd2}

        /* Thông tin nhận hàng: 3 trường */
        .info-grid{display:grid;grid-template-columns:1fr;gap:10px}
        .field{display:flex;flex-direction:column;gap:4px;padding:10px 12px;border:1px solid #eef0f5;border-radius:12px;background:#fff}
        .f-label{font-size:12px;color:var(--muted);font-weight:700}
        .f-value{font-size:15px;color:#111827;font-weight:800}

        /* Thẻ chọn phương thức thanh toán */
        #<%= rblPayment.ClientID %> br{display:none}
        #<%= rblPayment.ClientID %> input[type="radio"]{position:absolute;opacity:0;pointer-events:none}
        #<%= rblPayment.ClientID %> label{display:flex;align-items:center;gap:12px;border:2px solid #eef0f5;background:#fff;border-radius:14px;padding:14px 16px;font-weight:700;cursor:pointer;transition:.15s box-shadow,.15s transform,.15s border-color,.15s background;margin-bottom:18px;position:relative}
        #<%= rblPayment.ClientID %> label:hover{box-shadow:0 10px 24px rgba(2,6,23,.08);transform:translateY(-1px)}
        #<%= rblPayment.ClientID %> input[type="radio"]:checked + label{border-color:var(--brand);box-shadow:0 12px 28px rgba(255,122,0,.18);background:linear-gradient(180deg,#fff,#fff7ed 80%)}
        #<%= rblPayment.ClientID %> label::before{content:"";flex:0 0 44px;width:44px;height:44px;border-radius:10px;background:#fff1e6;border:1px solid #ffe1c6;margin-right:4px;background-size:contain;background-position:center;background-repeat:no-repeat}
        #<%= rblPayment.ClientID %> label[for$="_1"]::before{background-image:url('<%= ResolveUrl("~/images/zalopay.jpg") %>')}
        #<%= rblPayment.ClientID %> label[for$="_2"]::before{background-image:url('<%= ResolveUrl("~/images/vnpay.jpg") %>')}
        #<%= rblPayment.ClientID %> label[for$="_0"]::before{background-image:url('<%= ResolveUrl("~/images/cod.jpg") %>')}
    </style>
</head>
<body>
<form id="form1" runat="server">
    <asp:ScriptManager ID="sm" runat="server" EnablePartialRendering="true" />
    <uc:Header ID="Header1" runat="server" />

    <div class="page">
        <!-- Tổng hợp lỗi -->
        <asp:ValidationSummary ID="valSummary" runat="server"
            ValidationGroup="PlaceOrder" ShowSummary="true" DisplayMode="BulletList"
            CssClass="alert" HeaderText="Vui lòng kiểm tra:" />

        <div class="grid">
            <!-- LEFT -->
            <asp:UpdatePanel ID="updSummary" runat="server" UpdateMode="Conditional">
                <ContentTemplate>
                    <div>
                        <div class="card">
                            <div class="card-h">Thông tin nhận hàng</div>
                            <div class="card-b">
                                <div class="info-grid">
                                    <div class="field">
                                        <div class="f-label">Họ và tên</div>
                                        <div class="f-value"><asp:Label ID="lblShipName" runat="server" /></div>
                                    </div>
                                    <div class="field">
                                        <div class="f-label">Số điện thoại</div>
                                        <div class="f-value"><asp:Label ID="lblShipPhone" runat="server" /></div>
                                    </div>
                                    <div class="field">
                                        <div class="f-label">Địa chỉ</div>
                                        <div class="f-value"><asp:Label ID="lblShipAddress" runat="server" /></div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="card" style="margin-top:16px">
                            <div class="card-h">Sản phẩm &amp; Tạm tính</div>
                            <div class="card-b">
                                <asp:Repeater ID="rptItems" runat="server">
                                    <ItemTemplate>
                                        <div class="item">
                                            <img src='<%# Eval("ImageUrl") %>' alt="">
                                            <div>
                                                <div><strong><%# Eval("ProductName") %></strong></div>
                                                <div class="meta">Phân loại: <%# Eval("VariantName") %> · SL: <%# Eval("Quantity") %></div>
                                            </div>
                                            <div class="price"><%# Eval("LineTotal") %></div>
                                        </div>
                                    </ItemTemplate>
                                </asp:Repeater>

                                <hr style="border:none;border-top:1px solid var(--border);margin:14px 0" />
                                <div class="sum">
                                    <div class="sum-row"><span class="label">Tổng tiền hàng</span><asp:Label ID="lblSubtotal" runat="server" CssClass="value" Text="0 ₫" /></div>
                                    <div class="sum-row"><span class="label">Phí vận chuyển</span><asp:Label ID="lblShipping" runat="server" CssClass="value" Text="0 ₫" /></div>
                                    <div class="sum-row"><span class="label">VAT (8%)</span><asp:Label ID="lblVat" runat="server" CssClass="value" Text="0 ₫" /></div>
                                    <div class="sum-row"><span class="label">Giảm khuyến mãi</span><asp:Label ID="lblDiscount" runat="server" CssClass="value" Text="0 ₫" /></div>
                                    <div class="sum-row grand"><span>Tổng thanh toán</span><asp:Label ID="lblGrandTotal" runat="server" Text="0 ₫" /></div>
                                    <div class="muted" style="text-align:right"><small>Mã KM: <asp:Label ID="lblPromo" runat="server" Text="(không)"/></small></div>
                                </div>
                            </div>
                        </div>
                    </div>
                </ContentTemplate>
            </asp:UpdatePanel>

            <!-- RIGHT -->
            <div class="card">
                <div class="card-h">Chọn phương thức thanh toán</div>
                <div class="card-b">
                    <asp:Literal ID="litError" runat="server" Visible="false" />

                    <asp:RadioButtonList ID="rblPayment" runat="server" RepeatDirection="Vertical" RepeatLayout="Flow">
                        <asp:ListItem Value="0" Selected="True" Text="Thanh toán khi nhận hàng (COD)" />
                        <asp:ListItem Value="1" Text="ZaloPay" />
                        <asp:ListItem Value="2" Text="VNPAY" />
                    </asp:RadioButtonList>

                    <asp:RequiredFieldValidator runat="server" ControlToValidate="rblPayment"
                        InitialValue="" ErrorMessage="Vui lòng chọn phương thức thanh toán."
                        Display="Dynamic" CssClass="fv" ValidationGroup="PlaceOrder" />

                    <div class="btn-row" style="margin-top:8px">
                        <asp:Button ID="btnPlaceOrder" runat="server" Text="Đặt hàng"
                            CssClass="btn btn-primary btn-80-center"
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
