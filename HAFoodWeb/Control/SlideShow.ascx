<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="Slideshow.ascx.cs" Inherits="HAFoodWeb.Control.SlideShow" %>

<link href="https://fonts.googleapis.com/css2?family=Merriweather:wght@700&family=Noto+Serif:wght@700&display=swap" rel="stylesheet" />

<style>
    :root{
        --ha-cream:#FFF7EA;      /* NỀN BÊN NGOÀI SECTION */
        --ha-ink:#111827;
        --ha-accent:#28a745;
        --ha-shadow:0 .75rem 2rem rgba(0,0,0,.08);
    }

    /* Vùng bọc ngoài có nền KEM */
    .hero-wrap{
        background: var(--ha-cream);
        padding: 20px 0;
    }

    .hero-section{
        background:#fff;
        width: min(1400px, calc(100% - 4cm));
        margin: 0 auto;
        padding: 22px;
        border-radius: 18px;
        box-shadow: var(--ha-shadow);
    }

    .slide-frame{
        position: relative;
        overflow: hidden;
        border-radius: 16px;
        background:#fff;
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
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: flex-start;
        padding-left: 150px;
        color: #fff;
        position: relative;
    }
    .slide h1{
        font-size: 56px;
        font-family: "Merriweather", "Noto Serif", "Inter", system-ui, -apple-system, "Segoe UI", Roboto, Arial, "Times New Roman", serif; /* thay Georgia để hỗ trợ tiếng Việt */
        font-weight: 700;
        line-height: 1.2;
        -webkit-font-smoothing: antialiased;
        -moz-osx-font-smoothing: grayscale;
        text-rendering: optimizeLegibility;
        text-shadow: 0 2px 10px rgba(0,0,0,.25);
    }

    .slide p{
        font-size: 20px;
        margin-top: 14px;
        max-width: 520px;
        text-shadow: 0 2px 8px rgba(0,0,0,.25);
    }

    /* Nút điều hướng trái/phải */
    .slide-nav{ position: absolute; inset: 0; pointer-events: none; }
    .nav-btn{
        pointer-events: auto;
        position: absolute; top: 50%; transform: translateY(-50%);
        width: 42px; height: 42px; border-radius: 9999px;
        background: #fff; color: var(--ha-ink);
        border: 1px solid #E5E7EB;
        display: grid; place-items: center;
        box-shadow: 0 .5rem 1rem rgba(0,0,0,.08);
        cursor: pointer;
        transition: transform .15s ease, box-shadow .15s ease, background .15s ease;
        user-select: none;
        z-index: 2;
    }
    .nav-btn:hover{ transform: translateY(-50%) scale(1.06); background:#fafafa; }
    .nav-prev{ left: 14px; }
    .nav-next{ right: 14px; }

    /* Dots chỉ báo */
    .dots{
        position: absolute; left: 50%; bottom: 12px; transform: translateX(-50%);
        display: flex; gap: 8px; padding: 6px 10px; border-radius: 9999px;
        background: rgba(255,255,255,.75); backdrop-filter: blur(2px);
        box-shadow: 0 .25rem .75rem rgba(0,0,0,.08);
        z-index: 2;
    }
    .dot{
        width: 8px; height: 8px; border-radius: 9999px;
        background: #D1D5DB; cursor: pointer; transition: width .2s ease, background .2s ease;
    }
    .dot.active{ width: 26px; background: var(--ha-accent); }

    /* Responsive */
    @media (max-width: 992px){
        .hero-wrap{ padding: 14px 0; }
        .hero-section{ width: calc(100% - 32px); padding: 14px; }
        .slide-container{ height: 420px; }
        .slide{ padding-left: 24px; align-items: center; text-align: center; }
        .slide h1{ font-size: 36px; }
        .slide p{ font-size: 16px; max-width: 90%; }
        .nav-prev{ left: 8px; } .nav-next{ right: 8px; }
    }
</style>

<div class="hero-wrap">
  <div class="hero-section">
    <div class="slide-frame">
      <div class="slide-container" id="haSlider">
        <div class="slides-track">
          <!-- Slide 1 -->
          <div class="slide" style='background-image:url("<%= ResolveUrl("~/images/slide1.jpg") %>")'>
            <h1>Đồ Ăn Vặt Tươi Ngon Mỗi Ngày</h1>
            <p>Khô gà, cơm cháy, trái cây sấy… chuẩn vị nhà làm, nguyên liệu sạch – giòn ngon khó cưỡng.</p>
          </div>
          <!-- Slide 2 -->
          <div class="slide" style='background-image:url("<%= ResolveUrl("~/images/slide2.jpg") %>")'>
            <h1>Siêu Ngon – Siêu Giòn – Siêu Tiện</h1>
            <p>Đóng gói kỹ, giao nhanh tận nơi. Thưởng thức ngay khi xem phim, học tập hay làm việc!</p>
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
