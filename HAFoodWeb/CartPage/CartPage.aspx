<%@ Page Language="C#" AutoEventWireup="true"
    CodeBehind="CartPage.aspx.cs"
    Inherits="HAFoodWeb.Pages.CartPage"
    Async="true" %>

<%@ Register Src="~/Control/Header.ascx" TagPrefix="uc" TagName="Header" %>
<%@ Register Src="~/Control/Footer.ascx" TagPrefix="uc" TagName="Footer" %>
<%@ Register Src="~/CartPage/CartItem.ascx" TagPrefix="uc" TagName="CartItem" %>
<%@ Register Src="~/CartPage/CartVouchers.ascx" TagPrefix="uc" TagName="CartVouchers" %>

<!DOCTYPE html>
<html lang="vi">
<head runat="server">
    <title>Giỏ hàng - HAFood</title>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1" />

    <!-- Font + Icons -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;700&display=swap" rel="stylesheet" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet" />

    <style>
        :root{
          --border:#e9ecef;
          --muted:#667085;
          --bg:#fff8f1;
          --pill:#ef5350;
          --radius:14px;
          --surface:#ffffff;
          --shadow:0 12px 30px rgba(16,24,40,.08);
          --brand:#ff7a00;
          --brand-600:#ff6a00;
          --brand-700:#e36000;
        }
        *{box-sizing:border-box}
        body{
          font-family:'Poppins',system-ui,-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif;
          background:radial-gradient(1200px 600px at -10% -20%,#ffe6cf 0%,#fff3e6 38%,#fff 68%) fixed;
          margin:0;
          color:#111827;
        }
        .page{max-width:1280px;margin:24px auto;padding:0 16px}
        .page-grid{display:grid;grid-template-columns:2fr 1fr;gap:20px;align-items:start}
        @media (max-width: 992px){.page-grid{grid-template-columns:1fr}}

        .cart-box,.panel,.summary{
          background:var(--surface);
          border-radius:var(--radius);
          box-shadow:var(--shadow);
          border:1px solid rgba(16,24,40,.06);
        }

        /* Header bảng hàng */
        .cart-header{
          display:grid;
          grid-template-columns:40px 120px 1fr 120px 160px 120px 60px;
          gap:12px;align-items:center;
          padding:14px 16px;
          background:linear-gradient(180deg,#fffaf4 0%,#fff 100%);
          border-bottom:1px solid var(--border);
          border-radius:var(--radius) var(--radius) 0 0;
          font-weight:700;
          color:#374151;
        }
        .cart-header>div:nth-child(3){text-align:left;padding-left:20px}
        .cart-header>div:nth-child(4),
        .cart-header>div:nth-child(5),
        .cart-header>div:nth-child(6),
        .cart-header>div:nth-child(7){text-align:center}

        .cart-list{padding:8px 8px 12px}

        /* Hàng tổng tiền + nút xoá tất cả */
        .total-row{
          padding:16px;
          border-top:1px dashed var(--border);
          background:#fffaf4;
          display:flex;gap:10px;justify-content:flex-end;align-items:center;
          font-weight:800;color:#111827;
          border-radius:0 0 var(--radius) var(--radius);
        }

        /* Panel chung (địa chỉ, form) */
        .panel-title{
          padding:14px 16px;border-bottom:1px solid var(--border);
          font-weight:700;display:flex;align-items:center;gap:8px;
          background:linear-gradient(180deg,#fffaf4 0%,#fff 100%);
          border-radius:var(--radius) var(--radius) 0 0;
        }
        .panel-body{padding:16px}
        .form-row{display:flex;flex-direction:column;gap:6px;margin-bottom:12px}
        .form-row label{font-weight:600}
        .form-row .req::before{content:'* ';color:#e53935}
        .form-control{
          width:100%;height:42px;border:1px solid var(--border);border-radius:10px;padding:0 12px;font:inherit;
          transition:border-color .15s ease, box-shadow .15s ease;
        }
        .form-control:focus{outline:none;border-color:#ffd199;box-shadow:0 0 0 .16rem rgba(255,193,7,.25)}
        .fv{margin-top:4px;color:#dc3545;font-size:13px}

        /* Tóm tắt thanh toán */
        .summary{margin-top:16px;position:sticky;top:16px}
        .summary-row{
          display:flex;justify-content:space-between;align-items:center;
          padding:10px 16px;border-bottom:1px dashed var(--border);color:#374151
        }
        .summary-row:last-child{border-bottom:none}
        .grand{
          color:#e53935;font-size:20px;font-weight:800;text-align:center;padding:16px;
          background:#fff6f6;border-top:1px solid #fde2e2;border-bottom-left-radius:var(--radius);border-bottom-right-radius:var(--radius)
        }

        /* Nút chính */
        .btn-primary{
          display:block;width:100%;height:48px;border:none;border-radius:999px;font-weight:700;cursor:pointer;
          background:linear-gradient(135deg,var(--brand),var(--brand-600));color:#fff;
          box-shadow:0 14px 30px rgba(255,122,0,.25);
          transition:transform .15s ease, box-shadow .15s ease, background .2s ease;
        }
        .btn-primary:hover{transform:translateY(-1px);box-shadow:0 18px 36px rgba(255,122,0,.32);background:linear-gradient(135deg,var(--brand-600),var(--brand-700))}
        .btn-primary:active{transform:translateY(0);box-shadow:0 10px 22px rgba(255,122,0,.2)}

        /* ===== NÚT XÓA TẤT CẢ ===== */
        .btn-clear-all{
          display:inline-flex;align-items:center;gap:6px;padding:0 14px;height:34px;border-radius:999px;
          border:1px solid #ef4444;background:#fff;color:#b91c1c;font-size:14px;font-weight:700;cursor:pointer;margin-right:auto;
          transition:background .15s ease, transform .15s ease, box-shadow .15s ease;
        }
        .btn-clear-all i{font-size:16px}
        .btn-clear-all:hover{background:#fee2e2;transform:translateY(-1px);box-shadow:0 8px 18px rgba(185,28,28,.15)}
        .btn-clear-all:disabled{opacity:.6;cursor:not-allowed;border-color:#e5e7eb;background:#f9fafb;color:#9ca3af;transform:none;box-shadow:none}

        /* Chips/nhãn nhỏ */
        .pill{background:var(--pill);color:#fff;border-radius:999px;padding:4px 10px;font-size:12px}

        /* Alert tổng hợp validator */
        .alert{margin:12px 0 0 0;padding:10px 12px;border-radius:12px;background:#ffe6e9;color:#9f2a37;border:1px solid #f5c2c7}
        .invisible-input{position:absolute;left:-9999px;top:auto;width:1px;height:1px;opacity:0;pointer-events:none}

        /* ==== Combo searchable ==== */
        .combo{position:relative}
        .combo-input{
          display:flex;align-items:center;height:42px;border:1px solid var(--border);border-radius:10px;background:#fff;padding:0 10px;cursor:text;
          transition:border-color .15s ease, box-shadow .15s ease;
        }
        .combo-input:focus-within{border-color:#ffd199;box-shadow:0 0 0 .16rem rgba(255,193,7,.25)}
        .combo-text{flex:1 1 auto;border:none;outline:none;height:100%;font:inherit}
        .combo-caret{margin-left:8px}
        .combo-menu{
          position:absolute;left:0;right:0;top:calc(100% + 4px);background:#fff;border:1px solid var(--border);
          border-radius:10px;box-shadow:0 12px 26px rgba(16,24,40,.12);max-height:320px;overflow:auto;display:none;z-index:1000
        }
        .combo.open .combo-menu{display:block}
        .combo-item{padding:8px 10px;cursor:pointer}
        .combo-item:hover{background:#f5f5f5}

        /* ===== Address session ===== */
        .addr-session{margin-bottom:12px}
        .addr-link{display:block;width:100%;text-decoration:none;color:inherit;background:transparent;border:0;padding:0;cursor:pointer}
        .addr-card{
          display:flex;gap:12px;align-items:center;background:#fff;border:1px solid var(--border);
          border-radius:12px;padding:12px;text-align:left;transition:border-color .15s ease, box-shadow .15s ease, transform .15s ease
        }
        .addr-card:hover{border-color:#ffd9b3;box-shadow:0 12px 26px rgba(255,122,0,.15);transform:translateY(-1px)}
        .addr-icon{color:#ff7a45;font-size:20px;line-height:1}
        .addr-main{flex:1 1 auto}
        .addr-name{font-weight:700}
        .addr-phone{color:#6b7280;margin-left:8px}
        .addr-detail{color:#374151;margin-top:2px}
        .addr-chevron{color:#9ca3af}

        /* ===== Popup địa chỉ ===== */
        .modal-backdrop{
          position:fixed;inset:0;background:rgba(0,0,0,.38)!important;display:none;z-index:2000
        }
        .modal{position:fixed;inset:0;display:none;align-items:center;justify-content:center;z-index:2001}
        .modal.open,.modal-backdrop.open{display:flex}
        .modal-card{
          width:min(1000px,96vw);height:min(680px,92vh);background:#fff;border-radius:18px;
          box-shadow:0 24px 60px rgba(0,0,0,.28);display:flex;flex-direction:column;overflow:hidden;border:1px solid rgba(16,24,40,.06)
        }
        .modal-head{display:flex;align-items:center;justify-content:space-between;padding:12px 16px;border-bottom:1px solid var(--border);background:#fffaf4}
        .modal-title{font-weight:700}
        .modal-close{background:transparent;border:0;font-size:22px;cursor:pointer;line-height:1}
        .modal-body{flex:1 1 auto}
        .modal-body iframe{width:100%;height:100%;border:0}

        /* ===== Popup xác nhận xóa (dùng chung) ===== */
        #confirmModalBk,#confirmAllModalBk{
          position:fixed;inset:0;background:rgba(0,0,0,.38);display:none;z-index:2100
        }
        #confirmModal,#confirmAllModal{
          position:fixed;inset:0;display:none;align-items:center;justify-content:center;z-index:2101
        }
        #confirmModal.open,#confirmModalBk.open,#confirmAllModal.open,#confirmAllModalBk.open{display:flex}
        .confirm-card{
          width:min(520px,92vw);background:#fff;border-radius:16px;box-shadow:0 24px 60px rgba(0,0,0,.28);
          overflow:hidden;display:flex;flex-direction:column;border:1px solid rgba(16,24,40,.06)
        }
        .confirm-head{position:relative;display:flex;align-items:center;justify-content:center;padding:12px 16px;border-bottom:1px solid var(--border);background:#fffaf4}
        .confirm-title{font-weight:700;text-align:center;width:100%}
        .confirm-close{position:absolute;right:12px;top:50%;transform:translateY(-50%);background:transparent;border:0;font-size:22px;cursor:pointer;line-height:1}
        .confirm-body{padding:18px}
        .confirm-body .confirm-question{margin:0 0 16px 0;font-weight:600;text-align:center;color:#111827}
        .confirm-actions{display:flex;justify-content:space-between;padding-top:8px;gap:10px}
        .btn-confirm{display:inline-flex;align-items:center;justify-content:center;min-width:120px;height:40px;border-radius:999px;padding:0 16px;font-weight:700;cursor:pointer}
        .btn-confirm-primary{background:linear-gradient(135deg,var(--brand),var(--brand-600));color:#fff;border:none}
        .btn-confirm-primary:hover{background:linear-gradient(135deg,var(--brand-600),var(--brand-700))}
        .btn-confirm-secondary{background:#fff;color:#111;border:1px solid var(--border)}
        .btn-confirm-secondary:hover{background:#f9fafb}

        /* ===== Toast ===== */
        .toast-stack{position:fixed;right:16px;top:16px;z-index:2300;display:flex;flex-direction:column;gap:10px}
        .toast{
          width:fit-content;
          min-width:min(260px,92vw);
          max-width:min(560px,92vw);
          border-radius:14px;padding:14px 18px;box-shadow:0 8px 20px rgba(0,0,0,.12);
          border:1px solid var(--border);background:#fff;color:#111;font-weight:600;font-size:15.5px;
          display:flex;align-items:flex-start;gap:10px;opacity:0;transform:translateY(-8px);
          transition:opacity .18s ease, transform .18s ease;
          word-break:break-word;
        }
        .toast.show{opacity:1;transform:translateY(0)}
        .toast-success{background:#22c55e !important;border-color:#16a34a !important;color:#fff !important}
        .toast-success .toast-icon{color:#fff !important}
        .toast-text{flex:1;white-space:normal}
        @media (max-width:575.98px){.toast-stack{right:10px;left:10px}}

        /* ===== HARD READONLY ===== */
        .form-control[readonly],.form-control.readonly,.form-control[aria-readonly="true"]{
          background:#f3f4f6!important;color:#6b7280!important;pointer-events:none;user-select:none;caret-color:transparent
        }
        .form-control[readonly]:focus,.form-control.readonly:focus,.form-control[aria-readonly="true"]focus{
          outline:none!important;box-shadow:none!important;border-color:var(--border)!important
        }
        .combo.readonly{pointer-events:none}
        .combo.readonly .combo-input{background:#f3f4f6!important;color:#6b7280!important;border-color:var(--border)!important}
        .combo.readonly .combo-input:focus-within{outline:none!important;box-shadow:none!important;border-color:var(--border)!important}
        .combo.readonly .combo-text{background:transparent!important;color:#6b7280!important}
        .combo.readonly .combo-caret{display:none!important}

    </style>
</head>

<body>
<form id="form1" runat="server">
    <asp:ScriptManager ID="sm" runat="server" EnablePartialRendering="true" EnablePageMethods="true" />
    <uc:Header ID="Header1" runat="server" />

    <!-- Flags/params cho JS -->
    <asp:HiddenField ID="hidDeviceUuid" runat="server" />
    <asp:HiddenField ID="hidApiBase" runat="server" />
    <asp:HiddenField ID="hidIsAuth" runat="server" />
    <asp:HiddenField ID="hidJwt" runat="server" />

    <!-- Hidden mirror cho validators/submit -->
    <asp:TextBox ID="txtCitySel" runat="server" CssClass="invisible-input" />
    <asp:TextBox ID="txtWardSel" runat="server" CssClass="invisible-input" />
    <asp:TextBox ID="txtCityCode" runat="server" CssClass="invisible-input" />
    <asp:TextBox ID="txtWardCode" runat="server" CssClass="invisible-input" />
    <asp:HiddenField ID="hidSelectedLines" runat="server" />

    <!-- Hidden voucher fields -->
    <asp:HiddenField ID="hidPromoCodeSelected" runat="server" />
    <asp:HiddenField ID="hidPromoDiscount" runat="server" />
    <asp:HiddenField ID="hidPromoMetaJson" runat="server" />

    <div class="page">
        <div class="page-grid">
            <!-- LEFT -->
            <asp:UpdatePanel ID="updCart" runat="server" UpdateMode="Conditional" ChildrenAsTriggers="true">
                <ContentTemplate>
                    <div class="cart-box">
                        <div class="cart-header">
                            <div><asp:CheckBox ID="chkSelectAll" runat="server" /></div>
                            <div></div><div>SẢN PHẨM</div><div>GIÁ</div><div>SL</div><div>SỐ TIỀN</div><div></div>
                        </div>

                        <asp:Panel ID="pnlEmpty" runat="server" CssClass="panel-body" style="display:none">
                            <p>Giỏ hàng bạn đang trống</p>
                        </asp:Panel>

                        <div class="cart-list">
                            <asp:Repeater ID="rptCart" runat="server" OnItemDataBound="rptCart_ItemDataBound">
                                <ItemTemplate><uc:CartItem ID="CartItemControl" runat="server" /></ItemTemplate>
                            </asp:Repeater>
                        </div>

                        <div class="total-row">
                            <!-- Nút XÓA TẤT CẢ (luôn hiển thị, bật/tắt bằng disabled) -->
                            <button type="button" id="btnClearAll" class="btn-clear-all">
                                <i class="bi bi-trash3"></i>
                                <span>Xóa tất cả</span>
                            </button>

                            <span>Tổng chọn:</span> <asp:Label ID="lblTotal" runat="server" Text="0 ₫"></asp:Label>
                        </div>
                    </div>
                </ContentTemplate>
            </asp:UpdatePanel>

            <!-- RIGHT -->
            <div>
                <asp:ValidationSummary ID="valSummary" runat="server" ValidationGroup="Checkout" ShowSummary="true"
                    DisplayMode="BulletList" CssClass="alert" HeaderText="Vui lòng kiểm tra:" />

                <div class="panel">
                    <div class="panel-title"><span class="pill">i</span> Thông tin địa chỉ nhận hàng</div>
                    <div class="panel-body">

                        <!-- Session địa chỉ hiển thị -->
                        <asp:Panel ID="pnlAddrSession" runat="server" CssClass="addr-session" style="display:none">
                          <button type="button" class="addr-link" id="btnChooseAddr1">
                            <div class="addr-card">
                              <div class="addr-icon"><i class="bi bi-geo-alt-fill"></i></div>
                              <div class="addr-main">
                                <div>
                                  <span class="addr-name"><asp:Label ID="lblAddrName" runat="server" /></span>
                                  <span class="addr-phone">(<asp:Label ID="lblAddrPhone" runat="server" />)</span>
                                </div>
                                <div class="addr-detail"><asp:Label ID="lblAddrDetail" runat="server" /></div>
                              </div>
                              <div class="addr-chevron"><i class="bi bi-chevron-right"></i></div>
                            </div>
                          </button>
                        </asp:Panel>

                        <asp:Panel ID="pnlNoAddr" runat="server" CssClass="addr-session" style="display:none">
                          <button type="button" class="addr-link" id="btnChooseAddr2">
                            <div class="addr-card">
                              <div class="addr-icon"><i class="bi bi-geo-alt"></i></div>
                              <div class="addr-main">
                                <div class="text-muted">Chưa có địa chỉ — bấm để chọn</div>
                              </div>
                              <div class="addr-chevron"><i class="bi bi-chevron-right"></i></div>
                            </div>
                          </button>
                        </asp:Panel>

                        <!-- ====== Combobox searchable ====== -->
                        <div class="form-row">
                            <label class="req">Tỉnh/Thành</label>
                            <div id="cmbCity" class="combo"></div>
                            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtCitySel"
                                ErrorMessage="Vui lòng chọn Tỉnh/Thành." Display="Dynamic" CssClass="fv" ValidationGroup="Checkout" />
                            <asp:CustomValidator ID="cvCity" runat="server" ControlToValidate="txtCitySel"
                                ClientValidationFunction="validateCityCode"
                                OnServerValidate="cvCity_ServerValidate"
                                ValidateEmptyText="true"
                                ErrorMessage="Vui lòng chọn Tỉnh/Thành từ danh sách."
                                Display="Dynamic" CssClass="fv" ValidationGroup="Checkout" />
                        </div>

                        <div class="form-row">
                            <label class="req">Xã/Phường</label>
                            <div id="cmbWard" class="combo"></div>
                            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtWardSel"
                                ErrorMessage="Vui lòng chọn Xã/Phường." Display="Dynamic" CssClass="fv" ValidationGroup="Checkout" />
                            <asp:CustomValidator ID="cvWard" runat="server" ControlToValidate="txtWardSel"
                                ClientValidationFunction="validateWardCode"
                                OnServerValidate="cvWard_ServerValidate"
                                ValidateEmptyText="true"
                                ErrorMessage="Vui lòng chọn Xã/Phường từ danh sách."
                                Display="Dynamic" CssClass="fv" ValidationGroup="Checkout" />
                        </div>
                        <!-- ================================= -->

                        <div class="form-row">
                            <label class="req">Địa chỉ nhận hàng</label>
                            <asp:TextBox ID="txtAddress" runat="server" CssClass="form-control" />
                            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtAddress"
                                ErrorMessage="Vui lòng nhập địa chỉ nhận hàng."
                                Display="Dynamic" CssClass="fv" ValidationGroup="Checkout" />
                        </div>

                        <div class="form-row">
                            <label class="req">Số điện thoại liên lạc</label>
                            <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control" TextMode="SingleLine" MaxLength="20" />
                            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtPhone"
                                ErrorMessage="Vui lòng nhập số điện thoại."
                                Display="Dynamic" CssClass="fv" ValidationGroup="Checkout" />
                            <asp:CustomValidator ID="cvPhone" runat="server" ControlToValidate="txtPhone"
                                ClientValidationFunction="validatePhone"
                                OnServerValidate="cvPhone_ServerValidate"
                                ErrorMessage="Số điện thoại không hợp lệ."
                                Display="Dynamic" CssClass="fv" ValidationGroup="Checkout" SetFocusOnError="true" />
                        </div>

                        <div class="form-row">
                            <label class="req">Tên người nhận hàng</label>
                            <asp:TextBox ID="txtReceiver" runat="server" CssClass="form-control" />
                            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtReceiver"
                                ErrorMessage="Vui lòng nhập tên người nhận."
                                Display="Dynamic" CssClass="fv" ValidationGroup="Checkout" />
                        </div>

                        <!-- Ẩn hoàn toàn input khuyến mãi cũ -->
                        <asp:TextBox ID="txtPromo" runat="server" CssClass="invisible-input" />
                        <div class="form-row" style="display:none"><label>Mã khuyến mãi</label><input type="text" disabled class="form-control" value="" /></div>

                        <div class="form-row"><label>Ghi chú cho đơn hàng</label><asp:TextBox ID="txtNote" runat="server" CssClass="form-control" /></div>
                    </div>
                </div>

                <!-- Voucher UI -->
                <uc:CartVouchers ID="CartVouchers1" runat="server" />

                <asp:UpdatePanel ID="updSummary" runat="server" UpdateMode="Conditional">
                    <ContentTemplate>
                        <div class="summary">
                            <div class="summary-row"><span>Tổng số sản phẩm:</span><asp:Label ID="lblSumItems" runat="server" Text="0" /></div>
                            <div class="summary-row">
                                <span>Trọng lượng hàng:</span>
                                <asp:Label ID="lblTotalWeight" runat="server" Text="0" />
                                <%-- mirror tổng trọng lượng (gram) --%>
                                <asp:HiddenField ID="hidTotalWeightGram" runat="server" />
                            </div>

                            <div class="summary-row"><span>Tổng tiền hàng:</span><asp:Label ID="lblSubtotal" runat="server" Text="0 ₫" /></div>
                            <div class="summary-row">
                                <span>Phí vận chuyển:</span>
                                <asp:Label ID="lblShipping" runat="server" Text="0 ₫" />
                                <%-- mirror shipping cho server --%>
                                <asp:HiddenField ID="hidShippingFee" runat="server" />
                            </div>
                            <div class="summary-row">
                                <span>VAT (8%):</span>
                                <asp:Label ID="lblVat" runat="server" Text="0 ₫" />
                            </div>

                            <div class="summary-row"><span>Giảm khuyến mãi:</span><asp:Label ID="lblDiscount" runat="server" Text="0 ₫" /></div>
                            <div class="grand">Tổng thanh toán: <asp:Label ID="lblGrandTotal" runat="server" Text="0 ₫" /></div>
                            <div style="padding:0 16px 16px">
                                <asp:Button ID="btnCheckout" runat="server" CssClass="btn-primary" Text="Tiếp Tục Đặt Hàng"
                                    ValidationGroup="Checkout" CausesValidation="true" OnClick="btnCheckout_Click"
                                    OnClientClick="return beforeCheckoutSubmit();" />
                            </div>
                        </div>
                    </ContentTemplate>
                    <Triggers><asp:PostBackTrigger ControlID="btnCheckout" /></Triggers>
                </asp:UpdatePanel>
            </div>
        </div>
    </div>

    <uc:Footer ID="Footer1" runat="server" />

    <!-- ===== POPUP CHỌN ĐỊA CHỈ ===== -->
    <div class="modal-backdrop" id="addrModalBk"></div>
    <div class="modal" id="addrModal" aria-hidden="true" role="dialog" aria-label="Chọn địa chỉ">
        <div class="modal-card">
            <div class="modal-head">
                <div class="modal-title">Chọn địa chỉ</div>
                <button type="button" class="modal-close" id="addrCloseBtn" aria-label="Close">&times;</button>
            </div>
            <div class="modal-body">
                <iframe id="addrFrame" src="about:blank" title="Address Select"></iframe>
            </div>
        </div>
    </div>

    <!-- ===== POPUP XÁC NHẬN XÓA (MỚI) - XÓA 1 SẢN PHẨM ===== -->
    <div id="confirmModalBk"></div>
    <div id="confirmModal" aria-hidden="true" role="dialog" aria-label="Xóa sản phẩm">
        <div class="confirm-card">
            <div class="confirm-head">
                <div class="confirm-title">Xóa sản phẩm</div>
                <button type="button" class="confirm-close" id="confirmCloseBtn" aria-label="Close">&times;</button>
            </div>
            <div class="confirm-body">
                <p class="confirm-question">Bạn có muốn xóa sản phẩm trong giỏ hàng không?</p>
                <div class="confirm-actions">
                  <button type="button" class="btn-confirm btn-confirm-secondary" id="confirmCancelBtn">Hủy</button>
                  <button type="button" class="btn-confirm btn-confirm-primary"  id="confirmOkBtn">Xác nhận</button>
                </div>
            </div>
        </div>
    </div>

    <!-- ===== POPUP XÁC NHẬN XÓA TẤT CẢ ===== -->
    <div id="confirmAllModalBk"></div>
    <div id="confirmAllModal" aria-hidden="true" role="dialog" aria-label="Xóa tất cả sản phẩm">
        <div class="confirm-card">
            <div class="confirm-head">
                <div class="confirm-title">Xóa tất cả sản phẩm</div>
                <button type="button" class="confirm-close" id="confirmAllCloseBtn" aria-label="Close">&times;</button>
            </div>
            <div class="confirm-body">
                <p class="confirm-question">Bạn có muốn xóa tất cả sản phẩm trong giỏ hàng không?</p>
                <div class="confirm-actions">
                  <button type="button" class="btn-confirm btn-confirm-secondary" id="confirmAllCancelBtn">Hủy</button>
                  <button type="button" class="btn-confirm btn-confirm-primary"  id="confirmAllOkBtn">Xác nhận</button>
                </div>
            </div>
        </div>
    </div>

    <!-- ===== TOAST STACK ===== -->
    <div class="toast-stack" id="toastStack" aria-live="polite"></div>

    <script>
        // Giá trị mặc định là 1 nếu chưa set nơi khác
        window.CHANNEL = (typeof window.CHANNEL !== 'undefined') ? window.CHANNEL : 1;
    </script>

    <!-- Phone validator -->
    <script>
        function normalizePhone(s) { if (!s) return ''; s = String(s).replace(/[\s\.\-]/g, '').trim(); s = s.replace(/^\+840/, '+84'); return s; }
        function validatePhone(sender, args) { const s = normalizePhone(args.Value); args.IsValid = /^(0\d{9}|\+84\d{9})$/.test(s); }
    </script>

    <!-- Combobox searchable + expose cityWardAPI -->
    <script>
        (function () {
            const CHANNEL = Number(window.CHANNEL || 1);
            const DATA_BASE = '<%= Page.ResolveClientUrl("~/assets/vn-admin") %>';

            const cityBox = document.getElementById('cmbCity');
            const wardBox = document.getElementById('cmbWard');

            const hidCityName = document.getElementById('<%= txtCitySel.ClientID %>');
            const hidWardName = document.getElementById('<%= txtWardSel.ClientID %>');
            const hidCityCode = document.getElementById('<%= txtCityCode.ClientID %>');
            const hidWardCode = document.getElementById('<%= txtWardCode.ClientID %>');

            const rm = (s) => (s || '').normalize('NFD').replace(/[\u0300-\u036f]/g, '').replace(/đ/g, 'd').replace(/Đ/g, 'D').replace(/\s+/g, ' ').trim().toLowerCase();
            const baseCity = s => rm(String(s || '').replace(/^(tinh|thanh pho|tp\.?|tp)\s*/i, ''));
            const baseWard = s => rm(String(s || '')
                .replace(/^(phường|xã|thị\s*trấn|p\.|x\.|tt\.)\s*/i, '')
                .replace(/\s*(?:-|,|–)\s*(quận|huyện|thị\s*xã|thành\s*phố|q\.|h\.|tx\.|tp\.).*$/i, '')
                .replace(/\(.*?\)/g, '')
                .replace(/\b0+(\d)\b/g, '$1')
            );

            function createCombo(el, placeholder) {
                if (!el) return null;
                el.classList.add('combo');
                el.innerHTML = '<div class="combo-input" role="combobox" aria-expanded="false">'
                    + '  <input type="text" class="combo-text" placeholder="' + placeholder + '"/>'
                    + '  <i class="bi bi-chevron-down combo-caret"></i>'
                    + '</div><div class="combo-menu"></div>';
                const input = el.querySelector('.combo-text'); const menu = el.querySelector('.combo-menu');
                let all = []; let open = false;
                function render(list) { menu.innerHTML = ''; for (const opt of list) { const div = document.createElement('div'); div.className = 'combo-item'; div.textContent = opt.label; div.dataset.value = opt.value; div.addEventListener('mousedown', () => pick(opt)); menu.appendChild(div); } }
                function openMenu() { if (open) return; el.classList.add('open'); open = true; }
                function closeMenu() { if (!open) return; el.classList.remove('open'); open = false; }
                function filter() { const q = rm(input.value); render(!q ? all : all.filter(o => rm(o.label).includes(q))); openMenu(); }
                function pick(opt) { input.value = opt.label; el.dataset.value = opt.value; closeMenu(); el.dispatchEvent(new CustomEvent('combochange', { detail: opt })); }
                input.addEventListener('input', () => { el.dataset.value = ''; filter(); });
                input.addEventListener('keydown', (e) => { if (e.key === 'ArrowDown') { openMenu(); e.preventDefault(); } if (e.key === 'Escape') { closeMenu(); } if (e.key === 'Enter') { const first = menu.querySelector('.combo-item'); if (first) { first.dispatchEvent(new MouseEvent('mousedown')); e.preventDefault(); } } });
                el.addEventListener('click', () => { filter(); input.focus(); }); document.addEventListener('click', (e) => { if (!el.contains(e.target)) closeMenu(); });
                return { setData(arr) { all = arr || []; render(all); }, setSelected(val, label) { el.dataset.value = val || ''; input.value = label || ''; }, get value() { return el.dataset.value || ''; }, get label() { return input.value || ''; }, clear() { this.setSelected('', ''); } };
            }

            const cityCombo = createCombo(cityBox, '— Chọn Tỉnh/Thành —');
            const wardCombo = createCombo(wardBox, '— Chọn Xã/Phường —');

            function extractWardNumber(base) { const m = (base || '').match(/\b(\d{1,3})\b/); return m ? m[1] : null; }
            function findWardMatch(name, wards) {
                if (!name || !wards || !wards.length) return null;
                const tgt = baseWard(name); if (!tgt) return null;
                let w = wards.find(x => baseWard(x.name) === tgt); if (w) return w;
                w = wards.find(x => { const bx = baseWard(x.name); return bx.includes(tgt) || tgt.includes(bx); }); if (w) return w;
                const num = extractWardNumber(tgt); if (num) { const re = new RegExp(`\\b${num}\\b`); w = wards.find(x => re.test(baseWard(x.name))); if (w) return w; }
                w = wards.find(x => { const bx = baseWard(x.name); return bx.startsWith(tgt) || tgt.startsWith(bx) || bx.endsWith(tgt) || tgt.endsWith(bx); });
                return w || null;
            }

            let provinces = []; let wardsOfCurrent = [];

            /* === Ready promises === */
            let provincesReadyResolve; const provincesReady = new Promise(r => provincesReadyResolve = r);
            let wardsReadyResolve; let wardsReady = Promise.resolve();

            function prefillWardText() { wardCombo && wardCombo.setSelected('', hidWardName.value || ''); }

            async function loadWards(provCode) {
                wardCombo && wardCombo.clear(); hidWardCode.value = ''; wardsOfCurrent = [];
                wardsReady = new Promise(r => wardsReadyResolve = r);
                if (!provCode) { prefillWardText(); wardsReadyResolve && wardsReadyResolve(); return; }
                try {
                    const resp = await fetch(DATA_BASE + '/wards/' + encodeURIComponent(provCode) + '.json', { cache: 'force-cache' });
                    const wards = resp.ok ? await resp.json() : [];
                    wardsOfCurrent = wards || [];
                    wardCombo && wardCombo.setData(wardsOfCurrent.map(w => ({ value: String(w.code), label: w.name, raw: w })));

                    if (hidWardCode.value) {
                        const w = wardsOfCurrent.find(x => String(x.code) === hidWardCode.value); if (w) { pickWard(w); wardsReadyResolve && wardsReadyResolve(); return; }
                    }
                    if (hidWardName.value) {
                        const w = findWardMatch(hidWardName.value, wardsOfCurrent); if (w) { pickWard(w); wardsReadyResolve && wardsReadyResolve(); return; }
                    }
                    prefillWardText();
                } catch (e) { console.error(e); prefillWardText(); }
                wardsReadyResolve && wardsReadyResolve();
            }

            function setCity(p) {
                if (!cityCombo) return;
                cityCombo.setSelected(String(p.code), p.name);
                hidCityName.value = p.name; hidCityCode.value = String(p.code);
                loadWards(String(p.code));
            }
            function pickWard(w) {
                if (!wardCombo) return;
                wardCombo.setSelected(String(w.code), w.name);
                hidWardName.value = w.name; hidWardCode.value = String(w.code);
            }

            // fetch provinces
            fetch(DATA_BASE + '/provinces.json', { cache: 'force-cache' })
                .then(r => r.json())
                .then(list => {
                    provinces = list || [];
                    cityCombo && cityCombo.setData(provinces.map(p => ({ value: String(p.code), label: p.name, raw: p })));
                    let p = null;
                    if (hidCityCode.value) { p = provinces.find(x => String(x.code) === hidCityCode.value); }
                    if (!p && hidCityName.value) { p = provinces.find(x => baseCity(x.name) === baseCity(hidCityName.value)); }
                    if (p) setCity(p); else { cityCombo && cityCombo.setSelected('', hidCityName.value || ''); prefillWardText(); }
                    provincesReadyResolve && provincesReadyResolve();
                });

            cityBox && cityBox.addEventListener('combochange', (e) => setCity(e.detail.raw));
            wardBox && wardBox.addEventListener('combochange', (e) => pickWard(e.detail.raw));

            if (cityBox) cityBox.querySelector('.combo-text').addEventListener('blur', () => {
                const lb = cityCombo?.label || '';
                if (rm(lb) !== rm(hidCityName.value)) { hidCityName.value = lb; hidCityCode.value = ''; wardCombo && wardCombo.clear(); hidWardName.value = ''; hidWardCode.value = ''; }
            });
            if (wardBox) wardBox.querySelector('.combo-text').addEventListener('blur', () => {
                const lb = wardCombo?.label || '';
                if (rm(lb) !== rm(hidWardName.value)) { hidWardName.value = lb; hidWardCode.value = ''; }
            });

            // Validators + submit guard
            window.validateCityCode = function (sender, args) { args.IsValid = !!hidCityCode.value; }
            window.validateWardCode = function (sender, args) { args.IsValid = !!hidWardCode.value; }

            // === Public API
            window.cityWardAPI = {
                async setByNames(cityName, wardName) {
                    await provincesReady;
                    if (cityName) {
                        const p = provinces.find(x => baseCity(x.name) === baseCity(cityName));
                        if (p) setCity(p);
                    }
                    await wardsReady;
                    if (wardName) {
                        const w = findWardMatch(wardName, wardsOfCurrent);
                        if (w) pickWard(w);
                    }
                    return true;
                },
                async setByCodes(cityCode, cityName, wardCode, wardName) {
                    await provincesReady;
                    if (cityCode) {
                        let p = provinces.find(x => String(x.code) === String(cityCode));
                        if (!p && cityName) p = provinces.find(x => baseCity(x.name) === baseCity(cityName));
                        if (p) setCity(p);
                    } else if (cityName) {
                        const p = provinces.find(x => baseCity(x.name) === baseCity(cityName));
                        if (p) setCity(p);
                    }
                    await wardsReady;
                    if (wardCode) {
                        let w = wardsOfCurrent.find(x => String(x.code) === String(wardCode));
                        if (!w && wardName) w = findWardMatch(wardName, wardsOfCurrent);
                        if (w) pickWard(w);
                    } else if (wardName) {
                        const w = findWardMatch(wardName, wardsOfCurrent);
                        if (w) pickWard(w);
                    }
                    return true;
                },
                whenReady() { return provincesReady.then(() => wardsReady); }
            };

            // ⭐⭐ AUTO MAP CHO ĐỊA CHỈ MẶC ĐỊNH ⭐⭐
            (function autoMapInitialAddress() {
                const needMap =
                    (hidCityName.value && !hidCityCode.value) ||
                    (hidWardName.value && !hidWardCode.value);

                if (!needMap) return;

                window.cityWardAPI.setByNames(hidCityName.value, hidWardName.value)
                    .then(function () {
                        if (typeof window.haQuoteShipping === 'function') {
                            window.haQuoteShipping();
                        } else {
                            setTimeout(function () {
                                if (typeof window.haQuoteShipping === 'function') {
                                    window.haQuoteShipping();
                                }
                            }, 300);
                        }
                    })
                    .catch(function (e) { console.error('autoMapInitialAddress error', e); });
            })();
        })();
    </script>

    <!-- Cart JS + Address Popup + Confirm Delete + Toast -->
    <script>
        (function () {
            const API = document.getElementById('<%= hidApiBase.ClientID %>').value || '';
            const UUID = document.getElementById('<%= hidDeviceUuid.ClientID %>').value || '';
            const JWT = (document.getElementById('<%= hidJwt.ClientID %>')?.value || '').trim();

            let sameOrigin = false; try { sameOrigin = new URL(API).host === location.host; } catch { }
            const HAS_JWT = !!JWT;
            const USE_USER = HAS_JWT || sameOrigin;

            // ⚡ FLAG BUY NOW: đọc từ ?buynow=1&variantId=...
            let IS_BUY_NOW = false;
            let BUY_NOW_VARIANT_ID = 0;
            try {
                const qs = new URLSearchParams(window.location.search || '');
                IS_BUY_NOW = qs.get('buynow') === '1' || qs.get('buynow') === 'true';
                BUY_NOW_VARIANT_ID = parseInt(qs.get('variantId') || '0', 10) || 0;
            } catch { }

            const fmt = n => (n || 0).toLocaleString('vi-VN') + ' ₫';

            const selectAll = document.getElementById('<%= chkSelectAll.ClientID %>');
            const hidSelected = document.getElementById('<%= hidSelectedLines.ClientID %>');
            const pnlEmptyEl = document.getElementById('<%= pnlEmpty.ClientID %>');

            function writeBadge(n) {
                const el = document.querySelector('[data-cart-badge="true"]');
                if (!el) return;
                const v = Math.max(0, parseInt(n || 0, 10));
                el.textContent = v; el.style.display = v > 0 ? 'flex' : 'none';
            }
            function readBadge() {
                const el = document.querySelector('[data-cart-badge="true"]');
                if (!el) return 0;
                const n = parseInt((el.textContent || '0').trim(), 10);
                return Number.isFinite(n) ? n : 0;
            }
            function bumpBadge(delta) { writeBadge(readBadge() + (parseInt(delta || 0, 10) || 0)); }

            if (typeof window.setCartBadge !== 'function') {
                window.setCartBadge = writeBadge;
            }
            if (typeof window.refreshCartCount !== 'function') {
                window.refreshCartCount = function () {
                    let sum = 0;
                    document.querySelectorAll('.cart-item .qty-num').forEach(el => {
                        sum += parseInt((el.textContent || '0').trim(), 10) || 0;
                    });
                    writeBadge(sum);
                };
            }

            function syncSelectedHidden() {
                const selected = [];
                document.querySelectorAll('.cart-item').forEach(row => {
                    const cb = row.querySelector('input[type="checkbox"]');
                    if (cb && cb.checked) {
                        const id = row.getAttribute('data-line-id');
                        if (id) selected.push(id);
                    }
                });
                hidSelected.value = selected.join(',');
            }

            function updateSelectAllUI() {
                const cbs = Array.from(document.querySelectorAll('.cart-item input[type="checkbox"]'));
                if (!selectAll) return;
                if (cbs.length === 0) { selectAll.checked = false; selectAll.indeterminate = false; return; }
                const checkedCount = cbs.filter(x => x.checked).length;
                selectAll.checked = (checkedCount === cbs.length);
                selectAll.indeterminate = (checkedCount > 0 && checkedCount < cbs.length);
            }

            /* === NEW: helper apply totals (có discount) === */
            function readPromoDiscount() {
                const hidDisc = document.getElementById('<%= hidPromoDiscount.ClientID %>');
                const d = Number((hidDisc && hidDisc.value) ? hidDisc.value : 0) || 0;
                return Math.max(0, d);
            }

            let _requoteGuard = false;
            function requestRequoteVoucherTotals() {
                if (_requoteGuard) return;
                if (typeof window.haRequoteVoucherTotals !== 'function') return;
                _requoteGuard = true;
                setTimeout(function () {
                    try { window.haRequoteVoucherTotals(); } catch { }
                    _requoteGuard = false;
                }, 0);
            }

            function recalcTotals() {
                let subtotal = 0,
                    sumItems = 0,
                    totalWeightGram = 0;

                document.querySelectorAll('.cart-item').forEach(row => {
                    const cb = row.querySelector('input[type="checkbox"]');
                    if (!cb || !cb.checked) return;

                    const price = Number(row.getAttribute('data-price')) || 0;
                    const unitWeight = Number(row.getAttribute('data-weight')) || 0;
                    const qtyEl = row.querySelector('.qty-num');
                    const qty = Number(qtyEl?.textContent.trim() || '1') || 1;

                    subtotal += price * qty;
                    sumItems += qty;
                    totalWeightGram += unitWeight * qty;
                });

                const vat = Math.round(subtotal * 0.08);

                // lấy ship từ hidden
                var hidShip = document.getElementById('<%= hidShippingFee.ClientID %>');
                var ship = 0;
                if (hidShip && hidShip.value) ship = Number(hidShip.value) || 0;

                // NEW: discount từ hidden
                const discount = readPromoDiscount();

                const grand = Math.max(0, subtotal + vat + ship - discount);

                const lblSubtotal = document.getElementById('<%= lblSubtotal.ClientID %>');
                const lblVat = document.getElementById('<%= lblVat.ClientID %>');
                const lblShipping = document.getElementById('<%= lblShipping.ClientID %>');
                const lblGrand = document.getElementById('<%= lblGrandTotal.ClientID %>');
                const lblTotal = document.getElementById('<%= lblTotal.ClientID %>');
                const lblSumItems = document.getElementById('<%= lblSumItems.ClientID %>');
                const lblDiscount = document.getElementById('<%= lblDiscount.ClientID %>');

                if (lblSubtotal) lblSubtotal.textContent = fmt(subtotal);
                if (lblVat) lblVat.textContent = fmt(vat);
                if (lblShipping) lblShipping.textContent = fmt(ship);
                if (lblDiscount) lblDiscount.textContent = fmt(discount);
                if (lblGrand) lblGrand.textContent = fmt(grand);
                if (lblTotal) lblTotal.textContent = fmt(subtotal);
                if (lblSumItems) lblSumItems.textContent = String(sumItems);

                // cập nhật trọng lượng
                var lblWeight = document.getElementById('<%= lblTotalWeight.ClientID %>');
                var hidWeight = document.getElementById('<%= hidTotalWeightGram.ClientID %>');
                if (lblWeight) {
                    lblWeight.textContent =
                        (Math.max(0, totalWeightGram) || 0).toLocaleString('vi-VN') + ' g';
                }
                if (hidWeight) {
                    hidWeight.value = String(Math.max(0, totalWeightGram) || 0);
                }

                // NEW: subtotal/ship/weight thay đổi -> requote voucher (nếu voucher là %)
                requestRequoteVoucherTotals();
            }

            window.__cartAfterMutate = () => { recalcTotals(); updateSelectAllUI(); syncSelectedHidden(); };

            /* HARD-LOCK UI các trường địa chỉ */
            function lockAddressUI() {
                try {
                    const city = document.getElementById('cmbCity');
                    const ward = document.getElementById('cmbWard');
                    [city, ward].forEach(el => {
                        if (!el) return;
                        el.classList.add('readonly');
                        el.setAttribute('aria-disabled', 'true');
                        const inp = el.querySelector('.combo-text');
                        if (inp) {
                            inp.setAttribute('readonly', 'readonly');
                            inp.setAttribute('tabindex', '-1');
                            inp.blur();
                        }
                    });
                    [
                        '<%= txtAddress.ClientID %>',
                        '<%= txtPhone.ClientID %>',
                        '<%= txtReceiver.ClientID %>'
                    ].forEach(id => {
                        const el = document.getElementById(id);
                        if (el) {
                            el.setAttribute('readonly', 'readonly');
                            el.setAttribute('aria-readonly', 'true');
                            el.setAttribute('tabindex', '-1');
                            el.classList.add('readonly');
                            el.blur();
                        }
                    });
                } catch (e) { console.error(e); }
            }

            /* POPUP địa chỉ */
            const modal = document.getElementById('addrModal');
            const backdrop = document.getElementById('addrModalBk');
            const iframe = document.getElementById('addrFrame');
            const openBtns = [document.getElementById('btnChooseAddr1'), document.getElementById('btnChooseAddr2')].filter(Boolean);
            const closeBtn = document.getElementById('addrCloseBtn');

            const IS_AUTH = (document.getElementById('<%= hidIsAuth.ClientID %>').value === '1');

            // NEW: cố định đường dẫn đúng như bạn yêu cầu
            const LOGIN_URL = '/AuthPage/Login.aspx';

            const addressSelectUrl = '<%= Page.ResolveUrl("~/CartPage/AddressSelect.aspx") %>';

            function openAddrModal() {
                iframe.src = addressSelectUrl;
                modal.classList.add('open');
                backdrop.classList.add('open');
                modal.setAttribute('aria-hidden', 'false');
            }
            function closeAddrModal() {
                iframe.src = 'about:blank';
                modal.classList.remove('open');
                backdrop.classList.remove('open');
                modal.setAttribute('aria-hidden', 'true');
            }

            openBtns.forEach(b => b.addEventListener('click', (e) => {
                e.preventDefault();
                if (!IS_AUTH) {
                    const ret = encodeURIComponent(window.location.pathname + window.location.search);
                    window.location.href = `${LOGIN_URL}?returnUrl=${ret}`;
                    return;
                }
                openAddrModal();
            }));
            closeBtn.addEventListener('click', closeAddrModal);
            backdrop.addEventListener('click', closeAddrModal);

            window.addEventListener('message', function (ev) {
                try {
                    if (ev.source !== iframe.contentWindow) return;
                    const data = ev.data || {};
                    if (data.type === 'HAFood.AddressPicked') {
                        if (data.address) { applyAddressToUI(data.address).finally(closeAddrModal); return; }
                        if (typeof PageMethods !== 'undefined' && PageMethods.GetSelectedAddress) {
                            PageMethods.GetSelectedAddress(function (dto) {
                                if (!dto) { closeAddrModal(); return; }
                                applyAddressToUI(dto).finally(closeAddrModal);
                            }, function () { closeAddrModal(); });
                        } else { closeAddrModal(); }
                    } else if (data.type === 'HAFood.AddressCancel') {
                        closeAddrModal();
                    }
                } catch (e) { console.error(e); }
            });

            function applyAddressToUI(dto) {
                const pnlHas = document.getElementById('<%= pnlAddrSession.ClientID %>');
                const pnlNone = document.getElementById('<%= pnlNoAddr.ClientID %>');
                if (pnlHas) pnlHas.style.display = 'block';
                if (pnlNone) pnlNone.style.display = 'none';

                const nameEl = document.getElementById('<%= lblAddrName.ClientID %>');
                const phoneEl = document.getElementById('<%= lblAddrPhone.ClientID %>');
                const detailEl = document.getElementById('<%= lblAddrDetail.ClientID %>');

                if (nameEl) nameEl.textContent = dto.fullName || '';
                if (phoneEl) phoneEl.textContent = dto.phone || '';
                if (detailEl) detailEl.textContent = dto.fullAddress || '';

                const street = parseStreet(dto.fullAddress || '');
                document.getElementById('<%= txtAddress.ClientID %>').value  = street;
                document.getElementById('<%= txtReceiver.ClientID %>').value = dto.fullName || '';
                document.getElementById('<%= txtPhone.ClientID %>').value = dto.phone || '';

                const cityName = extractCity(dto.fullAddress || '');
                const wardName = extractWard(dto.fullAddress || '');

                if (window.cityWardAPI && window.cityWardAPI.setByNames) {
                    return window.cityWardAPI.setByNames(cityName, wardName)
                        .then(function () {
                            if (typeof window.haQuoteShipping === 'function') {
                                window.haQuoteShipping();
                            }
                        })
                        .finally(lockAddressUI);
                }

                lockAddressUI();
                if (typeof window.haQuoteShipping === 'function') {
                    window.haQuoteShipping();
                }
                return Promise.resolve();
            }

            function parseStreet(full) {
                const parts = (full || '').split(',').map(s => s.trim()).filter(Boolean);
                if (parts.length <= 1) return full || '';
                if (parts.length >= 4) return parts.slice(0, parts.length - 3).join(', ');
                return parts[0] || '';
            }
            function extractCity(full) {
                const parts = (full || '').split(',').map(s => s.trim()).filter(Boolean);
                return parts.length ? parts[parts.length - 1] : '';
            }
            function extractWard(full) {
                const parts = (full || '').split(',').map(s => s.trim()).filter(Boolean);
                if (parts.length >= 3) return parts[parts.length - 2];
                if (parts.length === 2) return parts[1];
                return '';
            }

            /* INIT */
            window.addEventListener('DOMContentLoaded', () => {
                const hasItems = document.querySelectorAll('.cart-item').length > 0;
                if (pnlEmptyEl) pnlEmptyEl.style.display = hasItems ? 'none' : 'block';

                var phone = document.getElementById('<%= txtPhone.ClientID %>');
                if (phone) {
                    phone.setAttribute('type', 'tel');
                    phone.setAttribute('inputmode', 'tel');
                    phone.setAttribute('autocomplete', 'tel');
                }

                if (selectAll) {
                    if (IS_BUY_NOW && BUY_NOW_VARIANT_ID > 0) {
                        // Mua ngay: bỏ chọn hết, chỉ chọn dòng có variantId tương ứng
                        selectAll.checked = false;
                        selectAll.indeterminate = false;
                        document.querySelectorAll('.cart-item input[type="checkbox"]').forEach(cb => cb.checked = false);

                        const rows = Array.from(document.querySelectorAll('.cart-item'));
                        let matched = rows.filter(r => {
                            const vid = parseInt(r.getAttribute('data-variant-id') || '0', 10) || 0;
                            return vid === BUY_NOW_VARIANT_ID;
                        });

                        if (!matched.length && rows.length) {
                            matched = [rows[rows.length - 1]];
                        }

                        matched.forEach(r => {
                            const cb = r.querySelector('input[type="checkbox"]');
                            if (cb) cb.checked = true;
                        });
                    } else {
                        // Trường hợp bình thường: chọn tất cả
                        selectAll.checked = true;
                        document.querySelectorAll('.cart-item input[type="checkbox"]').forEach(cb => cb.checked = true);
                    }
                }

                recalcTotals();
                updateSelectAllUI();
                syncSelectedHidden();
                lockAddressUI();

                const clearBtn = document.getElementById('btnClearAll');
                if (clearBtn) clearBtn.disabled = !hasItems;

                try { window.refreshCartCount(); } catch { }

                if (IS_BUY_NOW) {
                    try {
                        const p = new URLSearchParams(window.location.search || '');
                        p.delete('buynow');
                        p.delete('variantId');
                        const newUrl = window.location.pathname + (p.toString() ? ('?' + p.toString()) : '');
                        window.history.replaceState({}, '', newUrl);
                    } catch { }
                }
            });

            /* Helpers giỏ hàng */
            function withAuthQuery(url) {
                const ch = (() => {
                    const wch = window.CHANNEL;
                    const n = (typeof wch === 'number') ? wch : parseInt(wch, 10);
                    return Number.isFinite(n) ? n : 1;
                })();

                const parts = ['channel=' + encodeURIComponent(ch)];
                if (!USE_USER && UUID) parts.push('device_uuid=' + encodeURIComponent(UUID));
                return url + (url.includes('?') ? '&' : '?') + parts.join('&');
            }

            function ensure(opts) {
                const headers = { 'Content-Type': 'application/json' };
                if (HAS_JWT) headers['Authorization'] = 'Bearer ' + JWT;
                return Object.assign({ credentials: 'include', headers }, opts || {});
            }
            async function safeJson(resp) { try { return await resp.json(); } catch { return {}; } }

            function patchTotals(payload) {
                // nếu API có trả totals riêng thì vẫn patch, nhưng vẫn giữ logic discount theo hidden
                if (payload && payload.totals) {
                    const t = payload.totals;

                    if (t.discount != null) {
                        const hidDisc = document.getElementById('<%= hidPromoDiscount.ClientID %>');
                        if (hidDisc) hidDisc.value = String(Number(t.discount) || 0);
                    }

                    document.getElementById('<%= lblSubtotal.ClientID %>').textContent = fmt(t.subtotal);
                    document.getElementById('<%= lblVat.ClientID %>').textContent = fmt(t.vat);
                    document.getElementById('<%= lblShipping.ClientID %>').textContent = fmt(t.shipping);

                    // grand có thể đã trừ discount ở API, nhưng để đồng bộ UI: recalcTotals() sẽ tính theo hidden
                    recalcTotals();
                }
                if (payload?.header?.item_Count != null) {
                    window.setCartBadge(payload.header.item_Count);
                }
                if (typeof window.haSyncPromoUI === 'function') {
                    try { window.haSyncPromoUI(); } catch { }
                }
            }

            /* Toast (success only) */
            const toastStack = document.getElementById('toastStack');
            function showToastSuccess(message) {
                if (!toastStack) return;
                const div = document.createElement('div');
                div.className = 'toast toast-success';
                div.setAttribute('role', 'alert');

                const icon = document.createElement('i');
                icon.className = 'bi bi-check-circle-fill toast-icon';

                const text = document.createElement('span');
                text.className = 'toast-text';
                text.textContent = message || '';

                div.appendChild(icon);
                div.appendChild(text);
                toastStack.appendChild(div);

                div.offsetHeight;
                div.classList.add('show');

                const close = () => {
                    div.classList.remove('show');
                    setTimeout(() => div.remove(), 180);
                };
                const timer = setTimeout(close, 3000);
                div.addEventListener('click', () => { clearTimeout(timer); close(); });
            }

            /* Xóa dòng */
            async function deleteLine(row, lineId, silent) {
                try {
                    const qtyBefore = Number(row.querySelector('.qty-num')?.textContent.trim() || '1') || 1;

                    let url = withAuthQuery(`${API}/api/cart/lines/${lineId}`);
                    let resp = await fetch(url, ensure({ method: 'DELETE' }));
                    let json = await safeJson(resp);

                    if (!resp.ok && json?.code === 'MISSING_USER_OR_DEVICE' && UUID) {
                        url = withAuthQuery(`${API}/api/cart/lines/${lineId}`);
                        resp = await fetch(url, ensure({ method: 'DELETE' }));
                        json = await safeJson(resp);
                    }

                    if (!resp.ok) {
                        if (json?.code === 'CART_LINE_NOT_FOUND') location.reload();
                        console.error('Delete failed', json);
                        return;
                    }

                    row.remove();

                    const remaining = document.querySelectorAll('.cart-item').length;
                    if (remaining === 0 && pnlEmptyEl) {
                        pnlEmptyEl.style.display = 'block';

                        const clearBtn = document.getElementById('btnClearAll');
                        if (clearBtn) clearBtn.disabled = true;

                        if (!(json?.header?.item_Count != null)) window.setCartBadge(0);
                    }

                    if (json?.totals || json?.header) patchTotals(json);

                    if (json?.header?.item_Count != null) {
                        window.setCartBadge(json.header.item_Count);
                    } else {
                        bumpBadge(-qtyBefore);
                    }

                    recalcTotals(); updateSelectAllUI(); syncSelectedHidden();

                    if (!silent) {
                        showToastSuccess('Bạn đã xóa sản phẩm trong giỏ hàng thành công');
                    }
                } catch (err) {
                    console.error(err);
                }
            }

            /* Popup xác nhận xóa 1 sản phẩm */
            const cModal = document.getElementById('confirmModal');
            const cBackdrop = document.getElementById('confirmModalBk');
            const cBtnClose = document.getElementById('confirmCloseBtn');
            const cBtnCancel = document.getElementById('confirmCancelBtn');
            const cBtnOk = document.getElementById('confirmOkBtn');

            let pendingRow = null, pendingLineId = null;

            function openConfirm(rowEl, lineId) {
                pendingRow = rowEl || null;
                pendingLineId = lineId || null;
                cModal.classList.add('open');
                cBackdrop.classList.add('open');
                cModal.setAttribute('aria-hidden', 'false');
                try { cBtnOk && cBtnOk.focus(); } catch { }
            }
            function closeConfirm() {
                cModal.classList.remove('open');
                cBackdrop.classList.remove('open');
                cModal.setAttribute('aria-hidden', 'true');
                pendingRow = null; pendingLineId = null;
            }

            [cBtnClose, cBtnCancel].forEach(b => b && b.addEventListener('click', closeConfirm));
            cBackdrop && cBackdrop.addEventListener('click', closeConfirm);
            cBtnOk && cBtnOk.addEventListener('click', async function () {
                if (!pendingRow || !pendingLineId) { closeConfirm(); return; }
                await deleteLine(pendingRow, pendingLineId, false);
                closeConfirm();
            });

            /* Popup xác nhận xóa TẤT CẢ */
            const caModal = document.getElementById('confirmAllModal');
            const caBackdrop = document.getElementById('confirmAllModalBk');
            const caBtnClose = document.getElementById('confirmAllCloseBtn');
            const caBtnCancel = document.getElementById('confirmAllCancelBtn');
            const caBtnOk = document.getElementById('confirmAllOkBtn');
            const btnClearAll = document.getElementById('btnClearAll');

            function openConfirmAll() {
                caModal.classList.add('open');
                caBackdrop.classList.add('open');
                caModal.setAttribute('aria-hidden', 'false');
                try { caBtnOk && caBtnOk.focus(); } catch { }
            }
            function closeConfirmAll() {
                caModal.classList.remove('open');
                caBackdrop.classList.remove('open');
                caModal.setAttribute('aria-hidden', 'true');
            }

            [caBtnClose, caBtnCancel].forEach(b => b && b.addEventListener('click', closeConfirmAll));
            caBackdrop && caBackdrop.addEventListener('click', closeConfirmAll);

            btnClearAll && btnClearAll.addEventListener('click', () => {
                if (btnClearAll.disabled) return;
                const hasRows = document.querySelectorAll('.cart-item').length > 0;
                if (!hasRows) return;
                openConfirmAll();
            });

            caBtnOk && caBtnOk.addEventListener('click', async function () {
                const rows = Array.from(document.querySelectorAll('.cart-item'));
                if (!rows.length) { closeConfirmAll(); return; }

                for (const row of rows) {
                    const lineId = Number(row.getAttribute('data-line-id'));
                    if (!lineId) continue;
                    await deleteLine(row, lineId, true);
                }

                showToastSuccess('Bạn đã xóa tất cả sản phẩm trong giỏ hàng thành công');
                closeConfirmAll();
            });

            /* Events: chọn checkbox & Select All */
            document.addEventListener('change', (e) => {
                if (e.target.matches('.cart-item input[type="checkbox"]')) {
                    recalcTotals(); updateSelectAllUI(); syncSelectedHidden();
                }
                if (selectAll && e.target.id === '<%= chkSelectAll.ClientID %>') {
                    const checked = e.target.checked;
                    document.querySelectorAll('.cart-item input[type="checkbox"]').forEach(cb => cb.checked = checked);
                    selectAll.indeterminate = false;
                    recalcTotals(); syncSelectedHidden();
                }
            });

            /* Events: Tăng / Giảm / Xóa */
            document.addEventListener('click', async (e) => {
                const inc = e.target.closest('.qty-btn[data-inc]');
                const dec = e.target.closest('.qty-btn[data-dec]');
                const rm = e.target.closest('[data-remove]');
                if (!inc && !dec && !rm) return;

                const row = (inc || dec || rm).closest('.cart-item');
                if (!row) return;

                const lineId = Number(row.getAttribute('data-line-id'));
                const price = Number(row.getAttribute('data-price')) || 0;

                if (rm) {
                    openConfirm(row, lineId);
                    return;
                }

                const qtyEl = row.querySelector('.qty-num');
                const qOld = Number(qtyEl.textContent.trim()) || 1;

                if (dec && qOld <= 1) {
                    openConfirm(row, lineId);
                    return;
                }

                const q = inc ? qOld + 1 : Math.max(1, qOld - 1);
                const delta = q - qOld;

                qtyEl.textContent = q;
                const totalEl = row.querySelector('.cart-item-total');
                if (totalEl) totalEl.textContent = fmt(price * q);

                try {
                    const url = withAuthQuery(`${API}/api/cart/lines/batch?compact=1`);
                    let body = USE_USER ? { changes: [{ line_id: lineId, quantity: q }] }
                        : { device_uuid: UUID || null, changes: [{ line_id: lineId, quantity: q }] };

                    let resp = await fetch(url, ensure({ method: 'PUT', body: JSON.stringify(body) }));
                    let json = await safeJson(resp);

                    if (!resp.ok && json?.code === 'MISSING_USER_OR_DEVICE' && UUID) {
                        body = { device_uuid: UUID, changes: [{ line_id: lineId, quantity: q }] };
                        resp = await fetch(`${API}/api/cart/lines/batch?compact=1`, ensure({ method: 'PUT', body: JSON.stringify(body) }));
                        json = await safeJson(resp);
                    }
                    if (!resp.ok) {
                        if (json?.code === 'CART_LINE_NOT_FOUND') location.reload();
                        console.error('Update qty failed', json); return;
                    }

                    if (json?.totals || json?.header) patchTotals(json);

                    if (json?.header?.item_Count != null) {
                        window.setCartBadge(json.header.item_Count);
                    } else if (delta !== 0) {
                        bumpBadge(delta);
                    }

                    recalcTotals(); updateSelectAllUI(); syncSelectedHidden();
                } catch (err) { console.error(err); }
            });

        })();
    </script>


    <!-- Submit guard (NEW: chưa login -> đi Login luôn) -->
    <script>
        function beforeCheckoutSubmit() {
            // NEW: Nếu chưa đăng nhập -> chuyển thẳng sang /AuthPage/Login.aspx (không validate)
            try {
                var isAuth = (document.getElementById('<%= hidIsAuth.ClientID %>')?.value === '1');
                if (!isAuth) {
                    var ret = encodeURIComponent(window.location.pathname + window.location.search);
                    window.location.href = '/AuthPage/Login.aspx?returnUrl=' + ret;
                    return false;
                }
            } catch (e) { }

            // giữ logic copy promo code
            try {
                var hidCode = document.getElementById('<%= hidPromoCodeSelected.ClientID %>');
                var txtPromo = document.getElementById('<%= txtPromo.ClientID %>');
                if (hidCode && txtPromo && hidCode.value && !txtPromo.value) {
                    txtPromo.value = hidCode.value;
                }
            } catch (e) { }

            if (typeof (Page_ClientValidate) === 'function') {
                if (!Page_ClientValidate('Checkout')) return false;
            }
            return true;
        }
    </script>

    <!-- Shipping quote hook (NEW: grand có trừ discount) -->
    <script>
        (function () {
            var apiBaseEl = document.getElementById('<%= hidApiBase.ClientID %>');
            var apiBase = (apiBaseEl && apiBaseEl.value || '').trim().replace(/\/+$/, '');

            function parseMoney(text) {
                var s = (text || '').replace(/[^\d\-]/g, '');
                var n = parseInt(s, 10);
                return Number.isFinite(n) ? n : 0;
            }

            function readDiscount() {
                var hidDisc = document.getElementById('<%= hidPromoDiscount.ClientID %>');
                var d = parseMoney(hidDisc ? hidDisc.value : '0');
                return Math.max(0, d);
            }

            async function quoteShipping() {
                if (!apiBase) return;

                var cityCode = (document.getElementById('<%= txtCityCode.ClientID %>')?.value || '').trim();
                var wardCode = (document.getElementById('<%= txtWardCode.ClientID %>')?.value || '').trim();

                if (!cityCode || !wardCode) {
                    var lblShip = document.getElementById('<%= lblShipping.ClientID %>');
                    if (lblShip) lblShip.textContent = '0 ₫';

                    var hidShip0 = document.getElementById('<%= hidShippingFee.ClientID %>');
                    if (hidShip0) hidShip0.value = '0';

                    if (window.haRequoteVoucherTotals) window.haRequoteVoucherTotals();
                    return;
                }

                var lblSubtotal = document.getElementById('<%= lblSubtotal.ClientID %>');
                var lblWeight = document.getElementById('<%= lblTotalWeight.ClientID %>');
                var subtotal = parseMoney(lblSubtotal ? lblSubtotal.textContent : '0');
                var totalWeightGram = parseMoney(lblWeight ? lblWeight.textContent : '0');

                var payload = {
                    cityCode: cityCode,
                    wardCode: wardCode,
                    subtotal: subtotal,
                    totalWeightGram: totalWeightGram,
                    channel: 1
                };

                try {
                    var resp = await fetch(apiBase + '/api/shipping/quote', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        credentials: 'include',
                        body: JSON.stringify(payload)
                    });

                    if (!resp.ok) throw new Error('HTTP ' + resp.status);
                    var json = await resp.json();

                    var fee = Number(json.shippingFee || json.shipping_fee || 0) || 0;

                    var hidShip = document.getElementById('<%= hidShippingFee.ClientID %>');
                    if (hidShip) { hidShip.value = String(fee); }

                    var lblShip2 = document.getElementById('<%= lblShipping.ClientID %>');
                    if (lblShip2) { lblShip2.textContent = fee.toLocaleString('vi-VN') + ' ₫'; }

                    var lblSubtotal2 = document.getElementById('<%= lblSubtotal.ClientID %>');
                    var lblVat2 = document.getElementById('<%= lblVat.ClientID %>');
                    var lblGrand = document.getElementById('<%= lblGrandTotal.ClientID %>');

                    var subtotal2 = parseMoney(lblSubtotal2 ? lblSubtotal2.textContent : '0');
                    var vat2 = Math.round(subtotal2 * 0.08);
                    var disc = readDiscount();

                    if (lblVat2) lblVat2.textContent = vat2.toLocaleString('vi-VN') + ' ₫';
                    if (lblGrand) lblGrand.textContent = Math.max(0, (subtotal2 + vat2 + fee - disc)).toLocaleString('vi-VN') + ' ₫';

                    if (window.haRequoteVoucherTotals) window.haRequoteVoucherTotals();

                } catch (e) {
                    console.error('quoteShipping error', e);
                    var lblShip3 = document.getElementById('<%= lblShipping.ClientID %>');
                    if (lblShip3) lblShip3.textContent = '0 ₫';

                    if (window.haRequoteVoucherTotals) window.haRequoteVoucherTotals();
                }
            }

            window.haQuoteShipping = quoteShipping;

            if (document.readyState === 'complete' || document.readyState === 'interactive') {
                setTimeout(quoteShipping, 0);
            } else {
                document.addEventListener('DOMContentLoaded', function () {
                    setTimeout(quoteShipping, 0);
                });
            }

            document.getElementById('cmbCity')?.addEventListener('combochange', function () {
                quoteShipping();
            });
            document.getElementById('cmbWard')?.addEventListener('combochange', function () {
                quoteShipping();
            });
        })();
    </script>

    <!-- NEW: Sync promo UI (code xuống dòng + cảnh báo đỏ + NOTICE giống hình) -->
    <script>
        (function () {
            const hidCode = document.getElementById('<%= hidPromoCodeSelected.ClientID %>');
            const hidDiscount = document.getElementById('<%= hidPromoDiscount.ClientID %>');
            const hidMeta = document.getElementById('<%= hidPromoMetaJson.ClientID %>');

            const codeEl = document.getElementById('promoCodeText');
            const errEl = document.getElementById('promoError');

            function safeParseJson(s) {
                try { return JSON.parse(s || '{}'); } catch { return {}; }
            }

            function inferInvalid(meta) {
                if (!meta) return false;

                // flags phổ biến
                if (meta.isValid === false || meta.valid === false || meta.ok === false || meta.success === false) return true;

                // code/status phổ biến
                const c = String(meta.code || meta.errorCode || meta.status || meta.reason || '').toUpperCase();
                if (['INVALID', 'NOT_VALID', 'NOTFOUND', 'NOT_FOUND', 'EXPIRED', 'DISABLED', 'USED', 'OUT_OF_QUOTA', 'ERROR'].includes(c)) return true;

                return false;
            }

            function inferRemoved(meta) {
                if (!meta) return false;

                // flag phổ biến
                if (meta.removed === true || meta.isRemoved === true || meta.unapplied === true) return true;

                // action/status/code phổ biến
                const a = String(meta.action || '').toUpperCase();
                const s = String(meta.status || '').toUpperCase();
                const c = String(meta.code || '').toUpperCase();
                if (a === 'REMOVE' || a === 'REMOVED') return true;
                if (s === 'REMOVE' || s === 'REMOVED') return true;
                if (c === 'REMOVE' || c === 'REMOVED') return true;

                return false;
            }

            function syncPromoUI() {
                const code = (hidCode?.value || '').trim();
                const discount = Math.max(0, Number((hidDiscount?.value || '0')) || 0);
                const meta = safeParseJson(hidMeta?.value || '');

                const invalid = code ? inferInvalid(meta) : false;
                const removed = inferRemoved(meta);

                const msg = (meta.message || meta.error || meta.errorMessage || meta.detail || '').toString().trim();

                // 1) Summary: hiển thị mã
                if (codeEl) {
                    codeEl.innerHTML = '<i class="bi bi-ticket-perforated"></i> ' + (code ? code : '—');
                }

                // 2) Summary: cảnh báo đỏ dưới mã (khi code đang có nhưng invalid)
                if (errEl) {
                    if (code && invalid) {
                        errEl.style.display = 'block';
                        errEl.textContent = msg || 'Mã khuyến mãi không hợp lệ.';
                    } else {
                        errEl.style.display = 'none';
                        errEl.textContent = '';
                    }
                }

                // 3) NOTICE giống hình: chỉ show khi voucher bị gỡ / hoặc code trống nhưng có message
                //    (tránh show notice khi user chỉ nhập sai mã)
                if (typeof window.showVoucherNotice === 'function') {
                    const shouldNotice = !!msg && (removed || (!code && msg));
                    window.showVoucherNotice(shouldNotice ? msg : '');
                }

                // 4) đồng bộ discount label nếu cần
                const lblDiscount = document.getElementById('<%= lblDiscount.ClientID %>');
                if (lblDiscount) {
                    lblDiscount.textContent = (discount || 0).toLocaleString('vi-VN') + ' ₫';
                }
            }

            window.haSyncPromoUI = syncPromoUI;

            // nếu voucher control có haRequoteVoucherTotals thì wrap lại để luôn sync UI
            if (typeof window.haRequoteVoucherTotals === 'function') {
                const old = window.haRequoteVoucherTotals;
                window.haRequoteVoucherTotals = function () {
                    try { old(); } finally { try { syncPromoUI(); } catch { } }
                };
            } else {
                window.haRequoteVoucherTotals = syncPromoUI;
            }

            document.addEventListener('DOMContentLoaded', syncPromoUI);
        })();
    </script>
</form>
</body>
</html>
