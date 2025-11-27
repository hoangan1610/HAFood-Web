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

    .order-status-pill {
      font-size: .8rem; font-weight: 600; border-radius: 999px; padding: .35rem .8rem;
      background-color: rgba(25, 135, 84, .08); color: #198754; display: inline-flex; align-items: center; gap: .4rem;
    }

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

    /* Review: reuse style giống Product */
    .ha-btn-pill{ border-radius:999px; font-weight:600; letter-spacing:.01em; }
    .ha-input-sm{ font-size:.9rem; border-radius:.7rem; border-color:#d1d5db; }
    .ha-input-sm:focus{ border-color:#2aa33b; box-shadow:0 0 0 .15rem rgba(34,197,94,.22); }

    .ha-toast{
      position:fixed; top:20px; right:20px; background:#16a34a; color:#fff; padding:10px 14px;
      border-radius:999px; box-shadow:0 .25rem .9rem rgba(0,0,0,.22); z-index:20000; display:none; font-weight:500; font-size:.95rem;
    }

    @media (max-width: 767.98px) {
      .page-header-title { font-size: 1.35rem; }
      .card-order { padding: 1rem 1rem; }
      .img-thumb { width: 70px; height: 70px; }
    }
  </style>

  <% if ("1".Equals(Request["embed"])) { %>
    <style>
      html, body { height:auto; overflow: visible !important; background:#ffffff !important; background-image:none !important; min-height:auto !important; }
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
              <div class="text-end"><span id="litStatus" runat="server" class="order-status-pill"></span></div>
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

          <%-- ==== REVIEW THEO ĐƠN (nằm ngay dưới tóm tắt) ==== --%>
          <asp:Panel ID="pnlOrderReview" runat="server" Visible="false" CssClass="card-order">
            <div class="d-flex align-items-center justify-content-between mb-2">
              <h5 class="section-title mb-0"><i class="bi bi-chat-square-text"></i> Đánh giá đơn hàng</h5>
              <div class="mt-2 mt-sm-0">
                <button type="button" id="btnOpenOrderReview"
                        class="btn btn-outline-success btn-sm ha-btn-pill d-none">
                  <i class="bi bi-pencil-square me-1"></i>Viết đánh giá
                </button>

                <span id="orderReviewDisabled"
                      class="btn btn-outline-secondary btn-sm disabled ha-btn-pill d-none"
                      style="cursor:not-allowed; pointer-events:none;">
                  Bạn không thể đánh giá khi đơn hàng chưa được giao
                </span>

                <span id="orderReviewAlready"
                      class="btn btn-outline-secondary btn-sm disabled ha-btn-pill d-none"
                      style="cursor:not-allowed; pointer-events:none;">
                  Bạn đã đánh giá đơn hàng này rồi
                </span>
              </div>
            </div>

            <div class="small text-muted">Đánh giá sẽ được kiểm duyệt trước khi hiển thị công khai.</div>
          </asp:Panel>
          <%-- ================================================ --%>
        </div>
      </div>

      <%-- Hidden dùng cho JS --%>
      <asp:HiddenField ID="hOrderId" runat="server" />
      <asp:HiddenField ID="hOrderCode" runat="server" />
      <asp:HiddenField ID="hCanReview" runat="server" />
      <asp:HiddenField ID="hFirstProductId" runat="server" />
      <asp:HiddenField ID="hFirstVariantId" runat="server" />
    </div>
  </form>

  <%-- MODAL REVIEW THEO ĐƠN --%>
  <div class="modal fade" id="reviewModal" tabindex="-1" aria-labelledby="reviewModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title" id="reviewModalLabel">Viết đánh giá đơn hàng</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Đóng"></button>
        </div>
        <div class="modal-body">
          <div class="small text-muted mb-2">
            Đơn hàng: <span id="rvOrderCode" class="fw-semibold"></span>
          </div>

          <div class="mb-3">
            <label class="form-label small mb-1">Đánh giá của bạn</label>
            <div id="reviewRatingStars" class="d-flex gap-1 fs-4">
              <i class="bi bi-star" data-rating="1"></i>
              <i class="bi bi-star" data-rating="2"></i>
              <i class="bi bi-star" data-rating="3"></i>
              <i class="bi bi-star" data-rating="4"></i>
              <i class="bi bi-star" data-rating="5"></i>
            </div>
            <input type="hidden" id="reviewRatingValue" value="5" />
          </div>

          <div class="mb-2">
            <label class="form-label small mb-1">Tiêu đề</label>
            <input type="text" id="reviewTitleInput" class="form-control form-control-sm ha-input-sm"
                   maxlength="200" placeholder="Ví dụ: Giao nhanh, đóng gói kỹ" />
          </div>
          <div class="mb-2">
            <label class="form-label small mb-1">Nội dung</label>
            <textarea id="reviewContentInput" rows="4" maxlength="2000"
                      class="form-control form-control-sm ha-input-sm"
                      placeholder="Chia sẻ trải nghiệm thực tế về đơn hàng..."></textarea>
          </div>

          <div class="mb-2">
            <label class="form-label small mb-1">Hình ảnh (tùy chọn)</label>
            <input type="file" id="reviewImagesInput" class="form-control form-control-sm" accept="image/*" multiple />
            <div class="form-text small text-muted">Tối đa ~5 ảnh, mỗi ảnh không quá 2MB.</div>
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-light btn-sm" data-bs-dismiss="modal">Đóng</button>
          <button type="button" class="btn btn-success btn-sm ha-btn-pill" id="btnSubmitReview">Gửi đánh giá</button>
        </div>
      </div>
    </div>
  </div>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

  <script>
    function showToast(msg) {
      const el = document.getElementById('haToast'); if (!el) return;
      el.textContent = msg || 'Đã thực hiện'; el.style.display = 'block';
      setTimeout(() => { el.style.display = 'none'; }, 1800);
    }

    function setRatingUI(r) {
      var val = document.getElementById('reviewRatingValue'); if (val) val.value = r;
      var wrap = document.getElementById('reviewRatingStars'); if (!wrap) return;
      wrap.querySelectorAll('i[data-rating]').forEach(function (el) {
        var v = parseInt(el.getAttribute('data-rating') || '0', 10);
        if (v <= r) { el.classList.remove('bi-star'); el.classList.add('bi-star-fill', 'text-warning'); }
        else { el.classList.add('bi-star'); el.classList.remove('bi-star-fill', 'text-warning'); }
      });
    }

    async function decideOrderReviewUI() {
      const canReview = (document.getElementById('<%= hCanReview.ClientID %>').value === '1');
      const btn = document.getElementById('btnOpenOrderReview');
      const disabled = document.getElementById('orderReviewDisabled');
      const already = document.getElementById('orderReviewAlready');

      // reset
      [btn, disabled, already].forEach(x => x && x.classList.add('d-none'));

      if (!canReview) { disabled.classList.remove('d-none'); return; }

      // Kiểm tra đã review chưa (dựa theo eligibility của product đầu tiên trong đơn)
      try {
        const API_BASE = (window.__API_BASE || '').replace(/\/+$/, '');
        const token = window.__AUTH_TOKEN || '';
        const pid = parseInt(document.getElementById('<%= hFirstProductId.ClientID %>').value || '0', 10);
        const vid = parseInt(document.getElementById('<%= hFirstVariantId.ClientID %>').value || '0', 10);

        if (!API_BASE || !token || !pid) { btn.classList.remove('d-none'); return; }

        let url = `${API_BASE}/api/products/${pid}/reviews/eligibility`;
        if (vid > 0) url += `?variantId=${vid}`;

        const resp = await fetch(url, {
          method: 'GET',
          headers: { 'Accept': 'application/json', 'Authorization': 'Bearer ' + token },
          credentials: 'include'
        });

        if (!resp.ok) { btn.classList.remove('d-none'); return; }

        const data = await resp.json();
        const alreadyReviewed = !!(data.already_Reviewed || data.Already_Reviewed);
        if (alreadyReviewed) {
          already.classList.remove('d-none');
        } else {
          btn.classList.remove('d-none');
        }
      } catch (e) {
        console.warn('eligibility error', e);
        btn.classList.remove('d-none'); // fallback: vẫn cho viết
      }
    }

    document.addEventListener('DOMContentLoaded', function () {
      setRatingUI(5);
      document.getElementById('rvOrderCode').textContent = document.getElementById('<%= hOrderCode.ClientID %>').value || '';

      // Mở modal
      let reviewModalInstance = null;
      document.getElementById('btnOpenOrderReview')?.addEventListener('click', function () {
        const el = document.getElementById('reviewModal');
        if (!reviewModalInstance) reviewModalInstance = new bootstrap.Modal(el);
        reviewModalInstance.show();
      });

      // Submit
      document.getElementById('btnSubmitReview')?.addEventListener('click', async function () {
        try {
          var API_BASE = (window.__API_BASE || '').replace(/\/+$/, '');
          var auth = window.__AUTH_TOKEN || ''; 
          if (!API_BASE) { showToast('Thiếu cấu hình API'); return; }
          if (!auth) { showToast('Vui lòng đăng nhập để gửi đánh giá'); return; }

          var rating = parseInt((document.getElementById('reviewRatingValue') || {}).value || '0', 10);
          var title = (document.getElementById('reviewTitleInput') || {}).value || '';
          var content = (document.getElementById('reviewContentInput') || {}).value || '';
          var filesEl = document.getElementById('reviewImagesInput');
          var files = (filesEl && filesEl.files) ? filesEl.files : null;

          if (!rating || rating < 1 || rating > 5) { showToast('Vui lòng chọn số sao đánh giá'); return; }

          var orderId = parseInt((document.getElementById('<%= hOrderId.ClientID %>').value || '0'), 10);
          var productId = parseInt((document.getElementById('<%= hFirstProductId.ClientID %>').value || '0'), 10);
          var variantId = parseInt((document.getElementById('<%= hFirstVariantId.ClientID %>').value || '0'), 10);

          if (!orderId || !productId) { showToast('Thiếu dữ liệu đơn hàng/sản phẩm'); return; }

          var formData = new FormData();
          formData.append('Product_Id', String(productId));      // dùng product đầu tiên để gửi review cho "đơn"
          if (variantId > 0) formData.append('Variant_Id', String(variantId));
          formData.append('Order_Id', String(orderId));          // quan trọng: gắn vào đơn
          // KHÔNG truyền Order_Item_Id => hiểu là review theo đơn
          formData.append('Rating', String(rating));
          if (title.trim()) formData.append('Title', title.trim());
          if (content.trim()) formData.append('Content', content.trim());

          var hasImages = false;
          if (files && files.length) {
            for (var i = 0; i < files.length; i++) {
              var f = files[i]; if (!f) continue;
              if (f.size > 2 * 1024 * 1024) continue;
              hasImages = true; formData.append('Images', f);
            }
          }
          formData.append('Has_Image', hasImages ? 'true' : 'false');

          var resp = await fetch(API_BASE + '/api/reviews', {
            method: 'POST',
            headers: { 'Accept': 'application/json', 'Authorization': 'Bearer ' + auth },
            credentials: 'include',
            body: formData
          });

          var data = null; try { data = await resp.json(); } catch { }
          if (resp.status === 401 || resp.status === 403) { showToast('Vui lòng đăng nhập để gửi đánh giá'); return; }
          if (!resp.ok || (data && data.success === false)) {
            showToast((data && (data.message || data.detail)) || 'Không thể gửi đánh giá, vui lòng thử lại.');
            return;
          }

          showToast('Đã gửi đánh giá, chờ duyệt.');
          (document.getElementById('reviewTitleInput') || {}).value = '';
          (document.getElementById('reviewContentInput') || {}).value = '';
          if (filesEl) filesEl.value = ''; setRatingUI(5);
          try { bootstrap.Modal.getInstance(document.getElementById('reviewModal'))?.hide(); } catch { }

          // Sau khi gửi, chuyển sang trạng thái "đã đánh giá"
          document.getElementById('btnOpenOrderReview')?.classList.add('d-none');
          document.getElementById('orderReviewAlready')?.classList.remove('d-none');
        } catch (err) {
          console.error(err); showToast('Có lỗi xảy ra, vui lòng thử lại.');
        }
      });

      // Quyết định hiển thị nút/label theo trạng thái
      decideOrderReviewUI();

      // giữ logic back link khi embed
      var isEmbed = /[?&]embed=1\b/.test(location.search);
      var backLink = document.getElementById('<%= lnkBack.ClientID %>');
        if (isEmbed && backLink) {
            try { var u = new URL(backLink.href, location.origin); u.searchParams.set('embed', '1'); backLink.href = u.pathname + u.search + u.hash; }
            catch { backLink.href = backLink.href + (backLink.href.indexOf('?') >= 0 ? '&' : '?') + 'embed=1'; }
        }
    });
  </script>
</body>
</html>
