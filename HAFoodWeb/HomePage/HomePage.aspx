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

<meta name="api-base" content="<%: System.Configuration.ConfigurationManager.AppSettings["ApiBaseUrl"] ?? "" %>" />

  <script>
      window.__API_BASE = (document.querySelector('meta[name="api-base"]')?.content || '').replace(/\/+$/, '');
  </script>

  <!-- Bootstrap -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
  <!-- Bootstrap Icons -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet" />

  <!-- Fonts -->
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Great+Vibes&family=Playfair+Display:wght@600;700&display=swap&subset=latin,vietnamese" rel="stylesheet">
  <link href="https://fonts.googleapis.com/css2?family=Noto+Serif:ital,wght@0,400;0,700;1,400;1,700&display=swap&subset=latin,vietnamese" rel="stylesheet">

  <style>
    :root{
      --haf-primary:#2aa33b;
      --haf-primary-soft:#ecfdf3;
      --haf-accent:#f97316;
      --haf-accent-soft:#fff7ed;
      --haf-bg:#fffaf3;
      --haf-card-bg:#ffffff;
      --haf-radius-lg:24px;
      --haf-radius-md:18px;
      --haf-shadow-soft:0 18px 45px rgba(15,23,42,.08);
      --haf-shadow-subtle:0 10px 30px rgba(15,23,42,.06);
    }

    body{
      line-height:1.6;
      background:radial-gradient(circle at top,#fff7e6 0,#fffaf3 40%,#ffffff 100%);
      color:#111827;
    }

    /* ==== Featured category cards ==== */
    .cat-card{
      background:var(--haf-card-bg);
      border:1px solid #e5e7eb;
      border-radius:var(--haf-radius-md);
      transition:transform .18s ease, box-shadow .18s ease, border-color .18s ease;
      box-shadow:var(--haf-shadow-subtle);
    }
    .cat-card:hover{
      transform:translateY(-4px);
      border-color:#c4ddc7;
      box-shadow:var(--haf-shadow-soft);
    }
    .cat-img{
      max-height:120px;
      object-fit:contain;
      transition:transform .18s ease;
    }
    .cat-card:hover .cat-img{
      transform:translateY(-2px) scale(1.02);
    }
    .cat-name{
      font-weight:700;
      font-size:1.05rem;
      color:var(--haf-primary);
    }

    /* ==== Product cards ==== */
    .text-truncate-2{
      display:-webkit-box;
      -webkit-line-clamp:2;
      -webkit-box-orient:vertical;
      overflow:hidden
    }
    .price-now{
      color:#ef4444;
      font-weight:700
    }
    .price-old{
      text-decoration:line-through;
      color:#9ca3af;
      margin-left:.5rem
    }
    .badge-off{
      position:absolute;
      top:.5rem;
      right:.5rem;
      background:linear-gradient(135deg,#f97316,#facc15);
      color:#111827;
      padding:.35rem .6rem;
      border-radius:.6rem;
      font-weight:700;
      font-size:.75rem;
      display:none;
      box-shadow:0 4px 12px rgba(249,115,22,.25);
    }
    .of-contain{object-fit:contain}

    .ratio-badges{
      position:absolute;
      inset:0;
      z-index:2;
      pointer-events:none;
    }
    .ratio-badges .badge-off{
  position:absolute;
  top:.5rem;
  right:.5rem;
}
    /* ==== Horizontal shelf (Mới về) ==== */
    .shelf{
      display:flex;
      gap:1rem;
      overflow:auto;
      padding-bottom:.75rem;
      scroll-snap-type:x mandatory
    }
    .shelf::-webkit-scrollbar{height:8px}
    .shelf::-webkit-scrollbar-thumb{background:#d1d5db;border-radius:100px}
    .shelf-item{min-width:220px;scroll-snap-align:start}
    @media (min-width:576px){ .shelf-item{min-width:240px} }
    @media (min-width:992px){ .shelf-item{min-width:260px} }

    /* Card polish */
    .product-card{
      transition:transform .18s ease, box-shadow .18s ease, border-color .18s ease;
      border-radius:var(--haf-radius-lg);
      border:1px solid #e5e7eb;
      background:var(--haf-card-bg);
      box-shadow:var(--haf-shadow-subtle);
      overflow:hidden;
    }
    .product-card:hover{
      transform:translateY(-4px);
      box-shadow:var(--haf-shadow-soft);
      border-color:#c4ddc7;
    }

    /* ==== SERVICES (Welcome to HAFood) ==== */
    .services-wrap{
      position:relative;
      background:radial-gradient(circle at top left,#fff1d8 0,#faf8f2 45%,#f4fbf5 100%);
      overflow:hidden;
    }
    .services-wrap::before,
    .services-wrap::after{
      content:"";
      position:absolute;
      border-radius:999px;
      filter:blur(40px);
      opacity:.8;
      pointer-events:none;
    }
    .services-wrap::before{
      width:260px;height:260px;
      background:rgba(250,204,21,.45);
      top:-80px;right:-40px;
    }
    .services-wrap::after{
      width:220px;height:220px;
      background:rgba(16,185,129,.35);
      bottom:-70px;left:-40px;
    }
    .services-wrap > .container{position:relative;z-index:1;}

    .services-wrap .eyebrow{
      font-family:'Great Vibes',cursive;
      color:var(--haf-primary);
      font-size:1.8rem;
      line-height:1;
      margin-bottom:.25rem
    }
    .services-wrap .headline{
      font-family:"Georgia","Noto Serif","Times New Roman",Times,serif;
      font-size:2.1rem;
      font-weight:700;
      font-style:italic;
      color:#111827;
    }

    .service-item{
      padding:1.35rem 1.25rem;
      border-radius:1.5rem;
      text-align:center;
      background:rgba(255,255,255,.9);
      border:1px solid rgba(255,255,255,.6);
      box-shadow:var(--haf-shadow-subtle);
      transition:transform .18s ease, box-shadow .18s ease, border-color .18s ease, background .18s ease;
    }
    .service-item:hover{
      transform:translateY(-4px);
      border-color:rgba(148,163,184,.6);
      box-shadow:var(--haf-shadow-soft);
      background:#ffffff;
    }

    .service-title{
      font-family:"Georgia","Noto Serif","Times New Roman",Times,serif;
      font-weight:700;
      margin:.35rem 0 .45rem;
      cursor:pointer;
      color:var(--haf-primary);
      font-size:1.05rem
    }
    .service-desc{
      font-family:"Georgia","Noto Serif","Times New Roman",Times,serif;
      color:#6b7280;
      font-size:.9rem
    }

    .service-icon{
      width:140px;height:140px;border-radius:999px;margin:0 auto 16px;
      display:flex;align-items:center;justify-content:center;
      perspective:600px;
      font-family:"Georgia","Noto Serif","Times New Roman",Times,serif;
      box-shadow:0 12px 30px rgba(148,163,184,.45);
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
      text-align:center;
      color:#0f172a;
      font-family:"Georgia","Noto Serif","Times New Roman",Times,serif;
      font-weight:700;
      font-style:italic;
      margin:0;
      letter-spacing:.03em;
      position:relative;
    }
    .sec-title::after{
      content:"";
      display:block;
      width:72px;
      height:3px;
      border-radius:999px;
      margin:.45rem auto 0;
      background:linear-gradient(90deg,var(--haf-primary),var(--haf-accent));
    }

    .home-section-header{
      display:flex;
      align-items:center;
      justify-content:space-between;
      gap:.75rem;
    }

    /* ==== Product card tweaks ==== */
    .product-card .ratio,
    .shelf .ratio{
      background:var(--haf-accent-soft) !important
    }
    .product-name{
      font-family:"Georgia","Noto Serif","Times New Roman",Times,serif;
      font-weight:700;
      font-size:1.05rem;
    }
    .product-price{
      font-family:"Georgia","Times New Roman",Times,serif;
      font-size:.95rem;
    }

    /* Flash sale chips – ẨN mặc định; chỉ hiện khi có dữ liệu (class .is-live) */
    .product-price .js-countdown,
    .product-price .js-remaining{
      display:none;
    }
    .product-price .js-countdown.is-live,
    .product-price .js-remaining.is-live{
      display:inline-flex;
      align-items:center;gap:.35rem;
      padding:.18rem .55rem;border-radius:999px;margin-left:.5rem;margin-top:.25rem;
      font-size:.8rem;line-height:1.2;border:1px solid transparent;
    }
    .product-price .js-countdown.is-live{
      background:#ffe4e6;border-color:#fecaca;color:#b91c1c !important;
    }
    .product-price .js-remaining.is-live{
      background:#f3f4f6;border-color:#e5e7eb;color:#374151 !important;
    }

    /* Optional progress bar cho flash sale */
    .fs-progress{position:relative;height:8px;border-radius:999px;background:#f1f5f9;overflow:hidden;margin-top:.5rem}
    .fs-progress__bar{position:absolute;left:0;top:0;height:100%;width:0;background:linear-gradient(90deg,#f97316,#facc15);}

    :lang(vi) {
      font-family: "Noto Serif", "Times New Roman", Times, serif;
    }
    :lang(en), .en-georgia { font-family: Georgia, "Times New Roman", Times, serif; }

    .services-wrap .headline:lang(vi),
    .sec-title:lang(vi),
    .service-title:lang(vi),
    .service-desc:lang(vi),
    .product-name:lang(vi),
    .cat-name:lang(vi) {
      font-family: "Noto Serif", "Times New Roman", Times, serif !important;
    }

    .sec-title, .service-title, .product-name { line-height: 1.35; }

    /* section wrapper cards for homepage blocks (dùng nếu thêm class home-section sau này) */
    .home-section{
      background:rgba(255,255,255,.95);
      border-radius:var(--haf-radius-lg);
      padding:2.25rem 1.75rem;
      box-shadow:var(--haf-shadow-subtle);
    }
    @media (min-width:768px){
      .home-section{padding:2.5rem 2.5rem;}
    }
    .home-section + .home-section{
      margin-top:2.5rem;
    }

    /* ==== VÒNG QUAY POPUP ==== */
    .haf-spin-panel,
    .haf-spin-panel .spin-card,
    .haf-spin-panel .spin-title,
    .haf-spin-panel .spin-sub,
    #spin_turns_label,
    #spin_result_message,
    #btn_spin,
    .haf-spin-header-title span,
    .screen-4 h5,
    .screen-4 h3,
    .screen-4 button {
      font-family: "Noto Serif", "Times New Roman", Times, serif;
    }

    .spin-title{
      font-weight:700;
      font-style:italic;
      font-size:1.4rem;
      margin-bottom:4px;
    }

    .haf-spin-launcher{
      position: fixed;
      right: 30px;
      bottom: 150px;
      display: inline-flex;
      align-items: center;
      gap: 8px;
      height: 44px;
      padding: 0 14px;
      border-radius: 999px;
      border: 0;
      background: linear-gradient(135deg,#f97316,#facc15);
      color: #111827;
      font-weight: 600;
      cursor: pointer;
      box-shadow: 0 10px 24px rgba(0,0,0,.25);
      z-index: 1001;
      font-size: 14px;
      animation:haf-pulse 2.8s ease-in-out infinite;
    }
    .haf-spin-launcher:hover{
      filter: brightness(.95);
      transform: translateY(-1px);
    }

    @keyframes haf-pulse{
      0%,100%{transform:translateY(0) scale(1);}
      50%{transform:translateY(-2px) scale(1.02);}
    }

    .haf-spin-panel{
      position: fixed;
      left: 50%;
      top: 50%;
      width: min(560px, 100vw - 24px);
      max-height: 90vh;
      background: #fff;
      border-radius: 20px;
      box-shadow: 0 30px 70px rgba(0,0,0,.45);
      z-index: 1002;
      display: flex;
      flex-direction: column;
      overflow: hidden;
      opacity: 0;
      visibility: hidden;
      transform: translate(-50%, -45%);
      transition: opacity .18s ease, transform .18s ease, visibility .18s ease;
    }

    .haf-spin-body{
      padding: 12px 16px 20px;
      overflow-y: hidden;
      display: flex;
      align-items: center;
      justify-content: center;
      background: radial-gradient(circle at top,#fff7e6 0,#ffffff 45%,#e5f3ff 100%);
    }

    .spin-card{
      width: 100%;
      max-width: 480px;
      margin: 0 auto;
      background:#fff;
      border-radius: 24px;
      box-shadow: 0 .75rem 2rem rgba(15,23,42,.08);
      padding: 12px 10px 18px;
      text-align:center;
      display:flex;
      flex-direction:column;
      align-items:center;
      justify-content:space-between;
    }

    #btn_spin.disabled {
      color: #9ca3af !important;
      cursor: default;
      text-decoration: none;
    }

    .haf-spin-panel.is-open{
      opacity: 1;
      visibility: visible;
      transform: translate(-50%, -50%);
    }

    .haf-spin-header{
      padding: 10px 14px;
      border-bottom: 1px solid #e5e7eb;
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 8px;
      background: #fff7ea;
    }
    .haf-spin-header-title{
      font-weight: 600;
      display: flex;
      align-items: center;
      gap: 6px;
    }
    .haf-spin-close{
      border: 0;
      background: transparent;
      cursor: pointer;
      color: #6b7280;
      padding: 4px;
    }

    #btn_spin {
      font-size: 1.5rem;
      font-weight: 700;
      text-decoration: none;
    }

    .spin-sub{
      color:#6b7280;
      font-size:.92rem;
      margin-bottom:8px;
    }

    .screen-3,
    .screen-4{
      width: 100%;
      margin: 0 auto;
      display:flex;
      flex-direction:column;
      align-items:center;
      justify-content:center;
    }

    #mycanvas {
      display:block;
      max-width:100%;
      height:auto;
      margin:0 auto;
      image-rendering: auto;
    }

    .screen-3.is-out-of-turns {
      filter: blur(1.5px) grayscale(.1);
      opacity: 0.45;
      pointer-events: none;
      transition: filter .2s ease, opacity .2s ease;
    }

    .screen-4 img{ max-width:75px; height:auto; }

    @media (max-width: 480px){
      .haf-spin-panel{
        width: calc(100vw - 24px);
        max-height: 85vh;
      }
      .haf-spin-launcher{
        right: 10px;
        bottom: 140px;
      }
    }

    .spin-checkin-row{
      width:100%;
      display:flex;
      align-items:center;
      justify-content:space-between;
      gap:8px;
    }

    .spin-checkin-hint{
      flex:1;
      text-align:left;
    }

    @media (max-width: 480px){
      .spin-checkin-row{
        flex-direction:column;
        align-items:flex-start;
      }
      .spin-checkin-hint{
        font-size:.8rem;
      }
    }

        /* ==== MISSION SECTION ==== */
    .mission-section .mission-card{
      border-radius:16px;
      border:1px solid #e5e7eb;
      padding:12px 14px;
      margin-bottom:10px;
      background:#ffffff;
      box-shadow:var(--haf-shadow-subtle);
      display:flex;
      flex-direction:column;
      gap:4px;
    }
    .mission-section .mission-header{
      display:flex;
      align-items:center;
      justify-content:space-between;
      gap:.5rem;
      margin-bottom:2px;
    }
    .mission-section .mission-title{
      font-weight:600;
      font-size:.95rem;
    }
    .mission-section .mission-status{
      font-size:.75rem;
      padding:2px 8px;
      border-radius:999px;
      white-space:nowrap;
    }
    .mission-section .mission-status.available{
      background:#ecfdf3;
      color:#15803d;
    }
    .mission-section .mission-status.completed{
      background:#eff6ff;
      color:#1d4ed8;
    }
    .mission-section .mission-status.maxed{
      background:#f3f4f6;
      color:#4b5563;
    }
    .mission-section .mission-desc{
      font-size:.85rem;
      color:#4b5563;
    }
    .mission-section .mission-reward{
      font-size:.85rem;
      color:#16a34a;
      display:flex;
      align-items:center;
      gap:.35rem;
    }
    .mission-section .mission-meta{
      font-size:.78rem;
      color:#9ca3af;
    }
        /* ==== MISSION PROGRESS (milestone) ==== */
    .mission-section .mission-progress{
      margin-top:4px;
      height:6px;
      border-radius:999px;
      background:#f3f4f6;
      overflow:hidden;
    }
    .mission-section .mission-progress-bar{
      height:100%;
      width:0;
      border-radius:999px;
      background:linear-gradient(90deg,#22c55e,#a3e635);
      transition:width .25s ease-out;
    }
    .mission-section .mission-progress-label{
      font-size:.78rem;
      color:#6b7280;
      margin-top:2px;
    }

    /* ==== BLOG SECTION ==== */
    .blog-section .blog-shelf-wrap{
      position:relative;
      padding: 6px 10px;     
      overflow: visible;     
    }

    .blog-shelf{
      display:flex;
      gap:1rem;
      overflow:auto;
      scroll-snap-type:x mandatory;
      padding: 10px 10px 14px;
      scroll-padding-left: 10px;
      scroll-padding-right: 10px;
    }
    .blog-shelf::-webkit-scrollbar{height:8px}
    .blog-shelf::-webkit-scrollbar-thumb{background:#d1d5db;border-radius:100px}

    .blog-item{
      min-width: 320px;
      max-width: 320px;
      scroll-snap-align:start;
    }
    @media (min-width:576px){
      .blog-item{min-width:360px;max-width:360px;}
    }

    .blog-card{
      border: 1.5px solid rgba(229,231,235,.9);   
      border-radius: 18px;
      background:#ffffff;
      overflow:hidden;
      height:100%;
      display:flex;
      flex-direction:column;
      transition:transform .18s ease, box-shadow .18s ease, border-color .18s ease;
    }
    .blog-card:hover{
      transform:translateY(-3px);
      border-color: rgba(196,221,199,.95);
    }

    .blog-thumb{
      width:100%;
      height: 175px;
      background:var(--haf-accent-soft);
      display:flex;
      align-items:center;
      justify-content:center;
    }
    .blog-thumb img{ width:100%; height:100%; object-fit:cover; }

    .blog-body{
      padding:12px 14px;
      display:flex;
      flex-direction:column;
      gap:6px;
      flex:1;
      -webkit-font-smoothing: antialiased;
      -moz-osx-font-smoothing: grayscale;
    }
    .blog-title, .blog-excerpt, .blog-meta{
      font-family:"Noto Serif","Times New Roman",Times,serif !important;
    }
    .blog-title{
      font-weight:700;
      font-size:1.05rem;
      line-height:1.35;
      color:#111827;
    }
    .blog-excerpt{ color:#6b7280; font-size:.88rem; }
    .blog-meta{ color:#9ca3af; font-size:.78rem; margin-top:auto; }

    .blog-nav{
      position:absolute;
      top:50%;
      transform:translateY(-50%);
      width:36px;height:36px;
      border-radius:999px;
      border:0;
      background:rgba(255,255,255,.92);
      box-shadow:0 10px 24px rgba(15,23,42,.14);
      display:none;
      align-items:center;
      justify-content:center;
      z-index:5;
    }
    .blog-nav.is-show{display:flex}
    .blog-nav:hover{filter:brightness(.97)}
    .blog-nav-left{left:0}     /* ✅ tránh bị cắt */
    .blog-nav-right{right:0}   /* ✅ tránh bị cắt */

    /* ép badge trong ratio KHÔNG được full cover */
.ratio > .badge-off.js-badge-off{
  width: max-content !important;
  height: auto !important;
  inset: auto !important;

  top: .5rem !important;
  right: .5rem !important;
  left: auto !important;
  bottom: auto !important;

  display: none; /* mặc định ẩn */
  pointer-events: none !important;
  z-index: 10 !important;
}

  </style>
</head>

<body>
<form runat="server">
  <asp:ScriptManager ID="sm" runat="server" />

  <!-- HEADER -->
  <uc:Header ID="Header1" runat="server" />

  <!-- SLIDESHOW -->
  <uc:Slideshow ID="Slideshow1" runat="server" />

  <!-- SERVICES -->
  <section class="services-wrap py-5">
    <div class="container">
      <div class="text-center mb-4">
        <div class="eyebrow" lang="en">Services</div>
        <div class="headline">Chào mừng đến với HAFood</div>
      </div>

      <div class="row g-4 justify-content-center">
        <div class="col-6 col-md-3">
          <div class="service-item fresh">
            <div class="service-icon">
              <img src="/images/services/service-fresh.svg" alt="Always Fresh" loading="lazy" lang="en" />
            </div>
            <h5 class="service-title">Thực phẩm luôn sạch</h5>
            <p class="service-desc">Chúng tôi luôn quan đảm bảo về an toàn vệ sinh thực phẩm</p>
          </div>
        </div>

        <div class="col-6 col-md-3">
          <div class="service-item natural">
            <div class="service-icon">
              <img src="/images/services/service-natural.svg" alt="100% Natural" loading="lazy" lang="en" />
            </div>
            <h5 class="service-title">100% Tự nhiên</h5>
            <p class="service-desc">Nguyên liệu luôn sạch sẽ tự nhiên không chất bảo quản</p>
          </div>
        </div>

        <div class="col-6 col-md-3">
          <div class="service-item quality">
            <div class="service-icon">
              <img src="/images/services/service-quality.svg" alt="Best Quality" loading="lazy" lang="en" />
            </div>
            <h5 class="service-title">Chất lượng tốt nhất</h5>
            <p class="service-desc">Chúng tôi luôn đặt chất lượng sản phẩm lên hàng đầu</p>
          </div>
        </div>

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

  <!-- NEW ARRIVALS -->
  <div class="container my-5">
    <div class="text-center mb-3">
      <h3 class="sec-title">Sản phẩm mới về</h3>
      <a href="/category.aspx?sort=created_at:desc" class="text-decoration-none">Xem tất cả ›</a>
    </div>

    <div class="shelf">
      <asp:Repeater ID="rpNew" runat="server">
        <ItemTemplate>
          <div class="shelf-item">
            <!-- THÊM data-product-id + đổi nút thành Mua ngay -->
            <div class="card product-card shadow-sm h-100 js-product-card" data-product-id="<%# Eval("Id") %>">
              <a href='<%# Eval("Id", ResolveUrl("~/product/Product.aspx?id={0}")) %>' class="text-decoration-none">
                <div class="ratio ratio-4x3 position-relative">
                  <!-- ✅ FIX: chuẩn hoá URL ảnh (API base/relative) để không bị fallback về ảnh xanh -->
                  <img src="<%# ProductImageUrl(Eval("ImageUrl")) %>" loading="eager" decoding="async" fetchpriority="high"
                       class="w-100 h-100 of-contain p-2" alt="<%# Eval("Name") %>"
                       onerror="this.onerror=null;this.src='<%= ResolveUrl("~/images/product-default.png") %>';" />

                  <!-- ✅ Badge phải nằm trong wrapper để KHÔNG bị .ratio kéo giãn phủ kín -->
                  <div class="ratio-badges">
                    <div class="badge-off js-badge-off"></div>
                    <span class="badge bg-success badge-new">Mới</span>
                  </div>
                </div>
                </a>

              <div class="card-body d-flex flex-column">
                <h6 class="mb-1 text-truncate-2">
                  <a class="text-dark text-decoration-none product-name"
                     href='<%# Eval("Id", ResolveUrl("~/product/Product.aspx?id={0}")) %>'><%# Eval("Name") %></a>
                </h6>

                <div class="mb-2 product-price">
                  <span class="price-now js-price-now"><%# Eval("PriceRangeHtml") %></span>
                  <span class="price-old js-price-old"></span>
                  <small class="text-danger ms-2 js-countdown"></small>
                  <small class="text-muted ms-2 js-remaining"></small>
                </div>

                <select class="form-select form-select-sm mb-2 js-variant-select">
                  <asp:Repeater ID="rpVar" runat="server" DataSource='<%# Eval("Variants") %>'>
                    <ItemTemplate>
                      <option value="<%# Eval("Id") %>"><%# Eval("Label") %></option>
                    </ItemTemplate>
                  </asp:Repeater>
                </select>

                <!-- NÚT MUA NGAY -->
                <button type="button" class="btn btn-warning btn-sm mt-auto w-100 js-buy-now">Mua ngay</button>
              </div>
            </div>
          </div>
        </ItemTemplate>
      </asp:Repeater>
    </div>
  </div>


     <!-- MISSIONS (NHIỆM VỤ) -->
  <div class="container my-5">
    <div class="home-section mission-section">
      <div class="home-section-header mb-3">
        <h3 class="sec-title mb-0">Nhiệm vụ của bạn</h3>
        <div class="d-flex align-items-center gap-2">
          <small id="mission_hint" class="text-muted d-none d-sm-inline">
            Hoàn thành nhiệm vụ để nhận lượt quay &amp; điểm thưởng.
          </small>
          <button type="button"
                  id="btnMissionRefresh"
                  class="btn btn-outline-success btn-sm"
                  title="Làm mới">
            <i class="bi bi-arrow-clockwise"></i>
          </button>
        </div>
      </div>

      <div id="mission-list">
        <div class="text-muted small">Đang tải nhiệm vụ...</div>
      </div>
    </div>
  </div>

    <!-- BLOGS (BÀI VIẾT) -->
    <div class="container my-5">
      <div class="home-section blog-section">
        <div class="home-section-header mb-3">
          <h3 class="sec-title mb-0">Bài viết</h3>
          <div class="d-flex align-items-center gap-2">
            <small class="text-muted d-none d-sm-inline">
              Cập nhật tin tức &amp; mẹo hay mỗi ngày.
            </small>
            <button type="button"
                    id="btnBlogRefresh"
                    class="btn btn-outline-success btn-sm"
                    title="Làm mới">
              <i class="bi bi-arrow-clockwise"></i>
            </button>
          </div>
        </div>

        <div class="blog-shelf-wrap">
          <button type="button" class="blog-nav blog-nav-left" id="blogNavLeft" aria-label="Trước">
            <i class="bi bi-chevron-left"></i>
          </button>

          <div id="blog-shelf" class="blog-shelf">
            <div class="text-muted small">Đang tải bài viết...</div>
          </div>

          <button type="button" class="blog-nav blog-nav-right" id="blogNavRight" aria-label="Sau">
            <i class="bi bi-chevron-right"></i>
          </button>
        </div>

        <div class="mt-2 small">
          <a href="/blog" class="text-decoration-none">Xem tất cả bài viết ›</a>
        </div>
      </div>
    </div>

  <!-- RECOMMENDED GRID -->
  <div class="container my-5">
    <h3 class="sec-title mb-4">Gợi ý cho bạn</h3>

    <asp:Repeater ID="rpProducts" runat="server">
      <HeaderTemplate><div class="row gx-3 gy-4"></HeaderTemplate>
      <ItemTemplate>
        <div class="col-12 col-sm-6 col-lg-3">
          <!-- THÊM data-product-id -->
          <div class="card product-card h-100 shadow-sm d-flex js-product-card" data-product-id="<%# Eval("Id") %>">
            <a href='<%# Eval("Id", ResolveUrl("~/product/Product.aspx?id={0}")) %>' class="text-decoration-none">
              <div class="ratio ratio-4x3 position-relative">
                <!-- ✅ FIX tương tự cho phần Gợi ý -->
                <img src="<%# ProductImageUrl(Eval("ImageUrl")) %>" loading="lazy"
                     class="w-100 h-100 of-contain p-2"
                     onerror="this.onerror=null;this.src='<%# ResolveUrl("~/images/product-default.png") %>';" 
                     alt="<%# Eval("Name") %>" />

                    <div class="ratio-badges">
                <div class="badge-off js-badge-off"></div>
                        </div>
              </div>
            </a>

            <div class="card-body d-flex flex-column">
              <h6 class="card-title text-truncate-2 mb-2">
                <a class="text-dark text-decoration-none product-name"
                   href='<%# Eval("Id", ResolveUrl("~/product/Product.aspx?id={0}")) %>'><%# Eval("Name") %></a>
              </h6>

              <div class="mb-2 product-price">
                <span class="price-now js-price-now"><%# Eval("PriceRangeHtml") %></span>
                <span class="price-old js-price-old"></span>
                <small class="text-danger ms-2 js-countdown"></small>
                <small class="text-muted ms-2 js-remaining"></small>
              </div>

              <div class="mb-2">
                <select class="form-select form-select-sm js-variant-select">
                  <asp:Repeater ID="rpVariantInner" runat="server" DataSource='<%# Eval("Variants") %>'>
                    <ItemTemplate><option value="<%# Eval("Id") %>"><%# Eval("Label") %></option></ItemTemplate>
                  </asp:Repeater>
                </select>
              </div>

              <div class="d-flex align-items-center gap-2 mt-auto">
                <label class="me-2">SL</label>
                <!-- THÊM class js-qty-input -->
                <input type="number" class="form-control form-control-sm js-qty-input" style="width:90px" value="1" min="1" />
                <!-- NÚT MUA NGAY -->
                <button type="button" class="btn btn-warning btn-sm ms-auto js-buy-now">Mua ngay</button>
              </div>
            </div>
          </div>
        </div>
      </ItemTemplate>
      <FooterTemplate></div></FooterTemplate>
    </asp:Repeater>
  </div>


  <!-- POPUP VÒNG QUAY MAY MẮN -->
  <div id="hafSpinPanel" class="haf-spin-panel" aria-hidden="true">
    <div class="haf-spin-header">
      <div class="haf-spin-header-title">
        <span>🎁 Vòng quay HAFood</span>
      </div>
      <button type="button" class="haf-spin-close" id="hafSpinClose" aria-label="Đóng vòng quay">
        <i class="bi bi-x-lg"></i>
      </button>
    </div>
    <div class="haf-spin-body">
      <div class="spin-card">

        <!-- NÚT ĐIỂM DANH + GỢI Ý -->
        <div class="spin-checkin-row mb-2">
          <button type="button"
                  id="btnCheckin"
                  class="btn btn-outline-success btn-sm">
            ✅ Điểm danh hôm nay
          </button>
          <small id="checkin_hint"
                 class="spin-checkin-hint text-muted">
            Điểm danh mỗi ngày để nhận thêm điểm thưởng và lượt quay.
          </small>
        </div>

        <p id="checkin_status" class="small mb-2"></p>

        <p id="spin_turns_label" class="small text-secondary mb-2"></p>

        <!-- MÀN HÌNH VÒNG QUAY -->
        <div class="screen-3">
          <canvas id="mycanvas" width="500" height="500"></canvas>
          <a href="javascript:void(0)" id="btn_spin"
             onclick="clickSpinRota()"
             class="text-primary mt-3 h5 d-block text-center text-decoration-none">
            Bấm để quay
          </a>
        </div>

        <!-- MÀN HÌNH KẾT QUẢ -->
        <div class="screen-4" style="display:none">
          <h5 class="text-center mt-3 mb-3">
            Chúc mừng bạn nhận được<br /> phần quà
          </h5>
          <div class="img-reward text-center mb-2">
            <img id="img_result_spin"
                 src="<%= ResolveUrl("~/assets/spin/item-random/item1.png") %>" />
          </div>
          <h3 class="text-center mt-2 mb-2"
              id="name_result_spin"
              style="color:#2600ff"></h3>

          <p id="spin_result_message" class="mt-2 mb-2 text-muted"></p>

          <button type="button"
                  class="btn btn-outline-primary mt-2"
                  onclick="backToWheel()">
            Quay tiếp
          </button>
        </div>
      </div>
    </div>
  </div>

  <!-- NÚT FLOATING MỞ VÒNG QUAY -->
  <button id="hafSpinLauncher" type="button" class="haf-spin-launcher">
    🍀 Vòng quay
  </button>

  <!-- FOOTER -->
  <uc:Footer ID="Footer1" runat="server" />

  <!-- JS -->
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
  <script>
    // icon xoay 1 vòng khi hover tiêu đề
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

  <!-- Flash sale JS tách file (cập nhật text cho countdown/remaining) -->
  <script src="/assets/js/flashsale.js?v=1"></script>

  <!-- CreateJS cho Vòng quay -->
  <script src="https://code.createjs.com/1.0.0/easeljs.min.js"></script>
  <script src="https://code.createjs.com/1.0.0/tweenjs.min.js"></script>

  <!-- ====== ENHANCE PRODUCT CARD + FLASH SALE ====== -->
  <script>
    (function(){
      // Parse số tiền VN từ chuỗi "36.000 đ"
      function hafParseVnMoney(txt){
        if(!txt) return NaN;
        const n = String(txt).replace(/[^\d]/g,'');
        return n ? Number(n) : NaN;
      }

      // Chuẩn hoá text để biết có dữ liệu thật không
      function normalizeChipText(s){
        return (s||'').replace(/[\s\u00A0\-–—:]/g,'').trim();
      }
      // Chỉ hiện khi có dữ liệu
      function toggleChipLive(el){
        if(!el) return;
        const has = normalizeChipText(el.textContent).length > 0;
        if(has){
          el.classList.add('is-live');
          el.style.display = '';
        }else{
          el.classList.remove('is-live');
          el.style.display = 'none';
        }
      }

      function enhanceOneCard(card){
        const priceNowEl = card.querySelector('.js-price-now');
        const priceOldEl = card.querySelector('.js-price-old');
        const badgeOff   = card.querySelector('.js-badge-off');
        const countdown  = card.querySelector('.js-countdown');
        const remaining  = card.querySelector('.js-remaining');
        const priceBox   = card.querySelector('.product-price');

        // 1) Tự tính % giảm để hiển thị badge (nếu có dữ liệu)
        try{
          if (badgeOff && priceNowEl){
            const nowAttr = card.getAttribute('data-price-now');
            const oldAttr = card.getAttribute('data-price-old');
            let now = nowAttr ? Number(nowAttr) : hafParseVnMoney(priceNowEl.textContent || priceNowEl.innerText);
            let old = oldAttr ? Number(oldAttr) : hafParseVnMoney(priceOldEl && (priceOldEl.textContent || priceOldEl.innerText));

            if (!isNaN(now) && !isNaN(old) && old > now){
              const pct = Math.max(1, Math.round((1 - now/old) * 100));
              badgeOff.textContent = '-' + pct + '%';
              badgeOff.style.display = 'block';
            }
          }
        }catch(e){}

        // 2) Chip flash sale: chỉ bật khi có dữ liệu
        toggleChipLive(countdown);
        toggleChipLive(remaining);

        // 3) Progress bar nếu có data-left & data-total
        if (priceBox){
          const left = Number(card.getAttribute('data-left'));
          const total = Number(card.getAttribute('data-total'));
          if (!isNaN(left) && !isNaN(total) && total > 0){
            let wrap = priceBox.querySelector('.fs-progress');
            const sold = Math.max(0, Math.min(100, Math.round(((total - left)/total)*100)));
            if (!wrap){
              wrap = document.createElement('div');
              wrap.className = 'fs-progress';
              const bar = document.createElement('div');
              bar.className = 'fs-progress__bar';
              wrap.appendChild(bar);
              priceBox.appendChild(wrap);
            }
            const bar = wrap.querySelector('.fs-progress__bar');
            if (bar) bar.style.width = sold + '%';
          }
        }
      }

      function enhanceAllCards(){
        document.querySelectorAll('.js-product-card').forEach(enhanceOneCard);
      }

      document.addEventListener('DOMContentLoaded', function(){
        enhanceAllCards();
        // chạy lại sau khi flashsale.js có thể đã đổ dữ liệu
        setTimeout(enhanceAllCards, 1200);

        // Theo dõi thay đổi trong vùng giá để cập nhật lại badge/progress/chips
        const obs = new MutationObserver(function(mutations){
          const touched = new Set();
          mutations.forEach(m => {
            const card = (m.target && m.target.closest) ? m.target.closest('.js-product-card') : null;
            if (card) touched.add(card);
          });
          touched.forEach(enhanceOneCard);
        });
        document.querySelectorAll('.js-product-card .product-price').forEach(box=>{
          obs.observe(box, {subtree:true, characterData:true, childList:true});
        });
      });
    })();
  </script>

  <!-- ====== VÒNG QUAY – LOGIC ====== -->
  <script>
    var iconLayer;
    var baseAngles = [];
    var ICON_OFFSET = 95;

    // ====== GLOBAL ======
    var stage, imgRotation, imgCoverRota, centerRota;
    var item_random_file = "item-random";

    var remainingSpins = null;
    var hasLogin = true;
    var hasCheckedInToday = false;

    var linkImg = '<%= ResolveUrl("~/assets/spin/") %>';

      var imgContainRota = new Image();
      var imgCenterRota = new Image();
      imgContainRota.src = linkImg + "Vong-quay-nen.png";
      imgCenterRota.src = linkImg + "kim-vong-quay.png";

      var spinning = false;
      var spinningContinuous = false;
      var spinSpeed = 720;
      var totalRota = 5;
      var timeRota = 4000;

      function refreshSpinButtonByTurns() {
          var btn = document.getElementById("btn_spin");
          if (!btn) return;

          if (spinning) return;

          if (!hasLogin) {
              btn.classList.add("disabled");
              btn.style.pointerEvents = "none";
              btn.textContent = "Đăng nhập để quay";
              return;
          }

          if (remainingSpins == null) {
              btn.classList.add("disabled");
              btn.style.pointerEvents = "none";
              btn.textContent = "Đang kiểm tra...";
              return;
          }

          if (remainingSpins <= 0) {
              btn.classList.add("disabled");
              btn.style.pointerEvents = "none";
              btn.textContent = "Hết lượt quay";
          } else {
              btn.classList.remove("disabled");
              btn.style.pointerEvents = "";
              btn.textContent = "Bấm để quay";
          }
      }

      function updateSpinTurnsLabel() {
          var el = document.getElementById("spin_turns_label");
          if (!el) return;

          if (!hasLogin) {
              el.textContent = "Vui lòng đăng nhập để sử dụng vòng quay.";
              refreshSpinButtonByTurns();
              refreshSpinVisualState();
              return;
          }

          if (remainingSpins == null) {
              el.textContent = "Đang kiểm tra lượt quay...";
              refreshSpinButtonByTurns();
              refreshSpinVisualState();
              return;
          }

          if (remainingSpins > 0) {
              el.textContent = "Bạn còn " + remainingSpins + " lượt quay.";
          } else {
              el.textContent = "Bạn đã sử dụng hết lượt quay.";
          }

          refreshSpinButtonByTurns();
          refreshSpinVisualState();
      }

      function refreshSpinVisualState() {
          var s3 = document.querySelector('.screen-3');
          if (!s3) return;

          if (!hasLogin || (remainingSpins != null && remainingSpins <= 0)) {
              s3.classList.add("is-out-of-turns");
          } else {
              s3.classList.remove("is-out-of-turns");
          }
      }

      function setSpinButtonState(isSpinning) {
          var btn = document.getElementById("btn_spin");
          if (!btn) return;

          if (isSpinning) {
              spinning = true;
              btn.classList.add("disabled");
              btn.style.pointerEvents = "none";
              btn.textContent = "Đang quay...";
          } else {
              spinning = false;
              refreshSpinButtonByTurns();
          }
      }

      function init() {
          stage = new createjs.Stage("mycanvas");
          stage.snapToPixelEnabled = true;

          createjs.Touch.enable(stage);
          stage.enableMouseOver();

          imgCoverRota = new createjs.Container();
          stage.addChild(imgCoverRota);

          imgRotation = new createjs.Container();
          imgCoverRota.addChild(imgRotation);

          iconLayer = new createjs.Container();
          imgCoverRota.addChild(iconLayer);

          var toLoad = 2;
          function onLoadedImg() {
              toLoad--;
              if (toLoad === 0 && totalItem > 0) {
                  buildWheel();
              }
          }
          if (imgContainRota.complete) onLoadedImg(); else imgContainRota.onload = onLoadedImg;
          if (imgCenterRota.complete) onLoadedImg(); else imgCenterRota.onload = onLoadedImg;

          createjs.Ticker.framerate = 60;
          createjs.Ticker.on("tick", function (evt) {
              if (spinningContinuous && imgRotation) {
                  imgRotation.rotation += spinSpeed * (evt.delta / 1000);
              }
              updateAllIconsPosition();
              stage.update(evt);
          });

          window.addEventListener('resize', handleResize);
      }

      const SLICE_COLORS = [
          "rgba(255, 255, 255, 0.18)",
          "rgba(255, 190, 120, 0.35)"
      ];

      function buildWheel() {
          imgRotation.removeAllChildren();

          imgCoverRota.removeAllChildren();
          imgCoverRota.addChild(imgRotation);
          imgCoverRota.addChild(iconLayer);

          iconLayer.removeAllChildren();
          baseAngles = [];

          var baseSize = imgContainRota.width;
          stage.canvas.width = baseSize;
          stage.canvas.height = baseSize;

          imgCoverRota.x = baseSize / 2;
          imgCoverRota.y = baseSize / 2;

          imgCoverRota.scaleX = 1;
          imgCoverRota.scaleY = 1;

          var wheel = new createjs.Bitmap(imgContainRota);
          wheel.regX = imgContainRota.width / 2;
          wheel.regY = imgContainRota.height / 2;
          imgRotation.addChild(wheel);

          var wheelRadius = imgContainRota.width / 2;
          var sliceOuter = wheelRadius - 4;

          for (let i = 0; i < totalItem; i++) {
              var startDeg = degItem * i;
              var endDeg = startDeg + degItem;

              var startRadArc = (startDeg - 90) * Math.PI / 180;
              var endRadArc = (endDeg - 90) * Math.PI / 180;

              var slice = new createjs.Shape();
              var g = slice.graphics;

              var color = SLICE_COLORS[i % SLICE_COLORS.length];

              g.beginFill(color);
              g.moveTo(0, 0);
              g.lineTo(
                  Math.cos(startRadArc) * sliceOuter,
                  Math.sin(startRadArc) * sliceOuter
              );
              g.arc(0, 0, sliceOuter, startRadArc, endRadArc);
              g.closePath();
              g.endFill();

              imgRotation.addChild(slice);
          }

          for (let i = 0; i < totalItem; i++) {
              const angleDeg = degItem * i + degItem / 2;
              baseAngles[i] = angleDeg;

              let img = new Image();
              img.src = linkImg + item_random_file + "/" + arrItem[i].src + ".png";

              img.onload = function () {
                  let bmp = new createjs.Bitmap(img);
                  bmp.regX = img.width / 2;
                  bmp.regY = img.height / 2;

                  bmp.__slotIndex = i;

                  const maxW = 72, maxH = 104;
                  const scale = Math.min(1, maxW / img.width, maxH / img.height);
                  bmp.scaleX = bmp.scaleY = scale;

                  iconLayer.addChild(bmp);
                  updateSingleIconPosition(bmp);
                  stage.update();
              };
          }

          centerRota = new createjs.Bitmap(imgCenterRota);
          centerRota.regX = imgCenterRota.width / 2;
          centerRota.regY = imgCenterRota.height / 2;
          centerRota.scaleX = 0.5;
          centerRota.scaleY = 0.5;
          centerRota.x = 0;
          centerRota.y = 0;
          imgCoverRota.addChild(centerRota);

          stage.update();
          handleResize();
      }

      function updateSingleIconPosition(bmp) {
          if (!bmp || bmp.__slotIndex == null) return;
          if (!imgContainRota || !imgContainRota.complete) return;

          var wheelRadius = imgContainRota.width / 2;
          var r = wheelRadius - ICON_OFFSET;

          var slotIndex = bmp.__slotIndex;
          var baseAngle = baseAngles[slotIndex] || 0;

          var currentWheelDeg = imgRotation ? imgRotation.rotation : 0;
          var angleDeg = baseAngle + currentWheelDeg;
          var angleRad = angleDeg * Math.PI / 180;

          bmp.x = Math.sin(angleRad) * r;
          bmp.y = -Math.cos(angleRad) * r;

          bmp.rotation = 0;
      }

      function updateAllIconsPosition() {
          if (!iconLayer) return;
          for (let i = 0; i < iconLayer.numChildren; i++) {
              updateSingleIconPosition(iconLayer.getChildAt(i));
          }
      }

      function handleResize() {
          if (!stage || !imgCoverRota || !imgContainRota.complete) return;

          var canvas = stage.canvas;
          var baseSize = imgContainRota.width || 500;
          var host = document.querySelector('.screen-3');

          var hostWidth = host ? host.clientWidth : window.innerWidth;
          var maxByWidth = Math.max(220, hostWidth - 24);

          var viewportH = window.innerHeight || document.documentElement.clientHeight || 600;
          var panelMaxH = viewportH * 0.9;
          var reservedTopBottom = 220;
          var maxByHeight = Math.max(220, panelMaxH - reservedTopBottom);

          var maxLogical = baseSize;

          var size = Math.min(maxLogical, maxByWidth, maxByHeight);
          size = Math.max(220, size);

          canvas.width = size;
          canvas.height = size;

          imgCoverRota.x = size / 2;
          imgCoverRota.y = size / 2;

          var scale = size / baseSize;
          imgCoverRota.scaleX = scale;
          imgCoverRota.scaleY = scale;

          stage.update();
      }

      function stopWithResult(indexItem) {
          if (!spinning) return;
          spinningContinuous = false;

          var resultAngle = 360 - (degItem * indexItem + degItem / 2);

          var current = imgRotation.rotation;
          var curNorm = ((current % 360) + 360) % 360;

          var delta = (resultAngle - curNorm + 360) % 360;
          var target = current + totalRota * 360 + delta;

          createjs.Tween.removeTweens(imgRotation);
          createjs.Tween.get(imgRotation, { override: true })
              .to({ rotation: target }, timeRota, createjs.Ease.getPowOut(3))
              .call(function () { endRota(indexItem); });
      }

      function setSpinResultVisual(itemResult) {
          var imgEl = document.getElementById('img_result_spin');
          if (imgEl) {
              imgEl.src = linkImg + item_random_file + "/" + itemResult.src + ".png";
          }
          var nameEl = document.getElementById('name_result_spin');
          if (nameEl) {
              nameEl.textContent = itemResult.name || '';
          }
      }

      function setSpinMessage(msg) {
          var el = document.getElementById('spin_result_message');
          if (!el) return;
          if (!msg) {
              el.textContent = '';
              el.style.display = 'none';
          } else {
              el.textContent = msg;
              el.style.display = '';
          }
      }

      function endRota(indexItem) {
          spinning = false;
          spinningContinuous = false;
          pointerEffectStop();
          setSpinButtonState(false);

          var itemResult = arrItem[indexItem];
          setSpinResultVisual(itemResult);

          setTimeout(function () {
              var screen3 = document.querySelector('.screen-3');
              var screen4 = document.querySelector('.screen-4');
              if (screen3 && screen4) {
                  screen3.style.display = 'none';
                  screen4.style.display = '';
              }
          }, 800);
      }

      function startPointerShake() {
          if (!centerRota) return;
          createjs.Tween.removeTweens(centerRota);
          createjs.Tween.get(centerRota, { loop: true })
              .to({ rotation: -4 }, 120, createjs.Ease.sineInOut)
              .to({ rotation: 4 }, 240, createjs.Ease.sineInOut)
              .to({ rotation: 0 }, 120, createjs.Ease.sineInOut);
      }
      function pointerEffectStop() {
          if (!centerRota) return;
          createjs.Tween.removeTweens(centerRota);
          createjs.Tween.get(centerRota).to({ rotation: 0 }, 60, createjs.Ease.quadInOut);
      }

      function getRandomInt(min, max) {
          min = Math.ceil(min);
          max = Math.floor(max);
          return Math.floor(Math.random() * (max - min + 1)) + min;
      }

      function formatVnMoney(v) {
          v = Number(v) || 0;
          return v.toLocaleString("vi-VN") + " ₫";
      }

      function refreshCheckinUi() {
          var btn = document.getElementById('btnCheckin');
          var hint = document.getElementById('checkin_hint');
          if (!btn) return;

          if (!hasLogin) {
              btn.disabled = false;
              btn.classList.remove('btn-success');
              btn.classList.add('btn-outline-success');
              btn.textContent = '✅ Điểm danh hôm nay';
              if (hint) hint.style.display = '';
              return;
          }

          if (hasCheckedInToday) {
              btn.disabled = true;
              btn.classList.remove('btn-outline-success');
              btn.classList.add('btn-success');
              btn.textContent = '✅ Đã điểm danh hôm nay';
              if (hint) hint.style.display = 'none';
          } else {
              btn.disabled = false;
              btn.classList.remove('btn-success');
              btn.classList.add('btn-outline-success');
              btn.textContent = '✅ Điểm danh hôm nay';
              if (hint) hint.style.display = '';
          }
      }

      // ====== TÍCH HỢP API – SPIN_PROXY & CHECKIN ======
      const SPIN_PROXY = '<%= ResolveUrl("~/Proxy/SpinProxy.ashx") %>';
      const API_BASE = (window.__API_BASE || '').replace(/\/+$/, '') || window.location.origin;
      const CHECKIN_URL = SPIN_PROXY + '?action=checkin';

      var arrItem = [];
      var totalItem = 0;
      var degItem = 0;
      var currentSpinTurnId = null;

      function loadSpinConfig() {
          return fetch(SPIN_PROXY + '?action=config', {
              method: 'GET',
              credentials: 'include',
              cache: 'no-store'
          })
              .then(async r => {
                  if (r.status === 401) {
                      hasLogin = false;
                      remainingSpins = 0;
                      updateSpinTurnsLabel();

                      return {
                          items: [
                              { id: 1, label: 'Ưu đãi 10k', icon_key: 'item1', reward_type: 4 },
                              { id: 2, label: 'Ưu đãi 20k', icon_key: 'item2', reward_type: 4 },
                              { id: 3, label: 'Ưu đãi 30k', icon_key: 'item3', reward_type: 4 },
                              { id: 4, label: 'Ưu đãi 40k', icon_key: 'item4', reward_type: 4 },
                              { id: 5, label: 'Chúc bạn may mắn', icon_key: 'item5', reward_type: 4 }
                          ]
                      };
                  }

                  if (!r.ok) {
                      const txt = await r.text().catch(() => '');
                      console.error('config error', r.status, txt);
                      throw new Error('Không lấy được cấu hình vòng quay (HTTP ' + r.status + ')');
                  }

                  return r.json();
              })
              .then(cfg => {
                  arrItem = (cfg.items || []).map(function (it, idx) {
                      const iconKey =
                          it.icon_key ?? it.iconKey ?? it.icon_Key;

                      const rewardType =
                          it.reward_type ?? it.rewardType ?? it.reward_Type;

                      const rewardValue =
                          it.reward_value ?? it.rewardValue ?? it.reward_Value;

                      return {
                          config_item_id: it.id ?? it.Id,
                          name: it.label ?? it.Label,
                          src: iconKey || ('item' + (idx + 1)),
                          font: "12px utmavobold",
                          color: "#603913",
                          display: idx + 1,
                          index: idx + 1,
                          reward_type: rewardType,
                          reward_value: rewardValue
                      };
                  });

                  totalItem = arrItem.length;
                  degItem = 360 / Math.max(totalItem, 1);

                  if (imgContainRota.complete && imgCenterRota.complete && totalItem > 0) {
                      buildWheel();
                  }
              })
              .catch(err => {
                  console.error(err);
                  if (hasLogin) {
                      alert(err.message || 'Vòng quay chưa sẵn sàng, vui lòng thử lại.');
                  }
              });
      }

      function getAvailableSpinTurn() {
          return fetch(SPIN_PROXY + '?action=turns', {
              method: 'GET',
              credentials: 'include',
              cache: 'no-store'
          })
              .then(r => {
                  if (r.status === 401) {
                      hasLogin = false;
                      remainingSpins = 0;
                      updateSpinTurnsLabel();
                      throw new Error('Bạn cần đăng nhập để tham gia vòng quay.');
                  }
                  return r.json();
              })
              .then(list => {
                  // Chỉ dùng /turns để lấy turnId, KHÔNG đụng vào remainingSpins
                  hasLogin = true;

                  var available = (list || []).filter(function (x) {
                      var st = x.status ?? x.Status;
                      return st === 0;
                  });

                  if (!available.length) {
                      throw new Error('Bạn đã sử dụng hết lượt quay.');
                  }

                  var first = available[0];
                  return first.id ?? first.Id;
              });
      }


      function callSpinRoll(spinTurnId) {
          return fetch(SPIN_PROXY + '?action=roll&turnId=' + encodeURIComponent(spinTurnId), {
              method: 'POST',
              credentials: 'include',
              cache: 'no-store'
          })
              .then(r => {
                  if (r.status === 401) throw new Error('Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại.');
                  return r.json();
              });
      }

      function clickSpinRota() {
          if (spinning) return;
          if (totalItem <= 0) {
              alert('Vòng quay chưa sẵn sàng, vui lòng thử lại.');
              return;
          }

          setSpinMessage('');

          spinning = true;
          spinningContinuous = true;
          setSpinButtonState(true);
          startPointerShake();

          getAvailableSpinTurn()
              .then(function (turnId) {
                  currentSpinTurnId = turnId;
                  return callSpinRoll(turnId);
              })
              .then(function (res) {
                  console.log("Spin result:", res);

                  var success = res.success ?? res.Success;
                  if (!success) {
                      var errMsg =
                          res.error_message ??
                          res.error_Message ??
                          res.message ??
                          'Quay thất bại.';
                      throw new Error(errMsg);
                  }

                  var configItemId =
                      res.config_item_id ??
                      res.configItemId ??
                      res.config_Item_Id;

                  var idx = -1;
                  if (configItemId != null) {
                      idx = arrItem.findIndex(function (x) {
                          return x.config_item_id === configItemId;
                      });
                  }
                  if (idx < 0) {
                      idx = getRandomInt(0, totalItem - 1);
                  }

                  var itemResult = arrItem[idx];
                  setSpinResultVisual(itemResult);

                  var rt =
                      res.reward_type ??
                      res.rewardType ??
                      res.reward_Type;

                  var pointsAdded =
                      res.points_added ??
                      res.pointsAdded ??
                      res.points_Added;

                  var totalPoints =
                      res.total_points ??
                      res.totalPoints ??
                      res.total_Points;

                  var extraSpins =
                      res.spins_Created ??
                      res.extra_spins_created ??
                      res.extraSpinsCreated ??
                      res.extra_Spins_Created;

                  var promoCode =
                      res.promotion_code ??
                      res.promotionCode ??
                      res.promotion_Code;

                  var minAmount =
                      res.min_order_amount ??
                      res.minOrderAmount ??
                      res.min_Order_Amount;

                  var msg = '';
                  if (rt === 2 && pointsAdded > 0) {
                      msg = 'Bạn nhận được ' + pointsAdded + ' điểm thưởng'
                          + (totalPoints != null ? ' (tổng điểm hiện tại: ' + totalPoints + ')' : '')
                          + ' 🎉';
                  } else if (rt === 3 && extraSpins > 0) {
                      msg = 'Tuyệt vời! Bạn nhận thêm ' + extraSpins + ' lượt quay nữa 🎁';
                  } else if (rt === 4) {
                      msg = 'Chúc bạn may mắn lần sau nhé 🍀';
                  } else if (rt === 1 && promoCode) {
                      msg = 'Bạn nhận được mã khuyến mãi '
                          + promoCode
                          + (minAmount != null
                              ? ' cho đơn từ ' + formatVnMoney(minAmount) + ' trở lên'
                              : '')
                          + '. Nhập mã này ở bước thanh toán nhé 🎫';
                  }

                  // ❌ KHÔNG tự -1/+extraSpins nữa
                  // if (remainingSpins != null) {
                  //     remainingSpins = Math.max(0, remainingSpins - 1 + (extraSpins || 0));
                  //     updateSpinTurnsLabel();
                  // }

                  setSpinMessage(msg || '');

                  // ✅ Hỏi lại server cho chắc số lượt
                  fetchGamStatus();

                  stopWithResult(idx);

                

              })
              .catch(function (err) {
                  console.error(err);
                  pointerEffectStop();
                  spinning = false;
                  spinningContinuous = false;
                  setSpinButtonState(false);
                  alert(err.message || 'Không quay được, vui lòng thử lại.');
              });
      }

      function backToWheel() {
          var s3 = document.querySelector('.screen-3');
          var s4 = document.querySelector('.screen-4');
          if (s3) s3.style.display = '';
          if (s4) s4.style.display = 'none';
          setSpinMessage('');
      }

      // ====== NÚT ĐIỂM DANH CHECKIN ======
      function callCheckin() {
          var btn = document.getElementById('btnCheckin');
          var statusEl = document.getElementById('checkin_status');
          if (!btn) return;

          btn.disabled = true;
          btn.textContent = 'Đang điểm danh...';

          if (statusEl) {
              statusEl.textContent = '';
              statusEl.classList.remove('text-success', 'text-danger');
          }

          fetch(CHECKIN_URL, {
              method: 'POST',
              credentials: 'include',
              cache: 'no-store'
          })
              .then(async r => {
                  if (r.status === 401) {
                      throw { unauth: true, message: 'Bạn cần đăng nhập để điểm danh.' };
                  }

                  let data;
                  try {
                      data = await r.json();
                  } catch (ex) {
                      const txt = await r.text().catch(() => '');
                      throw { message: 'Không đọc được phản hồi điểm danh: ' + txt };
                  }

                  if (!data.success) {
                      throw {
                          message: data.error_Message || data.error_Code || 'Điểm danh không thành công.'
                      };
                  }

                  // ✅ Thành công
                  hasCheckedInToday = true;
                  refreshCheckinUi();

                  // Dùng /status để đồng bộ cả lượt quay & trạng thái checkin
                  fetchGamStatus();

                  // Không set statusEl success nữa (ẩn luôn)
                  var statusEl2 = document.getElementById('checkin_status');
                  if (statusEl2) {
                      statusEl2.textContent = '';
                      statusEl2.classList.remove('text-success', 'text-danger');
                  }

              })
              .catch(err => {
                  console.error('checkin error', err);
                  var msg = err && err.message ? err.message : 'Điểm danh không thành công, vui lòng thử lại.';

                  if (err && err.unauth) {
                      hasLogin = false;
                      remainingSpins = 0;
                      updateSpinTurnsLabel();
                      refreshCheckinUi();
                  }

                  var statusEl3 = document.getElementById('checkin_status');
                  if (statusEl3) {
                      statusEl3.textContent = msg;
                      statusEl3.classList.remove('text-success');
                      statusEl3.classList.add('text-danger');
                  } else {
                      alert(msg);
                  }
              })
              .finally(() => {
                  refreshCheckinUi();
              });
      }

      function fetchGamStatus() {
          return fetch(SPIN_PROXY + '?action=status', {
              method: 'GET',
              credentials: 'include',
              cache: 'no-store'
          })
              .then(async r => {
                  if (r.status === 401) {
                      // chưa login
                      hasLogin = false;
                      remainingSpins = 0;
                      updateSpinTurnsLabel();
                      refreshCheckinUi();
                      return null;
                  }

                  if (!r.ok) {
                      // 404, 500,... thì chỉ log, không parse JSON
                      const txt = await r.text().catch(() => '');
                      console.warn('status http error', r.status, txt);
                      return null;
                  }

                  try {
                      return await r.json();
                  } catch (e) {
                      console.warn('status parse error', e);
                      return null;
                  }
              })
              .then(data => {
                  if (!data) return;

                  // Đã login
                  hasLogin = true;

                  // has_Checked_In_Today
                  hasCheckedInToday = !!(
                      data.has_Checked_In_Today ??
                      data.hasCheckedInToday ??
                      data.has_checked_in_today
                  );

                  // remaining_Spins
                  if (typeof data.remaining_Spins === 'number') {
                      remainingSpins = data.remaining_Spins;
                  } else if (typeof data.remainingSpins === 'number') {
                      remainingSpins = data.remainingSpins;
                  } else if (typeof data.remaining_spins === 'number') {
                      remainingSpins = data.remaining_spins;
                  }

                  updateSpinTurnsLabel();
                  refreshCheckinUi();
              })
              .catch(err => {
                  console.error('status error', err);
              });
      }


      // ====== TOGGLE POPUP VÒNG QUAY ======
      (function () {
          const launcher = document.getElementById('hafSpinLauncher');
          const panel = document.getElementById('hafSpinPanel');
          const closeBtn = document.getElementById('hafSpinClose');

          function setSpinOpen(isOpen) {
              if (!panel) return;
              panel.classList.toggle('is-open', isOpen);
              panel.setAttribute('aria-hidden', isOpen ? 'false' : 'true');
              if (isOpen) {
                  const btn = document.getElementById('btn_spin');
                  btn && btn.focus();
              }
          }

          launcher && launcher.addEventListener('click', () => {
              const opened = panel.classList.contains('is-open');
              setSpinOpen(!opened);
          });
          closeBtn && closeBtn.addEventListener('click', () => setSpinOpen(false));

          document.addEventListener('keydown', (e) => {
              if (e.key === 'Escape') setSpinOpen(false);
          });
      })();

      // ====== BOOT ======
      window.addEventListener('DOMContentLoaded', function () {
          init();
          loadSpinConfig();

          // Lấy status tổng hợp: đã điểm danh chưa + còn bao nhiêu lượt
          fetchGamStatus();

          var btnCheckin = document.getElementById('btnCheckin');
          if (btnCheckin) {
              btnCheckin.addEventListener('click', callCheckin);
          }

          refreshCheckinUi();
      });
  </script>

  <!-- ====== MUA NGAY (HomePage) – dùng chung API như Product.aspx ====== -->
  <script>
    // Dùng lại Cart API & CartPage URL như Product.aspx
    window.CART_API = window.CART_API ?? '<%= ResolveUrl("~/Ajax/Cart.ashx") %>';
    window.CART_PAGE_URL = window.CART_PAGE_URL ?? '<%= ResolveUrl("~/CartPage/CartPage.aspx") %>';

      async function buyNowFromCard(btn) {
          try {
              const card = btn.closest('.js-product-card');
              const productId = parseInt(card?.dataset.productId || '0', 10);
              const variantSelect = card?.querySelector('.js-variant-select');
              const variantId = parseInt(variantSelect?.value || '0', 10);
              const qtyInput = card?.querySelector('.js-qty-input') || card?.querySelector('input[type="number"]');
              const qty = Math.max(1, parseInt(qtyInput?.value || '1', 10));

              if (!productId || !variantId) {
                  alert('Vui lòng chọn phân loại trước khi mua.');
                  return;
              }

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

              // ✅ chuyển tới CartPage
              location.href = window.CART_PAGE_URL || '/CartPage/CartPage.aspx';
          } catch (err) {
              console.error('BuyNow failed:', err);
              alert('Có lỗi xảy ra khi thêm vào giỏ. Vui lòng thử lại.');
          }
      }

      document.addEventListener('DOMContentLoaded', function () {
          document.querySelectorAll('.js-buy-now').forEach(btn => {
              btn.addEventListener('click', function (e) {
                  e.preventDefault();
                  buyNowFromCard(btn);
              });
          });
      });
  </script>
      <!-- ====== MISSIONS UI (HOME) ====== -->
  <script>
      (function () {
          const API_BASE = (window.__API_BASE || '').replace(/\/+$/, '');
          const MISSIONS_URL = (API_BASE ? API_BASE + '/api/missions/my' : '/api/missions/my');

          // LẤY JWT TỪ SESSION (server-side)
          const TOKEN = '<%= Session["JwtToken"] as string ?? "" %>';

          const missionListEl = document.getElementById('mission-list');
          const refreshBtn = document.getElementById('btnMissionRefresh');

          if (!missionListEl) return;

          function mapReward(m) {
              const rt = m.rewardType ?? m.reward_type ?? m.RewardType ?? m.Reward_Type;
              const val = m.rewardValue ?? m.reward_value ?? m.RewardValue ?? m.Reward_Value;

              if (rt === 0) return { text: `+${val} lượt quay`, icon: '🎡' };
              if (rt === 1) return { text: `+${val} điểm tích luỹ`, icon: '⭐' };
              return { text: 'Phần thưởng khác', icon: '🎁' };
          }

          function mapStatus(m) {
              const raw = (m.status ?? m.Status ?? '').toString().toLowerCase();
              switch (raw) {
                  case 'available': return { text: 'Chưa hoàn thành', className: 'available' };
                  case 'completed': return { text: 'Đã hoàn thành một phần', className: 'completed' };
                  case 'maxed': return { text: 'Đã hoàn thành tối đa', className: 'maxed' };
                  default: return { text: raw || 'Nhiệm vụ', className: '' };
              }
          }

          function safeInt(v, fallback) {
              const n = Number(v);
              return Number.isFinite(n) ? n : fallback;
          }

          function renderMissions(list) {
              if (!Array.isArray(list) || list.length === 0) {
                  missionListEl.innerHTML =
                      '<div class="text-muted small">Hiện chưa có nhiệm vụ nào.</div>';
                  return;
              }

              function getStatusRaw(m) {
                  return (m.status ?? m.Status ?? '').toString().toLowerCase();
              }

              // Giữ nguyên thứ tự backend (IsFeatured + DisplayOrder + Status đã sort ở API)
              const normalized = list.map(m => {
                  const raw = getStatusRaw(m);
                  return { raw, item: m };
              });

              // Ưu tiên show mission chưa max trên Home
              const onlyNonMax = normalized.filter(x => x.raw !== 'maxed');

              let forHome;
              if (onlyNonMax.length > 0) {
                  forHome = onlyNonMax.slice(0, 4);
              } else {
                  forHome = normalized.slice(0, 4);
              }

              missionListEl.innerHTML = '';

              forHome.forEach(w => {
                  const m = w.item;
                  const rawStatus = w.raw;

                  const status = (function () {
                      switch (rawStatus) {
                          case 'available': return { text: 'Chưa hoàn thành', className: 'available' };
                          case 'completed': return { text: 'Đã hoàn thành một phần', className: 'completed' };
                          case 'maxed': return { text: 'Đã hoàn thành tối đa', className: 'maxed' };
                          default: return { text: 'Nhiệm vụ', className: '' };
                      }
                  })();

                  const reward = mapReward(m);
                  const timesCompleted = safeInt(m.timesCompleted ?? m.TimesCompleted, 0);
                  const maxPerUser = m.maxPerUser ?? m.MaxPerUser;

                  const max = Number(maxPerUser || 0);
                  let progressHtml = '';

                  if (max > 0) {
                      const doneClamped = Math.min(timesCompleted, max);
                      const percent = Math.max(0, Math.min(100, Math.round((doneClamped / max) * 100)));

                      progressHtml = `
                        <div class="mission-progress" aria-hidden="true">
                            <div class="mission-progress-bar" style="width:${percent}%;"></div>
                        </div>
                        <div class="mission-progress-label">
                            Tiến độ: ${doneClamped} / ${max} lần
                        </div>
                    `;
                  }

                  const card = document.createElement('div');
                  card.className = 'mission-card';

                  card.innerHTML = `
                    <div class="mission-header">
                        <div class="mission-title">${m.name ?? m.Name ?? ''}</div>
                        <div class="mission-status ${status.className}">
                            ${status.text}
                        </div>
                    </div>
                    <div class="mission-desc">
                        ${(m.description ?? m.Description ?? '') || ''}
                    </div>
                    <div class="mission-reward">
                        <span>${reward.icon}</span>
                        <span>${reward.text}</span>
                    </div>
                    <div class="mission-meta">
                        Đã hoàn thành: ${timesCompleted}${maxPerUser ? ' / ' + maxPerUser + ' lần' : ''}
                    </div>
                    ${progressHtml}
                `;

                  missionListEl.appendChild(card);
              });

              // Nếu còn nhiều mission → link "Xem tất cả"
              if (list.length > forHome.length) {
                  const more = document.createElement('div');
                  more.className = 'mt-1 small';
                  more.innerHTML =
                      '<a href="/MissionPage/MissionPage.aspx" class="text-decoration-none">Xem tất cả nhiệm vụ ›</a>';
                  missionListEl.appendChild(more);
              }
          }

          async function loadMissions() {

              // Nếu TOKEN rỗng => khỏi gọi API, show luôn gợi ý
              if (!TOKEN) {
                  missionListEl.innerHTML =
                      '<div class="text-muted small">Vui lòng đăng nhập để xem nhiệm vụ & nhận thưởng.</div>';
                  return;
              }

              missionListEl.innerHTML =
                  '<div class="text-muted small">Đang tải nhiệm vụ...</div>';

              try {
                  const headers = { 'Accept': 'application/json' };
                  if (TOKEN) {
                      headers['Authorization'] = 'Bearer ' + TOKEN;
                  }

                  const resp = await fetch(MISSIONS_URL, {
                      method: 'GET',
                      headers,
                      credentials: 'include'
                  });

                  // Chưa đăng nhập → show gợi ý
                  if (resp.status === 401) {
                      missionListEl.innerHTML =
                          '<div class="text-muted small">Vui lòng đăng nhập để xem nhiệm vụ của bạn.</div>';
                      return;
                  }

                  if (!resp.ok) {
                      missionListEl.innerHTML =
                          `<div class="text-danger small">Không tải được nhiệm vụ (HTTP ${resp.status}).</div>`;
                      return;
                  }

                  const data = await resp.json();
                  renderMissions(data);
              } catch (err) {
                  console.error('load missions error', err);
                  missionListEl.innerHTML =
                      '<div class="text-danger small">Có lỗi khi tải nhiệm vụ, vui lòng thử lại.</div>';
              }
          }

          document.addEventListener('DOMContentLoaded', function () {
              loadMissions();
              if (refreshBtn) {
                  refreshBtn.addEventListener('click', function () {
                      loadMissions();
                  });
              }
          });
      })();
  </script>

    <script>
    (function () {
        const API_BASE = (window.__API_BASE || '').replace(/\/+$/, '');
        const ARTICLES_URL = (API_BASE ? (API_BASE + '/api/articles') : '/api/articles');

        // RouteConfig list = /blog , detail = /blog/{slug}
        const BLOG_LIST_URL = '/blog';
        const BLOG_DETAIL_URL = (slug) => (BLOG_LIST_URL.replace(/\/+$/, '') + '/' + encodeURIComponent(slug || ''));

        const shelfEl = document.getElementById('blog-shelf');
        const refreshBtn = document.getElementById('btnBlogRefresh');
        const navLeft = document.getElementById('blogNavLeft');
        const navRight = document.getElementById('blogNavRight');

        if (!shelfEl) return;

        function safeText(v) { return (v == null) ? '' : String(v); }
        function safeHtml(text) {
            return safeText(text)
                .replace(/&/g, '&amp;')
                .replace(/</g, '&lt;')
                .replace(/>/g, '&gt;')
                .replace(/"/g, '&quot;')
                .replace(/'/g, '&#039;');
        }
        function formatDateUtc(d) {
            if (!d) return '';
            const dt = new Date(d);
            if (isNaN(dt.getTime())) return '';
            return dt.toLocaleDateString('vi-VN');
        }

        // Đúng theo ArticleService.ListAsync(page,pageSize,q)
        async function fetchArticleListAll() {
            const pageSize = 20; // Home: lấy vừa đủ
            let page = 1;
            const out = [];
            let guard = 0;

            while (true) {
                guard++;
                if (guard > 20) break;

                const qs = new URLSearchParams({
                    page: String(page),
                    pageSize: String(pageSize)
                });

                const url = ARTICLES_URL + '?' + qs.toString();
                const r = await fetch(url, {
                    method: 'GET',
                    credentials: 'include',
                    cache: 'no-store'
                });

                if (!r.ok) {
                    const txt = await r.text().catch(() => '');
                    throw new Error('Không tải được bài viết (HTTP ' + r.status + '): ' + txt);
                }

                // ArticleListResponseDto: { page, pageSize, total, items: [...] }
                const data = await r.json().catch(() => null);
                const items = (data && Array.isArray(data.items)) ? data.items : [];
                out.push(...items);

                const total = (data && typeof data.total === 'number') ? data.total : out.length;
                if (out.length >= total) break;
                if (items.length < pageSize) break;

                page++;
            }

            return out;
        }

        function renderArticles(list) {
            if (!Array.isArray(list) || list.length === 0) {
                shelfEl.innerHTML = '<div class="text-muted small">Hiện chưa có bài viết nào.</div>';
                updateNav();
                return;
            }

            shelfEl.innerHTML = '';

            list.forEach(a => {
                // ArticleListItemDto fields: title, slug, excerpt, cover_Image_Url, published_At_Utc
                const title = a.title || 'Bài viết';
                const slug = a.slug || '';
                const excerpt = a.excerpt || '';
                const cover = a.cover_Image_Url || '';
                const meta = formatDateUtc(a.published_At_Utc);

                const href = slug ? BLOG_DETAIL_URL(slug) : BLOG_LIST_URL;

                const item = document.createElement('div');
                item.className = 'blog-item';

                const link = document.createElement('a');
                link.href = href;
                link.className = 'text-decoration-none text-reset';
                link.setAttribute('aria-label', safeText(title));

                const card = document.createElement('div');
                card.className = 'blog-card';

                const thumbWrap = document.createElement('div');
                thumbWrap.className = 'blog-thumb';

                if (cover) {
                    const img = document.createElement('img');
                    img.loading = 'lazy';
                    img.decoding = 'async';
                    img.alt = safeText(title);
                    img.src = cover;

                    img.onerror = function () {
                        img.remove();
                        thumbWrap.innerHTML = '<i class="bi bi-journal-text" style="font-size:2rem;color:#9ca3af"></i>';
                    };

                    thumbWrap.appendChild(img);
                } else {
                    thumbWrap.innerHTML = '<i class="bi bi-journal-text" style="font-size:2rem;color:#9ca3af"></i>';
                }

                const body = document.createElement('div');
                body.className = 'blog-body';

                const h = document.createElement('div');
                h.className = 'blog-title text-truncate-2';
                h.innerHTML = safeHtml(title);

                const p = document.createElement('div');
                p.className = 'blog-excerpt text-truncate-2';
                p.innerHTML = safeHtml(excerpt);

                const m = document.createElement('div');
                m.className = 'blog-meta';
                m.textContent = meta ? ('📅 ' + meta) : '';

                body.appendChild(h);
                if (excerpt) body.appendChild(p);
                if (meta) body.appendChild(m);

                card.appendChild(thumbWrap);
                card.appendChild(body);

                link.appendChild(card);
                item.appendChild(link);
                shelfEl.appendChild(item);
            });

            updateNav(true);
        }

        function scrollByShelf(dir) {
            const amount = Math.max(240, Math.round(shelfEl.clientWidth * 0.85));
            shelfEl.scrollBy({ left: dir * amount, behavior: 'smooth' });
        }

        function updateNav(forceShow) {
            if (!navLeft || !navRight) return;

            const canScroll = shelfEl.scrollWidth > shelfEl.clientWidth + 8;
            if (!canScroll) {
                navLeft.classList.remove('is-show');
                navRight.classList.remove('is-show');
                return;
            }

            const left = shelfEl.scrollLeft;
            const max = shelfEl.scrollWidth - shelfEl.clientWidth;

            if (left <= 2) navLeft.classList.remove('is-show'); else navLeft.classList.add('is-show');
            if (left >= max - 2) navRight.classList.remove('is-show'); else navRight.classList.add('is-show');

            if (forceShow && max > 2) navRight.classList.add('is-show');
        }

        async function loadBlogs() {
            try {
                shelfEl.innerHTML = '<div class="text-muted small">Đang tải bài viết...</div>';
                updateNav();

                const list = await fetchArticleListAll();
                renderArticles(list);
            } catch (err) {
                console.error('load blogs error', err);
                shelfEl.innerHTML = '<div class="text-danger small">Có lỗi khi tải bài viết, vui lòng thử lại.</div>';
                updateNav();
            }
        }

        document.addEventListener('DOMContentLoaded', function () {
            loadBlogs();

            if (refreshBtn) refreshBtn.addEventListener('click', loadBlogs);
            if (navLeft) navLeft.addEventListener('click', () => scrollByShelf(-1));
            if (navRight) navRight.addEventListener('click', () => scrollByShelf(1));

            shelfEl.addEventListener('scroll', () => updateNav());
            window.addEventListener('resize', () => updateNav());
        });
    })();
    </script>

</form>
</body>
</html>
