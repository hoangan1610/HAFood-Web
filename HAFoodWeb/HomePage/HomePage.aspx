<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="HomePage.aspx.cs"
    Inherits="HAFoodWeb.HomePage.HomePage" Async="true" %>

<%@ Register Src="~/Control/Header.ascx" TagPrefix="uc" TagName="Header" %>
<%@ Register Src="~/Control/SlideShow.ascx" TagPrefix="uc" TagName="Slideshow" %>
<%@ Register Src="~/Control/Footer.ascx" TagPrefix="uc" TagName="Footer" %>

<!DOCTYPE html>
<html lang="vi">
<head runat="server">
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>HAFood</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />

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
  </style>
</head>

<body>
<form runat="server">
  <asp:ScriptManager ID="sm" runat="server" />

  <!-- HEADER -->
  <uc:Header ID="Header1" runat="server" />

  <!-- SLIDESHOW -->
  <uc:Slideshow ID="Slideshow1" runat="server" />

  <!-- INTRO -->
  <div class="container text-center my-5">
    <h2 class="fw-semibold">Welcome to HAFood</h2>
    <p>Fresh food, delivered daily — from our farms to your table.</p>
  </div>

  <!-- FEATURED CATEGORIES -->
  <div class="container my-5">
    <h3 class="text-center fw-semibold mb-4">Danh Mục Nổi Bật</h3>
    <asp:Repeater ID="rpCategories" runat="server">
      <HeaderTemplate><div class="row gx-3"></HeaderTemplate>
      <ItemTemplate>
        <div class="col-6 col-md-4 col-lg-3 mb-4">
          <a href='<%# string.Format("{0}?category_id={1}", ResolveUrl("~/HomePage/Search"), Eval("Id")) %>' 
   class="text-decoration-none">

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
    <div class="d-flex align-items-center justify-content-between mb-3">
      <h3 class="fw-semibold m-0">Mới Về</h3>
      <a href="/category.aspx?sort=created_at:desc" class="text-decoration-none">Xem tất cả ›</a>
    </div>

    <div class="shelf">
      <asp:Repeater ID="rpNew" runat="server">
        <ItemTemplate>
          <div class="shelf-item">
            <div class="card product-card shadow-sm h-100">
              <div class="ratio ratio-4x3 bg-light position-relative">
                <img src="<%# Eval("ImageUrl") %>" loading="lazy"
                     class="w-100 h-100 of-contain p-2" alt="<%# Eval("Name") %>"
                     onerror="this.src='/images/product-default.png';" />
                <%# Eval("DiscountBadgeHtml") %>
                <span class="badge bg-success position-absolute top-0 start-0 m-2">Mới</span>
              </div>
              <div class="card-body d-flex flex-column">
                <h6 class="mb-1 text-truncate-2"><%# Eval("Name") %></h6>
                <div class="mb-2"><%# Eval("PriceRangeHtml") %></div>
                <select class="form-select form-select-sm mb-2">
                  <asp:Repeater ID="rpVar" runat="server" DataSource='<%# Eval("Variants") %>'>
                    <ItemTemplate><option value="<%# Eval("Id") %>"><%# Eval("Label") %></option></ItemTemplate>
                  </asp:Repeater>
                </select>
                <a class="btn btn-warning btn-sm mt-auto w-100" href='<%# Eval("Id", "/product.aspx?id={0}") %>'>Mua</a>
              </div>
            </div>
          </div>
        </ItemTemplate>
      </asp:Repeater>
    </div>
  </div>

  <!-- RECOMMENDED GRID -->
  <div class="container my-5">
    <h3 class="text-center fw-semibold mb-4" style="color:#ff6a00">Gợi Ý Cho Bạn Hôm Nay!</h3>

    <asp:Repeater ID="rpProducts" runat="server">
      <HeaderTemplate><div class="row gx-3 gy-4"></HeaderTemplate>
      <ItemTemplate>
        <div class="col-12 col-sm-6 col-lg-3">
          <div class="card product-card h-100 shadow-sm d-flex">
            <div class="position-relative">
              <div class="ratio ratio-4x3 bg-light">
                <img src="<%# Eval("ImageUrl") %>" loading="lazy"
                     class="w-100 h-100 of-contain p-2"
                     onerror="this.src='/images/product-default.png';"
                     alt="<%# Eval("Name") %>" />
              </div>
              <%# Eval("DiscountBadgeHtml") %>
            </div>

            <div class="card-body d-flex flex-column">
              <h6 class="card-title text-truncate-2 mb-2"><%# Eval("Name") %></h6>
              <div class="mb-2"><%# Eval("PriceRangeHtml") %></div>

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
                <a class="btn btn-warning btn-sm ms-auto" href='<%# Eval("Id", "/product.aspx?id={0}") %>'>Mua</a>
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

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</form>
</body>
</html>
