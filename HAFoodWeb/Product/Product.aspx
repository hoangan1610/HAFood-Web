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
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />

  <style>
    .product-title{font-weight:700;font-size:1.4rem}
    .price-now{color:#ff3b30;font-weight:700;font-size:1.25rem}
    .price-old{text-decoration:line-through;color:#888;margin-left:.5rem}
    .thumb{width:72px;height:72px;object-fit:contain;border:1px solid #eee;border-radius:.5rem;cursor:pointer}
    .thumb.active{outline:2px solid #2aa33b}
    .main-img{width:100%;height:420px;object-fit:contain;background:#f8f9fa;border:1px solid #eee;border-radius:.75rem}
    .of-contain{object-fit:contain}
    .text-truncate-2{display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden}
    .product-card{transition:transform .15s ease, box-shadow .15s ease}
    .product-card:hover{transform:translateY(-3px);box-shadow:0 .5rem 1rem rgba(0,0,0,.06)}
  </style>
</head>
<body>
<form runat="server">
  <asp:ScriptManager ID="sm" runat="server" />

  <uc:Header ID="Header1" runat="server" />

  <div class="container my-4">
    <!-- BREADCRUMB đơn giản -->
    <nav class="mb-3" aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><a href="/">Trang chủ</a></li>
        <li class="breadcrumb-item"><a href="/HomePage/Search">Sản phẩm</a></li>
        <li class="breadcrumb-item active" aria-current="page"><asp:Literal ID="litNameCrumb" runat="server" /></li>
      </ol>
    </nav>

    <div class="row g-4">
      <!-- LEFT: Gallery -->
      <div class="col-lg-5">
        <img id="imgMain" runat="server" class="main-img mb-3" alt="Ảnh sản phẩm"
             onerror="this.src='/images/product-default.png';" />
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
        <h1 class="product-title mb-2"><asp:Literal ID="litName" runat="server" /></h1>
        <div class="mb-2 text-muted">Thương hiệu: <strong><asp:Literal ID="litBrand" runat="server" /></strong></div>

        <div class="mb-3">
          <span class="price-now"><asp:Literal ID="litPrice" runat="server" /></span>
          <span id="oldPrice" runat="server" class="price-old d-none"></span>
        </div>

        <div class="row g-3 align-items-end">
          <div class="col-sm-6">
            <label class="form-label mb-1">Phân loại</label>
            <asp:DropDownList ID="ddlVariant" runat="server" CssClass="form-select form-select-sm"></asp:DropDownList>
          </div>
          <div class="col-sm-3">
            <label class="form-label mb-1">Số lượng</label>
            <input id="qty" type="number" class="form-control form-control-sm" value="1" min="1" />
          </div>
          <div class="col-sm-3 d-grid">
            <a id="btnBuy" class="btn btn-warning btn-sm">Mua ngay</a>
          </div>
        </div>

        <div class="mt-3 small text-muted">
          SKU: <span id="sku"><asp:Literal ID="litSku" runat="server" /></span> ·
          Tồn kho: <span id="stock"><asp:Literal ID="litStock" runat="server" /></span>
        </div>

        <hr class="my-4" />
        <div>
          <h5 class="mb-2">Mô tả</h5>
          <div class="lh-base"><asp:Literal ID="litDetail" runat="server" /></div>
        </div>
      </div>
    </div>

    <!-- Related / Gợi ý -->
    <div class="mt-5">
      <h4 class="fw-semibold mb-3">Gợi ý cho bạn</h4>
      <asp:Repeater ID="rpRelated" runat="server">
        <HeaderTemplate><div class="row gx-3 gy-4"></HeaderTemplate>
        <ItemTemplate>
          <div class="col-6 col-lg-3">
            <div class="card product-card h-100 shadow-sm d-flex">
              <div class="ratio ratio-4x3 bg-light">
                <img src="<%# Eval("ImageUrl") %>" class="w-100 h-100 of-contain p-2"
                     onerror="this.src='/images/product-default.png';" alt="<%# Eval("Name") %>" />
              </div>
              <div class="card-body d-flex flex-column">
                <h6 class="text-truncate-2 mb-2"><%# Eval("Name") %></h6>
                <div class="mb-2"><%# Eval("PriceRangeHtml") %></div>
                <a class="btn btn-outline-success btn-sm mt-auto" href='<%# Eval("Id", "/product.aspx?id={0}") %>'>Xem</a>
              </div>
            </div>
          </div>
        </ItemTemplate>
        <FooterTemplate></div></FooterTemplate>
      </asp:Repeater>
    </div>
  </div>

  <uc:Footer ID="Footer1" runat="server" />

  <asp:HiddenField ID="hVariantsJson" runat="server" />
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

  <script>
    // thumbnails click -> đổi ảnh chính
    document.addEventListener('click', function (e) {
      if (e.target && e.target.classList.contains('thumb')) {
        document.getElementById('<%= imgMain.ClientID %>').src = e.target.getAttribute('data-url');
        document.querySelectorAll('.thumb').forEach(x => x.classList.remove('active'));
        e.target.classList.add('active');
      }
    });

    // thay đổi biến thể -> cập nhật giá/SKU/stock/ảnh
    document.addEventListener('DOMContentLoaded', function () {
      const json = document.getElementById('<%= hVariantsJson.ClientID %>').value || '[]';
      const variants = JSON.parse(json);
      const ddl = document.getElementById('<%= ddlVariant.ClientID %>');
      const priceEl = document.getElementById('<%= litPrice.ClientID %>');
      const skuEl = document.getElementById('sku');
      const stockEl = document.getElementById('stock');
      const imgMain = document.getElementById('<%= imgMain.ClientID %>');

      function formatVnd(n){ try{ return n.toLocaleString('vi-VN') + 'đ'; }catch(e){ return n + 'đ'; } }

      function apply(v){
        if(!v) return;
        priceEl.innerText = formatVnd(v.retailPrice);
        skuEl.innerText = v.sku || '';
        stockEl.innerText = (v.stock ?? 0);
        if (v.image) imgMain.src = v.image;
      }

      ddl && ddl.addEventListener('change', function(){
        const id = Number(this.value);
        const v = variants.find(x => x.id === id);
        apply(v);
      });

      // áp dụng cho biến thể ban đầu (nếu có)
      if (ddl && ddl.value) {
        const v0 = variants.find(x => x.id === Number(ddl.value));
        apply(v0);
      }
    });
  </script>
</form>
</body>
</html>
