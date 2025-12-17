<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="BlogDetail.aspx.cs" Inherits="HAFoodWeb.Blog.BlogDetail" Async="true" %>
<%@ Register Src="~/Control/Header.ascx" TagPrefix="uc" TagName="Header" %>
<%@ Register Src="~/Control/Footer.ascx" TagPrefix="uc" TagName="Footer" %>

<!DOCTYPE html>
<html lang="vi">
<head runat="server">
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title runat="server" id="pageTitle">Bài viết - HAFood</title>

  <asp:Literal ID="litHeadMeta" runat="server" />
  <asp:Literal ID="litJsonLd" runat="server" />

  <!-- Fonts -->
  <link rel="preconnect" href="https://fonts.googleapis.com" />
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet" />

  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet" />

  <style>
    :root{
      --ha-cream:#FFF7EA;
      --ha-ink:#0f172a;
      --ha-muted:#64748b;
      --ha-accent:#22c55e;
      --ha-border: rgba(148,163,184,.28);
      --ha-shadow: 0 20px 60px rgba(15,23,42,.10);
      --ha-shadow-sm: 0 10px 28px rgba(15,23,42,.10);
      --ha-radius: 18px;
    }

    html, body{ height:100%; }
    body{
      font-family: Inter, system-ui, -apple-system, "Segoe UI", Roboto, Arial, "Noto Sans", sans-serif;
      color: var(--ha-ink);
      background:
        radial-gradient(900px 420px at 20% 0%, rgba(34,197,94,.10), transparent 55%),
        linear-gradient(180deg, var(--ha-cream) 0%, #fff 35%, #f6f7fb 100%);
    }

    /* progress bar */
    .read-progress{
      position: sticky;
      top: 0;
      z-index: 9998;
      height: 3px;
      background: transparent;
    }
    .read-progress > span{
      display:block;
      height: 3px;
      width: 0%;
      background: var(--ha-accent);
      box-shadow: 0 0 0 1px rgba(34,197,94,.10);
      transition: width .08s linear;
    }

    .ha-shell{
      max-width: 1140px;
      margin: 0 auto;
      padding: 18px 12px 0;
    }

    .ha-back{
      display:inline-flex;
      align-items:center;
      gap:8px;
      color: var(--ha-ink);
      text-decoration:none;
      font-weight: 700;
    }
    .ha-back:hover{ color: var(--ha-accent); }

    .ha-hero{
      border-radius: var(--ha-radius);
      background:#fff;
      border: 1px solid var(--ha-border);
      box-shadow: var(--ha-shadow);
      overflow:hidden;
    }

    .ha-coverwrap{
      position: relative;
      background:#f1f5f9;
      min-height: 220px;
    }
    .ha-cover{
      width:100%;
      max-height: 420px;
      object-fit: cover;
      display:block;
    }
    .ha-coverfade{
      position:absolute; inset:auto 0 0 0;
      height: 130px;
      background: linear-gradient(180deg, transparent 0%, rgba(0,0,0,.40) 100%);
      pointer-events:none;
    }

    .ha-hero-inner{
      padding: 14px 16px 16px;
    }
    @media(min-width:992px){
      .ha-hero-inner{ padding: 18px 22px 20px; }
    }

    .ha-title{
      font-weight: 900;
      letter-spacing: -.02em;
      line-height: 1.16;
      margin: 0;
      font-size: 1.65rem;
    }
    @media(min-width:992px){
      .ha-title{ font-size: 2.05rem; }
    }

    .ha-excerpt{
      margin-top: 10px;
      color: var(--ha-muted);
      font-size: 0.98rem;
      line-height: 1.55;
    }

    .ha-meta{
      margin-top: 12px;
      display:flex;
      flex-wrap:wrap;
      gap: 8px;
      align-items:center;
      color: var(--ha-muted);
      font-size: 13px;
    }
    .ha-chip{
      display:inline-flex;
      align-items:center;
      gap:6px;
      padding: 6px 10px;
      border-radius: 999px;
      background: rgba(15,23,42,.04);
      border: 1px solid rgba(148,163,184,.25);
      color: #0f172a;
      font-weight: 700;
    }
    .ha-chip i{ color: var(--ha-accent); }

    .ha-actions{
      margin-left:auto;
      display:flex;
      align-items:center;
      gap: 8px;
    }
    .ha-btn-icon{
      border: 1px solid rgba(148,163,184,.25);
      background:#fff;
      border-radius: 999px;
      height: 36px;
      width: 36px;
      display:inline-flex;
      align-items:center;
      justify-content:center;
      box-shadow: 0 8px 18px rgba(15,23,42,.06);
      cursor:pointer;
      transition: transform .12s ease, box-shadow .12s ease;
    }
    .ha-btn-icon:hover{ transform: translateY(-1px); box-shadow: 0 14px 26px rgba(15,23,42,.10); }
    .ha-btn-icon i{ font-size: 16px; color:#0f172a; }

    /* layout */
    .ha-layout{ margin-top: 14px; }
    .ha-maincol{ }
    .ha-asidecol{ }

    /* content card */
    .blog-content{
      background:#fff;
      border: 1px solid var(--ha-border);
      border-radius: var(--ha-radius);
      box-shadow: var(--ha-shadow-sm);
      padding: 18px;
    }
    @media(min-width:992px){
      .blog-content{ padding: 26px; }
    }

    /* typography (đọc sướng hơn) */
    .prose{
      max-width: 760px;
      margin: 0 auto;
    }
    .blog-content h2, .blog-content h3, .blog-content h4{
      margin-top: 18px;
      font-weight: 900;
      letter-spacing: -.01em;
    }
    .blog-content p{
      line-height: 1.85;
      font-size: 1.02rem;
      color: #0f172a;
    }
    .blog-content a{ color: #16a34a; font-weight: 700; }
    .blog-content a:hover{ text-decoration: underline; }

    .blog-content img{
      max-width:100%;
      height:auto;
      border-radius: 14px;
      border: 1px solid rgba(148,163,184,.25);
      box-shadow: 0 12px 28px rgba(15,23,42,.08);
    }
    .blog-content blockquote{
      padding: 14px 14px;
      border-left: 4px solid var(--ha-accent);
      background: rgba(34,197,94,.08);
      border-radius: 14px;
      margin: 16px 0;
      color:#0f172a;
    }
    .blog-content ul, .blog-content ol{ padding-left: 1.15rem; }
    .blog-content li{ line-height: 1.75; margin: 6px 0; }

    /* aside sticky */
    @media(min-width:992px){
      .ha-aside-sticky{
        position: sticky;
        top: 14px;
      }
    }

    .ha-sidecard{
      background:#fff;
      border: 1px solid var(--ha-border);
      border-radius: var(--ha-radius);
      box-shadow: var(--ha-shadow-sm);
      overflow:hidden;
    }
    .ha-sidecard .ha-sidehead{
      padding: 12px 14px;
      font-weight: 900;
      border-bottom: 1px solid rgba(148,163,184,.18);
      display:flex;
      align-items:center;
      justify-content:space-between;
    }
    .ha-sidecard .ha-sidebody{ padding: 12px; }

    /* product cards */
    .ha-card-img{ height:170px; object-fit:cover; border-bottom:1px solid rgba(148,163,184,.18); }
    .ha-price{ font-weight: 900; }
    .ha-card{
      border: 1px solid rgba(148,163,184,.20);
      border-radius: 16px;
      overflow:hidden;
      box-shadow: 0 10px 22px rgba(15,23,42,.08);
      transition: transform .12s ease, box-shadow .12s ease;
    }
    .ha-card:hover{ transform: translateY(-2px); box-shadow: 0 18px 38px rgba(15,23,42,.12); }

    /* related post cards */
    .ha-related{
      border:1px solid rgba(148,163,184,.20);
      border-radius: 16px;
      background:#fff;
      overflow:hidden;
      height:100%;
      box-shadow: 0 10px 22px rgba(15,23,42,.08);
      transition: transform .12s ease, box-shadow .12s ease;
    }
    .ha-related:hover{ transform: translateY(-2px); box-shadow: 0 18px 38px rgba(15,23,42,.12); }
    .ha-related-img{ height:140px; width:100%; object-fit:cover; background:#f1f5f9; }
    .line-2{
      display:-webkit-box; -webkit-line-clamp:2; -webkit-box-orient:vertical; overflow:hidden;
    }

    /* mini toast */
    .ha-toast{
      position: fixed; left: 50%; bottom: 22px; transform: translateX(-50%);
      z-index: 9999; background: rgba(15,23,42,.92); color:#fff;
      padding: 10px 12px; border-radius: 12px; font-size: 13px;
      max-width: calc(100vw - 24px); box-shadow: 0 16px 30px rgba(0,0,0,.18);
      opacity: 0; pointer-events:none; transition: opacity .15s ease, transform .15s ease;
    }
    .ha-toast.show{ opacity: 1; transform: translateX(-50%) translateY(-2px); }

    [data-cart-badge="true"].ha-bump{ transform: scale(1.12); transition: transform .18s ease; }
  </style>
</head>

<body>
<form runat="server">
    <asp:HiddenField ID="hidArticleId" runat="server" />
<asp:HiddenField ID="hidApiBase" runat="server" />

  <div class="read-progress" aria-hidden="true"><span id="readProgressBar"></span></div>

  <uc:Header ID="Header1" runat="server" />

  <div class="ha-shell">

    <a href="/blog" class="ha-back"><i class="bi bi-arrow-left"></i> Quay lại blog</a>

    <div class="ha-hero mt-2">
      <div class="ha-coverwrap">
        <asp:Literal ID="litCover" runat="server" />
        <div class="ha-coverfade"></div>
      </div>

      <div class="ha-hero-inner">
        <h1 class="ha-title">
          <asp:Literal ID="litTitle" runat="server" />
        </h1>

        <div class="ha-excerpt">
          <asp:Literal ID="litExcerpt" runat="server" />
        </div>

        <div class="ha-meta">
          <span class="ha-chip"><i class="bi bi-calendar2-week"></i> <asp:Literal ID="litMeta" runat="server" /></span>
          <span class="ha-chip"><i class="bi bi-clock-history"></i> <asp:Literal ID="litReadTime" runat="server" /></span>

          <div class="ha-actions">
            <button type="button" class="ha-btn-icon" id="btnCopyLink" title="Copy link"><i class="bi bi-link-45deg"></i></button>
            <a class="ha-btn-icon" id="btnShareFb" target="_blank" rel="noopener" title="Share Facebook"><i class="bi bi-facebook"></i></a>
          </div>
        </div>
      </div>
    </div>

    <div class="ha-layout mt-3">
      <div class="row g-3 align-items-start">
        <!-- MAIN -->
        <div class="col-12 col-lg-8 ha-maincol">
          <div class="blog-content">
            <div class="prose">
              <asp:Literal ID="litContentHtml" runat="server" />
            </div>
          </div>
        </div>

        <!-- ASIDE -->
        <div class="col-12 col-lg-4 ha-asidecol">
          <div class="ha-aside-sticky">

            <!-- ✅ Gợi ý sản phẩm -->
            <asp:Panel ID="pCards" runat="server" Visible="false" CssClass="mb-3">
              <div class="ha-sidecard">
                <div class="ha-sidehead">
                  <span>Gợi ý sản phẩm</span>
                </div>
                <div class="ha-sidebody">
                  <asp:Repeater ID="rpCards" runat="server">
                    <HeaderTemplate><div class="row g-2"></HeaderTemplate>
                    <ItemTemplate>
  <div class="col-12">
    <div class="ha-card">

      <!-- LINK ẢNH: ✅ gắn tracking -->
      <a class="text-decoration-none js-ap-prod"
         data-product="<%# Eval("Id") %>"
         data-default-variant="<%# Eval("DefaultVariantId") %>"
         href="/Product/Product.aspx?id=<%# Eval("Id") %>">
        <img class="card-img-top ha-card-img"
             src="<%# Eval("ImageUrl") %>"
             alt=""
             loading="lazy"
             onerror="this.src='/images/product-default.png';" />
      </a>

      <div class="p-3">
        <div class="d-flex justify-content-between align-items-start gap-2">

          <!-- LINK TÊN: ✅ gắn tracking -->
          <a class="text-decoration-none js-ap-prod"
             data-product="<%# Eval("Id") %>"
             data-default-variant="<%# Eval("DefaultVariantId") %>"
             href="/Product/Product.aspx?id=<%# Eval("Id") %>">
            <div class="fw-semibold" style="color:#0f172a"><%# Eval("Name") %></div>
          </a>

          <span class='badge <%# (Convert.ToInt32(Eval("TotalStock")) > 0) ? "bg-success" : "bg-secondary" %>'>
            <%# (Convert.ToInt32(Eval("TotalStock")) > 0) ? ("Còn " + Eval("TotalStock")) : "Hết hàng" %>
          </span>
        </div>

        <div class="mt-2 ha-price">
          <asp:Literal ID="litPrice" runat="server" Text='<%# Eval("PriceRangeHtml") %>' />
        </div>

        <asp:Literal ID="litVariant" runat="server" Mode="PassThrough"
                     Text='<%# RenderVariantSelect(Container.DataItem) %>' />

        <div class="mt-2 d-grid gap-2">

          <!-- LINK XEM CHI TIẾT: ✅ gắn tracking -->
          <a class="btn btn-outline-secondary btn-sm js-ap-prod"
             data-product="<%# Eval("Id") %>"
             data-default-variant="<%# Eval("DefaultVariantId") %>"
             href="/Product/Product.aspx?id=<%# Eval("Id") %>">Xem chi tiết</a>

          <button type="button"
                  class="btn btn-success btn-sm js-buy"
                  data-product="<%# Eval("Id") %>"
                  data-default-variant="<%# Eval("DefaultVariantId") %>"
                  <%# (Convert.ToInt32(Eval("TotalStock")) > 0) ? "" : "disabled='disabled'" %>>
            Thêm vào giỏ
          </button>
        </div>
      </div>
    </div>
  </div>
</ItemTemplate>

                    <FooterTemplate></div></FooterTemplate>
                  </asp:Repeater>
                </div>
              </div>
            </asp:Panel>

            <!-- ✅ Related posts -->
            <asp:Panel ID="pRelated" runat="server" Visible="false">
              <div class="ha-sidecard">
                <div class="ha-sidehead">
                  <span>Bài viết liên quan</span>
                  <a href="/blog" class="small text-decoration-none" style="font-weight:800;color:#16a34a">Xem thêm</a>
                </div>
                <div class="ha-sidebody">
                  <asp:Repeater ID="rpRelated" runat="server">
                    <HeaderTemplate><div class="row g-2"></HeaderTemplate>
                    <ItemTemplate>
                      <div class="col-12">
                        <a class="text-decoration-none" href="/blog/<%# Eval("slug") %>">
                          <div class="ha-related">
                            <img class="ha-related-img"
                                 src="<%# Eval("cover_Image_Url") %>"
                                 alt=""
                                 loading="lazy"
                                 onerror="this.src='/images/blog-cover-default.png';" />
                            <div class="p-3">
                              <div class="fw-bold line-2" style="color:#0f172a"><%# Eval("title") %></div>
                              <div class="text-muted small mt-2 line-2"><%# Eval("excerpt") %></div>
                            </div>
                          </div>
                        </a>
                      </div>
                    </ItemTemplate>
                    <FooterTemplate></div></FooterTemplate>
                  </asp:Repeater>
                </div>
              </div>
            </asp:Panel>

          </div>
        </div>
      </div>
    </div>

  </div>

  <uc:Footer ID="Footer1" runat="server" />

  <div class="ha-toast" id="haToast" aria-live="polite"></div>

<script>
    (function () {
        function qs(sel, root) { return (root || document).querySelector(sel); }
        function qsa(sel, root) { return Array.prototype.slice.call((root || document).querySelectorAll(sel)); }

        function fire(name, detail) {
            try { window.dispatchEvent(new CustomEvent(name, { detail: detail || {} })); } catch { }
        }

        function toast(msg) {
            var el = qs('#haToast');
            if (!el) return;
            el.textContent = msg || '';
            el.classList.add('show');
            clearTimeout(el.__t);
            el.__t = setTimeout(function () { el.classList.remove('show'); }, 1600);
        }

        // progress bar đọc
        function updateReadProgress() {
            var bar = qs('#readProgressBar');
            if (!bar) return;
            var doc = document.documentElement;
            var scrollTop = window.pageYOffset || doc.scrollTop || 0;
            var scrollHeight = (doc.scrollHeight || 0) - (doc.clientHeight || 1);
            var p = scrollHeight > 0 ? Math.max(0, Math.min(1, scrollTop / scrollHeight)) : 0;
            bar.style.width = (p * 100).toFixed(2) + '%';
        }
        window.addEventListener('scroll', updateReadProgress, { passive: true });
        window.addEventListener('resize', updateReadProgress);
        setTimeout(updateReadProgress, 0);

        // copy link + share fb
        var btnCopy = qs('#btnCopyLink');
        var btnFb = qs('#btnShareFb');
        var url = location.href;

        if (btnFb) btnFb.href = 'https://www.facebook.com/sharer/sharer.php?u=' + encodeURIComponent(url);

        if (btnCopy) {
            btnCopy.addEventListener('click', async function () {
                try {
                    await navigator.clipboard.writeText(url);
                    toast('✅ Đã copy link');
                } catch {
                    // fallback
                    var ta = document.createElement('textarea');
                    ta.value = url;
                    document.body.appendChild(ta);
                    ta.select();
                    try { document.execCommand('copy'); toast('✅ Đã copy link'); } catch { toast('⚠️ Không copy được'); }
                    ta.remove();
                }
            });
        }

        // =========================
        // ARTICLE -> PRODUCT CLICK TRACKING
        // =========================
        function getBootVal(id) {
            var el = document.getElementById(id);
            return el ? (el.value || '').trim() : '';
        }

        var __articleId = parseInt(getBootVal('<%= hidArticleId.ClientID %>') || '0', 10) || 0;
        var __apiBase = (getBootVal('<%= hidApiBase.ClientID %>') || '').replace(/\/+$/, '');

        function trackArticleProductClick(productId, variantId) {
            if (!__articleId) return;

            productId = parseInt(productId || '0', 10) || 0;
            if (!productId) return;

            var v = parseInt(variantId || '0', 10) || 0;

            // Nếu apiBase rỗng thì fallback relative (tuỳ cấu hình bạn)
            var base = __apiBase || '';

            var url =
                base +
                '/api/articles/' + __articleId +
                '/products/' + productId +
                '/click' + (v ? ('?variantId=' + v) : '');

            try {
                if (navigator.sendBeacon) {
                    // sendBeacon mặc định POST, không cần body
                    navigator.sendBeacon(url);
                } else {
                    fetch(url, { method: 'POST', keepalive: true, credentials: 'omit' });
                }
            } catch { }
        }

        // Track click vào link sản phẩm trong card (ảnh/tên/xem chi tiết)
        document.addEventListener('click', function (e) {
            var a = e.target.closest('a.js-ap-prod');
            if (!a) return;

            var card = a.closest('.ha-card') || a.closest('.card');
            var productId = a.getAttribute('data-product') || '';

            var variantId = a.getAttribute('data-default-variant') || '';
            var sel = card ? qs('select.js-variant', card) : null;
            if (sel && sel.value) variantId = sel.value;

            trackArticleProductClick(productId, variantId);
            // KHÔNG preventDefault để vẫn điều hướng bình thường
        }, true);

        // ===== CART (giữ logic của bạn, chỉ giữ phần làm badge update chắc chắn) =====
        function setBtnLoading(btn, on) {
            if (!btn) return;
            if (on) {
                if (!btn.__oldText) btn.__oldText = btn.textContent;
                btn.disabled = true;
                btn.textContent = 'Đang thêm...';
            } else {
                btn.disabled = false;
                if (btn.__oldText) btn.textContent = btn.__oldText;
            }
        }

        function getCount() {
            if (typeof window.getCartBadgeCount === 'function') return window.getCartBadgeCount();
            var b = qs('[data-cart-badge="true"]');
            var n = b ? parseInt(b.textContent || '0', 10) : 0;
            return Number.isFinite(n) ? n : 0;
        }

        function setCount(n) {
            var c = Number(n);
            if (!Number.isFinite(c)) return;

            if (typeof window.setCartBadge === 'function') window.setCartBadge(c);

            qsa('[data-cart-badge="true"]').forEach(function (b) {
                b.textContent = String(c);
                b.style.display = 'flex';
            });

            fire('cart:set', { count: c });
        }

        function bumpBadge() {
            qsa('[data-cart-badge="true"]').forEach(function (b) {
                b.classList.remove('ha-bump');
                void b.offsetWidth;
                b.classList.add('ha-bump');
                clearTimeout(b.__bt);
                b.__bt = setTimeout(function () { b.classList.remove('ha-bump'); }, 220);
            });
        }

        function optimisticAdd() { setCount(getCount() + 1); bumpBadge(); fire('cart:add', { delta: 1 }); }
        function optimisticRevert() { setCount(Math.max(0, getCount() - 1)); fire('cart:revert', { delta: 1 }); }

        function scheduleSync() {
            if (typeof window.refreshCartCount !== 'function') return;
            setTimeout(function () { window.refreshCartCount(); }, 300);
            setTimeout(function () { window.refreshCartCount(); }, 900);
            setTimeout(function () { window.refreshCartCount(); }, 1600);
        }

        function extractCount(any) {
            if (any == null) return null;
            if (typeof any === 'number' && Number.isFinite(any)) return any;
            if (typeof any === 'string') {
                var s = any.trim();
                if (/^\d+$/.test(s)) return parseInt(s, 10);
                return null;
            }
            if (typeof any === 'object') {
                var c = any.count ?? any.item_Count ?? any.itemCount ?? any.cartCount ?? any.data?.count ?? any.data?.item_Count;
                c = Number(c);
                return Number.isFinite(c) ? c : null;
            }
            return null;
        }

        async function addToCartViaAshx(variantId, qty) {
            var base = (window.CART_API || '/Ajax/Cart.ashx');
            var url2 = base + (base.indexOf('?') >= 0 ? '&' : '?') + 'action=add&t=' + Date.now();

            var resp = await fetch(url2, {
                method: 'POST',
                credentials: 'include',
                headers: { 'Content-Type': 'application/json; charset=utf-8' },
                body: JSON.stringify({ VariantId: variantId, Qty: qty || 1 })
            });

            var text = await resp.text();
            var json = null;
            try { json = JSON.parse(text); } catch { }

            if (!resp.ok) {
                var msg = (json && (json.message || json.error)) ? (json.message || json.error)
                    : (text && text.trim().length < 200 ? text.trim() : ('HTTP ' + resp.status));
                throw new Error(msg);
            }

            return { rawText: text, json: json };
        }

        // đổi variant => đổi giá + ảnh
        document.addEventListener('change', function (e) {
            var sel = e.target.closest('select.js-variant');
            if (!sel) return;
            var card = sel.closest('.ha-card') || sel.closest('.card');
            if (!card) return;

            var opt = sel.options[sel.selectedIndex];
            if (!opt) return;

            var price = opt.getAttribute('data-price');
            if (price) {
                var priceBox = qs('.ha-price', card);
                if (priceBox) priceBox.textContent = price;
            }

            var img = opt.getAttribute('data-img');
            if (img) {
                var imgel = qs('img.ha-card-img', card);
                if (imgel) imgel.src = img;
            }
        });

        // add to cart
        document.addEventListener('click', async function (e) {
            var btn = e.target.closest('.js-buy');
            if (!btn) return;

            e.preventDefault();

            var card = btn.closest('.ha-card') || btn.closest('.card');
            var productId = btn.getAttribute('data-product') || '';
            var variantId = btn.getAttribute('data-default-variant') || '';

            var sel = card ? qs('select.js-variant', card) : null;
            if (sel && sel.value) variantId = sel.value;

            variantId = parseInt(variantId || '0', 10);
            if (!variantId) {
                window.location.href = '/Product/Product.aspx?id=' + encodeURIComponent(productId);
                return;
            }
            try { trackArticleProductClick(productId, variantId); } catch { }

            optimisticAdd();

            try {
                setBtnLoading(btn, true);

                var res = await addToCartViaAshx(variantId, 1);

                var c = extractCount(res.json);
                if (c == null) c = extractCount(res.rawText);

                if (c != null) setCount(c);
                else scheduleSync();

                toast('✅ Đã thêm vào giỏ');
                bumpBadge();
            } catch (err) {
                optimisticRevert();
                toast('⚠️ ' + (err && err.message ? err.message : 'Có lỗi xảy ra'));
            } finally {
                setBtnLoading(btn, false);
            }
        });
    })();
</script>

</form>
</body>
</html>
