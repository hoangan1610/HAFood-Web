<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Product.aspx.cs"
    Inherits="HAFoodWeb.Product" Async="true" %>

<%@ Register Src="~/Control/Header.ascx" TagPrefix="uc" TagName="Header" %>
<%@ Register Src="~/Control/Footer.ascx" TagPrefix="uc" TagName="Footer" %>

<!DOCTYPE html>
<html lang="vi">
<head runat="server">
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title runat="server" id="pageTitle">Chi tiết sản phẩm</title>

  <!-- Bootstrap core -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
  <!-- Bootstrap Icons (chỉ dùng cho icon, không ảnh hưởng chức năng) -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet" />

  <script>
      // JWT lấy từ Session khi user đã login
      window.__AUTH_TOKEN = '<%= Session["JwtToken"] != null ? Session["JwtToken"].ToString() : "" %>';
  </script>

  <style>
    :root{
      --ha-primary:#2aa33b;
      --ha-primary-soft:#eaf7ec;
      --ha-border:#e5e7eb;
      --ha-text:#111827;
      --ha-muted:#6b7280;
      --ha-bg:#f3f4f6;
    }

    body{
      background: radial-gradient(circle at top left,#f9fafb, #f3f4f6);
      color:var(--ha-text);
      font-family: system-ui,-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,"Helvetica Neue",Arial,sans-serif;
    }

    .ha-page-wrap{
      padding-top:1.25rem;
      padding-bottom:2.5rem;
    }

    .ha-product-shell{
      background:#fff;
      border-radius:1.25rem;
      box-shadow:0 18px 35px rgba(15,23,42,0.08);
      border:1px solid rgba(148,163,184,.25);
      padding:1.5rem;
    }
    @media (min-width: 992px){
      .ha-product-shell{
        padding:2rem 2.25rem;
      }
    }

    .ha-breadcrumb-card{
      background:rgba(255,255,255,0.9);
      border-radius:999px;
      padding:.6rem 1.2rem;
      box-shadow:0 10px 25px rgba(15,23,42,.05);
      border:1px solid rgba(148,163,184,.25);
      backdrop-filter: blur(6px);
    }
    .ha-breadcrumb{ --bs-breadcrumb-divider: '>'; margin-bottom:0; }
    .ha-breadcrumb a{
      text-decoration:none !important;
      color:#0a58ca !important;
      font-weight:500;
    }
    .ha-breadcrumb a:hover,
    .ha-breadcrumb a:focus{
      color:#084298 !important;
    }
    .ha-breadcrumb .breadcrumb-item.active{
      color:var(--ha-muted);
      font-weight:500;
    }

    .product-title{
      font-weight:700;
      font-size:1.6rem;
      line-height:1.3;
      margin-bottom:0.35rem;
    }
    @media (min-width: 768px){
      .product-title{ font-size:1.8rem; }
    }

    .ha-subtitle-pill{
      display:inline-flex;
      align-items:center;
      gap:.35rem;
      padding:.15rem .65rem;
      border-radius:999px;
      background:var(--ha-primary-soft);
      color:var(--ha-primary);
      font-size:.78rem;
      font-weight:600;
      text-transform:uppercase;
      letter-spacing:.06em;
    }

    .meta-row{
      font-size:1.03rem;
    }
    .meta-label{
      color:var(--ha-muted);
    }
    .meta-value{
      color:#000;
      font-weight:600;
    }

    .meta-dot{
      color:#d1d5db;
      margin:0 .6rem;
    }

    .price-label{
      color:var(--ha-muted);
      margin-right:.35rem;
      font-weight:500;
    }
    .price-now{
      color:#ff3b30;
      font-weight:700;
      font-size:1.35rem;
    }
    .price-old{
      text-decoration:line-through;
      color:#888;
      margin-left:.5rem;
      font-size:.98rem;
    }

    .ha-price-row{
      padding:.85rem 1rem;
      border-radius:.9rem;
      background:linear-gradient(90deg,#fff7ed,#fefce8);
      border:1px dashed rgba(248, 92, 35, .4);
    }

    .main-img{
      width:100%;
      height:420px;
      object-fit:contain;
      background:linear-gradient(135deg,#f9fafb,#eef2ff);
      border-radius:1rem;
      border:1px solid var(--ha-border);
      box-shadow:0 14px 30px rgba(15,23,42,.08);
    }
    @media (max-width: 575.98px){
      .main-img{ height:320px; }
    }

    .thumb{
      width:72px;
      height:72px;
      object-fit:contain;
      border-radius:.85rem;
      border:1px solid var(--ha-border);
      cursor:pointer;
      background:#fff;
      transition:all .16s ease-in-out;
      padding:.25rem;
    }
    .thumb:hover{
      transform:translateY(-2px);
      box-shadow:0 .4rem .9rem rgba(0,0,0,.06);
      border-color:var(--ha-primary);
    }
    .thumb.active{
      outline:2px solid var(--ha-primary);
      box-shadow:0 .4rem 1rem rgba(34,197,94,.18);
    }

    .of-contain{ object-fit:contain; }

    .product-card{
      transition:transform .15s ease, box-shadow .15s ease, border-color .15s ease;
      border-radius:1rem;
      border:1px solid rgba(148,163,184,.35);
      overflow:hidden;
    }
    .product-card:hover{
      transform:translateY(-4px);
      box-shadow:0 18px 38px rgba(15,23,42,.14);
      border-color:rgba(34,197,94,.7);
    }

    .product-card .card-body{
      padding:.9rem .9rem 1rem;
    }

    .text-truncate-2{
      -webkit-line-clamp:2;
      display:-webkit-box;
      -webkit-box-orient:vertical;
      overflow:hidden;
    }

    .ha-toast{
      position:fixed;
      top:20px;
      right:20px;
      background:#16a34a;
      color:#fff;
      padding:10px 14px;
      border-radius:999px;
      box-shadow:0 .25rem .9rem rgba(0,0,0,.22);
      z-index:20000;
      display:none;
      font-weight:500;
      font-size:.95rem;
    }

    .ha-fly-img{
      position:fixed;
      width:80px;
      height:80px;
      object-fit:contain;
      pointer-events:none;
      z-index:19000;
      border-radius:8px;
      transition:transform .6s ease-in, opacity .6s ease-in;
      box-shadow:0 .75rem 1.8rem rgba(15,23,42,.4);
    }

    .ha-input-sm{
      font-size:.9rem;
      border-radius:.7rem;
      border-color:#d1d5db;
    }
    .ha-input-sm:focus{
      border-color:var(--ha-primary);
      box-shadow:0 0 0 .15rem rgba(34,197,94,.22);
    }

    .ha-btn-pill{
      border-radius:999px;
      font-weight:600;
      letter-spacing:.01em;
    }

    .ha-desc-block{
      background:#f9fafb;
      border-radius:1rem;
      padding:1.15rem 1.3rem;
      border:1px solid #e5e7eb;
    }

    .ha-desc-block h5{
      font-size:1.05rem;
      font-weight:600;
    }

    .ha-section-header{
      display:flex;
      align-items:center;
      gap:.5rem;
      margin-bottom:1rem;
    }
    .ha-section-header span.badge{
      border-radius:999px;
      font-size:.7rem;
      font-weight:600;
      text-transform:uppercase;
      letter-spacing:.08em;
    }

    #fsCountdown{
      font-weight:600;
    }
    #fsRemain{
      font-size:.86rem;
    }

    .ha-divider{
      border-color:#e5e7eb;
      opacity:.7;
    }

    /* ==== Reviews ==== */
    .ha-review-card{
      border-radius:1rem;
      border:1px solid var(--ha-border);
      padding:.9rem 1rem;
      background:#fff;
    }
    .ha-review-user{
      font-weight:600;
    }
    .ha-review-meta{
      font-size:.8rem;
      color:var(--ha-muted);
    }
    .ha-review-title{
      font-weight:600;
      margin-bottom:.15rem;
    }
    .ha-review-content{
      font-size:.9rem;
      white-space:pre-wrap;
    }
    .ha-star-filled{ color:#fbbf24; }
    .ha-star-empty{ color:#e5e7eb; }
    .ha-review-empty{ font-size:.9rem; color:var(--ha-muted); }

    /* Highlight khi focus review qua ?review=... */
    .ha-review-card { position: relative; }
    .ha-review-card.review-highlight{
      outline: 2px solid #0d6efd;
      box-shadow: 0 0 0 4px rgba(13,110,253,.18);
      background:#fffef7;
      animation: pulseFocus 1.1s ease-out 2;
    }
    @keyframes pulseFocus{
      0%{ box-shadow:0 0 0 0 rgba(13,110,253,.35); }
      70%{ box-shadow:0 0 0 14px rgba(13,110,253,0); }
      100%{ box-shadow:0 0 0 0 rgba(13,110,253,0); }
    }
    .ha-review-empty{
      font-size:.9rem;
      color:var(--ha-muted);
    }
  </style>

  <!-- Xuất API_BASE cho JS -->
  <script>
      window.__API_BASE = '<%= System.Configuration.ConfigurationManager.AppSettings["ApiBaseUrl"] ?? "" %>';
  </script>
</head>

<body>
  <div id="haToast" class="ha-toast">Đã thêm vào giỏ hàng</div>

  <form runat="server">
    <uc:Header ID="Header1" runat="server" />

    <div class="container ha-page-wrap">

      <!-- BREADCRUMB -->
      <div class="d-flex justify-content-between align-items-center mb-3 mb-md-4">
        <nav aria-label="breadcrumb" class="flex-grow-1">
          <div class="ha-breadcrumb-card">
            <ol class="breadcrumb ha-breadcrumb mb-0">
              <li class="breadcrumb-item"><a href="/">Trang chủ</a></li>
              <li class="breadcrumb-item"><a href="/HomePage/Search">Sản phẩm</a></li>
              <li class="breadcrumb-item active" aria-current="page">
                <asp:Literal ID="litNameCrumb" runat="server" />
              </li>
            </ol>
          </div>
        </nav>
      </div>

      <!-- MAIN CONTENT -->
      <div class="ha-product-shell mb-4">
        <div class="row g-4 g-lg-5 align-items-start">
          <!-- LEFT: Gallery -->
          <div class="col-lg-5">
            <div class="mb-3 mb-md-4">
              <img id="imgMain" runat="server" class="main-img" alt="Ảnh sản phẩm"
                   onerror="this.src='/images/product-default.png';" />
            </div>

            <div class="d-flex flex-wrap gap-2">
              <asp:Repeater ID="rpThumbs" runat="server">
                <ItemTemplate>
                  <img class="thumb" src="<%# Eval("Url") %>" alt="thumb"
                       onerror="this.src='/images/product-default.png';"
                       data-url="<%# Eval("Url") %>" />
                </ItemTemplate>
              </asp:Repeater>
            </div>
          </div>

          <!-- RIGHT: Info -->
          <div class="col-lg-7">
            <div class="d-flex align-items-center mb-2">
              <span class="ha-subtitle-pill">
                <i class="bi bi-bag-check"></i>
                Sản phẩm chính hãng
              </span>
            </div>

            <h1 class="product-title">
              <asp:Literal ID="litName" runat="server" />
            </h1>

            <div class="meta-row mb-1">
              <span class="meta-label">Thương hiệu:</span>
              <span class="meta-value">
                <asp:Literal ID="litBrand" runat="server" />
              </span>
            </div>

            <div class="meta-row mb-3">
              <span class="meta-label">SKU:</span>
              <span id="sku" class="meta-value">
                <asp:Literal ID="litSku" runat="server" />
              </span>
              <span class="meta-dot">•</span>
              <span class="meta-label">Tồn kho:</span>
              <span id="stock" class="meta-value">
                <asp:Literal ID="litStock" runat="server" />
              </span>
            </div>

            <div class="mb-3">
              <div class="ha-price-row d-inline-flex flex-column flex-sm-row align-items-sm-center gap-1 gap-sm-2">
                <div>
                  <span class="price-label">Giá:</span>
                  <span id="priceNow" class="price-now">
                    <asp:Literal ID="litPrice" runat="server" />
                  </span>
                  <span id="oldPrice" runat="server" class="price-old d-none"></span>
                </div>
                <div class="small mt-1 mt-sm-0 ms-sm-2">
                  <span id="fsCountdown" class="text-danger me-3"></span>
                  <span id="fsRemain" class="text-muted"></span>
                </div>
              </div>
            </div>

            <div class="row g-3 align-items-end">
              <div class="col-sm-6">
                <label class="form-label mb-1 small text-muted">Phân loại</label>
                <asp:DropDownList ID="ddlVariant" runat="server"
                  CssClass="form-select form-select-sm ha-input-sm"></asp:DropDownList>
              </div>

              <div class="col-sm-3">
                <label class="form-label mb-1 small text-muted">Số lượng</label>
                <input id="qty" name="qty" type="number"
                       class="form-control form-control-sm ha-input-sm"
                       value="1" min="1" />
              </div>

              <div class="col-sm-3 d-grid">
                <a id="btnBuy" class="btn btn-warning btn-sm ha-btn-pill">
                  <i class="bi bi-lightning-charge-fill me-1"></i>Mua ngay
                </a>
              </div>

              <asp:ScriptManager ID="ScriptManager1" runat="server"
                                 EnablePartialRendering="true" EnablePageMethods="true" />

              <asp:UpdatePanel ID="upAddCart" runat="server" UpdateMode="Conditional">
                <ContentTemplate>
                  <div class="col-sm-3 d-grid mt-2 mt-sm-0">
                    <asp:Button ID="btnAddToCart" runat="server" Text="Thêm vào giỏ"
                      CssClass="btn btn-success btn-sm ha-btn-pill"
                      OnClick="btnAddToCart_Click" />
                  </div>
                </ContentTemplate>
                <Triggers>
                  <asp:AsyncPostBackTrigger ControlID="btnAddToCart" EventName="Click" />
                </Triggers>
              </asp:UpdatePanel>
            </div>

            <hr class="my-4 ha-divider" />

            <div class="ha-desc-block">
              <div class="d-flex align-items-center justify-content-between mb-2">
                <h5 class="mb-0">Mô tả sản phẩm</h5>
              </div>
              <div class="lh-base small-small">
                <asp:Literal ID="litDetail" runat="server" />
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- REVIEWS -->
      <div class="ha-product-shell mb-4" id="reviewsSection">
        <div class="d-flex flex-wrap align-items-center justify-content-between mb-3">
          <div class="d-flex align-items-center gap-3">
            <div>
              <div class="small text-muted mb-1">Đánh giá sản phẩm</div>
              <div class="d-flex align-items-baseline gap-2">
                <span id="reviewAvgScore" class="fs-3 fw-bold">0.0</span>
                <span class="ms-1 text-warning" id="reviewStarIcons">
                  ★★★★★
                </span>
              </div>
              <div class="small text-muted">
                <span id="reviewTotalCount">0</span> lượt đánh giá
              </div>
            </div>
          </div>
          <div class="mt-3 mt-sm-0">
            <button type="button" class="btn btn-outline-success btn-sm ha-btn-pill" id="btnOpenReviewModal">
              <i class="bi bi-chat-square-text me-1"></i>Viết đánh giá
            </button>
          </div>
        </div>

        <!-- Filter -->
        <div class="border rounded-3 p-2 p-sm-3 mb-3 bg-light">
          <div class="d-flex flex-wrap align-items-center gap-2 small">
            <div class="me-2 fw-semibold">Lọc theo:</div>
            <button type="button" class="btn btn-sm btn-outline-secondary ha-btn-pill active" data-review-star="0">
              Tất cả
            </button>
            <button type="button" class="btn btn-sm btn-outline-secondary ha-btn-pill" data-review-star="5">
              5 ★ <span class="text-muted ms-1" id="reviewCountStar5"></span>
            </button>
            <button type="button" class="btn btn-sm btn-outline-secondary ha-btn-pill" data-review-star="4">
              4 ★ <span class="text-muted ms-1" id="reviewCountStar4"></span>
            </button>
            <button type="button" class="btn btn-sm btn-outline-secondary ha-btn-pill" data-review-star="3">
              3 ★ <span class="text-muted ms-1" id="reviewCountStar3"></span>
            </button>
            <button type="button" class="btn btn-sm btn-outline-secondary ha-btn-pill" data-review-star="2">
              2 ★ <span class="text-muted ms-1" id="reviewCountStar2"></span>
            </button>
            <button type="button" class="btn btn-sm btn-outline-secondary ha-btn-pill" data-review-star="1">
              1 ★ <span class="text-muted ms-1" id="reviewCountStar1"></span>
            </button>

            <div class="form-check form-switch ms-auto">
              <input class="form-check-input" type="checkbox" id="reviewFilterHasImage" />
              <label class="form-check-label small" for="reviewFilterHasImage">
                Chỉ xem đánh giá có hình ảnh
              </label>
            </div>
          </div>
        </div>

        <!-- List -->
        <div id="reviewList" class="vstack gap-3 mb-3">
          <div class="text-muted small">Đang tải đánh giá...</div>
        </div>

        <!-- Pagination -->
        <div class="d-flex justify-content-between align-items-center">
          <div class="small text-muted" id="reviewPagingInfo"></div>
          <div class="btn-group btn-group-sm" role="group" aria-label="Review pagination">
            <button type="button" class="btn btn-outline-secondary" id="reviewPrevBtn">Trước</button>
            <button type="button" class="btn btn-outline-secondary" id="reviewNextBtn">Sau</button>
          </div>
        </div>
      </div>

      <!-- Related -->
      <div class="mt-4 mt-md-5">
        <div class="ha-section-header">
          <h4 class="fw-semibold mb-0">Gợi ý cho bạn</h4>
          <span class="badge bg-success-subtle text-success-emphasis">
            <i class="bi bi-stars me-1"></i>Có thể bạn sẽ thích
          </span>
        </div>

        <asp:Repeater ID="rpRelated" runat="server">
          <HeaderTemplate>
            <div class="row gx-3 gy-4">
          </HeaderTemplate>

          <ItemTemplate>
            <div class="col-6 col-lg-3">
              <div class="card product-card h-100 shadow-sm d-flex">
                <div class="ratio ratio-4x3 bg-light position-relative">
                  <img src="<%# Eval("ImageUrl") %>"
                       class="w-100 h-100 of-contain p-2"
                       onerror="this.src='/images/product-default.png';"
                       alt="<%# Eval("Name") %>" />
                </div>
                <div class="card-body d-flex flex-column">
                  <h6 class="text-truncate-2 mb-2"><%# Eval("Name") %></h6>
                  <div class="mb-2 small text-danger fw-semibold">
                    <%# Eval("PriceRangeHtml") %>
                  </div>
                  <a class="btn btn-outline-success btn-sm mt-auto ha-btn-pill"
                     href='<%# Eval("Id", "/Product/Product.aspx?id={0}") %>'>
                    <i class="bi bi-eye me-1"></i>Xem chi tiết
                  </a>
                </div>
              </div>
            </div>
          </ItemTemplate>

          <FooterTemplate>
            </div>
          </FooterTemplate>
        </asp:Repeater>
      </div>
    </div>

    <uc:Footer ID="Footer1" runat="server" />

    <asp:HiddenField ID="hVariantsJson" runat="server" />

    <!-- Modal viết đánh giá -->
    <div class="modal fade" id="reviewModal" tabindex="-1" aria-labelledby="reviewModalLabel" aria-hidden="true">
      <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title" id="reviewModalLabel">Viết đánh giá sản phẩm</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Đóng"></button>
          </div>
          <div class="modal-body">
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
              <input type="text" id="reviewTitleInput"
                     class="form-control form-control-sm ha-input-sm"
                     maxlength="200"
                     placeholder="Ví dụ: Sản phẩm rất ngon" />
            </div>
            <div class="mb-2">
              <label class="form-label small mb-1">Nội dung</label>
              <textarea id="reviewContentInput"
                        class="form-control form-control-sm ha-input-sm"
                        rows="4"
                        maxlength="2000"
                        placeholder="Chia sẻ trải nghiệm thực tế của bạn..."></textarea>
            </div>

            <!-- ⚡ THÊM: Upload ảnh -->
            <div class="mb-2">
              <label class="form-label small mb-1">Hình ảnh (tùy chọn)</label>
              <input type="file"
                     id="reviewImagesInput"
                     class="form-control form-control-sm"
                     accept="image/*"
                     multiple />
              <div class="form-text small text-muted">
                Tối đa ~5 ảnh, mỗi ảnh không quá 2MB.
              </div>
            </div>

            <div class="small text-muted">
              Đánh giá sẽ được kiểm duyệt trước khi hiển thị công khai.
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-light btn-sm" data-bs-dismiss="modal">Đóng</button>
            <button type="button" class="btn btn-success btn-sm ha-btn-pill" id="btnSubmitReview">
              Gửi đánh giá
            </button>
          </div>
        </div>
      </div>
    </div>

  </form>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

  <script>
      // ===== Toast + fly-to-cart =====
      function showToast(msg) {
          const el = document.getElementById('haToast');
          if (!el) return;
          el.textContent = msg || 'Đã thêm vào giỏ hàng';
          el.style.display = 'block';
          setTimeout(() => { el.style.display = 'none'; }, 1800);
      }

      function flyToCart() {
          const img = document.getElementById('<%= imgMain.ClientID %>');
          const cartIcon = document.getElementById('cartIcon');
          if (!img || !cartIcon) return;
          const r1 = img.getBoundingClientRect(), r2 = cartIcon.getBoundingClientRect();
          const clone = img.cloneNode(true);
          clone.classList.add('ha-fly-img');
          clone.style.left = r1.left + 'px';
          clone.style.top = r1.top + 'px';
          clone.style.width = Math.min(r1.width, 80) + 'px';
          clone.style.height = Math.min(r1.height, 80) + 'px';
          document.body.appendChild(clone);
          requestAnimationFrame(() => {
              clone.style.transform = `translate(${r2.left - r1.left}px, ${r2.top - r1.top}px) scale(0.2)`;
              clone.style.opacity = '0.2';
          });
          setTimeout(() => { clone.remove(); }, 650);
      }

      window.onAddToCartSuccess = function (qty) {
          try { showToast('Đã thêm vào giỏ hàng'); } catch { }
          try { flyToCart(); } catch { }
      };

      window.CART_API = window.CART_API ?? '<%= ResolveUrl("~/Ajax/Cart.ashx") %>';
      window.CART_PAGE_URL = '<%= ResolveUrl("~/CartPage/CartPage.aspx") %>';

      function getSelectedVariantStock() {
          try {
              const json = document.getElementById('<%= hVariantsJson.ClientID %>').value || '[]';
              const variants = JSON.parse(json || '[]');
              const ddl = document.getElementById('<%= ddlVariant.ClientID %>');
              const id = Number(ddl?.value || 0);
              const found = variants.find(v => Number(v.id) === id);
              const stock = Number(found?.stock ?? 0);
              return Number.isFinite(stock) ? stock : 0;
          } catch { return 0; }
      }

      window.addToCartOptimistic = async function () {
          const stockLeft = getSelectedVariantStock();
          if (stockLeft <= 0) {
              showToast('Sản phẩm hiện tại đang hết hàng, xin quý khách vui lòng chọn sản phẩm khác');
              return;
          }

          const qty = Math.max(1, parseInt(document.getElementById('qty')?.value || '1', 10));

          window.dispatchEvent(new CustomEvent('cart:add', { detail: { delta: qty } }));

          try {
              const productId = parseInt(new URLSearchParams(location.search).get('id') || '0', 10);
              const variantId = parseInt(document.getElementById('<%= ddlVariant.ClientID %>').value || '0', 10);

              const r = await fetch(`${window.CART_API}?action=add`, {
                  method: 'POST',
                  headers: { 'Content-Type': 'application/json; charset=utf-8', 'Accept': 'application/json' },
                  credentials: 'include',
                  cache: 'no-store',
                  body: JSON.stringify({ productId, variantId, qty })
              });

              if (!r.ok) throw new Error('HTTP ' + r.status);
              const j = await r.json();
              if (!j?.ok) throw new Error(j?.message || 'Add failed');

              window.onAddToCartSuccess(qty);
          } catch (err) {
              window.dispatchEvent(new CustomEvent('cart:revert', { detail: { delta: qty } }));
              console.error('AddToCart failed:', err);
          }
      };

      window.buyNowAsync = async function () {
          const stockLeft = getSelectedVariantStock();
          if (stockLeft <= 0) { showToast('Sản phẩm hiện tại đang hết hàng, xin quý khách vui lòng chọn sản phẩm khác'); return; }

          const qty = Math.max(1, parseInt(document.getElementById('qty')?.value || '1', 10));

          try {
              const productId = parseInt(new URLSearchParams(location.search).get('id') || '0', 10);
              const variantId = parseInt(document.getElementById('<%= ddlVariant.ClientID %>').value || '0', 10);

              const r = await fetch(`${window.CART_API}?action=add`, {
                  method: 'POST',
                  headers: { 'Content-Type': 'application/json; charset=utf-8', 'Accept': 'application/json' },
                  credentials: 'include',
                  cache: 'no-store',
                  body: JSON.stringify({ productId, variantId, qty })
              });

              if (!r.ok) throw new Error('HTTP ' + r.status);
              const j = await r.json();
              if (!j?.ok) throw new Error(j?.message || 'Add failed');

              try { window.onAddToCartSuccess(qty); } catch {}

              if (window.CART_PAGE_URL) {
                  location.href = window.CART_PAGE_URL;
              } else {
                  location.href = '/CartPage/CartPage.aspx';
              }
          } catch (err) {
              console.error('BuyNow failed:', err);
              showToast('Có lỗi xảy ra khi mua ngay, vui lòng thử lại');
          }
      };

      (function bindAddToCartOnce() {
          if (window.__addToCartBound) return;
          window.__addToCartBound = true;
          document.addEventListener('DOMContentLoaded', () => {
              const btn = document.getElementById('<%= btnAddToCart.ClientID %>');
              if (btn) btn.addEventListener('click', e => { e.preventDefault(); window.addToCartOptimistic(); });

              const btnBuy = document.getElementById('btnBuy');
              if (btnBuy) btnBuy.addEventListener('click', e => { e.preventDefault(); window.buyNowAsync(); });
          });
      })();

      document.addEventListener('click', function (e) {
          if (e.target && e.target.classList.contains('thumb')) {
              document.getElementById('<%= imgMain.ClientID %>').src = e.target.getAttribute('data-url');
              document.querySelectorAll('.thumb').forEach(x => x.classList.remove('active'));
              e.target.classList.add('active');
          }
      });

      document.addEventListener('DOMContentLoaded', function () {
          const json = document.getElementById('<%= hVariantsJson.ClientID %>').value || '[]';
          const variants = JSON.parse(json || '[]');
          const ddl = document.getElementById('<%= ddlVariant.ClientID %>');
          const skuEl = document.getElementById('sku');
          const stockEl = document.getElementById('stock');
          const imgMain = document.getElementById('<%= imgMain.ClientID %>');

          function apply(v) {
              if (!v) return;
              skuEl.innerText = v.sku || '';
              stockEl.innerText = (v.stock ?? 0);
              if (v.image) imgMain.src = v.image;
          }

          if (ddl) {
              ddl.addEventListener('change', function () {
                  const id = Number(this.value);
                  apply(variants.find(x => x.id === id));
              });

              if (ddl.value) {
                  apply(variants.find(x => x.id === Number(ddl.value)));
              }
          }
      });

      window.ProductFS = {
          ddlId: '<%= ddlVariant.ClientID %>',
          priceNowId: 'priceNow',
          oldPriceId: '<%= oldPrice.ClientID %>',
          countdownId: 'fsCountdown',
          remainId: 'fsRemain',
          channel: 1
      };
  </script>

  <script src="/assets/js/product-flashsale.js?v=2"></script>

  <!-- ==== REVIEW JS (JSON -> MULTIPART, + HIỂN THỊ ẢNH) ==== -->
  <script>
      (function () {
          var API_BASE = window.__API_BASE || '';
          if (!API_BASE) return;

          var params = new URLSearchParams(window.location.search || '');
          var productId = parseInt(params.get('id') || '0', 10);
          if (!productId) return;

          var pageSize = 10;
          var curPage = 1;
          var starFilter = 0;
          var onlyHasImage = false;
          var totalCount = 0;
          var totalPages = 1;
          var reviewModalInstance = null;
          var reviewEligibility = null;

          function fmtDate(iso) {
              if (!iso) return '';
              try {
                  var d = new Date(iso);
                  if (isNaN(d.getTime())) return iso;
                  return d.toLocaleDateString('vi-VN', {
                      day: '2-digit',
                      month: '2-digit',
                      year: 'numeric'
                  });
              } catch { return iso; }
          }

          function renderStars(rating) {
              var r = Number(rating) || 0;
              var html = '';
              for (var i = 1; i <= 5; i++) {
                  if (i <= r) html += '<i class="bi bi-star-fill ha-star-filled"></i>';
                  else html += '<i class="bi bi-star ha-star-empty"></i>';
              }
              return html;
          }

          function updateSummary(summary) {
              summary = summary || {};

              var avgRaw =
                  summary.avg_Rating ??
                  summary.Avg_Rating ??
                  summary.avgRating ??
                  summary.AvgRating ??
                  0;

              var totalRaw =
                  summary.total_Reviews ??
                  summary.Total_Reviews ??
                  summary.totalReviews ??
                  summary.TotalReviews ??
                  0;

              var avg = Number(avgRaw) || 0;
              var total = Number(totalRaw) || 0;

              var spanAvg = document.getElementById('reviewAvgScore');
              var spanStars = document.getElementById('reviewStarIcons');
              var spanTotal = document.getElementById('reviewTotalCount');

              if (spanAvg) spanAvg.textContent = avg.toFixed(1);
              if (spanStars) spanStars.innerHTML = renderStars(avg);
              if (spanTotal) spanTotal.textContent = total;

              function getInt() {
                  for (var i = 0; i < arguments.length; i++) {
                      var k = arguments[i];
                      if (summary != null && summary[k] != null) {
                          var n = Number(summary[k]);
                          if (!isNaN(n)) return n;
                      }
                  }
                  return 0;
              }

              var c5 = getInt('star_5_Count', 'Star_5_Count');
              var c4 = getInt('star_4_Count', 'Star_4_Count');
              var c3 = getInt('star_3_Count', 'Star_3_Count');
              var c2 = getInt('star_2_Count', 'Star_2_Count');
              var c1 = getInt('star_1_Count', 'Star_1_Count');

              var el;
              el = document.getElementById('reviewCountStar5'); if (el) el.textContent = c5 ? '(' + c5 + ')' : '';
              el = document.getElementById('reviewCountStar4'); if (el) el.textContent = c4 ? '(' + c4 + ')' : '';
              el = document.getElementById('reviewCountStar3'); if (el) el.textContent = c3 ? '(' + c3 + ')' : '';
              el = document.getElementById('reviewCountStar2'); if (el) el.textContent = c2 ? '(' + c2 + ')' : '';
              el = document.getElementById('reviewCountStar1'); if (el) el.textContent = c1 ? '(' + c1 + ')' : '';
          }

          function renderList(items) {
              var wrap = document.getElementById('reviewList');
              if (!wrap) return;

              if (!items || !items.length) {
                  wrap.innerHTML = '<div class="ha-review-empty">Chưa có đánh giá nào cho sản phẩm này.</div>';
                  return;
              }

              var html = '';
              for (var i = 0; i < items.length; i++) {
                  var it = items[i] || {};
                  var userName = it.user_Full_Name || it.user_Name || 'Khách hàng ẩn danh';
                  var avatar = it.user_Avatar || '';

                  // --- chuẩn hoá avatar URL ---
                  if (avatar) {
                      if (avatar.startsWith('http://localhost') || avatar.startsWith('https://localhost')) {
                          var idx = avatar.indexOf('/uploads/');
                          if (idx > -1 && (window.__API_BASE || '')) {
                              avatar = (window.__API_BASE || '').replace(/\/+$/, '') + avatar.substring(idx);
                          }
                      } else if (avatar.charAt(0) === '/' && (window.__API_BASE || '')) {
                          avatar = (window.__API_BASE || '').replace(/\/+$/, '') + avatar;
                      }
                  }

                  var rating = it.rating || it.Rating || 0;
                  var title = it.title || it.Title || '';
                  var content = it.content || it.Content || '';
                  var hasImg = !!(it.has_image || it.Has_Image);
                  var verified = !!(it.is_verified_purchase || it.Is_Verified_Purchase);
                  var createdAt = fmtDate(it.created_at || it.created_At || it.Created_At || it.createdAt);

                  // 🔹 ảnh đầu tiên & số lượng ảnh
                  var firstImage = it.first_Image_Url || it.First_Image_Url || it.first_image_url || '';
                  var imgCount = Number(it.image_Count ?? it.Image_Count ?? 0) || 0;

                  if (firstImage) {
                      if (firstImage.startsWith('http://localhost') || firstImage.startsWith('https://localhost')) {
                          var idx2 = firstImage.indexOf('/uploads/');
                          if (idx2 > -1 && (window.__API_BASE || '')) {
                              firstImage = (window.__API_BASE || '').replace(/\/+$/, '') + firstImage.substring(idx2);
                          }
                      } else if (firstImage.charAt(0) === '/' && (window.__API_BASE || '')) {
                          firstImage = (window.__API_BASE || '').replace(/\/+$/, '') + firstImage;
                      }
                  }

                  // 🔹 thông tin reply
                  var hasReply = !!(it.has_Reply || it.Has_Reply);
                  var replyContent = it.reply_Content || it.Reply_Content || '';
                  var replyAt = fmtDate(it.reply_Created_At || it.Reply_Created_At);
                  var replyBy = it.reply_Admin_Name || it.Reply_Admin_Name || 'Cửa hàng';

                  html += '<div class="ha-review-card">';
                  html += '  <div class="d-flex align-items-start gap-3">';
                  html += '    <div>';
                  if (avatar) {
                      html += '      <img src="' + avatar + '" alt="" class="rounded-circle" style="width:40px;height:40px;object-fit:cover;" />';
                  } else {
                      html += '      <div class="rounded-circle bg-success-subtle text-success-emphasis d-flex align-items-center justify-content-center" style="width:40px;height:40px;font-size:.9rem;">';
                      html += (userName || '').charAt(0).toUpperCase();
                      html += '      </div>';
                  }
                  html += '    </div>';
                  html += '    <div class="flex-grow-1">';
                  html += '      <div class="d-flex align-items-center justify-content-between mb-1">';
                  html += '        <div>';
                  html += '          <div class="ha-review-user">' + userName + '</div>';
                  html += '          <div class="ha-review-meta">';
                  html += renderStars(rating);
                  var rr = Number(rating) || 0;
                  html += '            <span class="ms-1 small text-muted">' + rr.toFixed(1) + '/5</span>';

                  if (verified) {
                      html += '            <span class="badge bg-success-subtle text-success-emphasis ms-2">Đã mua hàng</span>';
                  }
                  if (hasImg) {
                      html += '            <span class="badge bg-info-subtle text-info-emphasis ms-2">Có hình ảnh</span>';
                  }
                  html += '          </div>';
                  html += '        </div>';
                  if (createdAt) {
                      html += '        <div class="ha-review-meta text-end">' + createdAt + '</div>';
                  }
                  html += '      </div>';

                  if (title) {
                      html += '      <div class="ha-review-title">' + title + '</div>';
                  }
                  if (content) {
                      html += '      <div class="ha-review-content">' + content + '</div>';
                  }

                  // 🔹 block hiển thị ảnh review
                  if (firstImage) {
                      html += '      <div class="mt-2 d-flex align-items-center gap-2 flex-wrap">';
                      html += '        <a href="' + firstImage + '" target="_blank">';
                      html += '          <img src="' + firstImage + '" alt="Ảnh đánh giá" class="rounded"';
                      html += '               style="width:80px;height:80px;object-fit:cover;border:1px solid #e5e7eb;" />';
                      html += '        </a>';
                      if (imgCount > 1) {
                          html += '        <span class="small text-muted">+ ' + (imgCount - 1) + ' ảnh khác</span>';
                      }
                      html += '      </div>';
                  }

                  // 🔹 block hiển thị reply của shop
                  if (hasReply && replyContent) {
                      html += '      <div class="mt-2 p-2 rounded-3 border bg-light-subtle small">';
                      html += '        <div class="fw-semibold mb-1">';
                      html += '          <i class="bi bi-reply-fill me-1"></i>' + replyBy + ' phản hồi:';
                      html += '        </div>';
                      html += '        <div>' + replyContent + '</div>';
                      if (replyAt) {
                          html += '        <div class="text-muted mt-1" style="font-size:.8rem;">' + replyAt + '</div>';
                      }
                      html += '      </div>';
                  }

                  html += '    </div>'; // flex-grow
                  html += '  </div>';   // row
                  html += '</div>';     // card
              }

              wrap.innerHTML = html;
          }



          function updatePagination() {
              var info = document.getElementById('reviewPagingInfo');
              var btnPrev = document.getElementById('reviewPrevBtn');
              var btnNext = document.getElementById('reviewNextBtn');

              if (info) {
                  if (totalCount === 0) info.textContent = 'Không có đánh giá.';
                  else info.textContent = 'Trang ' + curPage + '/' + totalPages + ' · ' + totalCount + ' đánh giá';
              }
              if (btnPrev) btnPrev.disabled = (curPage <= 1);
              if (btnNext) btnNext.disabled = (curPage >= totalPages);
          }

          async function loadReviewSummary() {
              try {
                  var url = API_BASE + '/api/products/' + productId + '/reviews/summary';
                  var resp = await fetch(url, { method: 'GET', headers: { 'Accept': 'application/json' } });
                  if (!resp.ok) return;
                  var data = await resp.json();
                  updateSummary(data);
              } catch (e) {
                  console.error('Summary error', e);
              }
          }

          async function loadReviews(page) {
              var listEl = document.getElementById('reviewList');
              if (listEl) listEl.innerHTML = '<div class="text-muted small">Đang tải đánh giá...</div>';

              curPage = page || 1;
              var url = API_BASE + '/api/products/' + productId + '/reviews?page=' + curPage + '&page_size=' + pageSize;
              if (starFilter && starFilter > 0) url += '&star=' + starFilter;
              if (onlyHasImage) url += '&has_image=true';

              try {
                  var resp = await fetch(url, {
                      method: 'GET',
                      headers: { 'Accept': 'application/json' },
                      credentials: 'include'
                  });
                  var data = await resp.json();

                  if (!resp.ok) {
                      console.error('Review list error:', data);
                      if (listEl) listEl.innerHTML = '<div class="ha-review-empty">Không thể tải danh sách đánh giá.</div>';
                      return;
                  }

                  var items = data.items || data.Items || [];
                  renderList(items);

                  var total = data.total_Count ?? data.Total_Count ?? 0;
                  totalCount = Number(total) || 0;
                  totalPages = totalCount > 0 ? Math.ceil(totalCount / pageSize) : 1;

                  updatePagination();
              } catch (err) {
                  console.error('Review list exception:', err);
                  if (listEl) listEl.innerHTML = '<div class="ha-review-empty">Có lỗi xảy ra khi tải đánh giá.</div>';
              }
          }

          async function loadReviewEligibility() {
              if (!window.__AUTH_TOKEN || !window.__AUTH_TOKEN.length) return;

              var ddl = document.getElementById('<%= ddlVariant.ClientID %>');
              var variantId = ddl ? parseInt(ddl.value || '0', 10) : 0;

              var url = API_BASE + '/api/products/' + productId + '/reviews/eligibility';
              if (variantId > 0) {
                  url += '?variantId=' + variantId;
              }

              try {
                  var resp = await fetch(url, {
                      method: 'GET',
                      headers: {
                          'Accept': 'application/json',
                          'Authorization': 'Bearer ' + window.__AUTH_TOKEN
                      },
                      credentials: 'include'
                  });

                  if (!resp.ok) {
                      console.warn('eligibility resp not ok', resp.status);
                      return;
                  }

                  var data = await resp.json();
                  reviewEligibility = data;

                  var btnOpenModal = document.getElementById('btnOpenReviewModal');
                  if (!btnOpenModal) return;

                  if (!data.has_Purchase && !data.Has_Purchase) {
                      btnOpenModal.disabled = true;
                      btnOpenModal.textContent = 'Chỉ khách đã mua mới đánh giá được';
                      btnOpenModal.classList.add('btn-outline-secondary');
                      btnOpenModal.classList.remove('btn-outline-success');
                      return;
                  }

                  var already = data.already_Reviewed || data.Already_Reviewed;
                  var canReview = data.can_Review || data.Can_Review;

                  if (already || !canReview) {
                      btnOpenModal.disabled = true;
                      btnOpenModal.textContent = 'Bạn đã đánh giá sản phẩm này';
                      btnOpenModal.classList.add('btn-outline-secondary');
                      btnOpenModal.classList.remove('btn-outline-success');
                  } else {
                      btnOpenModal.disabled = false;
                      btnOpenModal.textContent = 'Viết đánh giá';
                      btnOpenModal.classList.add('btn-outline-success');
                      btnOpenModal.classList.remove('btn-outline-secondary');
                  }
              } catch (e) {
                  console.error('Eligibility error', e);
              }
          }

          function setRatingUI(r) {
              var valInput = document.getElementById('reviewRatingValue');
              if (valInput) valInput.value = r;
              var wrap = document.getElementById('reviewRatingStars');
              if (!wrap) return;
              var icons = wrap.querySelectorAll('i[data-rating]');
              for (var i = 0; i < icons.length; i++) {
                  var el = icons[i];
                  var v = parseInt(el.getAttribute('data-rating') || '0', 10);
                  if (v <= r) {
                      el.classList.remove('bi-star');
                      el.classList.add('bi-star-fill', 'text-warning');
                  } else {
                      el.classList.add('bi-star');
                      el.classList.remove('bi-star-fill', 'text-warning');
                  }
              }
          }

          async function submitReview() {
              var rating = parseInt((document.getElementById('reviewRatingValue') || {}).value || '0', 10);
              var title = (document.getElementById('reviewTitleInput') || {}).value || '';
              var content = (document.getElementById('reviewContentInput') || {}).value || '';
              var ddl = document.getElementById('<%= ddlVariant.ClientID %>');
              var variantId = ddl ? parseInt(ddl.value || '0', 10) : 0;
              var imgInput = document.getElementById('reviewImagesInput');
              var files = (imgInput && imgInput.files) ? imgInput.files : null;

              title = title.trim();
              content = content.trim();

              if (!rating || rating < 1 || rating > 5) {
                  if (window.showToast) showToast('Vui lòng chọn số sao đánh giá');
                  return;
              }

              var params = new URLSearchParams(window.location.search || '');
              var productId = parseInt(params.get('id') || '0', 10);

              var orderId = 0, orderItemId = 0;
              if (reviewEligibility) {
                  orderId = reviewEligibility.last_Order_Id || reviewEligibility.Last_Order_Id || 0;
                  orderItemId = reviewEligibility.last_Order_Item_Id || reviewEligibility.Last_Order_Item_Id || 0;
              }

              var hasImages = !!(files && files.length > 0);

              var formData = new FormData();
              formData.append('Product_Id', String(productId));
              if (variantId > 0) formData.append('Variant_Id', String(variantId));
              if (orderId > 0) formData.append('Order_Id', String(orderId));
              if (orderItemId > 0) formData.append('Order_Item_Id', String(orderItemId));
              formData.append('Rating', String(rating));
              if (title) formData.append('Title', title);
              if (content) formData.append('Content', content);
              formData.append('Has_Image', hasImages ? 'true' : 'false');

              if (files && files.length) {
                  for (var i = 0; i < files.length; i++) {
                      var f = files[i];
                      if (!f) continue;
                      if (f.size > 2 * 1024 * 1024) {
                          // bỏ qua file > 2MB
                          continue;
                      }
                      formData.append('Images', f);
                  }
              }

              var url = API_BASE + '/api/reviews';

              var headers = {
                  'Accept': 'application/json'
              };

              if (window.__AUTH_TOKEN && window.__AUTH_TOKEN.length > 0) {
                  headers['Authorization'] = 'Bearer ' + window.__AUTH_TOKEN;
              }

              try {
                  var resp = await fetch(url, {
                      method: 'POST',
                      headers: headers,
                      credentials: 'include',
                      body: formData
                  });

                  var data = null;
                  try { data = await resp.json(); } catch { }

                  if (resp.status === 401 || resp.status === 403) {
                      if (window.showToast) showToast('Vui lòng đăng nhập để gửi đánh giá');
                      return;
                  }

                  if (!resp.ok || (data && data.success === false)) {
                      var msg = (data && (data.message || data.detail)) || 'Không thể gửi đánh giá, vui lòng thử lại.';
                      if (window.showToast) showToast(msg);
                      return;
                  }

                  if (window.showToast) showToast('Đã gửi đánh giá, chờ duyệt.');

                  var titleInput = document.getElementById('reviewTitleInput');
                  var contentInput = document.getElementById('reviewContentInput');
                  var imgInput2 = document.getElementById('reviewImagesInput');
                  if (titleInput) titleInput.value = '';
                  if (contentInput) contentInput.value = '';
                  if (imgInput2) imgInput2.value = '';

                  if (reviewModalInstance) reviewModalInstance.hide();

                  window.reloadProductReviews();
              } catch (err) {
                  console.error('Submit review error:', err);
                  if (window.showToast) showToast('Có lỗi xảy ra, vui lòng thử lại.');
              }
          }

          document.addEventListener('DOMContentLoaded', function () {
              var filterBtns = document.querySelectorAll('[data-review-star]');
              for (var i = 0; i < filterBtns.length; i++) {
                  filterBtns[i].addEventListener('click', function () {
                      var v = parseInt(this.getAttribute('data-review-star') || '0', 10);
                      starFilter = v || 0;

                      for (var j = 0; j < filterBtns.length; j++) {
                          filterBtns[j].classList.remove('btn-success', 'text-white', 'active');
                          filterBtns[j].classList.add('btn-outline-secondary');
                      }
                      this.classList.remove('btn-outline-secondary');
                      this.classList.add('btn-success', 'text-white', 'active');

                      loadReviews(1);
                  });
              }

              var chkHasImg = document.getElementById('reviewFilterHasImage');
              if (chkHasImg) {
                  chkHasImg.addEventListener('change', function () {
                      onlyHasImage = !!this.checked;
                      loadReviews(1);
                  });
              }

              var btnPrev = document.getElementById('reviewPrevBtn');
              var btnNext = document.getElementById('reviewNextBtn');
              if (btnPrev) btnPrev.addEventListener('click', function () {
                  if (curPage > 1) loadReviews(curPage - 1);
              });
              if (btnNext) btnNext.addEventListener('click', function () {
                  if (curPage < totalPages) loadReviews(curPage + 1);
              });

              var btnOpenModal = document.getElementById('btnOpenReviewModal');
              if (btnOpenModal) {
                  btnOpenModal.addEventListener('click', function () {
                      var el = document.getElementById('reviewModal');
                      if (!el || !window.bootstrap) return;
                      if (!reviewModalInstance) {
                          reviewModalInstance = new bootstrap.Modal(el);
                      }
                      reviewModalInstance.show();
                  });
              }

              var starWrap = document.getElementById('reviewRatingStars');
              if (starWrap) {
                  starWrap.addEventListener('click', function (e) {
                      var icon = e.target.closest('i[data-rating]');
                      if (!icon) return;
                      var v = parseInt(icon.getAttribute('data-rating') || '0', 10);
                      if (!v) return;
                      setRatingUI(v);
                  });
                  setRatingUI(parseInt((document.getElementById('reviewRatingValue') || {}).value || '5', 10));
              }

              var btnSubmit = document.getElementById('btnSubmitReview');
              if (btnSubmit) {
                  btnSubmit.addEventListener('click', function () {
                      submitReview();
                  });
              }

              // Khi đổi biến thể, reload eligibility theo variant
              var ddlVariant = document.getElementById('<%= ddlVariant.ClientID %>');
              if (ddlVariant) {
                  ddlVariant.addEventListener('change', function () {
                      loadReviewEligibility();
                  });
              }

              loadReviewSummary();
              loadReviews(1);
              loadReviewEligibility();
          });

          window.reloadProductReviews = function () {
              loadReviewSummary();
              loadReviews(1);
              loadReviewEligibility();
          };

      })();
  </script>

</body>
</html>
