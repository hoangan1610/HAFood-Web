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

    /* Khung tổng thể */
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

    /* Breadcrumb */
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

    /* Tiêu đề & meta */
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

    /* Giá */
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

    /* Gallery */
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

    /* Card sản phẩm gợi ý */
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

    /* Toast + effect */
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

    /* Form control nhỏ nhưng thoáng hơn */
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

    /* Khối mô tả */
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

    /* Header “Gợi ý cho bạn” */
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

    /* Nhãn flash sale */
    #fsCountdown{
      font-weight:600;
    }
    #fsRemain{
      font-size:.86rem;
    }

    /* Misc */
    .ha-divider{
      border-color:#e5e7eb;
      opacity:.7;
    }
  </style>

  <!-- Xuất API_BASE cho JS -->
  <script>
      window.__API_BASE = '<%= System.Configuration.ConfigurationManager.AppSettings["ApiBaseUrl"] ?? "" %>';
  </script>
</head>

<body>
  <!-- Toast đơn giản (hợp với showToast dùng textContent) -->
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
            <!-- Subtitle nhỏ -->
            <div class="d-flex align-items-center mb-2">
              <span class="ha-subtitle-pill">
                <i class="bi bi-bag-check"></i>
                Sản phẩm chính hãng
              </span>
            </div>

            <h1 class="product-title">
              <asp:Literal ID="litName" runat="server" />
            </h1>

            <!-- Thương hiệu -->
            <div class="meta-row mb-1">
              <span class="meta-label">Thương hiệu:</span>
              <span class="meta-value">
                <asp:Literal ID="litBrand" runat="server" />
              </span>
            </div>

            <!-- SKU & Tồn kho -->
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

            <!-- Giá -->
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

            <!-- Variants / Qty / Buttons -->
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

              <!-- ScriptManager với PageMethods -->
              <asp:ScriptManager ID="ScriptManager1" runat="server"
                                 EnablePartialRendering="true" EnablePageMethods="true" />

              <!-- UpdatePanel cho nút thêm vào giỏ -->
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

            <!-- Mô tả -->
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

      // ====== SAU KHI THÊM GIỎ HÀNG (KHÔNG ĐỒNG BỘ COUNT) ======
      window.onAddToCartSuccess = function (qty) {
          try { showToast('Đã thêm vào giỏ hàng'); } catch { }
          try { flyToCart(); } catch { }
          // KHÔNG cart:set
          // KHÔNG cartSyncNow
      };

      // ==== Cart.ashx ====
      window.CART_API = window.CART_API ?? '<%= ResolveUrl("~/Ajax/Cart.ashx") %>';

      window.addToCartOptimistic = async function () {
          const qty = Math.max(1, parseInt(document.getElementById('qty')?.value || '1', 10));

          // ⭐⭐ TĂNG NGAY TRÊN UI
          window.dispatchEvent(new CustomEvent('cart:add', { detail: { delta: qty } }));

          try {
              const productId = parseInt(new URLSearchParams(location.search).get('id') || '0', 10);
              const variantId = parseInt(document.getElementById('<%= ddlVariant.ClientID %>').value || '0', 10);

              const r = await fetch(`${window.CART_API}?action=add`, {
                  method: 'POST',
                  headers: {
                      'Content-Type': 'application/json; charset=utf-8',
                      'Accept': 'application/json'
                  },
                  credentials: 'include',
                  cache: 'no-store',
                  body: JSON.stringify({ productId, variantId, qty })
              });

              if (!r.ok) throw new Error('HTTP ' + r.status);
              const j = await r.json();
              if (!j?.ok) throw new Error(j?.message || 'Add failed');

              // ⭐ Không dùng serverCount để set lại badge
              window.onAddToCartSuccess(qty);

          } catch (err) {
              // ⭐⭐ LỖI → TRẢ LẠI SỐ VỪA CỘNG
              window.dispatchEvent(new CustomEvent('cart:revert', { detail: { delta: qty } }));
              console.error('AddToCart failed:', err);
          }
      };

      (function bindAddToCartOnce() {
          if (window.__addToCartBound) return;
          window.__addToCartBound = true;
          document.addEventListener('DOMContentLoaded', () => {
              const btn = document.getElementById('<%= btnAddToCart.ClientID %>');
            if (btn) btn.addEventListener('click', e => {
                e.preventDefault();
                window.addToCartOptimistic();
            });
        });
      })();

      // Gallery thumbs
      document.addEventListener('click', function (e) {
          if (e.target && e.target.classList.contains('thumb')) {
              document.getElementById('<%= imgMain.ClientID %>').src = e.target.getAttribute('data-url');
            document.querySelectorAll('.thumb').forEach(x => x.classList.remove('active'));
            e.target.classList.add('active');
        }
    });

    // Đồng bộ SKU/Stock/Image khi đổi biến thể
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

        ddl && ddl.addEventListener('change', function () {
            const id = Number(this.value);
            apply(variants.find(x => x.id === id));
        });

        if (ddl && ddl.value) {
            apply(variants.find(x => x.id === Number(ddl.value)));
        }
    });

    // Flash sale config
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

</body>
</html>
