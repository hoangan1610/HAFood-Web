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
      border-radius: 999px;
      display: inline-flex; align-items: center; gap: .35rem;
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

    .order-status-pill {
      font-size: .8rem; font-weight: 600; border-radius: 999px; padding: .35rem .8rem;
      background-color: rgba(25, 135, 84, .08); color: #198754; display: inline-flex; align-items: center; gap: .4rem;
    }
    .order-status-pill i { font-size: .9rem; }

    .header-badge {
      font-size: .75rem; letter-spacing: .06em; text-transform: uppercase; font-weight: 700;
      color: #fd7e14; background: rgba(253, 126, 20, .08); border-radius: 999px; padding: .25rem .75rem;
      display: inline-flex; align-items: center; gap: .35rem;
    }
    .header-badge i { font-size: .9rem; }

    .section-title { font-size: 1.05rem; font-weight: 600; margin-bottom: 0.75rem; color: #212529; display:flex; align-items:center; gap:.45rem; }
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
    .summary-badge i { font-size:.9rem; }

    @media (max-width: 767.98px) {
      .page-header-title { font-size: 1.35rem; }
      .card-order { padding: 1rem 1rem; }
      .img-thumb { width: 70px; height: 70px; }
    }
  </style>

  <%-- EMBED: nén & nền TRẮNG, KHÔNG cuộn riêng --%>
  <% if ("1".Equals(Request["embed"])) { %>
    <style>
      html,body{ height:auto; }
      html{ font-size:13px; }
      html, body {
        overflow: visible !important;
        background:#ffffff !important;
        background-image:none !important;
        min-height:auto !important;
      }
      .order-detail-page{
        max-width:100% !important;
        padding-top:2px !important;
        padding-bottom:2px !important;
        height:auto;
        overflow:visible;
      }
      .page-header-row{ margin:4px 0 6px !important; }
      .title-badge{ font-size:.7rem; padding:.2rem .5rem; margin-bottom:.2rem; }
      .page-header-title{ font-size:1.05rem; }
      .page-header-sub{ font-size:.78rem; }
      .btn-back{ font-size:.8rem; padding:.25rem .7rem; }

      .card-order{ padding:.6rem .75rem; border-radius:.8rem; box-shadow:none; }
      .section-title{ font-size:.9rem; margin-bottom:.4rem; }
      .header-badge{ font-size:.7rem; padding:.2rem .5rem; }
      .order-code{ font-size:.95rem; }
      .order-meta-label,.order-meta-value,.meta-small{ font-size:.8rem; }
      .item-row{ padding:6px 0; }
      .img-thumb{ width:60px; height:60px; }
      .summary-badge{ font-size:.7rem; padding:.18rem .5rem; margin-bottom:.3rem; }
      .summary-line{ padding:3px 0; font-size:.86rem; }
      .summary-line.total{ font-size:.94rem; }

      .embed-items-scroll{ max-height:none; overflow:visible; }
    </style>
  <% } %>
</head>

<body>
  <form id="form1" runat="server">
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
              <div class="text-end"><span id="litStatus" runat="server" class="order-status-pill"></span></div>
            </div>

            <div class="row g-2 mt-2">
              <div class="col-md-6">
                <div class="order-meta-row d-flex"><div class="order-meta-label">Người nhận</div><div class="order-meta-value ms-2"><span id="litShipName" runat="server"></span></div></div>
                <div class="order-meta-row d-flex"><div class="order-meta-label">Số điện thoại</div><div class="order-meta-value ms-2"><span id="litShipPhone" runat="server"></span></div></div>
              </div>
              <div class="col-md-6">
                <div class="order-meta-row d-flex"><div class="order-meta-label">Địa chỉ</div><div class="order-meta-value ms-2"><span id="litShipAddress" runat="server"></span></div></div>
                <div class="order-meta-row d-flex"><div class="order-meta-label">Ghi chú</div><div class="order-meta-value ms-2"><span id="litNote" runat="server"></span></div></div>
              </div>
            </div>

            <asp:Panel ID="pnlPayment" runat="server" Visible="false" CssClass="mt-3">
              <div class="meta-small fw-semibold text-primary d-flex align-items-center gap-2">
                <i class="bi bi-credit-card-2-front"></i> Phương thức thanh toán:
                <span id="litPayment" runat="server" class="order-meta-value ms-1"></span>
              </div>
            </asp:Panel>
          </asp:Panel>

          <asp:Panel ID="pnlItems" runat="server" Visible="false" CssClass="card-order mb-3">
            <h5 class="section-title"><i class="bi bi-bag-check"></i> Sản phẩm trong đơn</h5>
            <div class="embed-items-scroll">
              <asp:Repeater ID="rpItems" runat="server">
                <ItemTemplate>
                  <div class="d-flex item-row align-items-center">
                    <img src='<%# Eval("image_Variant") ?? Eval("image_Product") ?? "/images/product-default.png" %>' class="img-thumb me-3" onerror="this.src='/images/product-default.png';" />
                    <div class="flex-grow-1">
                      <div class="item-name"><%# Eval("product_Name") ?? Eval("name_Variant") %></div>
                      <div class="meta-small"><span class="me-2">Mã: <%# Eval("sku") %></span><span>• Số lượng: <strong><%# Eval("quantity") %></strong></span></div>
                    </div>
                    <div class="text-end">
                      <div class="price-main"><%# string.Format(new System.Globalization.CultureInfo("vi-VN"), "{0:#,0}đ", Eval("line_Subtotal")) %></div>
                      <div class="meta-small price-sub">Đơn giá: <%# string.Format(new System.Globalization.CultureInfo("vi-VN"), "{0:#,0}đ", Eval("price_Variant")) %></div>
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
            <div class="summary-line"><div class="label">Thành tiền</div><div class="value"><asp:Literal ID="litSubtotal" runat="server" /></div></div>
            <div class="summary-line"><div class="label">Giảm giá</div><div class="value text-success"><asp:Literal ID="litDiscount" runat="server" /></div></div>
            <div class="summary-line"><div class="label">Phí vận chuyển</div><div class="value"><asp:Literal ID="litShipping" runat="server" /></div></div>
            <div class="summary-line"><div class="label">VAT</div><div class="value"><asp:Literal ID="litVat" runat="server" /></div></div>
            <hr class="my-2" />
            <div class="summary-line total"><div class="label">Tổng thanh toán</div><div class="value"><asp:Literal ID="litPayTotal" runat="server" /></div></div>
          </asp:Panel>
        </div>
      </div>
    </div>
  </form>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

  <script>
    (function () {
      var isEmbed = /[?&]embed=1\b/.test(location.search);
      var backLink = document.getElementById('<%= lnkBack.ClientID %>');
          if (isEmbed && backLink) {
              try { var u = new URL(backLink.href, location.origin); u.searchParams.set('embed', '1'); backLink.href = u.pathname + u.search + u.hash; }
              catch { backLink.href = backLink.href + (backLink.href.indexOf('?') >= 0 ? '&' : '?') + 'embed=1'; }
          }
      })();
  </script>
</body>
</html>
