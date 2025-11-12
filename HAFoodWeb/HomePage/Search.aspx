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

  <!-- Preconnect -->
  <link rel="preconnect" href="https://api.hafood.id.vn" crossorigin="anonymous">
<link rel="preconnect" href="https://cdn.hafood.id.vn" crossorigin="anonymous">

  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />

  <style>
    :root{
      --card-radius: 1rem;
      --soft-shadow: 0 8px 24px rgba(0,0,0,.08);
      --brand: #ff6b00;
      --brand-hover:#e66000;
      --price:#ff3b30;
    }
    body{ background:#fafafa; }

    .of-contain{object-fit:contain}
    .text-truncate-2{display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden}
    .text-truncate-1{white-space:nowrap;overflow:hidden;text-overflow:ellipsis}

    /* Sticky toolbar */
    .result-toolbar{
      position: sticky; top: 0; z-index: 50; background: #fff; border-bottom: 1px solid #eee;
      padding: .5rem .75rem;
    }

    /* Card */
    .product-card{
      border:0; border-radius:var(--card-radius); overflow:hidden; background:#fff;
      box-shadow:var(--soft-shadow); height:100%;
      transition:transform .15s ease, box-shadow .15s ease;
    }
    .product-card:hover{ transform:translateY(-2px); box-shadow:0 10px 26px rgba(0,0,0,.10); }
    .product-card .card-body{ padding:.75rem .9rem 1rem; }
    .product-card h6{ margin-bottom:.35rem; line-height:1.35; }
    .product-thumb{ background:#fff; }
    .product-thumb img{ padding:.5rem; }

    .price-now{ color:var(--price); font-weight:800; letter-spacing:.2px; display:inline-block; margin-bottom:.25rem; }
    .price-sub{ color:#6c757d; font-size:.875rem; }

    /* Suggest */
    .suggest-box{position:absolute;z-index:100;background:#fff;border:1px solid #ddd;border-radius:.5rem;overflow:hidden; max-height:260px; overflow:auto;}
    .suggest-item{padding:.5rem .75rem;cursor:pointer}
    .suggest-item:hover{background:#f8f9fa}

    /* Category tree */
    .cat-card{ border-radius:.75rem; box-shadow:var(--soft-shadow); }
    .cat-node{margin:.35rem 0}
    .cat-children{margin-left:.75rem;border-left:1px dashed #eee;padding-left:.5rem}
    .cat-toggle{cursor:pointer;user-select:none}

    /* Chips */
    .chip{ display:inline-flex; align-items:center; gap:.35rem; padding:.35rem .6rem; border-radius:2rem;
           background:#f1f3f5; border:1px solid #e9ecef; font-size:.875rem; }
    .chip .x{ cursor:pointer; opacity:.75; }
    .chip .x:hover{ opacity:1; }

    /* Controls alignment */
    .form-select.form-select-sm{ height:36px; padding-top:.35rem; padding-bottom:.35rem; }
    .qty{ width:72px; height:36px; text-align:center; }
    .btn-buy{ height:36px; border-radius:.6rem; font-weight:600; }

    /* Buttons */
    .btn-brand{ background:var(--brand); border-color:var(--brand); color:#fff; }
    .btn-brand:hover{ background:var(--brand-hover); border-color:var(--brand-hover); color:#fff; }
    .btn-clear{ --bs-btn-padding-y:.35rem; --bs-btn-padding-x:.75rem; --bs-btn-border-radius:2rem; }

    /* Responsive */
    @media (max-width: 991.98px){ .sidebar-col{ display:none; } }
  </style>
</head>
<body>
<form id="form1" runat="server">
  <asp:ScriptManager ID="sm" runat="server" />
  <uc:Header ID="Header1" runat="server" />

  <div class="container py-3">

    <!-- Toolbar -->
    <div class="result-toolbar rounded-3 shadow-sm mb-3">
      <div class="d-flex align-items-center gap-2">
        <div class="me-auto small">
          <strong>Kết quả: </strong><asp:Literal ID="ltTotal" runat="server" />
        </div>

        <!-- Filter button (mobile) -->
        <button type="button" class="btn btn-outline-secondary d-lg-none"
                data-bs-toggle="offcanvas" data-bs-target="#offcanvasFilters"
                aria-controls="offcanvasFilters">Lọc</button>

        <!-- Sort -->
        <div class="d-flex align-items-center gap-2">
          <label class="small text-muted d-none d-sm-inline">Sắp xếp</label>
          <select id="ddlSortTop" class="form-select form-select-sm" onchange="applyFilters()">
            <option value="updated_at:desc">Mới nhất</option>
            <option value="price:asc">Giá tăng dần</option>
            <option value="price:desc">Giá giảm dần</option>
            <option value="name:asc">Tên A–Z</option>
            <option value="name:desc">Tên Z–A</option>
          </select>
        </div>
      </div>
    </div>

    <!-- Chips -->
    <div id="active-filters" class="d-flex flex-wrap gap-2 mb-3" aria-live="polite"></div>

    <div class="row g-3">
      <!-- Sidebar -->
      <div class="col-lg-3 sidebar-col">
        <div class="card cat-card">
          <div class="card-body">
            <h5 class="card-title mb-3">Danh Mục</h5>
            <div class="mb-4"><asp:Literal ID="ltCategoryTree" runat="server" /></div>

            <h5 class="card-title mb-3">Bộ Lọc</h5>

            <!-- Keyword -->
            <div class="mb-3 position-relative">
              <label class="form-label">Từ khóa</label>
              <input id="txtQ" name="q" type="text" class="form-control" autocomplete="off"
                     aria-label="Từ khóa" value="<%= Server.HtmlEncode(Request["q"] ?? "") %>" />
              <div id="suggest" class="suggest-box d-none w-100" role="listbox" aria-live="polite"></div>
            </div>

            <!-- Brand -->
            <div class="mb-3">
              <label class="form-label">Thương hiệu</label>
              <input name="brand" type="text" class="form-control" aria-label="Thương hiệu"
                     value="<%= Server.HtmlEncode(Request["brand"] ?? "") %>" />
            </div>

            <!-- Price -->
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

            <!-- Weight -->
            <div class="mb-3">
              <label class="form-label d-block">Trọng lượng</label>
              <div class="form-check"><input class="form-check-input" type="checkbox" name="w_100_250" id="w1" <%= Request["w_100_250"]=="on"?"checked":"" %> /><label class="form-check-label" for="w1">100–250g</label></div>
              <div class="form-check"><input class="form-check-input" type="checkbox" name="w_250_500" id="w2" <%= Request["w_250_500"]=="on"?"checked":"" %> /><label class="form-check-label" for="w2">250–500g</label></div>
              <div class="form-check"><input class="form-check-input" type="checkbox" name="w_500_1000" id="w3" <%= Request["w_500_1000"]=="on"?"checked":"" %> /><label class="form-check-label" for="w3">500g–1kg</label></div>
              <div class="form-check"><input class="form-check-input" type="checkbox" name="w_1000_5000" id="w4" <%= Request["w_1000_5000"]=="on"?"checked":"" %> /><label class="form-check-label" for="w4">1kg–5kg</label></div>
              <div class="form-check"><input class="form-check-input" type="checkbox" name="w_5000" id="w5" <%= Request["w_5000"]=="on"?"checked":"" %> /><label class="form-check-label" for="w5">Trên 5kg</label></div>
            </div>

            <!-- Stock -->
            <div class="form-check mb-3">
              <input class="form-check-input" type="checkbox" id="inStock" name="only_in_stock"
                     <%= (Request["only_in_stock"]=="true") ? "checked" : "" %> />
              <label class="form-check-label" for="inStock">Chỉ còn hàng</label>
            </div>

            <input type="hidden" name="category_id" value="<%= Server.HtmlEncode(Request["category_id"] ?? "") %>" />

            <!-- Actions -->
            <div class="d-flex gap-2">
              <button type="button" class="btn btn-outline-secondary btn-clear" id="btnClearAll">Xóa tất cả</button>
              <button type="button" class="btn btn-brand ms-auto" onclick="applyFilters()">Áp dụng</button>
            </div>
          </div>
        </div>
      </div>

      <!-- Results -->
      <div class="col-lg-9">
        <asp:Repeater ID="rpProducts" runat="server">
          <HeaderTemplate><div class="row g-3"></HeaderTemplate>
          <ItemTemplate>
            <div class="col-6 col-md-4">
              <div class="product-card d-flex flex-column">
                <div class="position-relative">
                  <a href='<%# ResolveUrl("~/Product/Product.aspx?id=" + Eval("Id")) %>' class="ratio ratio-1x1 product-thumb d-block">
                    <img
                      src="<%# Eval("ImageUrl") %>"
                      srcset="<%# Eval("ImageUrl") %>?w=240 240w, <%# Eval("ImageUrl") %>?w=480 480w, <%# Eval("ImageUrl") %>?w=720 720w"
                      sizes="(max-width: 576px) 48vw, (max-width: 992px) 32vw, 240px"
                      class="w-100 h-100 of-contain"
                      loading="lazy" decoding="async" fetchpriority="low"
                      onerror="this.src='/images/product-default.png';"
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

        <!-- Pager -->
        <div class="d-flex justify-content-center mt-4">
          <nav aria-label="page">
            <ul class="pagination"><asp:Literal ID="ltPager" runat="server" /></ul>
          </nav>
        </div>
      </div>
    </div>
  </div>

  <!-- Offcanvas Filter (mobile) -->
  <div class="offcanvas offcanvas-bottom" tabindex="-1" id="offcanvasFilters" aria-labelledby="offcanvasFiltersLabel" style="height:80vh;">
    <div class="offcanvas-header">
      <h5 class="offcanvas-title" id="offcanvasFiltersLabel">Bộ lọc</h5>
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
        <button type="button" class="btn btn-brand ms-auto" onclick="applyMobileFilters()">Áp dụng</button>
      </div>
    </div>
  </div>

  <uc:Footer ID="Footer1" runat="server" />

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
  <script>
  /* ==== COMPAT: tự đổi catId -> category_id (nếu link cũ còn cache) ==== */
  (function () {
      var url = new URL(window.location.href);
      var p = url.searchParams;
      if (p.has('catId') && !p.has('category_id')) {
          p.set('category_id', p.get('catId'));
          p.delete('catId');
          window.location.replace(url.pathname + '?' + p.toString());
      }
  })();

  /* ===== Utilities ===== */
  const debounce = (fn, ms) => { let t; return (...args) => { clearTimeout(t); t = setTimeout(() => fn.apply(this, args), ms) } };
  const apiBase = '<%= System.Configuration.ConfigurationManager.AppSettings["ApiBaseUrl"]?.TrimEnd('/') %>';

      /* ===== Suggest (desktop) ===== */
      const box = document.getElementById('suggest');
      const input = document.getElementById('txtQ');

      const renderSuggest = (items) => {
          if (!items || !items.length) { box.classList.add('d-none'); box.innerHTML = ''; return; }
          box.innerHTML = items.map(s => `<div class="suggest-item" data-v="${s}" role="option">${s}</div>`).join('');
          box.classList.remove('d-none');
          box.querySelectorAll('.suggest-item').forEach(x => {
              x.addEventListener('click', () => { input.value = x.dataset.v; box.classList.add('d-none'); applyFilters(); });
          });
      };

      const doSuggest = debounce(async () => {
          const q = input?.value?.trim() || '';
          if (q.length < 2 || !apiBase) { renderSuggest([]); return; }
          try {
              const r = await fetch(`${apiBase}/api/search/suggest?q=${encodeURIComponent(q)}`, { headers: { accept: 'application/json' } });
              const d = await r.json();
              renderSuggest(d.items || []);
          } catch { renderSuggest([]); }
      }, 250);

      input?.addEventListener('input', doSuggest);
      /* Enter ở ô Từ khóa: apply luôn */
      input?.addEventListener('keydown', (e) => { if (e.key === 'Enter') { e.preventDefault(); applyFilters(); } });
      /* Click ra ngoài: ẩn gợi ý */
      document.addEventListener('click', (e) => { if (!box.contains(e.target) && e.target !== input) box.classList.add('d-none'); });

      /* ===== Price dual range + inputs ===== */
      const fmtVnd = n => '₫' + (+n || 0).toLocaleString('vi-VN');
      const minEl = document.getElementById('rangeMin'), maxEl = document.getElementById('rangeMax');
      const hMin = document.getElementById('minPrice'), hMax = document.getElementById('maxPrice');
      const inMin = document.getElementById('minPriceInput'), inMax = document.getElementById('maxPriceInput');
      const lblMin = document.getElementById('priceMinLabel'), lblMax = document.getElementById('priceMaxLabel');

      (function initPrice() {
          const qs = new URLSearchParams(location.search);
          const m = +(qs.get('min_price') || 10000), x = +(qs.get('max_price') || 1000000);
          [minEl, maxEl].forEach(el => el && (el.min = 10000, el.max = 1000000, el.step = 1000));
          if (minEl) minEl.value = m; if (maxEl) maxEl.value = x;
          if (hMin) hMin.value = m; if (hMax) hMax.value = x;
          if (inMin) inMin.value = m; if (inMax) inMax.value = x;
          lblMin.textContent = fmtVnd(m); lblMax.textContent = fmtVnd(x);
      })();
      function syncRange() {
          let a = +minEl.value, b = +maxEl.value;
          if (a > b) { const t = a; a = b; b = t; minEl.value = a; maxEl.value = b; }
          hMin.value = a; hMax.value = b; inMin.value = a; inMax.value = b;
          lblMin.textContent = fmtVnd(a); lblMax.textContent = fmtVnd(b);
      }
      minEl?.addEventListener('input', syncRange);
      maxEl?.addEventListener('input', syncRange);
      inMin?.addEventListener('input', () => { const v = +inMin.value || 10000; minEl.value = v; syncRange(); });
      inMax?.addEventListener('input', () => { const v = +inMax.value || 1000000; maxEl.value = v; syncRange(); });

      /* ===== Category toggle ===== */
      document.addEventListener('click', function (e) {
          const t = e.target.closest('[data-toggle-cat]'); if (!t) return;
          const id = t.getAttribute('data-toggle-cat');
          const sub = document.getElementById('cat-children-' + id);
          if (sub) sub.classList.toggle('d-none');
      });

      /* ===== Helpers ===== */
      function readVal(sel) { const el = document.querySelector(sel); return el ? (el.value || '').trim() : ''; }
      function isCheckedByName(name) { const el = document.querySelector(`[name="${name}"]`); return !!(el && el.checked); }

      /* Build URL từ UI */
      function buildSearchParamsFromUI() {
          const p = new URLSearchParams();
          const q = readVal('#txtQ'); if (q) p.set('q', q);
          const brand = readVal('[name="brand"]'); if (brand) p.set('brand', brand);

          const min = readVal('#minPrice') || readVal('[name="min_price"]');
          const max = readVal('#maxPrice') || readVal('[name="max_price"]');
          if (min) p.set('min_price', min);
          if (max) p.set('max_price', max);

          if (document.getElementById('inStock')?.checked) p.set('only_in_stock', 'true');

          const cat = readVal('[name="category_id"]'); if (cat) p.set('category_id', cat);

          const sortTop = document.getElementById('ddlSortTop'); if (sortTop && sortTop.value) p.set('sort', sortTop.value);

          ['w_100_250', 'w_250_500', 'w_500_1000', 'w_1000_5000', 'w_5000'].forEach(n => { if (isCheckedByName(n)) p.set(n, 'on'); });

          return p;
      }

      /* Áp dụng (desktop) */
      function applyFilters(page) {
          const p = buildSearchParamsFromUI();
          p.set('page', page || 1);
          location.href = location.pathname + '?' + p.toString();
      }
      window.applyFilters = applyFilters;

      /* Xóa tất cả: XÓA SẠCH toàn bộ query (chỉ giữ page_size nếu đang có) */
      function clearAllFilters() {
          const url = new URL(location.href);
          const qs = url.searchParams;
          const base = location.pathname;

          // Nếu muốn giữ page_size (tùy cấu hình UI), giữ lại nhẹ nhàng
          const size = qs.get('page_size');
          if (size) {
              const p = new URLSearchParams();
              p.set('page_size', size);
              p.set('page', '1');
              location.href = base + '?' + p.toString();
          } else {
              // Xóa sạch mọi tham số
              location.href = base;
          }
      }
      document.getElementById('btnClearAll')?.addEventListener('click', clearAllFilters);

      /* Submit form mặc định → apply */
      document.getElementById('form1').addEventListener('submit', function (e) { e.preventDefault(); applyFilters(); });

      /* Sort init */
      (function initSort() {
          const v = new URLSearchParams(location.search).get('sort') || 'updated_at:desc';
          const ddl = document.getElementById('ddlSortTop'); if (ddl) ddl.value = v;
      })();

      /* Chips đang áp dụng + nút Xóa tất cả */
      (function renderActiveChips() {
          const p = new URLSearchParams(location.search);
          const dom = document.getElementById('active-filters');
          const labels = {
              q: 'Từ khóa', brand: 'Thương hiệu', min_price: 'Giá từ', max_price: 'Giá đến',
              only_in_stock: 'Còn hàng', 'w_100_250': '100–250g', 'w_250_500': '250–500g',
              'w_500_1000': '500g–1kg', 'w_1000_5000': '1–5kg', 'w_5000': '>5kg', category_id: 'Danh mục'
          };
          let has = false;
          p.forEach((v, k) => {
              if (!labels[k]) return;
              has = true;
              const chip = document.createElement('span'); chip.className = 'chip';
              const text = document.createElement('span');
              text.textContent = labels[k] + (v && v !== 'on' ? `: ${v}` : '');
              const close = document.createElement('span'); close.className = 'x'; close.innerHTML = '&times;';
              close.onclick = () => { p.delete(k); location.search = p.toString(); };
              chip.appendChild(text); chip.appendChild(close); dom.appendChild(chip);
          });
          if (has) {
              const clearBtn = document.createElement('button');
              clearBtn.type = 'button'; clearBtn.className = 'btn btn-sm btn-outline-secondary ms-1';
              clearBtn.textContent = 'Xóa tất cả';
              clearBtn.onclick = clearAllFilters;   // dùng cùng hàm xóa sạch
              dom.appendChild(clearBtn);
          }
      })();

      /* ===== Offcanvas (mobile) ===== */
      const oc = document.getElementById('offcanvasFilters');
      oc?.addEventListener('show.bs.offcanvas', () => {
          const qs = new URLSearchParams(location.search);
          const setChk = (id, key) => { const el = document.getElementById(id); if (el) el.checked = qs.has(key); };
          document.getElementById('m_q').value = qs.get('q') || '';
          document.getElementById('m_brand').value = qs.get('brand') || '';
          document.getElementById('m_min').value = qs.get('min_price') || '';
          document.getElementById('m_max').value = qs.get('max_price') || '';
          setChk('m_w1', 'w_100_250'); setChk('m_w2', 'w_250_500'); setChk('m_w3', 'w_500_1000'); setChk('m_w4', 'w_1000_5000'); setChk('m_w5', 'w_5000');
          document.getElementById('m_inStock').checked = (qs.get('only_in_stock') === 'true');
      });

      function resetMobileFilters() {
          ['m_q', 'm_brand', 'm_min', 'm_max'].forEach(id => { const el = document.getElementById(id); if (el) el.value = ''; });
          ['m_w1', 'm_w2', 'm_w3', 'm_w4', 'm_w5', 'm_inStock'].forEach(id => { const el = document.getElementById(id); if (el) el.checked = false; });
      }
      function applyMobileFilters() {
          const p = new URLSearchParams();
          const qs = new URLSearchParams(location.search);
          ['category_id', 'sort', 'page_size'].forEach(k => { if (qs.has(k)) p.set(k, qs.get(k)); });

          const g = id => (document.getElementById(id)?.value || '').trim();
          const c = id => !!document.getElementById(id)?.checked;

          if (g('m_q')) p.set('q', g('m_q'));
          if (g('m_brand')) p.set('brand', g('m_brand'));
          if (g('m_min')) p.set('min_price', g('m_min'));
          if (g('m_max')) p.set('max_price', g('m_max'));
          if (c('m_w1')) p.set('w_100_250', 'on');
          if (c('m_w2')) p.set('w_250_500', 'on');
          if (c('m_w3')) p.set('w_500_1000', 'on');
          if (c('m_w4')) p.set('w_1000_5000', 'on');
          if (c('m_w5')) p.set('w_5000', 'on');
          if (c('m_inStock')) p.set('only_in_stock', 'true');

          p.set('page', '1');
          location.href = location.pathname + '?' + p.toString();
      }
  </script>
</form>
</body>
</html>
