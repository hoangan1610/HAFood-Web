<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="OrderDetail.aspx.cs" Inherits="HAFoodWeb.OrderDetail" Async="true" %>

<!DOCTYPE html>
<html lang="vi">
<head runat="server">
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>Chi tiết đơn hàng - HAFood</title>

  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet" />

  <style>
    html, body { width:100%; max-width:100%; overflow-x:hidden; }
    body{ word-break:break-word; overflow-wrap:anywhere; margin:0; }

    body {
      font-family: 'Segoe UI', system-ui, -apple-system, BlinkMacSystemFont, sans-serif;
      background: radial-gradient(circle at top left, #ffe8cc 0, #f8f9fa 40%, #e9ecef 100%);
      min-height: 100vh;
    }
    .order-detail-page { max-width: 1080px; }

    .page-header-row{ margin-bottom: 0.75rem; }
    .page-header-title { font-weight: 700; font-size: 1.6rem; color: #212529; }
    .page-header-sub { font-size: .9rem; color: #6c757d; }

    .title-badge{
      font-size:.75rem; letter-spacing:.08em; text-transform:uppercase; font-weight:700;
      color:#fd7e14; background:rgba(253,126,20,.08); padding:.26rem .7rem; border-radius:999px;
      display:inline-flex; align-items:center; gap:.35rem; margin-bottom:.25rem;
    }
    .title-badge i{ font-size:.9rem; }

    .btn-back {
      border-radius: 999px; display: inline-flex; align-items: center; gap: .35rem;
      font-weight: 500; padding-inline: 0.9rem; padding-block: 0.35rem;
      border:1px solid #dee2e6; background:#f8f9fa; color:#495057; text-decoration:none; font-size:.88rem;
    }
    .btn-back:hover { background:#e9ecef; color:#212529; text-decoration:none; }
    .btn-back i { font-size: .9rem; }

    .card-order {
      background: #fff; padding: 1.25rem 1.35rem; border-radius: 1rem;
      box-shadow: 0 .35rem 1.25rem rgba(15, 23, 42, .06); border: 1px solid rgba(0, 0, 0, .03);
    }
    .card-order + .card-order { margin-top: 1rem; }

    .order-code { font-weight: 700; font-size: 1.15rem; color: #212529; }

    .order-meta-label { font-size: .9rem; color: #6c757d; min-width: 78px; }
    .order-meta-value { font-size: .95rem; font-weight: 500; color: #212529; }
    .order-meta-row + .order-meta-row { margin-top: .25rem; }

    /* Status pill */
    .order-status-pill {
      font-size: .8rem; font-weight: 700; border-radius: 999px; padding: .38rem .85rem;
      display: inline-flex; align-items: center; gap: .4rem;
      border: 1px solid rgba(0,0,0,.04);
      box-shadow: 0 .2rem .8rem rgba(15, 23, 42, .05);
      white-space: nowrap;
    }
    .status-0 { background: rgba(13,110,253,.08); color: #0d6efd; }
    .status-1 { background: rgba(111,66,193,.08); color: #6f42c1; }
    .status-2 { background: rgba(253,126,20,.10); color: #fd7e14; }
    .status-3 { background: rgba(25,135,84,.10); color: #198754; }
    .status-4 { background: rgba(108,117,125,.12); color: #6c757d; }
    .status-6 { background: rgba(13,110,253,.08); color: #0d6efd; }
    .status-7 { background: rgba(25,135,84,.10); color: #198754; }
    .status-9 { background: rgba(220,53,69,.10); color: #dc3545; }

    .header-badge {
      font-size: .75rem; letter-spacing: .06em; text-transform: uppercase; font-weight: 700;
      color: #fd7e14; background: rgba(253, 126, 20, .08); border-radius: 999px; padding: .25rem .75rem;
      display: inline-flex; align-items: center; gap: .35rem;
    }

    .section-title { font-size: 1.05rem; font-weight: 600; color: #212529; display:flex; align-items:center; gap:.45rem; }
    .section-title i { font-size: 1.05rem; color: #fd7e14; }

    .item-row { border-bottom: 1px dashed #e9ecef; padding: 12px 0; }
    .item-row:last-child { border-bottom: none; padding-bottom: 0; }

    .img-thumb {
      width: 80px; height: 80px; object-fit: cover; border-radius: .75rem;
      background: linear-gradient(135deg, #f8f9fa, #e9ecef); border: 1px solid rgba(0, 0, 0, .03);
    }

    .meta-small { color: #6c757d; font-size: .85rem; }
    .item-name { font-weight: 600; font-size: .97rem; margin-bottom: .1rem; color: #212529; }

    .price-main { font-weight: 700; font-size: .98rem; color: #e55a00; }
    .price-sub { font-size: .8rem; }

    .summary-line { display:flex; justify-content:space-between; gap:12px; padding:6px 0; font-size:.95rem; }
    .summary-line .label { color:#6c757d; font-weight:500; }
    .summary-line .value { font-weight:600; color:#212529; }

    .summary-line.total { font-size:1.05rem; margin-top:.2rem; }
    .summary-line.total .label { font-weight:700; color:#212529; }
    .summary-line.total .value { font-weight:800; color:#dc3545; }

    .summary-badge {
      font-size:.78rem; text-transform:uppercase; letter-spacing:.06em; font-weight:700; color:#0d6efd;
      background:rgba(13,110,253,.05); padding:.26rem .7rem; border-radius:999px; display:inline-flex; align-items:center; gap:.35rem; margin-bottom:.6rem;
    }

    .ha-btn-pill{ border-radius:999px; font-weight:600; letter-spacing:.01em; }
    .ha-input-sm{ font-size:.9rem; border-radius:.7rem; border-color:#d1d5db; }
    .ha-input-sm:focus{ border-color:#2aa33b; box-shadow:0 0 0 .15rem rgba(34,197,94,.22); }

    .ha-toast{
      position:fixed; top:20px; right:20px; background:#16a34a; color:#fff; padding:10px 14px;
      border-radius:999px; box-shadow:0 .25rem .9rem rgba(0,0,0,.22); z-index:20000; display:none; font-weight:500; font-size:.95rem;
    }

    /* Cancel button đẹp */
    .btn-cancel-order{
      border-radius:999px; font-weight:800; letter-spacing:.01em;
      padding:.55rem 1.05rem; font-size:.95rem;
      color:#dc3545; border:1px solid rgba(220,53,69,.28);
      background: linear-gradient(180deg, rgba(220,53,69,.06), rgba(220,53,69,.02));
      display:inline-flex; align-items:center; gap:.5rem;
      transition: transform .12s ease, box-shadow .12s ease, background .12s ease;
      white-space: nowrap;
    }
    .btn-cancel-order:hover{
      transform: translateY(-1px);
      box-shadow: 0 .35rem 1rem rgba(220,53,69,.12);
      background: linear-gradient(180deg, rgba(220,53,69,.09), rgba(220,53,69,.03));
      color:#dc3545;
    }
    .btn-cancel-order:active{ transform: translateY(0); }

    /* ✅ Confirm received button (NEW) */
    .btn-confirm-received{
      border-radius:999px; font-weight:800; letter-spacing:.01em;
      padding:.55rem 1.05rem; font-size:.95rem;
      color:#198754; border:1px solid rgba(25,135,84,.28);
      background: linear-gradient(180deg, rgba(25,135,84,.08), rgba(25,135,84,.02));
      display:inline-flex; align-items:center; gap:.5rem;
      transition: transform .12s ease, box-shadow .12s ease, background .12s ease;
      white-space: nowrap;
    }
    .btn-confirm-received:hover{
      transform: translateY(-1px);
      box-shadow: 0 .35rem 1rem rgba(25,135,84,.12);
      background: linear-gradient(180deg, rgba(25,135,84,.12), rgba(25,135,84,.03));
      color:#198754;
    }
    .btn-confirm-received:active{ transform: translateY(0); }

    /* ===== Review Modal (NEW - đẹp) ===== */
    .rv-progress-pill{
      font-size:.78rem; font-weight:800; letter-spacing:.02em;
      border-radius:999px; padding:.35rem .7rem;
      background: rgba(25,135,84,.10); color:#198754;
      display:inline-flex; align-items:center; gap:.4rem;
    }
    .rv-left{
      background: linear-gradient(180deg, rgba(13,110,253,.05), rgba(13,110,253,.02));
      border-radius: 1rem;
      border: 1px solid rgba(0,0,0,.05);
      padding: .6rem;
      max-height: 52vh;
      overflow:auto;
    }
    .rv-left .nav-link{
      border-radius: .9rem !important;
      display:flex; align-items:center; gap:.6rem;
      padding:.55rem .65rem;
      color:#212529;
      border: 1px solid transparent;
    }
    .rv-left .nav-link:hover{
      background: rgba(13,110,253,.06);
    }
    .rv-left .nav-link.active{
      background: #0d6efd;
      color:#fff;
      border-color: rgba(13,110,253,.25);
      box-shadow: 0 .25rem .9rem rgba(13,110,253,.18);
    }
    .rv-thumb{
      width:42px; height:42px; border-radius:.75rem; object-fit:cover;
      border:1px solid rgba(0,0,0,.06);
      background:#f8f9fa;
      flex: 0 0 auto;
    }
    .rv-name{ font-weight:700; font-size:.92rem; line-height:1.2; }
    .rv-meta{ font-size:.78rem; opacity:.85; }
    .rv-right{
      border-radius: 1rem;
      border: 1px solid rgba(0,0,0,.05);
      padding: 1rem 1rem;
      min-height: 52vh;
      background:#fff;
      box-shadow: 0 .35rem 1.25rem rgba(15, 23, 42, .05);
    }
    .rv-stars i{
      cursor:pointer;
      transition: transform .08s ease;
      font-size: 1.35rem;
    }
    .rv-stars i:hover{ transform: translateY(-1px); }
    .rv-badge{
      font-size:.78rem; font-weight:800;
      border-radius:999px; padding:.25rem .6rem;
      border: 1px solid rgba(0,0,0,.06);
      white-space:nowrap;
    }
    .rv-badge.todo{ background: rgba(253,126,20,.10); color:#fd7e14; }
    .rv-badge.done{ background: rgba(25,135,84,.10); color:#198754; }
    .rv-badge.lock{ background: rgba(108,117,125,.12); color:#6c757d; }

    #reviewModal .rv-submit,
    #reviewModal .rv-submit-item{
      border-radius: 999px;
      font-weight: 600 !important;
      letter-spacing:.01em;
      padding: .55rem 1rem;
    }

    .rv-hint{ font-size:.8rem; color:#6c757d; }

    @media (max-width: 767.98px) {
      .page-header-title { font-size: 1.35rem; }
      .card-order { padding: 1rem 1rem; }
      .img-thumb { width: 70px; height: 70px; }
      .btn-cancel-order, .btn-confirm-received { width: 100%; justify-content: center; }

      .rv-left{ max-height: 22vh; }
      .rv-right{ min-height: auto; }
    }

    #reviewModal .modal-dialog.rv-modal-wide{
      --bs-modal-width: calc(100vw - 2rem);
      width: calc(100vw - 2rem) !important;
      max-width: calc(100vw - 2rem) !important;
      margin: 1rem auto !important;
    }

    @media (max-width: 575.98px){
      #reviewModal .modal-dialog.rv-modal-wide{
        --bs-modal-width: calc(100vw - 1rem);
        width: calc(100vw - 1rem) !important;
        max-width: calc(100vw - 1rem) !important;
        margin: .5rem auto !important;
      }
    }
    #reviewModal .modal-content{
      border-radius: 1rem;
      width: 100% !important;
    }
  </style>

  <% if ("1".Equals(Request["embed"])) { %>
    <style>
      html, body {
        height:auto !important;
        min-height:auto !important;
        overflow: visible !important;
        background:#ffffff !important;
        background-image:none !important;
      }
    </style>
  <% } %>
</head>

<body>
  <div id="haToast" class="ha-toast">Đã thực hiện</div>

  <form id="form1" runat="server">
    <script>
        window.__AUTH_TOKEN = '<%= Session["JwtToken"] != null ? Session["JwtToken"].ToString() : "" %>';
        window.__API_BASE = '<%= System.Configuration.ConfigurationManager.AppSettings["ApiBaseUrl"] ?? "" %>';
    </script>

    <div class="container order-detail-page py-4">
      <header class="page-header-row d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2">
        <a runat="server" id="lnkBack" href="OrderPage.aspx" class="btn btn-outline-secondary btn-sm btn-back">
          <i class="bi bi-arrow-left"></i> Quay lại đơn hàng
        </a>
        <div class="text-end">
          <div class="title-badge"><i class="bi bi-basket2"></i> HAFood - Lịch sử mua hàng</div>
          <div class="page-header-title">Chi tiết đơn hàng</div>
          <div class="page-header-sub">Kiểm tra thông tin sản phẩm và thanh toán của đơn hàng của bạn.</div>
        </div>
      </header>

      <asp:Literal ID="litDebug" runat="server" Visible="false"></asp:Literal>

      <div class="row g-4">
        <div class="col-lg-8">
          <asp:Panel ID="pnlHeader" runat="server" Visible="false" CssClass="card-order mb-3">
            <div class="d-flex justify-content-between align-items-start flex-wrap gap-2 mb-2">
              <div>
                <div class="header-badge mb-2"><i class="bi bi-receipt-cutoff"></i> Thông tin đơn hàng</div>
                <div class="order-code">Mã đơn: <span id="litOrderCode" runat="server"></span></div>
              </div>
              <div class="text-end">
                <span id="litStatus" runat="server" class="order-status-pill"></span>
              </div>
            </div>

            <div class="row g-2 mt-2">
              <div class="col-md-6">
                <div class="order-meta-row d-flex">
                  <div class="order-meta-label">Người nhận</div>
                  <div class="order-meta-value ms-2"><span id="litShipName" runat="server"></span></div>
                </div>
                <div class="order-meta-row d-flex">
                  <div class="order-meta-label">Số điện thoại</div>
                  <div class="order-meta-value ms-2"><span id="litShipPhone" runat="server"></span></div>
                </div>
              </div>
              <div class="col-md-6">
                <div class="order-meta-row d-flex">
                  <div class="order-meta-label">Địa chỉ</div>
                  <div class="order-meta-value ms-2"><span id="litShipAddress" runat="server"></span></div>
                </div>
                <div class="order-meta-row d-flex">
                  <div class="order-meta-label">Ghi chú</div>
                  <div class="order-meta-value ms-2"><span id="litNote" runat="server"></span></div>
                </div>
              </div>
            </div>

            <asp:Panel ID="pnlPayment" runat="server" Visible="false" CssClass="mt-3">
              <div class="meta-small fw-semibold text-primary">
                <div class="d-flex align-items-center gap-2 flex-wrap">
                  <i class="bi bi-credit-card-2-front"></i>
                  <span>Phương thức thanh toán:</span>
                  <span id="litPayment" runat="server" class="order-meta-value ms-1"></span>
                </div>

                <small id="litPaymentExtra" runat="server" class="meta-small d-block mt-1 ms-4 text-muted"></small>
              </div>
            </asp:Panel>
          </asp:Panel>

          <asp:Panel ID="pnlItems" runat="server" Visible="false" CssClass="card-order mb-3">
            <h5 class="section-title"><i class="bi bi-bag-check"></i> Sản phẩm trong đơn</h5>
            <div class="embed-items-scroll">
              <asp:Repeater ID="rpItems" runat="server">
                <ItemTemplate>
                  <div class="d-flex item-row align-items-center">
                    <img src='<%# Eval("image_Variant") ?? Eval("image_Product") ?? "/images/product-default.png" %>'
                         class="img-thumb me-3"
                         onerror="this.src='/images/product-default.png';" />
                    <div class="flex-grow-1">
                      <div class="item-name"><%# Eval("product_Name") ?? Eval("name_Variant") %></div>
                      <div class="meta-small">
                        <span class="me-2">Mã: <%# Eval("sku") %></span>
                        <span>• Số lượng: <strong><%# Eval("quantity") %></strong></span>
                      </div>
                    </div>
                    <div class="text-end">
                      <div class="price-main">
                        <%# string.Format(new System.Globalization.CultureInfo("vi-VN"), "{0:#,0}đ", Eval("line_Subtotal")) %>
                      </div>
                      <div class="meta-small price-sub">
                        Đơn giá:
                        <%# string.Format(new System.Globalization.CultureInfo("vi-VN"), "{0:#,0}đ", Eval("price_Variant")) %>
                      </div>
                    </div>
                  </div>
                </ItemTemplate>
              </asp:Repeater>
            </div>
          </asp:Panel>
        </div>

        <div class="col-lg-4">
          <asp:Panel ID="pnlSummary" runat="server" Visible="false" CssClass="card-order">
            <div class="summary-badge"><i class="bi bi-clipboard-data"></i> Tóm tắt thanh toán</div>

            <div class="summary-line">
              <div class="label">Thành tiền</div>
              <div class="value"><asp:Literal ID="litSubtotal" runat="server" /></div>
            </div>

            <div class="summary-line">
              <div class="label">Giảm giá</div>
              <div class="value text-success"><asp:Literal ID="litDiscount" runat="server" /></div>
            </div>

            <div class="summary-line">
              <div class="label">Phí vận chuyển</div>
              <div class="value"><asp:Literal ID="litShipping" runat="server" /></div>
            </div>

            <div class="summary-line">
              <div class="label">VAT</div>
              <div class="value"><asp:Literal ID="litVat" runat="server" /></div>
            </div>

            <hr class="my-2" />

            <div class="summary-line total">
              <div class="label">Tổng thanh toán</div>
              <div class="value"><asp:Literal ID="litPayTotal" runat="server" /></div>
            </div>
          </asp:Panel>

          <%-- ==== REVIEW THEO ĐƠN ==== --%>
          <asp:Panel ID="pnlOrderReview" runat="server" Visible="false" CssClass="card-order">
            <div class="d-flex align-items-center justify-content-between mb-2">
              <h5 class="section-title mb-0"><i class="bi bi-chat-square-text"></i> Đánh giá đơn hàng</h5>
              <div class="mt-2 mt-sm-0">
                <button type="button" id="btnOpenOrderReview" class="btn btn-outline-success btn-sm ha-btn-pill d-none">
                  <i class="bi bi-pencil-square me-1"></i>Đánh giá từng sản phẩm
                </button>

                <span id="orderReviewDisabled" class="btn btn-outline-secondary btn-sm disabled ha-btn-pill d-none" style="cursor:not-allowed; pointer-events:none;">
                  Bạn chưa thể đánh giá (cần xác nhận đã nhận hàng)
                </span>

                <span id="orderReviewAlready" class="btn btn-outline-secondary btn-sm disabled ha-btn-pill d-none" style="cursor:not-allowed; pointer-events:none;">
                  Bạn đã đánh giá tất cả sản phẩm trong đơn rồi
                </span>
              </div>
            </div>

            <div class="small text-muted">Đánh giá sẽ được kiểm duyệt trước khi hiển thị công khai.</div>
          </asp:Panel>
        </div>
      </div>

      <%-- ✅ NÚT Ở CUỐI TRANG --%>
      <div class="mt-4 d-flex justify-content-end gap-2 flex-wrap">
        <button type="button" id="btnConfirmReceived" class="btn-confirm-received d-none">
          <i class="bi bi-check2-circle"></i> Tôi đã nhận hàng
        </button>

        <button type="button" id="btnCancelOrder" class="btn-cancel-order d-none">
          <i class="bi bi-x-circle"></i> Hủy đơn hàng
        </button>
      </div>

      <%-- Hidden dùng cho JS --%>
      <asp:HiddenField ID="hOrderId" runat="server" />
      <asp:HiddenField ID="hOrderCode" runat="server" />
      <asp:HiddenField ID="hCanReview" runat="server" />
      <asp:HiddenField ID="hFirstProductId" runat="server" />
      <asp:HiddenField ID="hFirstVariantId" runat="server" />

      <%-- ✅ NEW: JSON danh sách item trong đơn để render modal đánh giá từng sản phẩm --%>
      <asp:HiddenField ID="hOrderItemsJson" runat="server" />

      <%-- Hidden cho hủy đơn --%>
      <asp:HiddenField ID="hStatus" runat="server" />
      <asp:HiddenField ID="hCanCancel" runat="server" />

      <%-- ✅ Hidden cho xác nhận đã nhận hàng --%>
      <asp:HiddenField ID="hCanConfirmReceived" runat="server" />
    </div>
  </form>

  <%-- MODAL HỦY ĐƠN HÀNG --%>
  <div class="modal fade" id="cancelModal" tabindex="-1" aria-labelledby="cancelModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title" id="cancelModalLabel">
            <i class="bi bi-x-circle me-2 text-danger"></i>Hủy đơn hàng
          </h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Đóng"></button>
        </div>
        <div class="modal-body">
          <div class="small text-muted mb-2">Đơn hàng: <span id="cnOrderCode" class="fw-semibold"></span></div>
          <div class="alert alert-warning py-2 mb-0">
            <i class="bi bi-exclamation-triangle me-2"></i>
            Bạn chắc chắn muốn <strong>hủy đơn hàng</strong> này chứ?
          </div>
        </div>

        <div class="modal-footer d-flex justify-content-between w-100">
          <button type="button" class="btn btn-danger btn-sm ha-btn-pill" id="btnConfirmCancelOrder">
            <i class="bi bi-x-circle me-1"></i>Xác nhận hủy
          </button>
          <button type="button" class="btn btn-light btn-sm" data-bs-dismiss="modal">
            Hủy
          </button>
        </div>
      </div>
    </div>
  </div>

  <!-- ✅ MODAL XÁC NHẬN ĐÃ NHẬN HÀNG -->
  <div class="modal fade" id="receivedModal" tabindex="-1" aria-labelledby="receivedModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title" id="receivedModalLabel">
            <i class="bi bi-check2-circle me-2 text-success"></i>Xác nhận đã nhận hàng
          </h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Đóng"></button>
        </div>

        <div class="modal-body">
          <div class="small text-muted mb-2">Đơn hàng: <span id="rcOrderCode" class="fw-semibold"></span></div>
          <div class="alert alert-success py-2 mb-0">
            <i class="bi bi-info-circle me-2"></i>
            Bạn chắc chắn đã <strong>nhận đủ hàng</strong> và muốn hoàn tất đơn này chứ?
          </div>
          <div class="small text-muted mt-2">
            * Sau khi xác nhận, đơn sẽ chuyển sang <strong>Đã nhận hàng</strong> và bạn có thể đánh giá sản phẩm.
          </div>
        </div>

        <div class="modal-footer d-flex justify-content-between w-100">
          <button type="button" class="btn btn-success btn-sm ha-btn-pill" id="btnConfirmReceivedDo">
            <i class="bi bi-check2-circle me-1"></i>Xác nhận
          </button>
          <button type="button" class="btn btn-light btn-sm" data-bs-dismiss="modal">
            Hủy
          </button>
        </div>
      </div>
    </div>
  </div>

  <%-- ✅ MODAL REVIEW TỪNG SẢN PHẨM (NEW UI) --%>
  <div class="modal fade" id="reviewModal" tabindex="-1" aria-labelledby="reviewModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-xl modal-dialog-centered modal-dialog-scrollable rv-modal-wide">
      <div class="modal-content">
        <div class="modal-header">
          <div class="d-flex flex-column">
            <h5 class="modal-title" id="reviewModalLabel">Đánh giá từng sản phẩm</h5>
            <div class="small text-muted mt-1">Đơn hàng: <span id="rvOrderCode" class="fw-semibold"></span></div>
          </div>

          <div class="d-flex align-items-center gap-2">
            <span id="rvProgress" class="rv-progress-pill">
              <i class="bi bi-check2-circle"></i> <span>0/0 đã đánh giá</span>
            </span>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Đóng"></button>
          </div>
        </div>

        <div class="modal-body">
          <div class="row g-3">
            <div class="col-md-4">
              <div class="rv-left">
                <div id="rvNav" class="nav nav-pills flex-column gap-2" role="tablist" aria-orientation="vertical"></div>
              </div>
            </div>

            <div class="col-md-8">
              <div class="rv-right">
                <div id="rvTabs" class="tab-content"></div>

                <div id="rvEmpty" class="text-center text-muted d-none" style="padding: 2rem 0;">
                  <i class="bi bi-inbox fs-2 d-block mb-2"></i>
                  Không có sản phẩm để đánh giá.
                </div>

                <div class="rv-hint mt-3">
                  * Mỗi sản phẩm có thể có nội dung đánh giá khác nhau. Ảnh tối đa ~5 ảnh, mỗi ảnh không quá 2MB.
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="modal-footer">
          <button type="button" class="btn btn-light btn-sm" data-bs-dismiss="modal">Đóng</button>
          <button type="button" class="btn btn-success btn-sm ha-btn-pill rv-submit" id="btnSubmitAllReviews">
            <i class="bi bi-send-check me-1"></i>Gửi tất cả đánh giá
          </button>
        </div>
      </div>
    </div>
  </div>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

  <script>
      function showToast(msg, isError) {
          const el = document.getElementById('haToast'); if (!el) return;
          el.textContent = msg || 'Đã thực hiện';
          el.style.background = isError ? '#dc3545' : '#16a34a';
          el.style.display = 'block';
          setTimeout(() => { el.style.display = 'none'; }, 1800);
      }

      function statusText(status) {
          switch (parseInt(status || '0', 10)) {
              case 0: return 'Đã được tạo';
              case 1: return 'Đã xác nhận';
              case 2: return 'Đang giao';
              case 3: return 'Đã giao';
              case 6: return 'Đang giao hàng';
              case 7: return 'Đã nhận hàng';
              case 4: return 'Đã huỷ';
              case 9: return 'Huỷ đơn';
              default: return 'Không rõ';
          }
      }

      function setStatusPill(status) {
          var pill = document.getElementById('<%= litStatus.ClientID %>');
          if (!pill) return;
          var s = parseInt(status || '0', 10);
          pill.textContent = statusText(s);
          pill.className = 'order-status-pill status-' + s;
      }

      // ✅ Chỉ hiện nút hủy khi status=0; còn lại ẩn hoàn toàn
      function decideCancelUI() {
          const status = parseInt(document.getElementById('<%= hStatus.ClientID %>').value || '0', 10);
        const canCancel = (document.getElementById('<%= hCanCancel.ClientID %>').value === '1');
          const btn = document.getElementById('btnCancelOrder');
          if (!btn) return;

          if (status === 0 && canCancel) btn.classList.remove('d-none');
          else btn.classList.add('d-none');
      }

      function decideConfirmReceivedUI() {
          const status = parseInt(document.getElementById('<%= hStatus.ClientID %>').value || '0', 10);
        const can = (document.getElementById('<%= hCanConfirmReceived.ClientID %>').value === '1');
          const btn = document.getElementById('btnConfirmReceived');
          if (!btn) return;

          if (can && status === 3) btn.classList.remove('d-none');
          else btn.classList.add('d-none');
      }

      // ✅ Swagger: POST /api/orders/{id}/status, body là số 4
      async function callCancelOrderApi(orderId) {
          const API_BASE = (window.__API_BASE || '').replace(/\/+$/, '');
          const token = window.__AUTH_TOKEN || '';
          if (!API_BASE) throw new Error('Thiếu cấu hình API');
          if (!token) throw new Error('Vui lòng đăng nhập để hủy đơn');

          const resp = await fetch(`${API_BASE}/api/orders/${orderId}/status`, {
              method: 'POST',
              headers: {
                  'Accept': 'application/json',
                  'Content-Type': 'application/json',
                  'Authorization': 'Bearer ' + token
              },
              credentials: 'include',
              body: JSON.stringify(4)
          });

          let data = null; try { data = await resp.json(); } catch { }
          if (resp.status === 401 || resp.status === 403) throw new Error('Vui lòng đăng nhập để hủy đơn');
          if (!resp.ok) throw new Error((data && (data.message || data.detail)) || 'Không thể hủy đơn, vui lòng thử lại.');
          return data;
      }

      // ✅ POST /api/orders/{id}/confirm-received
      async function callConfirmReceivedApi(orderId) {
          const API_BASE = (window.__API_BASE || '').replace(/\/+$/, '');
          const token = window.__AUTH_TOKEN || '';
          if (!API_BASE) throw new Error('Thiếu cấu hình API');
          if (!token) throw new Error('Vui lòng đăng nhập để xác nhận');

          const resp = await fetch(`${API_BASE}/api/orders/${orderId}/confirm-received`, {
              method: 'POST',
              headers: {
                  'Accept': 'application/json',
                  'Authorization': 'Bearer ' + token
              },
              credentials: 'include'
              // ✅ KHÔNG gửi body, KHÔNG set Content-Type
          });

          // ✅ nhiều API trả 204 NoContent / body rỗng
          let data = null;
          const ct = resp.headers.get('content-type') || '';
          if (ct.includes('application/json')) {
              try { data = await resp.json(); } catch { data = null; }
          } else {
              // nếu không phải json thì cố đọc text để debug
              try { data = await resp.text(); } catch { }
          }

          if (resp.status === 401 || resp.status === 403) throw new Error('Vui lòng đăng nhập để xác nhận');

          if (!resp.ok) {
              // nếu data là json có message/detail
              if (data && typeof data === 'object') {
                  throw new Error((data.message || data.detail) || 'Không thể xác nhận nhận hàng.');
              }
              // nếu data là text
              if (typeof data === 'string' && data.trim()) {
                  throw new Error(data);
              }
              throw new Error('Không thể xác nhận nhận hàng.');
          }

          return data;
      }

      // ===== Review (NEW) =====
      window.__rvEligibility = window.__rvEligibility || {};
      window.__rvSubmitting = window.__rvSubmitting || {};

      function escapeHtml(s) {
          return String(s ?? '').replace(/[&<>"']/g, function (m) {
              return ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[m];
          });
      }

      function makeKey(productId, variantId) {
          const p = parseInt(productId || 0, 10);
          const v = parseInt(variantId || 0, 10);
          return p + ':' + v;
      }

      function keyToId(key) { return String(key).replace(/[^a-zA-Z0-9_]/g, '_'); }

      function getOrderItems() {
          try {
              const raw = document.getElementById('<%= hOrderItemsJson.ClientID %>')?.value || '[]';
              const arr = JSON.parse(raw) || [];
              return arr
                  .map(x => ({
                      productId: parseInt(x.productId || x.ProductId || 0, 10),
                      variantId: parseInt(x.variantId || x.VariantId || 0, 10),
                      name: (x.name || x.Name || ''),
                      sku: (x.sku || x.Sku || ''),
                      image: (x.image || x.Image || '/images/product-default.png'),
                      quantity: parseInt(x.quantity || x.Quantity || 0, 10)
                  }))
                  .filter(x => x.productId > 0);
          } catch {
              return [];
          }
      }

      async function isAlreadyReviewed(productId, variantId) {
          const key = makeKey(productId, variantId);
          if (window.__rvEligibility.hasOwnProperty(key)) return window.__rvEligibility[key];

          try {
              const API_BASE = (window.__API_BASE || '').replace(/\/+$/, '');
              const token = window.__AUTH_TOKEN || '';
              if (!API_BASE || !token || !productId) { window.__rvEligibility[key] = false; return false; }

              let url = `${API_BASE}/api/products/${productId}/reviews/eligibility`;
              if (variantId > 0) url += `?variantId=${variantId}`;

              const resp = await fetch(url, {
                  method: 'GET',
                  headers: { 'Accept': 'application/json', 'Authorization': 'Bearer ' + token },
                  credentials: 'include'
              });

              if (!resp.ok) { window.__rvEligibility[key] = false; return false; }

              const data = await resp.json();
              const already = !!(data.already_Reviewed || data.Already_Reviewed);
              window.__rvEligibility[key] = already;
              return already;
          } catch {
              window.__rvEligibility[key] = false;
              return false;
          }
      }

      function setStars(container, rating) {
          const r = parseInt(rating || '0', 10);
          const hidden = container.closest('.rv-pane')?.querySelector('input.rv-rating-value');
          if (hidden) hidden.value = String(r);

          container.querySelectorAll('i[data-rating]').forEach(function (el) {
              const v = parseInt(el.getAttribute('data-rating') || '0', 10);
              if (v <= r) { el.classList.remove('bi-star'); el.classList.add('bi-star-fill', 'text-warning'); }
              else { el.classList.add('bi-star'); el.classList.remove('bi-star-fill', 'text-warning'); }
          });
      }

      function bindStars(container) {
          container.addEventListener('click', function (e) {
              const t = e.target;
              if (!t || !t.getAttribute) return;
              const r = parseInt(t.getAttribute('data-rating') || '0', 10);
              if (r >= 1 && r <= 5) setStars(container, r);
          });
      }

      function setPaneDone(key) {
          const id = keyToId(key);
          const pane = document.getElementById('rvPane_' + id);
          if (!pane) return;

          pane.querySelectorAll('input, textarea, button').forEach(function (el) {
              if (el.classList.contains('btn-close')) return;
              el.disabled = true;
          });

          const badge = pane.querySelector('.rv-badge');
          if (badge) {
              badge.classList.remove('todo', 'lock');
              badge.classList.add('done');
              badge.textContent = 'Đã đánh giá';
          }

          const submitBtn = pane.querySelector('button.rv-submit-item');
          if (submitBtn) submitBtn.classList.add('d-none');

          const nav = document.querySelector(`[data-bs-target="#rvPane_${id}"]`);
          if (nav) {
              const meta = nav.querySelector('.rv-meta');
              if (meta) meta.innerHTML = (meta.innerHTML || '').replace(/•\s*Chưa đánh giá/gi, '') + ' • Đã đánh giá';
          }
      }

      function updateProgress(items) {
          const total = items.length;
          let done = 0;
          items.forEach(it => {
              const key = makeKey(it.productId, it.variantId);
              if (window.__rvEligibility[key] === true) done++;
          });
          const el = document.getElementById('rvProgress');
          if (el) {
              const span = el.querySelector('span');
              if (span) span.textContent = `${done}/${total} đã đánh giá`;
          }
      }

      function updateSubmitAllButton(items) {
          const btn = document.getElementById('btnSubmitAllReviews');
          if (!btn) return;

          const list = items || [];
          const hasTodo = list.some(it => window.__rvEligibility[makeKey(it.productId, it.variantId)] !== true);

          if (!hasTodo) {
              btn.disabled = true;
              btn.classList.remove('btn-success');
              btn.classList.add('btn-secondary');
              btn.setAttribute('aria-disabled', 'true');
              btn.title = 'Tất cả sản phẩm đã được đánh giá';
          } else {
              btn.disabled = false;
              btn.classList.remove('btn-secondary');
              btn.classList.add('btn-success');
              btn.removeAttribute('aria-disabled');
              btn.title = '';
          }
      }

      function renderReviewModal(items) {
          const nav = document.getElementById('rvNav');
          const tabs = document.getElementById('rvTabs');
          const empty = document.getElementById('rvEmpty');

          if (!nav || !tabs) return;

          nav.innerHTML = '';
          tabs.innerHTML = '';

          if (!items || !items.length) {
              if (empty) empty.classList.remove('d-none');
              updateSubmitAllButton([]);
              return;
          } else {
              if (empty) empty.classList.add('d-none');
          }

          items.forEach(function (it, idx) {
              const key = makeKey(it.productId, it.variantId);
              const id = keyToId(key);

              const name = escapeHtml(it.name || ('Sản phẩm #' + it.productId));
              const sku = escapeHtml(it.sku || '');
              const img = escapeHtml(it.image || '/images/product-default.png');
              const qty = it.quantity > 0 ? it.quantity : '';

              const navBtn = document.createElement('button');
              navBtn.type = 'button';
              navBtn.className = 'nav-link ' + (idx === 0 ? 'active' : '');
              navBtn.setAttribute('data-bs-toggle', 'pill');
              navBtn.setAttribute('data-bs-target', '#rvPane_' + id);
              navBtn.setAttribute('role', 'tab');
              navBtn.innerHTML = `
          <img class="rv-thumb" src="${img}" onerror="this.src='/images/product-default.png';" />
          <div class="flex-grow-1 text-start">
            <div class="rv-name">${name}</div>
            <div class="rv-meta">${sku ? ('SKU: ' + sku) : 'Sản phẩm'}${qty ? (' • SL: ' + qty) : ''} • Chưa đánh giá</div>
          </div>
        `;
              nav.appendChild(navBtn);

              const pane = document.createElement('div');
              pane.className = 'tab-pane fade rv-pane ' + (idx === 0 ? 'show active' : '');
              pane.id = 'rvPane_' + id;
              pane.setAttribute('role', 'tabpanel');
              pane.innerHTML = `
          <div class="d-flex align-items-start justify-content-between gap-2 mb-2">
            <div class="d-flex align-items-center gap-2">
              <img class="rv-thumb" src="${img}" onerror="this.src='/images/product-default.png';" />
              <div>
                <div class="fw-bold">${name}</div>
                <div class="text-muted small">${sku ? ('SKU: ' + sku) : ''}${qty ? (' • Số lượng: ' + qty) : ''}</div>
              </div>
            </div>
            <span class="rv-badge todo">Chưa đánh giá</span>
          </div>

          <hr class="my-3" />

          <div class="mb-3">
            <label class="form-label small mb-1 fw-semibold">Số sao</label>
            <div class="rv-stars d-flex gap-1">
              <i class="bi bi-star" data-rating="1"></i>
              <i class="bi bi-star" data-rating="2"></i>
              <i class="bi bi-star" data-rating="3"></i>
              <i class="bi bi-star" data-rating="4"></i>
              <i class="bi bi-star" data-rating="5"></i>
            </div>
            <input type="hidden" class="rv-rating-value" id="rvRating_${id}" value="5" />
          </div>

          <div class="mb-2">
            <label class="form-label small mb-1 fw-semibold">Tiêu đề</label>
            <input type="text" class="form-control form-control-sm ha-input-sm" id="rvTitle_${id}" maxlength="200"
                   placeholder="Ví dụ: Ngon, đóng gói kỹ, giao nhanh..." />
          </div>

          <div class="mb-2">
            <label class="form-label small mb-1 fw-semibold">Nội dung</label>
            <textarea class="form-control form-control-sm ha-input-sm" rows="4" maxlength="2000" id="rvContent_${id}"
                      placeholder="Chia sẻ trải nghiệm thực tế của bạn về sản phẩm này..."></textarea>
          </div>

          <div class="mb-2">
            <label class="form-label small mb-1 fw-semibold">Hình ảnh (tùy chọn)</label>
            <input type="file" class="form-control form-control-sm" accept="image/*" multiple id="rvImages_${id}" />
            <div class="form-text small text-muted">Tối đa ~5 ảnh, mỗi ảnh không quá 2MB.</div>
          </div>

          <div class="d-flex align-items-center justify-content-between gap-2 mt-3 flex-wrap">
            <button type="button" class="btn btn-success btn-sm rv-submit rv-submit-item"
                    data-product-id="${it.productId}" data-variant-id="${it.variantId}">
              <i class="bi bi-send me-1"></i>Gửi đánh giá sản phẩm này
            </button>
            <div class="small text-muted" id="rvMsg_${id}"></div>
          </div>
        `;
              tabs.appendChild(pane);

              const starsWrap = pane.querySelector('.rv-stars');
              if (starsWrap) {
                  bindStars(starsWrap);
                  setStars(starsWrap, 5);
              }
          });

          updateSubmitAllButton(items);
      }

      async function postReviewForItem(productId, variantId) {
          const key = makeKey(productId, variantId);
          const id = keyToId(key);

          const pane = document.getElementById('rvPane_' + id);
          if (!pane) throw new Error('Không tìm thấy form đánh giá');

          const rating = parseInt(pane.querySelector('#rvRating_' + id)?.value || '0', 10);
          const title = pane.querySelector('#rvTitle_' + id)?.value || '';
          const content = pane.querySelector('#rvContent_' + id)?.value || '';
          const filesEl = pane.querySelector('#rvImages_' + id);
          const files = filesEl && filesEl.files ? filesEl.files : null;

          if (!rating || rating < 1 || rating > 5) throw new Error('Vui lòng chọn số sao đánh giá');

          const orderId = parseInt((document.getElementById('<%= hOrderId.ClientID %>')?.value || '0'), 10);
          if (!orderId) throw new Error('Thiếu dữ liệu đơn hàng');

          const API_BASE = (window.__API_BASE || '').replace(/\/+$/, '');
          const auth = window.__AUTH_TOKEN || '';
          if (!API_BASE) throw new Error('Thiếu cấu hình API');
          if (!auth) throw new Error('Vui lòng đăng nhập để gửi đánh giá');

          const formData = new FormData();
          formData.append('Product_Id', String(productId));
          if (parseInt(variantId || 0, 10) > 0) formData.append('Variant_Id', String(variantId));
          formData.append('Order_Id', String(orderId));
          formData.append('Rating', String(rating));
          if (title.trim()) formData.append('Title', title.trim());
          if (content.trim()) formData.append('Content', content.trim());

          let hasImages = false;
          let count = 0;
          if (files && files.length) {
              for (let i = 0; i < files.length; i++) {
                  const f = files[i]; if (!f) continue;
                  if (f.size > 2 * 1024 * 1024) continue;
                  count++;
                  if (count > 5) break;
                  hasImages = true;
                  formData.append('Images', f);
              }
          }
          formData.append('Has_Image', hasImages ? 'true' : 'false');

          const resp = await fetch(API_BASE + '/api/reviews', {
              method: 'POST',
              headers: { 'Accept': 'application/json', 'Authorization': 'Bearer ' + auth },
              credentials: 'include',
              body: formData
          });

          let data = null; try { data = await resp.json(); } catch { }
          if (resp.status === 401 || resp.status === 403) throw new Error('Vui lòng đăng nhập để gửi đánh giá');
          if (!resp.ok || (data && data.success === false)) {
              throw new Error((data && (data.message || data.detail)) || 'Không thể gửi đánh giá, vui lòng thử lại.');
          }
          return data;
      }

      async function hydrateEligibility(items) {
          for (const it of items) {
              const key = makeKey(it.productId, it.variantId);
              const already = await isAlreadyReviewed(it.productId, it.variantId);
              if (already) setPaneDone(key);
          }
          updateProgress(items);
          updateSubmitAllButton(items);
      }

      async function decideOrderReviewUI() {
          const canReviewEl = document.getElementById('<%= hCanReview.ClientID %>');
      const canReview = (canReviewEl && canReviewEl.value === '1');

      const btn = document.getElementById('btnOpenOrderReview');
      const disabled = document.getElementById('orderReviewDisabled');
      const already = document.getElementById('orderReviewAlready');

      [btn, disabled, already].forEach(x => x && x.classList.add('d-none'));

      if (!canReview) { if (disabled) disabled.classList.remove('d-none'); return; }

      const items = getOrderItems();
      if (!items.length) { if (btn) btn.classList.remove('d-none'); return; }

      try {
        for (const it of items) {
          const ar = await isAlreadyReviewed(it.productId, it.variantId);
          if (!ar) { if (btn) btn.classList.remove('d-none'); return; }
        }
        if (already) already.classList.remove('d-none');
      } catch {
        if (btn) btn.classList.remove('d-none');
      }
    }

    document.addEventListener('DOMContentLoaded', function () {
      setStatusPill(document.getElementById('<%= hStatus.ClientID %>').value || '0');

      const oc = document.getElementById('<%= hOrderCode.ClientID %>')?.value || '';
      const rv = document.getElementById('rvOrderCode'); if (rv) rv.textContent = oc;
      const cn = document.getElementById('cnOrderCode'); if (cn) cn.textContent = oc;
      const rc = document.getElementById('rcOrderCode'); if (rc) rc.textContent = oc;

      // Cancel modal
      let cancelModalInstance = null;
      document.getElementById('btnCancelOrder')?.addEventListener('click', function () {
        const el = document.getElementById('cancelModal');
        if (!cancelModalInstance) cancelModalInstance = new bootstrap.Modal(el);
        cancelModalInstance.show();
      });

      // Confirm cancel
      document.getElementById('btnConfirmCancelOrder')?.addEventListener('click', async function () {
        const btn = document.getElementById('btnConfirmCancelOrder');
        const oldHtml = btn.innerHTML;

        try {
          const status = parseInt(document.getElementById('<%= hStatus.ClientID %>').value || '0', 10);
          const canCancel = (document.getElementById('<%= hCanCancel.ClientID %>').value === '1');
          if (!(canCancel && status === 0)) { showToast('Đơn hàng không đủ điều kiện để hủy.', true); return; }

          const orderId = parseInt(document.getElementById('<%= hOrderId.ClientID %>').value || '0', 10);
          if (!orderId) { showToast('Thiếu dữ liệu đơn hàng', true); return; }

          btn.disabled = true;
          btn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Đang hủy...';

          await callCancelOrderApi(orderId);

          document.getElementById('<%= hStatus.ClientID %>').value = '4';
          document.getElementById('<%= hCanCancel.ClientID %>').value = '0';
          setStatusPill(4);
          decideCancelUI();

          // cancel => không confirm received / không review
          document.getElementById('<%= hCanConfirmReceived.ClientID %>').value = '0';
          decideConfirmReceivedUI();

          document.getElementById('<%= hCanReview.ClientID %>').value = '0';
          decideOrderReviewUI();

          showToast('Đã hủy đơn hàng.');
          try { bootstrap.Modal.getInstance(document.getElementById('cancelModal'))?.hide(); } catch { }

          btn.disabled = false;
          btn.innerHTML = oldHtml;
        } catch (err) {
          console.error(err);
          showToast((err && err.message) ? err.message : 'Có lỗi xảy ra, vui lòng thử lại.', true);
          btn.disabled = false;
          btn.innerHTML = oldHtml;
        }
      });

      // Received modal
      let receivedModalInstance = null;

      document.getElementById('btnConfirmReceived')?.addEventListener('click', function () {
        const el = document.getElementById('receivedModal');
        if (!receivedModalInstance) receivedModalInstance = new bootstrap.Modal(el);
        receivedModalInstance.show();
      });

      document.getElementById('btnConfirmReceivedDo')?.addEventListener('click', async function () {
        const btn = document.getElementById('btnConfirmReceivedDo');
        const oldHtml = btn.innerHTML;

        try {
          const status = parseInt(document.getElementById('<%= hStatus.ClientID %>').value || '0', 10);
          const can = (document.getElementById('<%= hCanConfirmReceived.ClientID %>').value === '1');
          if (!(can && status === 3)) { showToast('Đơn hàng chưa đủ điều kiện xác nhận.', true); return; }

          const orderId = parseInt(document.getElementById('<%= hOrderId.ClientID %>').value || '0', 10);
          if (!orderId) { showToast('Thiếu dữ liệu đơn hàng', true); return; }

          btn.disabled = true;
          btn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Đang xác nhận...';

          await callConfirmReceivedApi(orderId);

          // update UI: status=7
          document.getElementById('<%= hStatus.ClientID %>').value = '7';
          document.getElementById('<%= hCanConfirmReceived.ClientID %>').value = '0';
          setStatusPill(7);
          decideConfirmReceivedUI();

          // ✅ cho phép review sau khi nhận hàng
          document.getElementById('<%= hCanReview.ClientID %>').value = '1';
          decideOrderReviewUI();

          showToast('Đã xác nhận nhận hàng.');
          try { bootstrap.Modal.getInstance(document.getElementById('receivedModal'))?.hide(); } catch { }

          btn.disabled = false;
          btn.innerHTML = oldHtml;
        } catch (err) {
          console.error(err);
          showToast((err && err.message) ? err.message : 'Có lỗi xảy ra, vui lòng thử lại.', true);
          btn.disabled = false;
          btn.innerHTML = oldHtml;
        }
      });

      // Review modal
      let reviewModalInstance = null;

      document.getElementById('btnOpenOrderReview')?.addEventListener('click', async function () {
        const items = getOrderItems();
        renderReviewModal(items);

        const tabs = document.getElementById('rvTabs');
        if (tabs && !tabs.__bound) {
          tabs.__bound = true;
          tabs.addEventListener('click', async function (e) {
            const btn = e.target.closest('button.rv-submit-item');
            if (!btn) return;

            const productId = parseInt(btn.getAttribute('data-product-id') || '0', 10);
            const variantId = parseInt(btn.getAttribute('data-variant-id') || '0', 10);
            const key = makeKey(productId, variantId);

            if (window.__rvSubmitting[key]) return;

            try {
              const already = await isAlreadyReviewed(productId, variantId);
              if (already) {
                setPaneDone(key);
                const itemsNow0 = getOrderItems();
                updateProgress(itemsNow0);
                updateSubmitAllButton(itemsNow0);
                return;
              }

              window.__rvSubmitting[key] = true;
              btn.disabled = true;
              btn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Đang gửi...';

              await postReviewForItem(productId, variantId);

              window.__rvEligibility[key] = true;
              setPaneDone(key);

              const itemsNow = getOrderItems();
              updateProgress(itemsNow);
              updateSubmitAllButton(itemsNow);

              showToast('Đã gửi đánh giá.');
              decideOrderReviewUI();
            } catch (err) {
              console.error(err);
              showToast((err && err.message) ? err.message : 'Có lỗi xảy ra, vui lòng thử lại.', true);
            } finally {
              window.__rvSubmitting[key] = false;
            }
          });
        }

        const allBtn = document.getElementById('btnSubmitAllReviews');
        if (allBtn && !allBtn.__bound) {
          allBtn.__bound = true;
          allBtn.addEventListener('click', async function () {
            const items2 = getOrderItems();
            if (!items2.length) return;

            const targets = [];
            for (const it of items2) {
              const ar = await isAlreadyReviewed(it.productId, it.variantId);
              if (!ar) targets.push(it);
            }

            if (!targets.length) {
              showToast('Bạn đã đánh giá tất cả sản phẩm trong đơn rồi.', true);
              updateProgress(items2);
              updateSubmitAllButton(items2);
              decideOrderReviewUI();
              return;
            }

            const old = allBtn.innerHTML;
            allBtn.disabled = true;
            allBtn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Đang gửi...';

            let ok = 0, fail = 0;
            for (const it of targets) {
              const key = makeKey(it.productId, it.variantId);
              const id = keyToId(key);
              try {
                await postReviewForItem(it.productId, it.variantId);
                window.__rvEligibility[key] = true;
                setPaneDone(key);
                const msg = document.getElementById('rvMsg_' + id);
                if (msg) msg.textContent = 'Đã gửi, chờ duyệt.';
                ok++;
              } catch (e) {
                console.warn('submit fail', it, e);
                fail++;
              }
              const itemsLoop = getOrderItems();
              updateProgress(itemsLoop);
              updateSubmitAllButton(itemsLoop);
            }

            allBtn.innerHTML = old;
            allBtn.disabled = false;

            const itemsAfter = getOrderItems();
            updateProgress(itemsAfter);
            updateSubmitAllButton(itemsAfter);

            if (fail === 0) showToast(`Đã gửi ${ok} đánh giá.`);
            else showToast(`Đã gửi ${ok}/${ok + fail}. Có ${fail} lỗi.`, true);

            decideOrderReviewUI();
          });
        }

        await hydrateEligibility(items);

        const el = document.getElementById('reviewModal');
        if (!reviewModalInstance) reviewModalInstance = new bootstrap.Modal(el);
        reviewModalInstance.show();
      });

      decideOrderReviewUI();
      decideCancelUI();
      decideConfirmReceivedUI();

      // ===== embed helpers =====
      var isEmbed = /[?&]embed=1\b/.test(location.search);

      var backLink = document.getElementById('<%= lnkBack.ClientID %>');
      if (isEmbed && backLink) {
        try {
          var u = new URL(backLink.getAttribute('href') || backLink.href, location.href);
          u.searchParams.set('embed', '1');
          backLink.setAttribute('href', u.pathname + u.search + u.hash);
        } catch (e) {
          var href = backLink.getAttribute('href') || backLink.href;
          backLink.setAttribute('href', href + (href.indexOf('?') >= 0 ? '&' : '?') + 'embed=1');
        }
      }

      if (isEmbed) {
        try {
          document.querySelectorAll('a[href]').forEach(function (a) {
            var href = a.getAttribute('href'); if (!href) return;
            if (href.startsWith('#') || href.startsWith('javascript:')) return;
            var u = new URL(href, location.href);
            if (u.origin !== location.origin) return;
            u.searchParams.set('embed', '1');
            a.setAttribute('href', u.pathname + u.search + u.hash);
          });
        } catch (e) { }
      }
    });
  </script>

  <!-- Dọn text-node rơi ra DOM -->
  <script>
    (function () {
      try {
        var nodes = Array.from(document.body.childNodes);
        nodes.forEach(function (n) {
          if (n.nodeType === 3 && /ResizeObserver|ro\.observe|measure\(\)/.test(n.nodeValue || '')) n.remove();
        });
      } catch (e) { }
    })();
  </script>

  <%-- Auto-height (robust) --%>
  <script>
      (function () {
          var isEmbed = /[?&]embed=1\b/.test(location.search) && window.parent && window.parent !== window;
          if (!isEmbed) return;

          var params = new URLSearchParams(location.search);
          var TARGET = params.get('parentOrigin') || '*';

          function measure() {
              try {
                  var d = document, b = d.body, e = d.documentElement;
                  var h = Math.max(
                      b.scrollHeight || 0, e.scrollHeight || 0,
                      b.offsetHeight || 0, e.offsetHeight || 0,
                      b.clientHeight || 0, e.clientHeight || 0
                  );
                  if (!h || h < 400) h = 400;
                  window.parent.postMessage({ type: 'haf-embed-height', height: h }, TARGET);
              } catch (_) { }
          }

          function rafMeasure() { try { requestAnimationFrame(measure); } catch { measure(); } }

          document.addEventListener('DOMContentLoaded', function () { setTimeout(rafMeasure, 0); });
          window.addEventListener('load', function () { setTimeout(rafMeasure, 20); });

          if (document.fonts && document.fonts.ready) {
              document.fonts.ready.then(function () { setTimeout(rafMeasure, 20); });
          }

          var ro = (typeof ResizeObserver !== 'undefined') ? new ResizeObserver(function () { rafMeasure(); }) : null;
          if (ro) { ro.observe(document.documentElement); ro.observe(document.body); }

          var mo = (typeof MutationObserver !== 'undefined') ? new MutationObserver(function () { rafMeasure(); }) : null;
          if (mo) { mo.observe(document.body, { childList: true, subtree: true, attributes: true, characterData: true }); }

          setTimeout(rafMeasure, 200);
          setTimeout(rafMeasure, 600);
          setTimeout(rafMeasure, 1200);
      })();
  </script>
</body>
</html>
