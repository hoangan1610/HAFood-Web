<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="HomePage.aspx.cs" Inherits="HAFoodWeb.HomePage.HomePage" Async="true" %>

<%@ Register Src="~/Control/Header.ascx" TagPrefix="uc" TagName="Header" %>
<%@ Register Src="~/Control/SlideShow.ascx" TagPrefix="uc" TagName="Slideshow" %>
<%@ Register Src="~/Control/Footer.ascx" TagPrefix="uc" TagName="Footer" %>

<!DOCTYPE html>
<html lang="vi">
<head runat="server">
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>HAFood</title>

  <!-- Bootstrap -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />

  <!-- Fonts -->
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <!-- Great Vibes + Playfair Display (giống layout cũ) -->
  <link href="https://fonts.googleapis.com/css2?family=Great+Vibes&family=Playfair+Display:wght@600;700&display=swap&subset=latin,vietnamese" rel="stylesheet">
  <!-- Noto Serif: fallback có hỗ trợ tiếng Việt, dùng cùng với Georgia -->
  <link href="https://fonts.googleapis.com/css2?family=Noto+Serif:ital,wght@0,400;0,700;1,400;1,700&display=swap&subset=latin,vietnamese" rel="stylesheet">

  <style>
    /* ==== Featured category cards ==== */
    .cat-card{background:#fff;border:1px solid #eee;transition:transform .15s ease}
    .cat-card:hover{transform:translateY(-3px)}
    .cat-img{max-height:120px;object-fit:contain}
    .cat-name{font-weight:700;font-size:1.05rem;color:#2aa33b}

    /* ==== Product cards ==== */
    .text-truncate-2{display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden}
    .price-now{color:#ff3b30;font-weight:700}
    .price-old{text-decoration:line-through;color:#888;margin-left:.5rem}
    .badge-off{position:absolute;top:.5rem;right:.5rem;background:#ffe08a;color:#333;padding:.35rem .5rem;border-radius:.35rem;font-weight:700}
    .of-contain{object-fit:contain}

    /* ==== Horizontal shelf (Mới về) ==== */
    .shelf{display:flex;gap:1rem;overflow:auto;padding-bottom:.5rem;scroll-snap-type:x mandatory}
    .shelf::-webkit-scrollbar{height:8px}
    .shelf::-webkit-scrollbar-thumb{background:#ddd;border-radius:100px}
    .shelf-item{min-width:220px;scroll-snap-align:start}
    @media (min-width:576px){ .shelf-item{min-width:240px} }
    @media (min-width:992px){ .shelf-item{min-width:260px} }

    /* Card polish */
    .product-card{transition:transform .15s ease, box-shadow .15s ease}
    .product-card:hover{transform:translateY(-3px);box-shadow:0 .5rem 1rem rgba(0,0,0,.06)}

    /* ==== SERVICES (Welcome to HAFood) ==== */
    .services-wrap{background:#faf8f2}
    .services-wrap .eyebrow{
      font-family:'Great Vibes',cursive;color:#2aa33b;font-size:1.8rem;line-height:1;margin-bottom:.25rem
    }
    .services-wrap .headline{
      font-family:"Georgia","Noto Serif","Times New Roman",Times,serif;
      font-size:2rem;font-weight:700;font-style:italic; color:#000;
    }

    .service-item{padding:1.25rem;border-radius:1.25rem;text-align:center;background:transparent}

    .service-title{
      font-family:"Georgia","Noto Serif","Times New Roman",Times,serif;
      font-weight:700;margin:.25rem 0 .5rem;cursor:pointer;color:#2aa33b
    }
    .service-desc{
      font-family:"Georgia","Noto Serif","Times New Roman",Times,serif;
      color:#6b7280
    }

    .service-icon{
      width:150px;height:150px;border-radius:999px;margin:0 auto 16px;
      display:flex;align-items:center;justify-content:center;
      perspective:600px;
      font-family:"Georgia","Noto Serif","Times New Roman",Times,serif;
    }
    .service-icon *{
      font-family:"Georgia","Noto Serif","Times New Roman",Times,serif !important
    }
    .service-icon img{
      max-width:72%;height:auto;will-change:transform;
      transform-style:preserve-3d;backface-visibility:hidden
    }
    .service-item.fresh   .service-icon{background:#FFE2B3}
    .service-item.natural .service-icon{background:#D6F1DB}
    .service-item.quality .service-icon{background:#FFD5DE}
    .service-item.safe    .service-icon{background:#D3EAFE}

    @keyframes svc-flip-y { from{transform:rotateY(0)} to{transform:rotateY(360deg)} }
    .spinY{ animation:svc-flip-y .6s ease-in-out 1 }

    /* ==== SECTION TITLES ==== */
    .sec-title{
      text-align:center;color:#000;
      font-family:"Georgia","Noto Serif","Times New Roman",Times,serif;
      font-weight:700;font-style:italic;margin:0;
    }

    /* ==== Product card tweaks ==== */
    .product-card .ratio{background:#FFF4E5 !important}  /* nền kem */
    .shelf .ratio{background:#FFF4E5 !important}
    .product-name{
      font-family:"Georgia","Noto Serif","Times New Roman",Times,serif;
      font-weight:700;font-size:1.12rem; /* nhỉnh hơn xíu */
    }
    .product-price{
      font-family:"Georgia","Times New Roman",Times,serif;
    }

    /* ====== FONT THEO NGÔN NGỮ (Cách 1) ======
       Đặt KHỐI NÀY Ở CUỐI để override các font-family phía trên */
    :lang(vi) {
      /* Toàn bộ nội dung tiếng Việt sẽ dùng serif hỗ trợ VN để không lỗi dấu */
      font-family: "Noto Serif", "Times New Roman", Times, serif;
    }
    :lang(en), .en-georgia {
      /* Những đoạn tiếng Anh (được đánh dấu lang="en") giữ đúng Georgia */
      font-family: Georgia, "Times New Roman", Times, serif;
    }

    /* Ép các khu vực có selector mạnh (như .headline) dùng Noto Serif khi là tiếng Việt */
    .services-wrap .headline:lang(vi),
    .sec-title:lang(vi),
    .service-title:lang(vi),
    .service-desc:lang(vi),
    .product-name:lang(vi),
    .cat-name:lang(vi) {
      font-family: "Noto Serif", "Times New Roman", Times, serif !important;
    }

    /* Tránh cắt dấu khi đậm/italic */
    body { line-height: 1.55; }
    .sec-title, .service-title, .product-name { line-height: 1.35; }
  </style>
</head>

<body>
<form runat="server">
  <asp:ScriptManager ID="sm" runat="server" />

  <!-- HEADER -->
  <uc:Header ID="Header1" runat="server" />

  <!-- SLIDESHOW -->
  <uc:Slideshow ID="Slideshow1" runat="server" />

  <!-- SERVICES (Welcome To HAFood) -->
  <section class="services-wrap py-5">
    <div class="container">
      <div class="text-center mb-4">
        <!-- Tiếng Anh: dùng Georgia -->
        <div class="eyebrow" lang="en">Services</div>
        <!-- Tiếng Việt: được ép dùng Noto Serif, không lỗi dấu -->
        <div class="headline">Chào mừng đến với HAFood</div>
      </div>

      <div class="row g-4 justify-content-center">
        <!-- 1. Always Fresh -->
        <div class="col-6 col-md-3">
          <div class="service-item fresh">
            <div class="service-icon">
              <img src="/images/services/service-fresh.svg" alt="Always Fresh" loading="lazy" lang="en" />
            </div>
            <h5 class="service-title">Thực phẩm luôn sạch</h5>
            <p class="service-desc">Chúng tôi luôn quan đảm bảo về an toàn vệ sinh thực phẩm</p>
          </div>
        </div>

        <!-- 2. 100% Natural -->
        <div class="col-6 col-md-3">
          <div class="service-item natural">
            <div class="service-icon">
              <img src="/images/services/service-natural.svg" alt="100% Natural" loading="lazy" lang="en" />
            </div>
            <h5 class="service-title">100% Tự nhiên</h5>
            <p class="service-desc">Nguyên liệu luôn sạch sẽ tự nhiên không chất bảo quản</p>
          </div>
        </div>

        <!-- 3. Best Quality -->
        <div class="col-6 col-md-3">
          <div class="service-item quality">
            <div class="service-icon">
              <img src="/images/services/service-quality.svg" alt="Best Quality" loading="lazy" lang="en" />
            </div>
            <h5 class="service-title">Chất lượng tốt nhất</h5>
            <p class="service-desc">Chúng tôi luôn đặt chất lượng sản phẩm lên hàng đầu</p>
          </div>
        </div>

        <!-- 4. Food Safety -->
        <div class="col-6 col-md-3">
          <div class="service-item safe">
            <div class="service-icon">
              <img src="/images/services/service-safety.svg" alt="Food Safety" loading="lazy" lang="en" />
            </div>
            <h5 class="service-title">Thức ăn an toàn</h5>
            <p class="service-desc">Nguyên liệu và quá trình chế biến luôn đảm bảo an toàn vệ sinh</p>
          </div>
        </div>
      </div>
    </div>
  </section>

  <!-- FEATURED CATEGORIES -->
  <div class="container my-5">
    <h3 class="sec-title mb-4">Danh mục nổi bật</h3>
    <asp:Repeater ID="rpCategories" runat="server">
      <HeaderTemplate><div class="row gx-3"></HeaderTemplate>
      <ItemTemplate>
        <div class="col-6 col-md-4 col-lg-3 mb-4">
          <a href='<%# string.Format("{0}?category_id={1}", ResolveUrl("~/HomePage/Search"), Eval("Id")) %>' class="text-decoration-none">
            <div class="cat-card shadow-sm rounded-4 p-3 h-100 text-center">
              <img src='<%# Eval("ImageUrlComputed") %>' loading="lazy" width="300" height="300"
                   alt='<%# Eval("Name") %>' class="img-fluid cat-img mb-3" />
              <div class="cat-name"><%# Eval("Name") %></div>
            </div>
          </a>
        </div>
      </ItemTemplate>
      <FooterTemplate></div></FooterTemplate>
    </asp:Repeater>
  </div>

  <!-- NEW ARRIVALS: Horizontal shelf -->
  <div class="container my-5">
    <div class="text-center mb-3">
      <h3 class="sec-title">Sản phẩm mới về</h3>
      <a href="/category.aspx?sort=created_at:desc" class="text-decoration-none">Xem tất cả ›</a>
    </div>

    <div class="shelf">
      <asp:Repeater ID="rpNew" runat="server">
        <ItemTemplate>
          <div class="shelf-item">
            <div class="card product-card shadow-sm h-100">
              <a href='<%# Eval("Id", ResolveUrl("~/product/Product.aspx?id={0}")) %>' class="text-decoration-none">
                <div class="ratio ratio-4x3 position-relative">
                  <img src="<%# Eval("ImageUrl") %>" loading="lazy"
                       class="w-100 h-100 of-contain p-2" alt="<%# Eval("Name") %>"
                       onerror="this.src='/images/product-default.png';" />
                  <%# Eval("DiscountBadgeHtml") %>
                  <span class="badge bg-success position-absolute top-0 start-0 m-2">Mới</span>
                </div>
              </a>

              <div class="card-body d-flex flex-column">
                <h6 class="mb-1 text-truncate-2">
                  <a class="text-dark text-decoration-none product-name"
                     href='<%# Eval("Id", ResolveUrl("~/product/Product.aspx?id={0}")) %>'><%# Eval("Name") %></a>
                </h6>

                <div class="mb-2 product-price"><%# Eval("PriceRangeHtml") %></div>

                <select class="form-select form-select-sm mb-2">
                  <asp:Repeater ID="rpVar" runat="server" DataSource='<%# Eval("Variants") %>'>
                    <ItemTemplate>
                      <option value="<%# Eval("Id") %>"><%# Eval("Label") %></option>
                    </ItemTemplate>
                  </asp:Repeater>
                </select>

                <a class="btn btn-warning btn-sm mt-auto w-100"
                   href='<%# Eval("Id", ResolveUrl("~/product/Product.aspx?id={0}")) %>'>Mua</a>
              </div>
            </div>
          </div>
        </ItemTemplate>
      </asp:Repeater>
    </div>
  </div>

  <!-- RECOMMENDED GRID -->
  <div class="container my-5">
    <h3 class="sec-title mb-4">Gợi ý cho bạn</h3>

    <asp:Repeater ID="rpProducts" runat="server">
      <HeaderTemplate><div class="row gx-3 gy-4"></HeaderTemplate>
      <ItemTemplate>
        <div class="col-12 col-sm-6 col-lg-3">
          <div class="card product-card h-100 shadow-sm d-flex">
            <a href='<%# Eval("Id", ResolveUrl("~/product/Product.aspx?id={0}")) %>' class="text-decoration-none">
              <div class="ratio ratio-4x3">
                <img src="<%# Eval("ImageUrl") %>" loading="lazy"
                     class="w-100 h-100 of-contain p-2"
                     onerror="this.src='/images/product-default.png';"
                     alt="<%# Eval("Name") %>" />
              </div>
            </a>
            <%# Eval("DiscountBadgeHtml") %>

            <div class="card-body d-flex flex-column">
              <h6 class="card-title text-truncate-2 mb-2">
                <a class="text-dark text-decoration-none product-name"
                   href='<%# Eval("Id", ResolveUrl("~/product/Product.aspx?id={0}")) %>'><%# Eval("Name") %></a>
              </h6>

              <div class="mb-2 product-price"><%# Eval("PriceRangeHtml") %></div>

              <div class="mb-2">
                <select class="form-select form-select-sm">
                  <asp:Repeater ID="rpVariantInner" runat="server" DataSource='<%# Eval("Variants") %>'>
                    <ItemTemplate><option value="<%# Eval("Id") %>"><%# Eval("Label") %></option></ItemTemplate>
                  </asp:Repeater>
                </select>
              </div>

              <div class="d-flex align-items-center gap-2 mt-auto">
                <label class="me-2">SL</label>
                <input type="number" class="form-control form-control-sm" style="width:90px" value="1" min="1" />
                <a class="btn btn-warning btn-sm ms-auto"
                   href='<%# Eval("Id", ResolveUrl("~/product/Product.aspx?id={0}")) %>'>Mua</a>
              </div>
            </div>
          </div>
        </div>
      </ItemTemplate>
      <FooterTemplate></div></FooterTemplate>
    </asp:Repeater>
  </div>

  <!-- FOOTER -->
  <uc:Footer ID="Footer1" runat="server" />

  <!-- JS -->
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
  <script>
      // Hover tiêu đề -> icon xoay theo trục Y đúng 1 vòng
      document.addEventListener('DOMContentLoaded', function () {
          document.querySelectorAll('.service-item').forEach(function (item) {
              const title = item.querySelector('.service-title');
              const img = item.querySelector('.service-icon img');
              if (!title || !img) return;

              title.addEventListener('mouseenter', function () {
                  img.classList.remove('spinY');
                  void img.offsetWidth;
                  img.classList.add('spinY');
              });

              img.addEventListener('animationend', function () {
                  img.classList.remove('spinY');
              });
          });
      });
  </script>
</form>
</body>
</html>