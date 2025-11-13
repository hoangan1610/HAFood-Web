<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="Slideshow.ascx.cs" Inherits="HAFoodWeb.Control.SlideShow" %>

<link href="https://fonts.googleapis.com/css2?family=Merriweather:wght@700&family=Noto+Serif:wght@700&display=swap" rel="stylesheet" />

<style>
    :root{
        --ha-cream:#FFF7EA;      /* NỀN BÊN NGOÀI SECTION */
        --ha-ink:#111827;
        --ha-accent:#28a745;
        --ha-shadow:0 .75rem 2rem rgba(0,0,0,.08);
    }

    /* Reset nhỏ trong vùng hero */
    .hero-wrap *,
    .hero-wrap *::before,
    .hero-wrap *::after{
        box-sizing: border-box;
    }

    /* Vùng bọc ngoài có nền KEM + gradient */
    .hero-wrap{
        background: radial-gradient(circle at top left,#fffdf6 0%,#ffe9c7 38%,#ffe1b8 70%,#fffbf3 100%);
        padding: 24px 0 30px;
    }

    .hero-section{
        background:#fff;
        width: min(1400px, calc(100% - 4cm));
        margin: 0 auto;
        padding: 22px 22px 26px;
        border-radius: 22px;
        box-shadow: var(--ha-shadow);
        border: 1px solid rgba(148,163,184,.35);
        position: relative;
        overflow: hidden;
    }

    /* dải màu trên đỉnh card */
    .hero-section::before{
        content:"";
        position:absolute;
        inset:0;
        height:4px;
        background: linear-gradient(90deg,#22c55e,#86efac,#facc15,#fb923c);
        opacity:.85;
    }

    .slide-frame{
        position: relative;
        overflow: hidden;
        border-radius: 18px;
        background:#fff;
        box-shadow: 0 .75rem 1.8rem rgba(15,23,42,.14);
    }

    .slide-container{
        position: relative;
        width: 100%;
        height: 520px;
        background:#fff;
    }

    .slides-track{
        display: flex;
        height: 100%;
        width: 100%;
        transition: transform .55s ease; /* hiệu ứng trượt */
        will-change: transform;
    }

    /* Khi cần reset vị trí tức thì (không hiệu ứng) */
    .slides-track.no-anim{
        transition: none !important;
    }

    .slide{
        flex: 0 0 100%;
        height: 100%;
        background-size: cover;
        background-position: center;
        position: relative;
        display: flex;
        align-items: center;
        justify-content: flex-start;
        padding: 60px 80px 60px 110px;
        color: #fff;
        overflow: hidden;
    }

    /* lớp phủ gradient để chữ rõ hơn trên ảnh */
    .slide::before{
        content:"";
        position:absolute;
        inset:0;
        background:
          linear-gradient(120deg,rgba(0,0,0,.70) 0%,rgba(0,0,0,.35) 45%,rgba(0,0,0,.55) 100%);
        mix-blend-mode: multiply;
        z-index:0;
    }

    .slide-content{
        position: relative;
        z-index:1;
        max-width: 580px;
        animation: slideFadeIn .9s ease-out;
    }

    .slide-eyebrow{
        display:inline-flex;
        align-items:center;
        gap:6px;
        font-size: 13px;
        letter-spacing: .16em;
        text-transform: uppercase;
        padding: 6px 12px;
        border-radius: 999px;
        background: rgba(15,23,42,.76);
        border: 1px solid rgba(148,163,184,.6);
        margin-bottom: 12px;
        font-weight:600;
    }
    .slide-eyebrow::before{
        content:"●";
        font-size: 10px;
        color:#4ade80;
    }

    .slide h1{
        font-size: 52px;
        font-family: "Merriweather", "Noto Serif", "Inter", system-ui, -apple-system, "Segoe UI", Roboto, Arial, "Times New Roman", serif;
        font-weight: 700;
        line-height: 1.2;
        -webkit-font-smoothing: antialiased;
        -moz-osx-font-smoothing: grayscale;
        text-rendering: optimizeLegibility;
        text-shadow: 0 2px 12px rgba(0,0,0,.45);
        margin: 0;
    }

    .slide p{
        font-size: 18px;
        margin-top: 16px;
        max-width: 540px;
        line-height: 1.6;
        text-shadow: 0 2px 8px rgba(0,0,0,.35);
        color: #f9fafb;
    }

    .slide-actions{
        margin-top: 24px;
        display:flex;
        align-items:center;
        gap: 14px;
        flex-wrap: wrap;
    }

    .slide-btn{
        display:inline-flex;
        align-items:center;
        justify-content:center;
        padding: 11px 22px;
        border-radius: 999px;
        font-size: 14px;
        font-weight: 600;
        letter-spacing: .05em;
        text-transform: uppercase;
        text-decoration:none;
        border:1px solid transparent;
        cursor:pointer;
        transition:
            background .18s ease,
            color .18s ease,
            box-shadow .18s ease,
            transform .12s ease,
            border-color .18s ease;
        white-space: nowrap;
    }

    .slide-btn.primary{
        background: linear-gradient(90deg,#22c55e,#16a34a);
        color:#022c22;
        box-shadow: 0 14px 30px rgba(34,197,94,.42);
    }

    .slide-btn.primary:hover{
        transform: translateY(-1px) scale(1.02);
        box-shadow: 0 18px 34px rgba(34,197,94,.52);
        background: linear-gradient(90deg,#4ade80,#16a34a);
    }

    .slide-btn.ghost{
        background: rgba(15,23,42,.68);
        color:#e5e7eb;
        border-color: rgba(148,163,184,.8);
    }

    .slide-btn.ghost:hover{
        background: rgba(15,23,42,.9);
        border-color:#e5e7eb;
        transform: translateY(-1px);
    }

    .slide-btn .btn-icon{
        margin-left: 6px;
        font-size: 16px;
    }

    /* Nút điều hướng trái/phải */
    .slide-nav{
        position: absolute;
        inset: 0;
        pointer-events: none;
    }

    .nav-btn{
        pointer-events: auto;
        position: absolute;
        top: 50%;
        transform: translateY(-50%);
        width: 44px;
        height: 44px;
        border-radius: 9999px;
        background: rgba(255,255,255,.94);
        color: var(--ha-ink);
        border: 1px solid #E5E7EB;
        display: grid;
        place-items: center;
        box-shadow: 0 .8rem 1.7rem rgba(15,23,42,.18);
        cursor: pointer;
        transition:
            transform .15s ease,
            box-shadow .15s ease,
            background .15s ease,
            border-color .15s ease;
        user-select: none;
        z-index: 2;
        font-size: 18px;
    }

    .nav-btn:hover{
        transform: translateY(-50%) scale(1.07);
        background:#f9fafb;
        border-color:#cbd5e1;
        box-shadow: 0 1.1rem 2.2rem rgba(15,23,42,.22);
    }

    .nav-prev{ left: 16px; }
    .nav-next{ right: 16px; }

    /* Dots chỉ báo */
    .dots{
        position: absolute;
        left: 50%;
        bottom: 18px;
        transform: translateX(-50%);
        display: flex;
        gap: 8px;
        padding: 7px 12px;
        border-radius: 9999px;
        background: rgba(15,23,42,.62);
        backdrop-filter: blur(5px);
        box-shadow: 0 .45rem 1.1rem rgba(15,23,42,.45);
        z-index: 2;
    }

    .dot{
        width: 8px;
        height: 8px;
        border-radius: 9999px;
        background: #9ca3af;
        cursor: pointer;
        transition: width .2s ease, background .2s ease, opacity .2s ease;
        opacity:.7;
    }

    .dot.active{
        width: 26px;
        background: var(--ha-accent);
        opacity:1;
    }

    /* Animation text */
    @keyframes slideFadeIn{
        from{
            opacity:0;
            transform: translateY(10px) translateX(-6px);
        }
        to{
            opacity:1;
            transform: translateY(0) translateX(0);
        }
    }

    /* Responsive */
    @media (max-width: 1200px){
        .slide{
            padding: 50px 40px;
        }
        .slide h1{
            font-size: 42px;
        }
    }

    @media (max-width: 992px){
        .hero-wrap{
            padding: 16px 0 20px;
        }
        .hero-section{
            width: calc(100% - 24px);
            padding: 16px 14px 20px;
            border-radius: 18px;
        }
        .slide-container{
            height: 420px;
        }
        .slide{
            padding: 30px 24px;
            align-items: center;
            text-align: center;
            justify-content: center;
        }
        .slide-content{
            max-width: 90%;
        }
        .slide h1{
            font-size: 34px;
        }
        .slide p{
            font-size: 16px;
            max-width: 100%;
        }
        .slide-actions{
            justify-content:center;
        }
        .nav-prev{ left: 10px; }
        .nav-next{ right: 10px; }
    }

    @media (max-width: 640px){
        .slide-container{
            height: 360px;
        }
        .slide{
            padding: 24px 16px;
        }
        .slide h1{
            font-size: 26px;
        }
        .slide p{
            font-size: 14px;
        }
        .slide-eyebrow{
            font-size: 11px;
        }
        .slide-btn{
            width: 100%;
            justify-content:center;
        }
        .nav-btn{
            width: 38px;
            height: 38px;
            font-size: 16px;
        }
        .dots{
            bottom: 14px;
        }
    }
</style>

<div class="hero-wrap">
  <div class="hero-section">
    <div class="slide-frame">
      <div class="slide-container" id="haSlider">
        <div class="slides-track">
          <!-- Slide 1 -->
          <div class="slide" style='background-image:url("<%= ResolveUrl("~/images/slide1.jpg") %>")'>
            <div class="slide-content">
              <span class="slide-eyebrow">HA FOOD • ĐỒ ĂN VẶT</span>
              <h1>Đồ Ăn Vặt Tươi Ngon Mỗi Ngày</h1>
              <p>Khô gà, cơm cháy, trái cây sấy… chuẩn vị nhà làm, nguyên liệu sạch – giòn ngon khó cưỡng.</p>
            </div>
          </div>

          <!-- Slide 2 -->
          <div class="slide" style='background-image:url("<%= ResolveUrl("~/images/slide2.jpg") %>")'>
            <div class="slide-content">
              <span class="slide-eyebrow">SNACK GIÒN – GIAO NHANH</span>
              <h1>Siêu Ngon – Siêu Giòn – Siêu Tiện</h1>
              <p>Đóng gói kỹ, giao nhanh tận nơi. Thưởng thức ngay khi xem phim, học tập hay làm việc!</p>
            </div>
          </div>
        </div>

        <!-- Nút điều hướng -->
        <div class="slide-nav">
          <button type="button" class="nav-btn nav-prev" aria-label="Prev">&#10094;</button>
          <button type="button" class="nav-btn nav-next" aria-label="Next">&#10095;</button>
        </div>

        <!-- Dots -->
        <div class="dots" aria-label="Slide indicators"></div>
      </div>
    </div>
  </div>
</div>

<script>
    (function () {
        const root = document.getElementById('haSlider');
        if (!root) return;

        const track = root.querySelector('.slides-track');
        const prevBtn = root.querySelector('.nav-prev');
        const nextBtn = root.querySelector('.nav-next');
        const dotsWrap = root.querySelector('.dots');

        // Lấy danh sách slide "thật" ban đầu
        const realSlides = Array.from(track.children);
        const N = realSlides.length;
        if (N === 0) return;

        // Tạo clone cho infinite loop
        const firstClone = realSlides[0].cloneNode(true);
        const lastClone = realSlides[N - 1].cloneNode(true);
        firstClone.classList.add('clone');
        lastClone.classList.add('clone');

        // Chèn clone: [lastClone][slide1..slideN][firstClone]
        track.insertBefore(lastClone, track.firstChild);
        track.appendChild(firstClone);

        // Index bắt đầu ở slide "thật" đầu tiên (sau lastClone) => 1
        let idx = 1;
        let isAnimating = false;
        let timer = null;

        // Dots cho N slide thật
        dotsWrap.innerHTML = '';
        for (let i = 0; i < N; i++) {
            const d = document.createElement('div');
            d.className = 'dot' + (i === 0 ? ' active' : '');
            d.dataset.index = i + 1; // map về index "thật": 1..N
            d.addEventListener('click', () => goTo(i + 1, true));
            dotsWrap.appendChild(d);
        }

        // Helper cập nhật dots theo idx hiện tại (1..N)
        function updateDots() {
            const realIndex = ((idx - 1 + N) % N); // 0..N-1
            dotsWrap.querySelectorAll('.dot').forEach((d, i) => {
                d.classList.toggle('active', i === realIndex);
            });
        }

        // Set transform về vị trí idx hiện tại
        function setTranslate(noAnim = false) {
            if (noAnim) track.classList.add('no-anim'); else track.classList.remove('no-anim');
            track.style.transform = `translateX(-${idx * 100}%)`;
            if (noAnim) {
                // Force reflow để đảm bảo bỏ transition xong mới áp transform
                void track.offsetHeight;
                track.classList.remove('no-anim');
            }
        }

        // Di chuyển tới index (bao gồm cả clone): 0..N+1
        function goTo(targetIdx, fromUser = false) {
            if (isAnimating) return;
            isAnimating = true;
            idx = targetIdx;
            // dùng transition bình thường
            track.classList.remove('no-anim');
            track.style.transform = `translateX(-${idx * 100}%)`;
            if (fromUser) restartAuto();
        }

        function next() { goTo(idx + 1, true); }
        function prev() { goTo(idx - 1, true); }

        prevBtn.addEventListener('click', prev);
        nextBtn.addEventListener('click', next);

        // Sau khi trượt xong, nếu đang ở clone thì reset về slide thật tương ứng
        track.addEventListener('transitionend', () => {
            // Nếu đang ở clone cuối (idx = 0) => nhảy về slide thật cuối (idx = N)
            if (idx === 0) {
                idx = N;
                setTranslate(true); // reset tức thì, không animation
            }
            // Nếu đang ở clone đầu (idx = N+1) => nhảy về slide thật đầu (idx = 1)
            else if (idx === N + 1) {
                idx = 1;
                setTranslate(true);
            }
            updateDots();
            isAnimating = false;
        });

        // Auto play
        function startAuto() { stopAuto(); timer = setInterval(() => { if (!isAnimating) goTo(idx + 1, false); }, 8000); }
        function stopAuto() { if (timer) { clearInterval(timer); timer = null; } }
        function restartAuto() { stopAuto(); startAuto(); }

        root.addEventListener('mouseenter', stopAuto);
        root.addEventListener('mouseleave', startAuto);

        // Khởi tạo vị trí ban đầu
        setTranslate(true);
        updateDots();
        startAuto();

        // Khi resize, giữ nguyên slide hiện tại (reset tức thì để không bị “dật”)
        window.addEventListener('resize', () => setTranslate(true));
    })();
</script>
