<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="Footer.ascx.cs" Inherits="HAFoodWeb.Control.Footer" %>

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">

<style>
    /* ===== Footer gốc ===== */
    .footer-container {
        background-color: #1a1a1a;
        color: #ffffff;
        padding: 60px 0 20px;
        margin-top: 80px;
    }
    .footer-logo { max-width: 120px; margin: 0 auto 30px; display: block; border-radius: 40%; }
    .footer-section h5 { font-size: 18px; font-weight: 600; margin-bottom: 25px; color: #ffffff; }
    .footer-links { list-style: none; padding: 0; margin: 0; }
    .footer-links li { margin-bottom: 12px; }
    .footer-links a { color: #b0b0b0; text-decoration: none; font-size: 14px; transition: color 0.3s ease; }
    .footer-links a:hover { color: #8bc34a; }
    .footer-contact-info p {
        color: #b0b0b0; font-size: 14px; margin-bottom: 15px;
        display: flex; align-items: flex-start; gap: 10px; justify-content: center;
    }
    .footer-contact-info i { color: #8bc34a; margin-top: 3px; font-size: 16px; }
    .social-links { display: flex; gap: 15px; margin-top: 20px; }
    .social-links a {
        width: 40px; height: 40px; background-color: #2a2a2a; border-radius: 50%;
        display: flex; align-items: center; justify-content: center; color: #ffffff; font-size: 18px;
        transition: all 0.3s ease;
    }
    .social-links a:hover { background-color: #8bc34a; transform: translateY(-3px); color: #ffffff; }
    .footer-bottom { border-top: 1px solid #333; margin-top: 40px; padding-top: 25px; text-align: center; color: #888; font-size: 14px; }

    /* ===== Nút về đầu trang (đẩy lên để Chat nằm phía dưới) ===== */
    .back-to-top {
        position: fixed; bottom: 95px; right: 30px; width: 50px; height: 50px; background-color: #8bc34a;
        border-radius: 50%; display: flex; align-items: center; justify-content: center; color: #ffffff;
        font-size: 24px; cursor: pointer; transition: all 0.3s ease; opacity: 0; visibility: hidden; z-index: 1000;
        box-shadow: 0 4px 12px rgba(139, 195, 74, 0.4);
    }
    .back-to-top.show { opacity: 1; visibility: visible; }
    .back-to-top:hover { background-color: #7cb342; transform: translateY(-5px); box-shadow: 0 6px 16px rgba(139, 195, 74, 0.5); }

    /* ===== CHAT WIDGET (UI ONLY) ===== */
    /* Nút mở Chat */
    .haf-chat-launcher{
        position: fixed; right: 30px; bottom: 30px;
        display: inline-flex; align-items: center; gap: 10px;
        height: 48px; padding: 0 14px; border: 0; border-radius: 9999px;
        background: #0f172a; color: #fff; font-weight: 600; cursor: pointer;
        box-shadow: 0 10px 24px rgba(0,0,0,.25); z-index: 1001;
        transition: transform .2s ease, box-shadow .2s ease, background-color .2s ease;
    }
    .haf-chat-launcher i{ font-size: 20px; line-height: 1; }
    .haf-chat-launcher:hover{ transform: translateY(-2px); box-shadow: 0 14px 32px rgba(0,0,0,.3); background:#111827; }
    .haf-chat-badge{ display:inline-block; min-width: 8px; height: 8px; background:#10b981; border-radius:999px; }

    /* Panel chat */
    .haf-chat-panel{
        position: fixed; right: 30px; bottom: 90px; /* nằm phía trên nút Chat */
        width: 360px; max-width: calc(100vw - 40px);
        background: #0f172a; border-radius: 16px; overflow: hidden;
        box-shadow: 0 30px 70px rgba(0,0,0,.45); z-index: 1002;

        opacity: 0; visibility: hidden; transform: translateY(12px);
        transition: opacity .18s ease, transform .18s ease, visibility .18s ease;
    }
    .haf-chat-panel.is-open{ opacity:1; visibility:visible; transform: translateY(0); }

    .haf-chat-header{
        padding: 14px 16px; background:#0b1220; color:#fff;
        display:flex; align-items:center; justify-content:space-between; gap:8px;
        border-bottom: 1px solid rgba(255,255,255,.06);
    }
    .haf-chat-header .title{ display:flex; align-items:center; gap:8px; font-weight:700; }
    .haf-chat-close{
        background: transparent; border:0; color:#cbd5e1; cursor:pointer; padding:6px;
    }
    .haf-chat-close:hover{ color:#fff; }

    .haf-chat-body{
        background:#111827; color:#e5e7eb; padding: 16px; max-height: 55vh; overflow:auto;
    }
    .haf-chat-card{
        background:#1f2937; border:1px solid #263244; color:#e5e7eb;
        border-radius: 14px; padding: 14px; line-height: 1.5;
    }
    .haf-quick{ margin-top: 16px; font-size: 13px; color:#94a3b8; }
    .haf-quick-btn{
        margin-top: 8px; display:inline-flex; align-items:center; gap:8px;
        background:#0b1220; color:#fff; border:1px solid #223049; border-radius: 10px;
        padding: 10px 12px; cursor:pointer;
    }
    .haf-quick-btn:hover{ background:#0f172a; }

    .haf-chat-input{
        display:flex; align-items:center; gap:8px; padding:12px; background:#0b1220; border-top:1px solid rgba(255,255,255,.06);
    }
    .haf-chat-input input{
        flex:1; height:42px; border-radius: 10px; border:1px solid #223049;
        background:#111827; color:#e5e7eb; padding: 0 12px; outline: none;
    }
    .haf-chat-input input::placeholder{ color:#94a3b8; }
    .haf-chat-send{
        width:42px; height:42px; border-radius: 10px; border:0; cursor:pointer;
        background:#22c55e; color:#0b1220; display:flex; align-items:center; justify-content:center; font-size:18px;
    }
    .haf-chat-send:hover{ filter: brightness(.95); }

    /* Mobile */
    @media (max-width: 768px) {
        .footer-container { padding: 40px 0 20px; }
        .footer-section { margin-bottom: 30px; }
        .back-to-top { width: 45px; height: 45px; bottom: 80px; right: 20px; } /* đẩy lên để nhường chỗ cho Chat */
    }
    @media (max-width: 480px){
        .haf-chat-panel{ right: 10px; left: 10px; width: auto; bottom: 80px; }
        .haf-chat-launcher{ right: 10px; bottom: 20px; }
        .back-to-top{ right: 10px; bottom: 80px; }
    }
</style>

<footer class="footer-container" aria-label="Chân trang">
    <div class="container">
        <div class="row">
            <!-- Sản phẩm -->
            <div class="col-lg-3 col-md-6 footer-section">
                <h5>Sản phẩm</h5>
                <ul class="footer-links">
                    <li><a href="#" aria-label="Danh sách yêu thích">Danh sách yêu thích</a></li>
                    <li><a href="#" aria-label="Blog">Blog</a></li>
                    <li><a href="#" aria-label="Câu hỏi thường gặp">Câu hỏi thường gặp</a></li>
                    <li><a href="#" aria-label="Giao hàng">Giao hàng</a></li>
                    <li><a href="#" aria-label="Tìm kiếm">Tìm kiếm</a></li>
                    <li><a href="#" aria-label="Bộ sưu tập">Bộ sưu tập</a></li>
                </ul>
            </div>

            <!-- Thông tin công ty -->
            <div class="col-lg-6 col-md-6 footer-section">
                <img src="<%= ResolveUrl("~/images/HAFood_logo.png") %>" alt="Logo HAFood" class="footer-logo">
                <div class="footer-contact-info" style="text-align: center;">
                    <p>
                        <i class="bi bi-geo-alt-fill" aria-hidden="true"></i>
                        <span>Trường của tôi, 1 Võ Văn Ngân, Thủ Đức, TP. Hồ Chí Minh</span>
                    </p>
                    <p>
                        <i class="bi bi-envelope-fill" aria-hidden="true"></i>
                        <span>hafood123@gmail.com</span>
                    </p>
                    <p>
                        <i class="bi bi-telephone-fill" aria-hidden="true"></i>
                        <span>(+84) 123-456-789</span>
                    </p>
                </div>
                <div class="social-links justify-content-center">
                    <a href="#" aria-label="X (Twitter)"><i class="bi bi-twitter-x"></i></a>
                    <a href="https://www.facebook.com/vinhhung.tran.37454961"
                       aria-label="Facebook của Trần Vĩnh Hùng"
                       target="_blank" rel="noopener noreferrer">
                        <i class="bi bi-facebook"></i>
                    </a>
                    <a href="#" aria-label="Pinterest"><i class="bi bi-pinterest"></i></a>
                    <a href="#" aria-label="Instagram"><i class="bi bi-instagram"></i></a>
                </div>
            </div>

            <!-- Công ty chúng tôi -->
            <div class="col-lg-3 col-md-6 footer-section">
                <h5>Công ty chúng tôi</h5>
                <ul class="footer-links">
                    <li><a href="#" aria-label="Liên hệ">Liên hệ</a></li>
                    <li><a href="#" aria-label="Giao hàng">Giao hàng</a></li>
                    <li><a href="#" aria-label="Điều khoản &amp; Điều kiện sử dụng">Điều khoản &amp; Điều kiện sử dụng</a></li>
                    <li><a href="#" aria-label="Về chúng tôi">Về chúng tôi</a></li>
                    <li><a href="#" aria-label="Thông báo pháp lý">Thông báo pháp lý</a></li>
                </ul>
            </div>
        </div>

        <!-- Cuối chân trang -->
        <div class="row">
            <div class="col-12">
                <div class="footer-bottom">
                    <p class="mb-0">
                        Bản quyền © 2025 • Chủ đề: Veggie (Mật khẩu: 1) • Vận hành bởi Shopify
                    </p>
                </div>
            </div>
        </div>
    </div>
</footer>

<!-- Nút về đầu trang -->
<div class="back-to-top" id="backToTop" onclick="scrollToTop()" title="Lên đầu trang" aria-label="Lên đầu trang">
    <i class="bi bi-chevron-up"></i>
</div>

<!-- Nút mở Chat -->
<button id="hafChatLauncher"
        class="haf-chat-launcher"
        type="button"
        aria-label="Mở cửa sổ chat"
        aria-controls="hafChatPanel"
        aria-expanded="false">
    <i class="bi bi-chat-dots-fill" aria-hidden="true"></i>
    <span>Chat</span>
    <span class="haf-chat-badge" aria-hidden="true"></span>
</button>

<!-- Cửa sổ Chat (UI) -->
<section id="hafChatPanel"
         class="haf-chat-panel"
         role="dialog"
         aria-label="Hộp thoại Chat"
         aria-modal="false">
    <div class="haf-chat-header">
        <div class="title">
            <i class="bi bi-chat-dots-fill"></i>
            <span>Chat with us</span>
        </div>
        <button class="haf-chat-close" id="hafChatClose" type="button" aria-label="Đóng chat">
            <i class="bi bi-x-lg" aria-hidden="true"></i>
        </button>
    </div>
    <div class="haf-chat-body">
        <div class="haf-chat-card">
            <div style="font-size:22px; margin-bottom:8px; font-weight:600">👋 Xin chào!</div>
            <div>Hãy cho mình biết câu hỏi của bạn, hoặc mô tả bạn đang tìm gì để mình gợi ý.</div>
        </div>

        <div class="haf-quick">Câu trả lời nhanh</div>
        <button class="haf-quick-btn" type="button">
            <i class="bi bi-truck" aria-hidden="true"></i> Theo dõi đơn hàng
        </button>
    </div>
    <div class="haf-chat-input">
        <input type="text" placeholder="Viết tin nhắn" aria-label="Ô nhập tin nhắn">
        <button class="haf-chat-send" type="button" aria-label="Gửi">
            <i class="bi bi-send-fill" aria-hidden="true"></i>
        </button>
    </div>
</section>

<script>
    // Hiện/ẩn nút Lên đầu trang
    window.addEventListener('scroll', function () {
        var backToTop = document.getElementById('backToTop');
        if (window.pageYOffset > 300) backToTop.classList.add('show');
        else backToTop.classList.remove('show');
    });

    // Cuộn mượt lên đầu trang
    function scrollToTop() {
        window.scrollTo({ top: 0, behavior: 'smooth' });
    }

    // Toggle mở/đóng panel Chat
    (function () {
        const launcher = document.getElementById('hafChatLauncher');
        const panel = document.getElementById('hafChatPanel');
        const closeBtn = document.getElementById('hafChatClose');

        function setOpen(isOpen) {
            panel.classList.toggle('is-open', isOpen);
            launcher.setAttribute('aria-expanded', String(isOpen));
        }

        launcher.addEventListener('click', () => setOpen(!panel.classList.contains('is-open')));
        closeBtn.addEventListener('click', () => setOpen(false));

        // Đóng bằng phím ESC
        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape') setOpen(false);
        });
    })();
</script>