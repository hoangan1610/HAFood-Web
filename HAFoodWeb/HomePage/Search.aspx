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
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
  <style>
    .of-contain{object-fit:contain}
    .text-truncate-2{display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden}
    .price-now{color:#ff3b30;font-weight:700}
    .product-card{transition:transform .15s ease, box-shadow .15s ease}
    .product-card:hover{transform:translateY(-3px);box-shadow:0 .5rem 1rem rgba(0,0,0,.06)}
    .suggest-box{position:absolute;z-index:10;background:#fff;border:1px solid #ddd;border-radius:.5rem;overflow:hidden}
    .suggest-item{padding:.5rem .75rem;cursor:pointer}
    .suggest-item:hover{background:#f8f9fa}

    /* Category tree */
    .cat-node{margin:.35rem 0}
    .cat-children{margin-left:.75rem;border-left:1px dashed #eee;padding-left:.5rem}
    .cat-toggle{cursor:pointer;user-select:none}
  </style>
</head>
<body>
<form id="form1" runat="server"> <%-- KHÔNG dùng method="get" để tránh VIEWSTATE trên URL --%>
  <asp:ScriptManager ID="sm" runat="server" />
  <uc:Header ID="Header1" runat="server" />

  <div class="container my-4">
    <div class="row">
      <!-- Sidebar -->
      <div class="col-lg-3 mb-4">
        <div class="card">
          <div class="card-body">

            <h5 class="card-title mb-3">Danh Mục</h5>
            <div class="mb-4">
              <asp:Literal ID="ltCategoryTree" runat="server" />
            </div>

            <h5 class="card-title mb-3">Bộ Lọc Tìm Kiếm</h5>

            <!-- Từ khóa + suggest -->
            <div class="mb-3 position-relative">
              <label class="form-label">Từ khóa</label>
              <input id="txtQ" name="q" type="text" class="form-control" autocomplete="off"
                     value="<%= Server.HtmlEncode(Request["q"] ?? "") %>" />
              <div id="suggest" class="suggest-box d-none w-100"></div>
            </div>

            <!-- Brand -->
            <div class="mb-3">
              <label class="form-label">Thương hiệu</label>
              <input name="brand" type="text" class="form-control"
                     value="<%= Server.HtmlEncode(Request["brand"] ?? "") %>" />
            </div>

            <!-- Khoảng giá (dual-range) -->
            <div class="mb-3">
              <label class="form-label d-block">Khoảng giá (đ)</label>
              <div class="small text-muted d-flex justify-content-between">
                <span id="priceMinLabel">₫10.000</span>
                <span id="priceMaxLabel">₫1.000.000</span>
              </div>
              <div class="d-flex gap-2 align-items-center mt-2">
                <input id="rangeMin" type="range" min="10000" max="1000000" step="1000" class="form-range" />
                <input id="rangeMax" type="range" min="10000" max="1000000" step="1000" class="form-range" />
              </div>
              <input id="minPrice" name="min_price" type="hidden" value="<%= Server.HtmlEncode(Request["min_price"] ?? "") %>" />
              <input id="maxPrice" name="max_price" type="hidden" value="<%= Server.HtmlEncode(Request["max_price"] ?? "") %>" />
            </div>

            <!-- Trọng lượng (lọc client-side) -->
            <div class="mb-3">
              <label class="form-label d-block">Trọng lượng</label>
              <div class="form-check"><input class="form-check-input" type="checkbox" name="w_100_250" id="w1" <%= Request["w_100_250"]=="on"?"checked":"" %> /><label class="form-check-label" for="w1">100–250g</label></div>
              <div class="form-check"><input class="form-check-input" type="checkbox" name="w_250_500" id="w2" <%= Request["w_250_500"]=="on"?"checked":"" %> /><label class="form-check-label" for="w2">250–500g</label></div>
              <div class="form-check"><input class="form-check-input" type="checkbox" name="w_500_1000" id="w3" <%= Request["w_500_1000"]=="on"?"checked":"" %> /><label class="form-check-label" for="w3">500g–1kg</label></div>
              <div class="form-check"><input class="form-check-input" type="checkbox" name="w_1000_5000" id="w4" <%= Request["w_1000_5000"]=="on"?"checked":"" %> /><label class="form-check-label" for="w4">1kg–5kg</label></div>
              <div class="form-check"><input class="form-check-input" type="checkbox" name="w_5000" id="w5" <%= Request["w_5000"]=="on"?"checked":"" %> /><label class="form-check-label" for="w5">Trên 5kg</label></div>
            </div>

            <!-- Chỉ còn hàng -->
            <div class="form-check mb-3">
              <input class="form-check-input" type="checkbox" id="inStock" name="only_in_stock"
                     <%= (Request["only_in_stock"]=="true") ? "checked" : "" %> />
              <label class="form-check-label" for="inStock">Chỉ còn hàng</label>
            </div>

            <!-- Giữ category id nếu tới từ Home -->
            <input type="hidden" name="category_id" value="<%= Server.HtmlEncode(Request["category_id"] ?? "") %>" />

            <!-- KHÔNG submit form; gọi JS để build URL sạch -->
            <button type="button" class="btn btn-success w-100" onclick="applyFilters()">Áp dụng</button>
          </div>
        </div>
      </div>

      <!-- Kết quả -->
      <div class="col-lg-9">
        <div class="d-flex align-items-center justify-content-between mb-3">
          <div>
            <strong>Kết quả:</strong>
            <asp:Literal ID="ltTotal" runat="server" />
          </div>

          <div class="d-flex align-items-center gap-2">
            <label class="me-2">Sắp xếp</label>
            <select id="ddlSort" name="sort" class="form-select" onchange="applyFilters()">
              <option value="updated_at:desc">Mới nhất</option>
              <option value="price:asc">Giá tăng dần</option>
              <option value="price:desc">Giá giảm dần</option>
              <option value="name:asc">Tên A–Z</option>
              <option value="name:desc">Tên Z–A</option>
            </select>
            <script>
              document.addEventListener('DOMContentLoaded', function(){
                var v = new URLSearchParams(location.search).get('sort') || 'updated_at:desc';
                var ddl = document.getElementById('ddlSort'); ddl.value = v;
              });
            </script>
          </div>
        </div>

        <asp:Repeater ID="rpProducts" runat="server">
          <HeaderTemplate><div class="row gx-3 gy-4"></HeaderTemplate>
          <ItemTemplate>
            <div class="col-12 col-sm-6 col-lg-4">
              <div class="card product-card h-100 shadow-sm d-flex">
                <div class="ratio ratio-4x3 bg-light">
                  <img src="<%# Eval("ImageUrl") %>" class="w-100 h-100 of-contain p-2"
                       loading="lazy" onerror="this.src='/images/product-default.png';"
                       alt="<%# Eval("Name") %>" />
                </div>
                <div class="card-body d-flex flex-column">
                  <h6 class="text-truncate-2 mb-2"><%# Eval("Name") %></h6>
                  <div class="mb-2"><%# Eval("PriceRangeHtml") %></div>
                  <div class="mb-2">
                    <select class="form-select form-select-sm">
                      <asp:Repeater ID="rpVar" runat="server" DataSource='<%# Eval("Variants") %>'>
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

        <!-- Phân trang -->
        <div class="d-flex justify-content-center mt-4">
          <nav aria-label="page">
            <ul class="pagination">
              <asp:Literal ID="ltPager" runat="server" />
            </ul>
          </nav>
        </div>
      </div>
    </div>
  </div>

  <uc:Footer ID="Footer1" runat="server" />

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
  <script>
    // Debounce
    const debounce=(fn,ms)=>{let t;return(...args)=>{clearTimeout(t);t=setTimeout(()=>fn.apply(this,args),ms)}};

    // ======= Autocomplete suggest =======
    const box = document.getElementById('suggest');
    const input = document.getElementById('txtQ');
    const apiBase = '<%= System.Configuration.ConfigurationManager.AppSettings["ApiBaseUrl"]?.TrimEnd('/') %>';

      const renderSuggest = (items) => {
          if (!items || !items.length) { box.classList.add('d-none'); box.innerHTML = ''; return; }
          box.innerHTML = items.map(s => `<div class="suggest-item" data-v="${s}">${s}</div>`).join('');
          box.classList.remove('d-none');
          box.querySelectorAll('.suggest-item').forEach(x => {
              x.addEventListener('click', () => { input.value = x.dataset.v; box.classList.add('d-none'); });
          });
      };

      const doSuggest = debounce(async () => {
          const q = input.value.trim();
          if (q.length < 2) { renderSuggest([]); return; }
          try {
              const r = await fetch(`${apiBase}/api/search/suggest?q=${encodeURIComponent(q)}`, { headers: { 'accept': 'text/plain' } });
              const d = await r.json();
              renderSuggest(d.items || []);
          } catch { renderSuggest([]); }
      }, 250);

      input.addEventListener('input', doSuggest);
      document.addEventListener('click', (e) => { if (!box.contains(e.target) && e.target !== input) { box.classList.add('d-none'); } });

      // ======= Dual-range price =======
      const fmtVnd = n => '₫' + (+n || 0).toLocaleString('vi-VN');
      const minEl = document.getElementById('rangeMin'), maxEl = document.getElementById('rangeMax');
      const hMin = document.getElementById('minPrice'), hMax = document.getElementById('maxPrice');
      const lblMin = document.getElementById('priceMinLabel'), lblMax = document.getElementById('priceMaxLabel');

      (function initPrice() {
          const qs = new URLSearchParams(location.search);
          const m = +(qs.get('min_price') || 10000), x = +(qs.get('max_price') || 1000000);
          minEl.value = m; maxEl.value = x; hMin.value = m; hMax.value = x;
          lblMin.textContent = fmtVnd(m); lblMax.textContent = fmtVnd(x);
      })();

      function syncRange() {
          let a = +minEl.value, b = +maxEl.value;
          if (a > b) { const t = a; a = b; b = t; minEl.value = a; maxEl.value = b; }
          hMin.value = a; hMax.value = b; lblMin.textContent = fmtVnd(a); lblMax.textContent = fmtVnd(b);
      }
      minEl.addEventListener('input', syncRange);
      maxEl.addEventListener('input', syncRange);

      // ======= Toggle Category nodes =======
      document.addEventListener('click', function (e) {
          const t = e.target.closest('[data-toggle-cat]'); if (!t) return;
          const id = t.getAttribute('data-toggle-cat');
          const sub = document.getElementById('cat-children-' + id);
          if (sub) sub.classList.toggle('d-none');
      });

      // ======= Build URL sạch & điều hướng (không submit form) =======
      function readVal(sel) { const el = document.querySelector(sel); return el ? (el.value || '').trim() : ''; }
      function isCheckedByName(name) { const el = document.querySelector(`[name="${name}"]`); return !!(el && el.checked); }

      function applyFilters(page) {
          const p = new URLSearchParams();

          // Từ khóa & brand
          const q = readVal('#txtQ'); if (q) p.set('q', q);
          const brand = readVal('[name="brand"]'); if (brand) p.set('brand', brand);

          // Giá: hỗ trợ cả hidden (#minPrice/#maxPrice) lẫn input number name=min_price/max_price (nếu có)
          const min = readVal('#minPrice') || readVal('[name="min_price"]');
          const max = readVal('#maxPrice') || readVal('[name="max_price"]');
          if (min) p.set('min_price', min);
          if (max) p.set('max_price', max);

          // Còn hàng
          if (document.getElementById('inStock')?.checked) p.set('only_in_stock', 'true');

          // Danh mục
          const cat = readVal('[name="category_id"]'); if (cat) p.set('category_id', cat);

          // Sort
          const sortEl = document.getElementById('ddlSort');
          if (sortEl && sortEl.value) p.set('sort', sortEl.value);

          // Trọng lượng (giữ trạng thái trên URL để server đọc & lọc client-side)
          ['w_100_250', 'w_250_500', 'w_500_1000', 'w_1000_5000', 'w_5000'].forEach(n => {
              if (isCheckedByName(n)) p.set(n, 'on');
          });

          // Reset page về 1 khi đổi filter/sort
          p.set('page', page || 1);

          // Điều hướng (GET sạch, không VIEWSTATE)
          window.location.href = location.pathname + '?' + p.toString();
      }

      // Chặn submit form mặc định (kể cả Enter) để luôn dùng applyFilters()
      document.getElementById('form1').addEventListener('submit', function (e) {
          e.preventDefault();
          applyFilters();
      });
  </script>
</form>
</body>
</html>
