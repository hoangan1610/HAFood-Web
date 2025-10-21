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
    .text-truncate-2{-webkit-line-clamp:2;display:-webkit-box;-webkit-box-orient:vertical;overflow:hidden}
    .product-card{transition:transform .15s ease, box-shadow .15s ease}
    .product-card:hover{transform:translateY(-3px);box-shadow:0 .5rem 1rem rgba(0,0,0,.06)}

    /* Toast + Fly image */
    .ha-toast {
      position: fixed; top: 20px; right: 20px;
      background: #28a745; color: #fff;
      padding: 10px 14px; border-radius: 6px;
      box-shadow: 0 .25rem .75rem rgba(0,0,0,.15);
      z-index: 20000; display: none;
    }
    .ha-fly-img {
      position: fixed; width: 80px; height: 80px; object-fit: contain;
      pointer-events: none; z-index: 19000; border-radius: 8px;
      transition: transform .6s ease-in, opacity .6s ease-in;
    }
  </style>
</head>

<body>
  <div id="haToast" class="ha-toast">Đã thêm vào giỏ hàng</div>

  <form runat="server">
    <uc:Header ID="Header1" runat="server" />

    <div class="container my-4">
      <!-- BREADCRUMB -->
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
              <input id="qty" name="qty" type="number" class="form-control form-control-sm" value="1" min="1" />
            </div>
            <div class="col-sm-3 d-grid">
              <a id="btnBuy" class="btn btn-warning btn-sm">Mua ngay</a>
            </div>

            <!-- ✅ ScriptManager với PageMethods -->
            <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePartialRendering="true" EnablePageMethods="true" />

            <!-- ✅ UpdatePanel cho nút thêm vào giỏ -->
            <asp:UpdatePanel ID="upAddCart" runat="server" UpdateMode="Conditional">
              <ContentTemplate>
                <div class="col-sm-3 d-grid mt-2 mt-sm-0">
                  <asp:Button ID="btnAddToCart" runat="server" Text="Thêm vào giỏ"
                      CssClass="btn btn-success btn-sm"
                      OnClick="btnAddToCart_Click" />
                </div>
              </ContentTemplate>
              <Triggers>
                <asp:AsyncPostBackTrigger ControlID="btnAddToCart" EventName="Click" />
              </Triggers>
            </asp:UpdatePanel>
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

      <!-- Related -->
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
  </form>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<script>
    // ===== Các function UI giữ nguyên của bạn =====
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

        const rectImg = img.getBoundingClientRect();
        const rectCart = cartIcon.getBoundingClientRect();

        const clone = img.cloneNode(true);
        clone.classList.add('ha-fly-img');
        clone.style.left = rectImg.left + 'px';
        clone.style.top = rectImg.top + 'px';
        clone.style.width = Math.min(rectImg.width, 80) + 'px';
        clone.style.height = Math.min(rectImg.height, 80) + 'px';
        document.body.appendChild(clone);

        const dx = rectCart.left - rectImg.left;
        const dy = rectCart.top - rectImg.top;
        requestAnimationFrame(() => {
            clone.style.transform = `translate(${dx}px, ${dy}px) scale(0.2)`;
            clone.style.opacity = '0.2';
        });
        setTimeout(() => { clone.remove(); }, 650);
    }

    // onAddToCartSuccess: chỉ UI + sync lại count (đã có guard trong Header)
    window.onAddToCartSuccess ??= async function () {
        try { showToast('Đã thêm vào giỏ hàng'); } catch { }
        try { flyToCart(); } catch { }
        try {
            await window.refreshCartCount?.(true);
            setTimeout(() => { try { window.refreshCartCount?.(true); } catch { } }, 200);
        } catch { }
    };

    // ==== BỎ .asmx, dùng Cart.ashx. Tránh khai báo trùng bằng guarded global ====
    window.CART_API = window.CART_API ?? '<%= ResolveUrl("~/Ajax/Cart.ashx") %>';

    // Thêm vào giỏ kiểu optimistic – guard để không redefine
    window.addToCartOptimistic ??= async function () {
        const qtyInput = document.getElementById('qty');
        const qty = Math.max(1, parseInt(qtyInput?.value || '1', 10));

        // + ngay để mượt
        window.dispatchEvent(new CustomEvent('cart:add', { detail: { delta: qty } }));
        try { window.onAddToCartSuccess?.(); } catch { }

        try {
            const productId = parseInt(new URLSearchParams(location.search).get('id') || '0', 10);
            const variantId = parseInt(document.getElementById('<%= ddlVariant.ClientID %>').value || '0', 10);

            const r = await fetch(`${window.CART_API}?action=add`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json; charset=utf-8', 'Accept': 'application/json' },
                credentials: 'include',
                cache: 'no-store',
                body: JSON.stringify({
                    productId,
                    variantId,
                    qty
                    // name/price/image nếu muốn gửi thêm thì bổ sung ở đây
                })
            });
            if (!r.ok) throw new Error('HTTP ' + r.status);
            const j = await r.json();
            if (!j?.ok) throw new Error(j?.message || 'Add failed');

            if (Number.isFinite(j.count)) window.setCartBadge?.(j.count);
            setTimeout(() => { try { window.refreshCartCount?.(true); } catch { } }, 200);
        } catch (err) {
            // Nếu lỗi -> revert số vừa cộng
            window.dispatchEvent(new CustomEvent('cart:revert', { detail: { delta: qty } }));
            console.error('AddToCart failed:', err);
        }
    };

    // Gắn click cho ASP:Button chỉ 1 lần (chặn postback)
    (function bindAddToCartOnce() {
        if (window.__addToCartBound) return;
        window.__addToCartBound = true;

        document.addEventListener('DOMContentLoaded', () => {
            const btn = document.getElementById('<%= btnAddToCart.ClientID %>');
        if (btn) btn.addEventListener('click', e => { e.preventDefault(); window.addToCartOptimistic(); });
    });
    })();

    // ==== (Giữ các đoạn đổi ảnh/biến thể của bạn như cũ) ====
    document.addEventListener('click', function (e) {
        if (e.target && e.target.classList.contains('thumb')) {
            document.getElementById('<%= imgMain.ClientID %>').src = e.target.getAttribute('data-url');
      document.querySelectorAll('.thumb').forEach(x => x.classList.remove('active'));
      e.target.classList.add('active');
    }
  });

  document.addEventListener('DOMContentLoaded', function () {
    const json = document.getElementById('<%= hVariantsJson.ClientID %>').value || '[]';
    const variants = JSON.parse(json);
    const ddl = document.getElementById('<%= ddlVariant.ClientID %>');
    const priceEl = document.getElementById('<%= litPrice.ClientID %>');
    const skuEl = document.getElementById('sku');
    const stockEl = document.getElementById('stock');
    const imgMain = document.getElementById('<%= imgMain.ClientID %>');

      function formatVnd(n) { try { return n.toLocaleString('vi-VN') + 'đ'; } catch { return n + 'đ'; } }
      function apply(v) {
          if (!v) return;
          priceEl.innerText = formatVnd(v.retailPrice);
          skuEl.innerText = v.sku || '';
          stockEl.innerText = (v.stock ?? 0);
          if (v.image) imgMain.src = v.image;
      }

      ddl && ddl.addEventListener('change', function () {
          const id = Number(this.value);
          const v = variants.find(x => x.id === id);
          apply(v);
      });

      if (ddl && ddl.value) {
          const v0 = variants.find(x => x.id === Number(ddl.value));
          apply(v0);
      }
  });
</script>


</body>
</html>
