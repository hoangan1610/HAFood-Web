<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Search.aspx.cs"
    Inherits="HAFoodWeb.Search" Async="true" %>

<%@ Register Src="~/Control/Header.ascx" TagPrefix="uc" TagName="Header" %>
<%@ Register Src="~/Control/Footer.ascx" TagPrefix="uc" TagName="Footer" %>

<!DOCTYPE html>
<html lang="vi">
<head runat="server">
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>Tìm kiếm sản phẩm - HAFood</title>

  <!-- ✅ bỏ preconnect localhost (prod user không có localhost) -->
  <link rel="preconnect" href="https://cdn.hafood.id.vn" crossorigin="anonymous" />

  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600&display=swap" rel="stylesheet" />

  <style>
    :root{
      --card-radius: 1rem;
      --soft-shadow: 0 10px 30px rgba(0,0,0,.08);
      --brand: #ffc107;
      --brand-hover:#e0ac05;
      --price:#ff3b30;
      --border-subtle:#e9ecef;
      --bg-soft:#f8f9fb;
    }

    *{ box-sizing:border-box; }

    body{
      margin:0;
      background:#fff6e9;
      font-family:'Poppins', system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
      color:#212529;
    }

    .of-contain{object-fit:contain}
    .text-truncate-2{
      display:-webkit-box;
      -webkit-line-clamp:2;
      -webkit-box-orient:vertical;
      overflow:hidden;
    }
    .text-truncate-1{white-space:nowrap;overflow:hidden;text-overflow:ellipsis}

    .search-shell{
      border-radius:1.25rem;
      background:#ffffff;
      box-shadow:0 18px 45px rgba(0,0,0,.10);
      padding:1.25rem 1.25rem 1.5rem;
      margin-top:1.5rem;
      margin-bottom:2rem;
      position:relative;
      overflow:hidden;
    }

    .search-header{
      position:relative;
      z-index:1;
      margin-bottom:.75rem;
      padding-bottom:.5rem;
      border-bottom:1px dashed #f1f3f5;
    }
    .search-title{
      font-size:1.35rem;
      font-weight:600;
      display:flex;
      align-items:center;
      gap:.5rem;
    }
    .search-pill{
      display:inline-flex;
      align-items:center;
      gap:.35rem;
      padding:.25rem .6rem;
      border-radius:999px;
      font-size:.82rem;
      background:#fff3e8;
      color:#ff6600;
      border:1px solid rgba(255,102,0,.18);
    }
    .search-subtitle{
      font-size:.9rem;
      color:#6c757d;
      margin-top:.25rem;
    }

    .result-toolbar{
      position:sticky;
      top:0;
      z-index:40;
      background:rgba(255,255,255,.96);
      border-radius:.85rem;
      border:1px solid #f1f3f5;
      padding:.55rem .9rem;
      box-shadow:0 8px 20px rgba(0,0,0,.06);
      backdrop-filter:blur(6px);
      margin-bottom:1rem;
    }

    .sort-group{
      display:flex;
      align-items:center;
      gap:.5rem;
      white-space:nowrap;
    }
    .sort-label{ white-space:nowrap; }

    .product-card{
      border:0;
      border-radius:var(--card-radius);
      overflow:hidden;
      background:#ffffff;
      box-shadow:var(--soft-shadow);
      height:100%;
      transition:transform .18s ease, box-shadow .18s ease, border-color .18s ease;
      border:1px solid rgba(0,0,0,.02);
      position:relative;
    }
    .product-card:hover{
      transform:translateY(-3px);
      box-shadow:0 16px 36px rgba(0,0,0,.14);
    }
    .product-card .card-body{ padding:.75rem .9rem .95rem; }
    .product-card h6{ margin-bottom:.35rem; line-height:1.35; font-size:.95rem; font-weight:600; }

    .product-thumb{
      background:#ffffff;
      border-bottom:1px solid #f1f3f5;
    }
    .product-thumb img{ padding:.6rem; }

    .badge-soft{
      display:inline-flex; align-items:center; gap:.25rem;
      padding:.15rem .5rem; border-radius:999px; font-size:.7rem;
      background:#f1f3f5; color:#6c757d;
    }

    .price-now{ color:var(--price); font-weight:800; letter-spacing:.2px; display:inline-block; margin-bottom:.1rem; font-size:.95rem; }
    .product-meta{ font-size:.78rem; color:#868e96; }

    .suggest-box{
      position:absolute; z-index:100; background:#fff; border:1px solid #ddd;
      border-radius:.75rem; overflow:hidden; max-height:260px; overflow:auto;
      box-shadow:0 12px 28px rgba(0,0,0,.12);
    }
    .suggest-item{ padding:.5rem .75rem; cursor:pointer; font-size:.9rem; }
    .suggest-item:hover{ background:#f8f9fa; }

    .cat-card{ border-radius:1rem; box-shadow:var(--soft-shadow); border:0; background:#ffffff; }
    .cat-card .card-header{ background:#fff7ec; border-bottom:1px solid #ffe1c2; border-radius:1rem 1rem 0 0 !important; padding:.7rem .95rem; }
    .cat-card .card-header h5{ margin:0; font-size:1rem; font-weight:600; color:#e66000; }
    .cat-card .card-body{ padding:.85rem .95rem 1rem; font-size:.9rem; }

    .filter-section-title{ font-size:.9rem; font-weight:600; color:#343a40; margin-bottom:.5rem; margin-top:.75rem; }
    .cat-node{margin:.3rem 0}
    .cat-children{margin-left:.75rem;border-left:1px dashed #eee;padding-left:.5rem}
    .cat-toggle{cursor:pointer;user-select:none}

    /* ✅ Highlight danh mục đang chọn */
    .cat-link{
      color:#212529;
      text-decoration:none;
      display:inline-flex;
      align-items:center;
      gap:.35rem;
      padding:.18rem .35rem;
      border-radius:.6rem;
    }
    .cat-link:hover{ background:#f8f9fa; }
    .cat-link.is-active{
      background:#fff3e8;
      color:#e66000;
      font-weight:600;
      border:1px solid rgba(255,102,0,.18);
    }

    .chip{
      display:inline-flex; align-items:center; gap:.35rem; padding:.3rem .7rem;
      border-radius:2rem; background:#fff7ec; border:1px solid rgba(255,102,0,.2);
      font-size:.82rem; color:#e66000;
    }
    .chip .x{ cursor:pointer; opacity:.75; font-size:.9rem; }
    .chip .x:hover{ opacity:1; }

    .form-control{ border-radius:.75rem; border-color:#dee2e6; font-size:.9rem; }
    .form-control:focus{ border-color:var(--brand); box-shadow:0 0 0 .16rem rgba(255,193,7,.25); }

    .qty{ width:72px; height:36px; text-align:center; border-radius:999px; font-size:.85rem; }
    .btn-buy{ height:36px; border-radius:.9rem; font-weight:600; font-size:.82rem; padding-inline:1rem; }

    .btn-warning{
      background-color:#ffc107 !important;
      border-color:#ffc107 !important;
      color:#212529 !important;
      border-radius:999px !important;
      font-weight:600 !important;
      box-shadow:none !important;
    }
    .btn-warning:hover,
    .btn-warning:active,
    .btn-warning:focus{
      background-color:#e0ac05 !important;
      border-color:#e0ac05 !important;
      color:#212529 !important;
      box-shadow:none !important;
    }

    .btn-clear{ --bs-btn-padding-y:.35rem; --bs-btn-padding-x:.9rem; --bs-btn-border-radius:2rem; font-size:.8rem; }
    .btn-outline-secondary{ border-radius:999px; }

    #active-filters{ position:relative; z-index:1; }

    .pager-wrap{
      display:inline-flex;
      align-items:center;
      padding:.35rem .45rem;
      border-radius:999px;
      border:1px solid #f1f3f5;
      background:rgba(255,255,255,.96);
      box-shadow:0 10px 24px rgba(0,0,0,.06);
    }
    .pager-wrap .pagination{ margin:0; gap:.2rem; }
    .pagination .page-link{
      border-radius:999px !important;
      border-color:#edf2f7;
      color:#6c757d;
      font-weight:600;
      min-width:40px;
      text-align:center;
      padding:.35rem .7rem;
    }
    .pagination .page-link:hover{
      background:#fff3cd;
      border-color:#ffe08a;
      color:#212529;
    }
    .pagination .page-item.active .page-link{
      background:#ffc107;
      border-color:#ffc107;
      color:#212529;
      box-shadow:0 8px 18px rgba(255,193,7,.22);
    }
    .pagination .page-item.disabled .page-link{
      opacity:.55;
      pointer-events:none;
      background:#fff;
    }

    .offcanvas{ border-radius:1.5rem 1.5rem 0 0; }
    .offcanvas-title{ font-weight:600; }

    /* ===== Dropdown giống hình (✓ + divider sát chữ + bo tròn nhẹ) ===== */
    .ui-dd-btn{
      height:36px;
      border-radius:999px;
      padding:.35rem .9rem;
      border:1px solid #dee2e6;
      background:#fff;
      font-size:.82rem;
      font-weight:500;
    }
    .ui-dd-btn:focus{
      border-color:var(--brand);
      box-shadow:0 0 0 .16rem rgba(255,193,7,.25);
    }
    .ui-dd-menu{
      min-width:200px;
      padding:.25rem 0;
      border-radius:.75rem;
      border:1px solid #e9ecef;
      box-shadow:0 12px 28px rgba(0,0,0,.12);
      overflow:hidden;
    }
    .ui-dd-item{
      padding:.38rem 1rem;
      display:flex;
      align-items:center;
      gap:.55rem;
      font-size:1rem;
      background:#fff;
    }
    .ui-dd-item:hover{ background:#f8f9fa; }
    .ui-dd-item .dd-check{
      width:18px;
      display:inline-flex;
      justify-content:center;
      color:#212529;
    }
    .ui-dd-divider{
      margin:.10rem 0;
      opacity:.5;
    }

    /* Loading khi AJAX */
    #resultsRoot.is-loading{
      opacity:.6;
      pointer-events:none;
      filter:saturate(.9);
    }

    @media (max-width: 991.98px){
      .sidebar-col{ display:none; }
      .search-shell{ box-shadow:none; padding-inline:0; background:transparent; }
      .result-toolbar{ border-radius:.9rem; }
    }
    @media (max-width: 575.98px){
      .search-title{ font-size:1.1rem; }
      .search-shell{ margin-top:.75rem; }
      .pagination .page-link{ min-width:36px; padding:.3rem .55rem; }
    }
  </style>
</head>
<body>
<form id="form1" runat="server">
  <asp:ScriptManager ID="sm" runat="server" />
  <uc:Header ID="Header1" runat="server" />

  <div class="container py-3">
    <div class="search-shell">

      <div class="search-header d-flex flex-wrap align-items-center justify-content-between gap-2">
        <div>
          <div class="search-title">
            Tìm kiếm sản phẩm
            <span class="search-pill">
              <span>🔍</span>
              <span>
                <%
                  var q = Request["q"];
                  if (!string.IsNullOrWhiteSpace(q))
                  {
                      Response.Write(Server.HtmlEncode(q));
                  }
                  else
                  {
                      Response.Write("Tất cả sản phẩm");
                  }
                %>
              </span>
            </span>
          </div>
          <div class="search-subtitle">
            Kết quả được cập nhật theo bộ lọc và sắp xếp bạn đã chọn.
          </div>
        </div>
        <div class="text-end small text-muted">
          <span>Kết quả: </span>
          <strong id="totalText"><asp:Literal ID="ltTotal" runat="server" /></strong>
        </div>
      </div>

      <div class="result-toolbar mb-3">
        <div class="d-flex align-items-center gap-2 flex-wrap">
          <div class="me-auto small text-muted">
            Điều chỉnh bộ lọc &amp; sắp xếp để tìm sản phẩm phù hợp với bạn.
          </div>

          <button type="button" class="btn btn-outline-secondary d-lg-none btn-sm"
                  data-bs-toggle="offcanvas" data-bs-target="#offcanvasFilters"
                  aria-controls="offcanvasFilters">
            Bộ lọc
          </button>

          <!-- Sort dropdown (custom) -->
          <div class="sort-group">
            <label class="small text-muted sort-label d-none d-sm-inline">Sắp xếp</label>

            <input type="hidden" id="sortVal" value="" />

            <div class="dropdown">
              <button id="sortMenuBtn" class="ui-dd-btn dropdown-toggle" type="button"
                      data-bs-toggle="dropdown" aria-expanded="false">
                Sắp xếp
              </button>

              <ul id="sortMenu" class="dropdown-menu ui-dd-menu" aria-labelledby="sortMenuBtn">
                <li>
                  <button type="button" class="dropdown-item ui-dd-item" data-value="updated_at:desc">
                    <span class="dd-check"></span><span class="dd-label">Mới nhất</span>
                  </button>
                </li>
                <li><hr class="dropdown-divider ui-dd-divider"></li>

                <li>
                  <button type="button" class="dropdown-item ui-dd-item" data-value="price:asc">
                    <span class="dd-check"></span><span class="dd-label">Giá thấp đến cao</span>
                  </button>
                </li>
                <li><hr class="dropdown-divider ui-dd-divider"></li>

                <li>
                  <button type="button" class="dropdown-item ui-dd-item" data-value="price:desc">
                    <span class="dd-check"></span><span class="dd-label">Giá cao đến thấp</span>
                  </button>
                </li>
                <li><hr class="dropdown-divider ui-dd-divider"></li>

                <li>
                  <button type="button" class="dropdown-item ui-dd-item" data-value="name:asc">
                    <span class="dd-check"></span><span class="dd-label">Tên A–Z</span>
                  </button>
                </li>
                <li><hr class="dropdown-divider ui-dd-divider"></li>

                <li>
                  <button type="button" class="dropdown-item ui-dd-item" data-value="name:desc">
                    <span class="dd-check"></span><span class="dd-label">Tên Z–A</span>
                  </button>
                </li>
              </ul>
            </div>
          </div>

          <!-- Grid/PageSize dropdown (custom) -->
          <div class="sort-group">
            <label class="small text-muted sort-label d-none d-sm-inline">Lọc lưới</label>

            <input type="hidden" id="pageSizeVal" value="" />

            <div class="dropdown">
              <button id="gridMenuBtn" class="ui-dd-btn dropdown-toggle" type="button"
                      data-bs-toggle="dropdown" aria-expanded="false">
                Lưới
              </button>

              <ul id="gridMenu" class="dropdown-menu ui-dd-menu" aria-labelledby="gridMenuBtn">
                <li>
                  <button type="button" class="dropdown-item ui-dd-item" data-value="">
                    <span class="dd-check"></span><span class="dd-label">Mặc định </span>
                  </button>
                </li>
                <li><hr class="dropdown-divider ui-dd-divider"></li>

                <li>
                  <button type="button" class="dropdown-item ui-dd-item" data-value="3">
                    <span class="dd-check"></span><span class="dd-label">3 sản phẩm</span>
                  </button>
                </li>
                <li><hr class="dropdown-divider ui-dd-divider"></li>

                <li>
                  <button type="button" class="dropdown-item ui-dd-item" data-value="6">
                    <span class="dd-check"></span><span class="dd-label">6 sản phẩm</span>
                  </button>
                </li>
                <li><hr class="dropdown-divider ui-dd-divider"></li>

                <li>
                  <button type="button" class="dropdown-item ui-dd-item" data-value="9">
                    <span class="dd-check"></span><span class="dd-label">9 sản phẩm</span>
                  </button>
                </li>
              </ul>
            </div>
          </div>

        </div>
      </div>

      <div id="active-filters" class="d-flex flex-wrap gap-2 mb-3" aria-live="polite"></div>

      <div class="row g-3">
        <div class="col-lg-3 sidebar-col">
          <div class="card cat-card">
            <div class="card-header">
              <h5>Danh mục &amp; bộ lọc</h5>
            </div>
            <div class="card-body">

              <div class="mb-3">
                <div class="filter-section-title">Danh mục</div>

                <!-- ✅ wrapper để AJAX có thể replace cả tree -->
                <div id="catTreeRoot">
                  <asp:Literal ID="ltCategoryTree" runat="server" />
                </div>
              </div>

              <div class="filter-section-title">Bộ lọc chi tiết</div>

              <div class="mb-3 position-relative">
                <label class="form-label">Từ khóa</label>
                <input id="txtQ" name="q" type="text" class="form-control" autocomplete="off"
                       aria-label="Từ khóa" value="<%= Server.HtmlEncode(Request["q"] ?? "") %>" />
                <div id="suggest" class="suggest-box d-none w-100" role="listbox" aria-live="polite"></div>
              </div>

              <div class="mb-3">
                <label class="form-label">Thương hiệu</label>
                <input name="brand" type="text" class="form-control" aria-label="Thương hiệu"
                       value="<%= Server.HtmlEncode(Request["brand"] ?? "") %>" />
              </div>

              <div class="mb-3">
                <label class="form-label d-block">Khoảng giá (đ)</label>
                <div class="small text-muted d-flex justify-content-between">
                  <span id="priceMinLabel">₫10.000</span><span id="priceMaxLabel">₫1.000.000</span>
                </div>
                <div class="d-flex gap-2 align-items-center mt-2">
                  <input id="rangeMin" type="range" min="10000" max="1000000" step="1000" class="form-range" aria-label="Giá tối thiểu" />
                  <input id="rangeMax" type="range" min="10000" max="1000000" step="1000" class="form-range" aria-label="Giá tối đa" />
                </div>
                <div class="d-flex gap-2 mt-2">
                  <input id="minPriceInput" type="number" class="form-control form-control-sm" placeholder="Từ" min="10000" max="1000000" step="1000">
                  <input id="maxPriceInput" type="number" class="form-control form-control-sm" placeholder="Đến" min="10000" max="1000000" step="1000">
                </div>
                <input id="minPrice" name="min_price" type="hidden" value="<%= Server.HtmlEncode(Request["min_price"] ?? "") %>" />
                <input id="maxPrice" name="max_price" type="hidden" value="<%= Server.HtmlEncode(Request["max_price"] ?? "") %>" />
              </div>

              <div class="mb-3">
                <label class="form-label d-block">Trọng lượng</label>
                <div class="form-check"><input class="form-check-input" type="checkbox" name="w_100_250" id="w1" <%= Request["w_100_250"]=="on"?"checked":"" %> /><label class="form-check-label" for="w1">100–250g</label></div>
                <div class="form-check"><input class="form-check-input" type="checkbox" name="w_250_500" id="w2" <%= Request["w_250_500"]=="on"?"checked":"" %> /><label class="form-check-label" for="w2">250–500g</label></div>
                <div class="form-check"><input class="form-check-input" type="checkbox" name="w_500_1000" id="w3" <%= Request["w_500_1000"]=="on"?"checked":"" %> /><label class="form-check-label" for="w3">500g–1kg</label></div>
                <div class="form-check"><input class="form-check-input" type="checkbox" name="w_1000_5000" id="w4" <%= Request["w_1000_5000"]=="on"?"checked":"" %> /><label class="form-check-label" for="w4">1kg–5kg</label></div>
                <div class="form-check"><input class="form-check-input" type="checkbox" name="w_5000" id="w5" <%= Request["w_5000"]=="on"?"checked":"" %> /><label class="form-check-label" for="w5">Trên 5kg</label></div>
              </div>

              <div class="form-check mb-3">
                <input class="form-check-input" type="checkbox" id="inStock" name="only_in_stock"
                       <%= (Request["only_in_stock"]=="true") ? "checked" : "" %> />
                <label class="form-check-label" for="inStock">Chỉ còn hàng</label>
              </div>

              <!-- ✅ thêm id để AJAX sync theo URL -->
              <input type="hidden" id="categoryIdHidden" name="category_id" value="<%= Server.HtmlEncode(Request["category_id"] ?? "") %>" />

              <div class="d-flex gap-2 mt-3">
                <button type="button" class="btn btn-outline-secondary btn-clear" id="btnClearAll">Xóa tất cả</button>
                <button type="button" class="btn btn-warning ms-auto" onclick="applyFilters(1)">Áp dụng</button>
              </div>
            </div>
          </div>
        </div>

        <div class="col-lg-9">
          <div id="resultsRoot">
            <asp:Repeater ID="rpProducts" runat="server">
              <HeaderTemplate><div class="row g-3"></HeaderTemplate>
              <ItemTemplate>
                <div class="col-6 col-md-4">
                  <div class="product-card d-flex flex-column">
                    <div class="position-relative">
                     <a href='<%# ResolveUrl("~/Product/Product.aspx?id=" + Eval("Id")) %>' class="ratio ratio-1x1 product-thumb d-block">
  <%-- chống loop nếu default cũng lỗi: KHÔNG đặt <!-- --> trong thẻ img --%>
  <img
    src="<%# Eval("ImageUrl") %>"
    srcset="<%# Eval("ImageUrl") %>?w=240 240w, <%# Eval("ImageUrl") %>?w=480 480w, <%# Eval("ImageUrl") %>?w=720 720w"
    sizes="(max-width: 576px) 48vw, (max-width: 992px) 32vw, 240px"
    class="w-100 h-100 of-contain"
    loading="lazy"
    decoding="async"
    fetchpriority="low"
    onerror="this.onerror=null;this.src='/images/product-default.png';"
    alt="<%# Eval("Name") %>" />
</a>

                    </div>

                    <div class="card-body d-flex flex-column">
                      <h6 class="text-truncate-2">
                        <a class="text-decoration-none text-dark" href='<%# ResolveUrl("~/Product/Product.aspx?id=" + Eval("Id")) %>'>
                          <%# Eval("Name") %>
                        </a>
                      </h6>

                      <div class="price-now"><%# Eval("PriceRangeHtml") %></div>

                      <div class="product-meta mb-1">
                        <span class="badge-soft">HAFood</span>
                      </div>

                      <div class="mb-2">
                        <select class="form-select form-select-sm">
                          <asp:Repeater ID="rpVar" runat="server" DataSource='<%# Eval("Variants") %>'>
                            <ItemTemplate>
                              <option value="<%# Eval("Id") %>"><%# Eval("Label") %></option>
                            </ItemTemplate>
                          </asp:Repeater>
                        </select>
                      </div>

                      <div class="d-flex align-items-center gap-2 mt-auto">
                        <input type="number" class="form-control form-control-sm qty" value="1" min="1" aria-label="Số lượng" />
                        <a class="btn btn-warning btn-sm btn-buy ms-auto" href='<%# ResolveUrl("~/Product/Product.aspx?id=" + Eval("Id")) %>'>Mua</a>
                      </div>
                    </div>
                  </div>
                </div>
              </ItemTemplate>
              <FooterTemplate></div></FooterTemplate>
            </asp:Repeater>

            <asp:Literal ID="ltEmpty" runat="server" />

            <div class="d-flex justify-content-center mt-4">
              <nav aria-label="page" class="pager-wrap">
                <ul class="pagination pagination-sm">
                  <asp:Literal ID="ltPager" runat="server" />
                </ul>
              </nav>
            </div>
          </div>
        </div>

      </div>
    </div>
  </div>

  <div class="offcanvas offcanvas-bottom" tabindex="-1" id="offcanvasFilters" aria-labelledby="offcanvasFiltersLabel" style="height:80vh;">
    <div class="offcanvas-header">
      <h5 class="offcanvas-title" id="offcanvasFiltersLabel">Bộ lọc sản phẩm</h5>
      <button type="button" class="btn-close" data-bs-dismiss="offcanvas" aria-label="Close"></button>
    </div>
    <div class="offcanvas-body">
      <div class="mb-3 position-relative">
        <label class="form-label">Từ khóa</label>
        <input id="m_q" type="text" class="form-control" autocomplete="off" />
      </div>

      <div class="mb-3">
        <label class="form-label">Thương hiệu</label>
        <input id="m_brand" type="text" class="form-control" />
      </div>

      <div class="mb-3">
        <label class="form-label">Sắp xếp</label>
        <select id="m_sort" class="form-select">
          <option value="updated_at:desc">Mới nhất</option>
          <option value="price:asc">Giá tăng dần</option>
          <option value="price:desc">Giá giảm dần</option>
          <option value="name:asc">Tên A–Z</option>
          <option value="name:desc">Tên Z–A</option>
        </select>
      </div>

      <div class="mb-3">
        <label class="form-label">Lưới (số sản phẩm/trang)</label>
        <select id="m_pageSize" class="form-select">
          <option value="">Mặc định (20/sp)</option>
          <option value="3">3 sản phẩm/trang</option>
          <option value="6">6 sản phẩm/trang</option>
          <option value="9">9 sản phẩm/trang</option>
        </select>
      </div>

      <div class="mb-3">
        <label class="form-label d-block">Khoảng giá (đ)</label>
        <div class="d-flex gap-2">
          <input id="m_min" type="number" class="form-control" placeholder="Từ" min="10000" max="1000000" step="1000">
          <input id="m_max" type="number" class="form-control" placeholder="Đến" min="10000" max="1000000" step="1000">
        </div>
      </div>

      <div class="mb-3">
        <label class="form-label d-block">Trọng lượng</label>
        <div class="form-check"><input class="form-check-input" type="checkbox" id="m_w1"><label class="form-check-label" for="m_w1">100–250g</label></div>
        <div class="form-check"><input class="form-check-input" type="checkbox" id="m_w2"><label class="form-check-label" for="m_w2">250–500g</label></div>
        <div class="form-check"><input class="form-check-input" type="checkbox" id="m_w3"><label class="form-check-label" for="m_w3">500g–1kg</label></div>
        <div class="form-check"><input class="form-check-input" type="checkbox" id="m_w4"><label class="form-check-label" for="m_w4">1kg–5kg</label></div>
        <div class="form-check"><input class="form-check-input" type="checkbox" id="m_w5"><label class="form-check-label" for="m_w5">Trên 5kg</label></div>
      </div>

      <div class="form-check mb-3">
        <input class="form-check-input" type="checkbox" id="m_inStock" />
        <label class="form-check-label" for="m_inStock">Chỉ còn hàng</label>
      </div>

      <div class="d-flex gap-2">
        <button type="button" class="btn btn-outline-secondary" onclick="resetMobileFilters()">Xoá</button>
        <button type="button" class="btn btn-warning ms-auto" onclick="applyMobileFilters()">Áp dụng</button>
      </div>
    </div>
  </div>

  <uc:Footer ID="Footer1" runat="server" />

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
 <script>
     (function () {
         var url = new URL(window.location.href);
         var p = url.searchParams;
         if (p.has('catId') && !p.has('category_id')) {
             p.set('category_id', p.get('catId'));
             p.delete('catId');
             window.location.replace(url.pathname + '?' + p.toString());
         }
     })();

     /* ===== Utils ===== */
     const debounce = (fn, ms) => {
         let t;
         return (...args) => { clearTimeout(t); t = setTimeout(() => fn.apply(this, args), ms); };
     };

     // ✅ Suggest dùng Proxy (không gọi thẳng API public)
     const suggestUrl = '<%= ResolveUrl("~/Proxy/Suggest.ashx") %>';

     /* ===== Suggest (desktop) - Proxy + anti-XSS + Abort ===== */
     const box = document.getElementById('suggest');
     const input = document.getElementById('txtQ');

     function clearSuggest() {
         if (!box) return;
         box.classList.add('d-none');
         box.innerHTML = '';
     }

     function renderSuggest(items) {
         if (!box) return;
         if (!items || !items.length) { clearSuggest(); return; }

         box.innerHTML = '';
         const frag = document.createDocumentFragment();

         items.forEach((s) => {
             const div = document.createElement('div');
             div.className = 'suggest-item';
             div.setAttribute('role', 'option');

             // ✅ chống XSS: không innerHTML
             const val = (s ?? '').toString();
             div.textContent = val;
             div.dataset.v = val;

             div.addEventListener('click', () => {
                 if (input) input.value = div.dataset.v || '';
                 clearSuggest();
                 applyFilters(1);
             });

             frag.appendChild(div);
         });

         box.appendChild(frag);
         box.classList.remove('d-none');
     }

     let suggestAbort = null;

     const doSuggest = debounce(async () => {
         const q = input?.value?.trim() || '';
         if (q.length < 2) { clearSuggest(); return; }

         try {
             if (suggestAbort) suggestAbort.abort();
             suggestAbort = new AbortController();

             const r = await fetch(`${suggestUrl}?q=${encodeURIComponent(q)}`, {
                 headers: { accept: 'application/json' },
                 signal: suggestAbort.signal
             });

             const d = await r.json();
             renderSuggest(d.items || []);
         } catch (e) {
             // ignore abort; fallback empty
             clearSuggest();
         }
     }, 250);

     input?.addEventListener('input', doSuggest);
     input?.addEventListener('keydown', (e) => {
         if (e.key === 'Enter') { e.preventDefault(); clearSuggest(); applyFilters(1); }
         if (e.key === 'Escape') { clearSuggest(); }
     });

     document.addEventListener('click', (e) => {
         if (!box) return;
         if (!box.contains(e.target) && e.target !== input) clearSuggest();
     });

     /* ===== Price dual range + inputs ===== */
     const fmtVnd = n => '₫' + (+n || 0).toLocaleString('vi-VN');
     const minEl = document.getElementById('rangeMin'),
         maxEl = document.getElementById('rangeMax');
     const hMin = document.getElementById('minPrice'),
         hMax = document.getElementById('maxPrice');
     const inMin = document.getElementById('minPriceInput'),
         inMax = document.getElementById('maxPriceInput');
     const lblMin = document.getElementById('priceMinLabel'),
         lblMax = document.getElementById('priceMaxLabel');

     function applyPriceFromUrl() {
         const qs = new URLSearchParams(location.search);
         const m = +(qs.get('min_price') || 10000);
         const x = +(qs.get('max_price') || 1000000);
         if (minEl) minEl.value = m;
         if (maxEl) maxEl.value = x;
         if (hMin) hMin.value = m;
         if (hMax) hMax.value = x;
         if (inMin) inMin.value = m;
         if (inMax) inMax.value = x;
         if (lblMin) lblMin.textContent = fmtVnd(m);
         if (lblMax) lblMax.textContent = fmtVnd(x);
     }

     (function initPrice() {
         [minEl, maxEl].forEach(el => el && (el.min = 10000, el.max = 1000000, el.step = 1000));
         applyPriceFromUrl();
     })();

     function syncRange() {
         if (!minEl || !maxEl || !hMin || !hMax) return;

         let a = +minEl.value, b = +maxEl.value;
         if (a > b) { const t = a; a = b; b = t; minEl.value = a; maxEl.value = b; }

         hMin.value = a;
         hMax.value = b;

         if (inMin) inMin.value = a;
         if (inMax) inMax.value = b;
         if (lblMin) lblMin.textContent = fmtVnd(a);
         if (lblMax) lblMax.textContent = fmtVnd(b);
     }
     minEl?.addEventListener('input', syncRange);
     maxEl?.addEventListener('input', syncRange);
     inMin?.addEventListener('input', () => { const v = +inMin.value || 10000; if (minEl) minEl.value = v; syncRange(); });
     inMax?.addEventListener('input', () => { const v = +inMax.value || 1000000; if (maxEl) maxEl.value = v; syncRange(); });

     /* ===== Category toggle ===== */
     document.addEventListener('click', function (e) {
         const t = e.target.closest('[data-toggle-cat]');
         if (!t) return;
         const id = t.getAttribute('data-toggle-cat');
         const sub = document.getElementById('cat-children-' + id);
         if (sub) sub.classList.toggle('d-none');
     });

     /* ===== Helpers ===== */
     function readVal(sel) { const el = document.querySelector(sel); return el ? (el.value || '').trim() : ''; }
     function isCheckedByName(name) { const el = document.querySelector(`[name="${name}"]`); return !!(el && el.checked); }

     function buildSearchParamsFromUI() {
         const p = new URLSearchParams();

         const q = readVal('#txtQ'); if (q) p.set('q', q);
         const brand = readVal('[name="brand"]'); if (brand) p.set('brand', brand);

         const min = readVal('#minPrice') || readVal('[name="min_price"]');
         const max = readVal('#maxPrice') || readVal('[name="max_price"]');
         if (min) p.set('min_price', min);
         if (max) p.set('max_price', max);

         if (document.getElementById('inStock')?.checked) p.set('only_in_stock', 'true');

         const cat = readVal('#categoryIdHidden'); if (cat) p.set('category_id', cat);

         const sort = (document.getElementById('sortVal')?.value || '').trim();
         if (sort) p.set('sort', sort);

         const ps = (document.getElementById('pageSizeVal')?.value || '').trim();
         if (ps) p.set('page_size', ps);
         else p.delete('page_size');

         ['w_100_250', 'w_250_500', 'w_500_1000', 'w_1000_5000', 'w_5000']
             .forEach(n => { if (isCheckedByName(n)) p.set(n, 'on'); });

         return p;
     }

     function setDropdownUI(menuId, btnId, value) {
         const menu = document.getElementById(menuId);
         const btn = document.getElementById(btnId);
         if (!menu || !btn) return;

         const items = Array.from(menu.querySelectorAll('.ui-dd-item'));
         items.forEach(it => {
             const v = (it.dataset.value ?? '');
             const selected = v === (value ?? '');
             const check = it.querySelector('.dd-check');
             if (check) check.textContent = selected ? '✓' : '';
         });

         const active = items.find(it => (it.dataset.value ?? '') === (value ?? ''));
         if (active) {
             const label = active.querySelector('.dd-label')?.textContent?.trim() || '';
             btn.textContent = label || btn.textContent;
         }
     }

     function syncToolbarFromUrl() {
         const qs = new URLSearchParams(location.search);
         const sort = qs.get('sort') || 'updated_at:desc';
         const ps = qs.get('page_size') || '';

         const sortVal = document.getElementById('sortVal');
         const psVal = document.getElementById('pageSizeVal');
         if (sortVal) sortVal.value = sort;
         if (psVal) psVal.value = ps;

         setDropdownUI('sortMenu', 'sortMenuBtn', sort);
         setDropdownUI('gridMenu', 'gridMenuBtn', ps);
     }

     /* ✅ Sync sidebar inputs theo URL */
     function syncSidebarFromUrl() {
         const qs = new URLSearchParams(location.search);

         const cat = qs.get('category_id') || '';
         const catHidden = document.getElementById('categoryIdHidden');
         if (catHidden) catHidden.value = cat;

         const q = qs.get('q') || '';
         const txtQ = document.getElementById('txtQ');
         if (txtQ && document.activeElement !== txtQ) txtQ.value = q;

         const brand = qs.get('brand') || '';
         const brandEl = document.querySelector('[name="brand"]');
         if (brandEl && document.activeElement !== brandEl) brandEl.value = brand;

         const inStock = qs.get('only_in_stock') === 'true';
         const inStockEl = document.getElementById('inStock');
         if (inStockEl) inStockEl.checked = inStock;

         const setChk = (name, key) => {
             const el = document.querySelector(`[name="${name}"]`);
             if (el) el.checked = qs.has(key);
         };
         setChk('w_100_250', 'w_100_250');
         setChk('w_250_500', 'w_250_500');
         setChk('w_500_1000', 'w_500_1000');
         setChk('w_1000_5000', 'w_1000_5000');
         setChk('w_5000', 'w_5000');

         applyPriceFromUrl();
         syncRange();
     }

     async function ajaxNavigate(url, pushState = true) {
         const root = document.getElementById('resultsRoot');
         if (!root) { location.href = url; return; }

         root.classList.add('is-loading');
         try {
             const r = await fetch(url, { headers: { 'X-Requested-With': 'fetch' } });
             const html = await r.text();

             const doc = new DOMParser().parseFromString(html, 'text/html');

             const newRoot = doc.getElementById('resultsRoot');
             const newTotal = doc.getElementById('totalText');

             if (newRoot) root.innerHTML = newRoot.innerHTML;
             if (newTotal && document.getElementById('totalText')) {
                 document.getElementById('totalText').innerHTML = newTotal.innerHTML;
             }

             /* ✅ replace category tree để highlight đúng + lấy name đúng */
             const curTree = document.getElementById('catTreeRoot');
             const newTree = doc.getElementById('catTreeRoot');
             if (curTree && newTree) curTree.innerHTML = newTree.innerHTML;

             if (pushState) history.pushState(null, '', url);

             syncSidebarFromUrl();
             renderActiveChips();
             syncToolbarFromUrl();
         } catch (err) {
             console.error(err);
             location.href = url;
         } finally {
             root.classList.remove('is-loading');
         }
     }

     function applyFilters(page) {
         const p = buildSearchParamsFromUI();
         p.set('page', page || 1);
         const url = location.pathname + '?' + p.toString();
         ajaxNavigate(url, true);
     }
     window.applyFilters = applyFilters;

     function clearAllFilters() {
         const url = new URL(location.href);
         const qs = url.searchParams;
         const base = location.pathname;

         const size = qs.get('page_size');
         if (size) {
             const p = new URLSearchParams();
             p.set('page_size', size);
             p.set('page', '1');
             ajaxNavigate(base + '?' + p.toString(), true);
         } else {
             ajaxNavigate(base, true);
         }
     }
     window.clearAllFilters = clearAllFilters;

     document.getElementById('btnClearAll')?.addEventListener('click', clearAllFilters);
     document.getElementById('form1')?.addEventListener('submit', function (e) {
         e.preventDefault();
         applyFilters(1);
     });

     /* ✅ chip: category_id hiển thị theo tên danh mục (lookup từ tree) */
     function lookupCategoryName(catId) {
         if (!catId) return '';
         const a = document.querySelector(`#catTreeRoot a[data-cat-id="${CSS.escape(catId)}"]`);
         return a ? (a.textContent || '').trim() : '';
     }

     function renderActiveChips() {
         const p = new URLSearchParams(location.search);
         const dom = document.getElementById('active-filters');
         if (!dom) return;
         dom.innerHTML = '';

         const labels = {
             q: 'Từ khóa', brand: 'Thương hiệu', min_price: 'Giá từ', max_price: 'Giá đến',
             only_in_stock: 'Còn hàng', 'w_100_250': '100–250g', 'w_250_500': '250–500g',
             'w_500_1000': '500g–1kg', 'w_1000_5000': '1–5kg', 'w_5000': '>5kg',
             category_id: 'Danh mục'
         };

         let has = false;
         p.forEach((v, k) => {
             if (!labels[k]) return;
             has = true;

             let showVal = v;
             if (k === 'category_id') {
                 const name = lookupCategoryName(v);
                 showVal = name || v;
             }

             const chip = document.createElement('span'); chip.className = 'chip';
             const text = document.createElement('span');
             text.textContent = labels[k] + (showVal && showVal !== 'on' ? `: ${showVal}` : '');

             const close = document.createElement('span'); close.className = 'x'; close.innerHTML = '&times;';
             close.onclick = () => {
                 p.delete(k);
                 p.set('page', '1');
                 ajaxNavigate(location.pathname + '?' + p.toString(), true);
             };

             chip.appendChild(text);
             chip.appendChild(close);
             dom.appendChild(chip);
         });

         if (has) {
             const clearBtn = document.createElement('button');
             clearBtn.type = 'button';
             clearBtn.className = 'btn btn-sm btn-outline-secondary ms-1';
             clearBtn.textContent = 'Xóa tất cả';
             clearBtn.onclick = clearAllFilters;
             dom.appendChild(clearBtn);
         }
     }

     // Intercept pager/category link => AJAX
     document.addEventListener('click', function (e) {
         const a = e.target.closest('a');
         if (!a) return;

         try {
             const u = new URL(a.getAttribute('href') || '', location.origin);
             if (u.pathname !== location.pathname) return; // chỉ chặn link cùng trang Search

             const li = a.closest('li.page-item');
             if (li && (li.classList.contains('disabled') || li.classList.contains('active'))) {
                 e.preventDefault();
                 return;
             }

             e.preventDefault();
             ajaxNavigate(u.pathname + (u.search || ''), true);
         } catch { }
     });

     window.addEventListener('popstate', () => {
         ajaxNavigate(location.pathname + location.search, false);
     });

     function bindToolbarDropdowns() {
         document.querySelectorAll('#sortMenu .ui-dd-item').forEach(btn => {
             btn.addEventListener('click', () => {
                 document.getElementById('sortVal').value = btn.dataset.value ?? '';
                 applyFilters(1);
             });
         });

         document.querySelectorAll('#gridMenu .ui-dd-item').forEach(btn => {
             btn.addEventListener('click', () => {
                 document.getElementById('pageSizeVal').value = btn.dataset.value ?? '';
                 applyFilters(1);
             });
         });
     }

     bindToolbarDropdowns();
     syncToolbarFromUrl();
     syncSidebarFromUrl();
     renderActiveChips();

     /* ===== Offcanvas (mobile) ===== */
     const oc = document.getElementById('offcanvasFilters');

     oc?.addEventListener('show.bs.offcanvas', () => {
         const qs = new URLSearchParams(location.search);
         const setChk = (id, key) => { const el = document.getElementById(id); if (el) el.checked = qs.has(key); };

         document.getElementById('m_q').value = qs.get('q') || '';
         document.getElementById('m_brand').value = qs.get('brand') || '';
         document.getElementById('m_min').value = qs.get('min_price') || '';
         document.getElementById('m_max').value = qs.get('max_price') || '';
         document.getElementById('m_pageSize').value = qs.get('page_size') || '';
         document.getElementById('m_sort').value = qs.get('sort') || 'updated_at:desc';

         setChk('m_w1', 'w_100_250'); setChk('m_w2', 'w_250_500'); setChk('m_w3', 'w_500_1000');
         setChk('m_w4', 'w_1000_5000'); setChk('m_w5', 'w_5000');

         document.getElementById('m_inStock').checked = (qs.get('only_in_stock') === 'true');
     });

     function resetMobileFilters() {
         ['m_q', 'm_brand', 'm_min', 'm_max', 'm_pageSize'].forEach(id => {
             const el = document.getElementById(id); if (el) el.value = '';
         });
         ['m_w1', 'm_w2', 'm_w3', 'm_w4', 'm_w5', 'm_inStock'].forEach(id => {
             const el = document.getElementById(id); if (el) el.checked = false;
         });
         const s = document.getElementById('m_sort'); if (s) s.value = 'updated_at:desc';
     }
     window.resetMobileFilters = resetMobileFilters;

     function applyMobileFilters() {
         const p = new URLSearchParams();
         const qs = new URLSearchParams(location.search);

         // giữ category đang chọn
         if (qs.has('category_id')) p.set('category_id', qs.get('category_id'));

         const g = id => (document.getElementById(id)?.value || '').trim();
         const c = id => !!document.getElementById(id)?.checked;

         if (g('m_q')) p.set('q', g('m_q'));
         if (g('m_brand')) p.set('brand', g('m_brand'));
         if (g('m_min')) p.set('min_price', g('m_min'));
         if (g('m_max')) p.set('max_price', g('m_max'));

         if (g('m_sort')) p.set('sort', g('m_sort'));
         if (g('m_pageSize')) p.set('page_size', g('m_pageSize'));

         if (c('m_w1')) p.set('w_100_250', 'on');
         if (c('m_w2')) p.set('w_250_500', 'on');
         if (c('m_w3')) p.set('w_500_1000', 'on');
         if (c('m_w4')) p.set('w_1000_5000', 'on');
         if (c('m_w5')) p.set('w_5000', 'on');
         if (c('m_inStock')) p.set('only_in_stock', 'true');

         p.set('page', '1');

         const url = location.pathname + '?' + p.toString();
         ajaxNavigate(url, true);

         try { bootstrap.Offcanvas.getInstance(oc)?.hide(); } catch { }
     }
     window.applyMobileFilters = applyMobileFilters;
 </script>

</form>
</body>
</html>
