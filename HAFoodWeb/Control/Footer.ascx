<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="Footer.ascx.cs" Inherits="HAFoodWeb.Control.Footer" %>

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">

<style>
    /* ===== FOOTER MỚI ===== */
    .footer-container {
        position: relative;
        background: radial-gradient(circle at top left, #1e293b 0, #020617 55%, #020617 100%);
        color: #e5e7eb;
        padding: 64px 0 24px;
        margin-top: 80px;
        overflow: hidden;
    }

    .footer-container::before {
        content: "";
        position: absolute;
        inset: 0;
        background: radial-gradient(circle at top, rgba(74, 222, 128, 0.12), transparent 55%);
        opacity: 0.8;
        pointer-events: none;
    }

    .footer-container .container {
        position: relative;
        z-index: 1;
    }

    .footer-section {
        margin-bottom: 32px;
    }

    .footer-logo {
        max-width: 140px;
        margin: 0 auto 20px;
        display: block;
        border-radius: 32px;
        background: #020617;
        padding: 8px;
        box-shadow: 0 10px 30px rgba(15, 23, 42, 0.75);
    }

    .footer-section h5 {
        font-size: 14px;
        letter-spacing: 0.14em;
        text-transform: uppercase;
        font-weight: 700;
        margin-bottom: 18px;
        color: #f9fafb;
        position: relative;
        padding-bottom: 6px;
    }

    .footer-section h5::after {
        content: "";
        position: absolute;
        left: 0;
        bottom: 0;
        width: 36px;
        height: 2px;
        border-radius: 9999px;
        background: linear-gradient(90deg, #22c55e, #a3e635);
    }

    .footer-center-text {
        max-width: 460px;
        margin: 0 auto 18px;
        font-size: 14px;
        color: #cbd5e1;
        text-align: center;
    }

    .footer-links {
        list-style: none;
        padding: 0;
        margin: 0;
    }

    .footer-links li {
        margin-bottom: 10px;
    }

    .footer-links a {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 10px;
        padding: 6px 0;
        color: #94a3b8;
        font-size: 14px;
        text-decoration: none;
        transition: color 0.2s ease, transform 0.15s ease;
    }

    .footer-links a i {
        font-size: 12px;
        opacity: 0.5;
        transition: transform 0.15s ease, opacity 0.15s ease;
    }

    .footer-links a:hover {
        color: #bbf7d0;
        transform: translateX(2px);
    }

    .footer-links a:hover i {
        opacity: 1;
        transform: translateX(3px);
    }

    .footer-contact-info {
        margin-top: 6px;
        text-align: left;
    }

    .footer-contact-info p {
        color: #cbd5e1;
        font-size: 14px;
        margin-bottom: 10px;
        display: flex;
        align-items: flex-start;
        justify-content: flex-start;
        gap: 10px;
        background: rgba(15, 23, 42, 0.85);
        border-radius: 9999px;
        padding: 8px 14px;
        border: 1px solid rgba(148, 163, 184, 0.18);
    }

    .footer-contact-info span {
        flex: 1;
    }

    .footer-contact-info i {
        color: #22c55e;
        margin-top: 2px;
        font-size: 16px;
    }

    .social-links {
        display: flex;
        gap: 14px;
        margin-top: 22px;
    }

    .social-links a {
        width: 40px;
        height: 40px;
        border-radius: 9999px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 18px;
        color: #e5e7eb;
        background: radial-gradient(circle at 30% 20%, rgba(148, 163, 184, 0.25), rgba(15, 23, 42, 1));
        border: 1px solid rgba(148, 163, 184, 0.45);
        box-shadow: 0 10px 25px rgba(15, 23, 42, 0.75);
        transition: transform 0.18s ease, box-shadow 0.18s ease, border-color 0.18s ease, background 0.18s ease;
    }

    .social-links a:hover {
        transform: translateY(-3px) scale(1.02);
        box-shadow: 0 14px 32px rgba(22, 163, 74, 0.65);
        border-color: rgba(74, 222, 128, 0.9);
        background: linear-gradient(135deg, #22c55e, #a3e635);
        color: #022c22;
    }

    .footer-bottom {
        border-top: 1px solid rgba(148, 163, 184, 0.28);
        margin-top: 32px;
        padding-top: 20px;
        text-align: center;
        color: #9ca3af;
        font-size: 13px;
    }

    .footer-bottom .highlight {
        color: #bbf7d0;
        font-weight: 500;
    }

    /* ===== NÚT VỀ ĐẦU TRANG ===== */
    .back-to-top {
        position: fixed;
        bottom: 96px;
        right: 30px;
        width: 46px;
        height: 46px;
        border-radius: 9999px;
        background: radial-gradient(circle at 30% 20%, #4ade80, #16a34a);
        display: flex;
        align-items: center;
        justify-content: center;
        color: #022c22;
        font-size: 22px;
        cursor: pointer;
        transition: transform 0.18s ease, box-shadow 0.18s ease, opacity 0.18s ease, background 0.18s ease;
        opacity: 0;
        visibility: hidden;
        z-index: 1000;
        box-shadow: 0 14px 30px rgba(22, 163, 74, 0.55);
    }

    .back-to-top.show {
        opacity: 1;
        visibility: visible;
        transform: translateY(0);
    }

    .back-to-top:hover {
        transform: translateY(-4px);
        box-shadow: 0 18px 40px rgba(22, 163, 74, 0.75);
    }

    .back-to-top i {
        transform: translateY(1px);
    }

    /* ===== CHAT WIDGET (GIỮ NGUYÊN) ===== */
    .haf-chat-launcher{
        position: fixed; right: 30px; bottom: 30px;
        display: inline-flex; align-items: center; gap: 10px;
        height: 48px; padding: 0 14px; border: 0; border-radius: 9999px;
        background: #0f172a; color: #fff; font-weight: 600; cursor: pointer;
        box-shadow: 0 10px 24px rgba(0,0,0,.25); z-index: 1001;
        transition: transform .2s ease, box-shadow .2s ease, background-color .2s ease;
    }
    .haf-chat-launcher i{ font-size: 20px; line-height: 1; }

    /* Panel—kích thước nhất quán */
    .haf-chat-panel{
        position: fixed; right: 30px; bottom: 100px;
        width: 430px; max-width: calc(100vw - 40px);
        height: 70vh; min-height: 420px;
        display: flex; flex-direction: column;
        background: #0f172a; border-radius: 16px; overflow: hidden;
        box-shadow: 0 30px 70px rgba(0,0,0,.45); z-index: 1002;
        opacity: 0; visibility: hidden; transform: translateY(12px);
        transition: opacity .18s ease, transform .18s ease, visibility .18s ease;
        box-sizing: border-box;
    }
    .haf-chat-panel.is-open{ opacity:1; visibility:visible; transform: translateY(0); }

    .haf-chat-header{
        flex: 0 0 auto;
        padding: 14px 16px; background:#0b1220; color:#fff;
        display:flex; align-items:center; justify-content:space-between; gap:8px;
        border-bottom: 1px solid rgba(255,255,255,.06);
    }
    .haf-chat-header .title{ display:flex; align-items:center; gap:8px; font-weight:700; }
    .haf-chat-close{ background: transparent; border:0; color:#cbd5e1; cursor:pointer; padding:6px; }
    .haf-chat-close:hover{ color:#fff; }

    .haf-chat-body{
        flex: 1 1 auto; min-height: 0;
        background:#111827; color:#e5e7eb; padding: 16px;
        overflow-y: auto;
        scrollbar-gutter: stable both-edges;
        scrollbar-width: thin;
        scrollbar-color: #263244 #0b1220;
    }
    .haf-chat-body::-webkit-scrollbar{ width: 10px; }
    .haf-chat-body::-webkit-scrollbar-track{ background: #0b1220; border-radius: 10px; }
    .haf-chat-body::-webkit-scrollbar-thumb{ background:#263244; border-radius: 10px; border: 2px solid #0b1220; }
    .haf-chat-body::-webkit-scrollbar-thumb:hover{ background:#2f4058; }
    .haf-chat-body::-webkit-scrollbar-thumb:active{ background:#16a34a; }

    .haf-msg { margin-bottom: 10px; display:flex; gap:8px; }
    .haf-msg.user { justify-content: flex-end; }
    .haf-msg .bubble{
        max-width: 85%;
        padding: 10px 12px; border-radius: 12px; line-height: 1.5;
        border: 1px solid #263244; word-break: break-word;
    }
    .haf-msg.user .bubble { background:#22c55e; color:#0b1220; border-color:#16a34a; }
    .haf-msg.bot  .bubble { background:#1f2937; color:#e5e7eb; }

    .haf-chat-card{
        background:#1f2937; border:1px solid #263244; color:#e5e7eb;
        border-radius: 14px; padding: 14px; line-height: 1.5;
        /* FIX: tạo khoảng cách tách khỏi tin nhắn đầu tiên */
        margin-bottom: 12px;
    }
    /* đảm bảo tin nhắn đầu tiên luôn có khoảng cách với khung gợi ý */
    .haf-chat-card + .haf-msg{ margin-top: 10px; }

    .haf-chat-input{
        flex: 0 0 auto;
        display:flex; align-items:center; gap:8px; padding:12px; background:#0b1220;
        border-top:1px solid rgba(255,255,255,.06);
    }
    .haf-chat-input input[type="text"]{
        flex:1; height:46px; border-radius: 10px; border:1px solid #223049;
        background:#111827; color:#e5e7eb; padding: 0 12px; outline: none;
    }
    .haf-chat-input input::placeholder{ color:#94a3b8; }
    .haf-chat-send{
        width:46px; height:46px; border-radius: 10px; border:0; cursor:pointer;
        background:#22c55e; color:#0b1220; display:flex; align-items:center; justify-content:center; font-size:18px;
    }
    .haf-chat-send:hover{ filter: brightness(.95); }

    .haf-hint{ font-size:12px; color:#94a3b8; margin-top:6px; }
    .haf-spinner{ display:inline-block; width:16px; height:16px; border:2px solid #93c5fd; border-top-color:transparent; border-radius:50%; animation:spin 1s linear infinite; }
    @keyframes spin { to { transform: rotate(360deg); } }

    /* --- Dấu ba chấm lượn sóng --- */
    .typing { display:inline-flex; align-items:center; gap:6px; height: 16px; }
    .typing .dot{ width:6px; height:6px; border-radius:50%; background:#cbd5e1; opacity:.6; animation: wave 1.2s infinite ease-in-out; }
    .typing .dot:nth-child(2){ animation-delay:.15s; }
    .typing .dot:nth-child(3){ animation-delay:.3s; }
    @keyframes wave{ 0%,100%{ transform: translateY(0); opacity:.6; } 50%{ transform: translateY(-5px); opacity:1; } }

    /* --- Gợi ý nhanh --- */
    .haf-quick-wrap{ margin-top: 14px; }
    .haf-quick-title{ font-size:13px; color:#94a3b8; margin-bottom: 8px; }
    .haf-quick-grid{ display: grid; grid-template-columns: 1fr; gap: 8px; }
    .haf-quick-btn{
        display: inline-flex; width: 100%; text-align: left;
        align-items: center; gap: 8px; padding: 10px 12px;
        background:#0b1220; color:#e5e7eb; border:1px solid #223049;
        border-radius: 10px; cursor: pointer; font-size: 14px;
        transition: background .15s ease, transform .1s ease;
    }
    .haf-quick-btn:hover{ background:#111827; }
    .haf-quick-btn:active{ transform: translateY(1px); }

    /* Responsive footer layout */
    @media (max-width: 991.98px){
        .footer-container{
            padding-top: 52px;
        }
        .footer-section{
            text-align: center;
        }
        .footer-section h5::after{
            left: 50%;
            transform: translateX(-50%);
        }
        .footer-links a{
            justify-content: center;
        }
        .footer-contact-info{
            text-align: center;
        }
        .footer-contact-info p{
            justify-content: center;
        }
        .social-links{
            justify-content: center;
        }
    }

    /* Mobile */
    @media (max-width: 480px){
        .haf-chat-panel{ right: 10px; left: 10px; bottom: 80px; width: auto; height: 70vh; min-height: 420px; }
        .haf-chat-launcher{ right: 10px; bottom: 20px; }
        .back-to-top{ right: 10px; bottom: 80px; }
    }
    @media (min-width: 481px) and (max-width: 768px){
        .haf-chat-panel{ width: 430px; height: 70vh; min-height: 420px; }
    }
</style>

<footer class="footer-container" aria-label="Chân trang">
    <div class="container">
        <div class="row">
            <!-- Sản phẩm -->
            <div class="col-lg-3 col-md-6 footer-section">
                <h5>Sản phẩm</h5>
                <ul class="footer-links">
                    <li>
                        <a href="#" aria-label="Danh sách yêu thích">
                            <span>Danh sách yêu thích</span>
                            <i class="bi bi-chevron-right"></i>
                        </a>
                    </li>
                    <li>
                        <a href="#" aria-label="Blog">
                            <span>Blog</span>
                            <i class="bi bi-chevron-right"></i>
                        </a>
                    </li>
                    <li>
                        <a href="#" aria-label="Câu hỏi thường gặp">
                            <span>Câu hỏi thường gặp</span>
                            <i class="bi bi-chevron-right"></i>
                        </a>
                    </li>
                    <li>
                        <a href="#" aria-label="Giao hàng">
                            <span>Giao hàng</span>
                            <i class="bi bi-chevron-right"></i>
                        </a>
                    </li>
                    <li>
                        <a href="#" aria-label="Tìm kiếm">
                            <span>Tìm kiếm</span>
                            <i class="bi bi-chevron-right"></i>
                        </a>
                    </li>
                    <li>
                        <a href="#" aria-label="Bộ sưu tập">
                            <span>Bộ sưu tập</span>
                            <i class="bi bi-chevron-right"></i>
                        </a>
                    </li>
                </ul>
            </div>

            <!-- Thông tin công ty -->
            <div class="col-lg-6 col-md-6 footer-section">
                <img src="<%= ResolveUrl("~/images/HAFood_logo.png") %>" alt="Logo HAFood" class="footer-logo">
                <p class="footer-center-text">
                    HAFood mang đến thực phẩm tươi, an toàn, giao nhanh trong ngày tại TP. Hồ Chí Minh.
                </p>
                <div class="footer-contact-info">
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
                    <a href="#" aria-label="X (Twitter)">
                        <i class="bi bi-twitter-x"></i>
                    </a>
                    <a href="https://www.facebook.com/vinhhung.tran.37454961" aria-label="Facebook của Trần Vĩnh Hùng" target="_blank" rel="noopener noreferrer">
                        <i class="bi bi-facebook"></i>
                    </a>
                    <a href="#" aria-label="Pinterest">
                        <i class="bi bi-pinterest"></i>
                    </a>
                    <a href="#" aria-label="Instagram">
                        <i class="bi bi-instagram"></i>
                    </a>
                </div>
            </div>

            <!-- Công ty chúng tôi -->
            <div class="col-lg-3 col-md-6 footer-section">
                <h5>Công ty chúng tôi</h5>
                <ul class="footer-links">
                    <li>
                        <a href="#" aria-label="Liên hệ">
                            <span>Liên hệ</span>
                            <i class="bi bi-chevron-right"></i>
                        </a>
                    </li>
                    <li>
                        <a href="#" aria-label="Giao hàng">
                            <span>Giao hàng</span>
                            <i class="bi bi-chevron-right"></i>
                        </a>
                    </li>
                    <li>
                        <a href="#" aria-label="Điều khoản &amp; Điều kiện sử dụng">
                            <span>Điều khoản &amp; Điều kiện sử dụng</span>
                            <i class="bi bi-chevron-right"></i>
                        </a>
                    </li>
                    <li>
                        <a href="#" aria-label="Về chúng tôi">
                            <span>Về chúng tôi</span>
                            <i class="bi bi-chevron-right"></i>
                        </a>
                    </li>
                    <li>
                        <a href="#" aria-label="Thông báo pháp lý">
                            <span>Thông báo pháp lý</span>
                            <i class="bi bi-chevron-right"></i>
                        </a>
                    </li>
                </ul>
            </div>
        </div>

        <!-- Cuối chân trang -->
        <div class="row">
            <div class="col-12">
                <div class="footer-bottom">
                    <p class="mb-0">
                        Bản quyền © 2025 • <span class="highlight">Vận hành bởi HAFood</span>
                    </p>
                </div>
            </div>
        </div>
    </div>
</footer>

<div class="back-to-top" id="backToTop" onclick="scrollToTop()" title="Lên đầu trang" aria-label="Lên đầu trang">
    <i class="bi bi-chevron-up"></i>
</div>

<button id="hafChatLauncher" class="haf-chat-launcher" type="button" aria-label="Mở cửa sổ chat" aria-controls="hafChatPanel" aria-expanded="false">
    <i class="bi bi-chat-dots-fill" aria-hidden="true"></i>
    <span>Nhắn tin</span>
    <span class="haf-chat-badge" aria-hidden="true"></span>
</button>

<section id="hafChatPanel" class="haf-chat-panel" role="dialog" aria-label="Hộp thoại Chat" aria-modal="false">
    <div class="haf-chat-header">
        <div class="title">
            <i class="bi bi-chat-dots-fill"></i>
            <span>Nhắn tin với chúng tôi</span>
        </div>
        <button class="haf-chat-close" id="hafChatClose" type="button" aria-label="Đóng chat">
            <i class="bi bi-x-lg" aria-hidden="true"></i>
        </button>
    </div>

    <div class="haf-chat-body" id="hafChatBody">
        <div class="haf-chat-card" id="hafWelcome">
            <div style="font-size:22px; margin-bottom:8px; font-weight:600">👋 Xin chào!</div>
            <div>Chào bạn, tôi là trợ lý CSKH cho HAFood. Tôi hỗ trợ tra cứu đơn, tìm sản phẩm và giải đáp thắc mắc. Bạn cần gì hôm nay?</div>
            <div class="haf-hint">Bạn có thể đặt câu hỏi bất kỳ về sản phẩm hoặc đơn hàng.</div>

            <!-- Gợi ý nhanh -->
            <div class="haf-quick-wrap" aria-label="Gợi ý nhanh">
                <div class="haf-quick-title">Gợi ý câu hỏi</div>
                <div class="haf-quick-grid" id="hafQuickGrid">
                    <button type="button" class="haf-quick-btn" data-text="Bạn muốn tìm kiếm sản phẩm có giá trị bao nhiêu?">
                        <i class="bi bi-cash-coin" aria-hidden="true"></i>
                        <span>Bạn muốn tìm kiếm sản phẩm có giá trị bao nhiêu?</span>
                    </button>
                    <button type="button" class="haf-quick-btn" data-text="Bạn có muốn mình gợi ý các sản phẩm bán chạy không?">
                        <i class="bi bi-stars" aria-hidden="true"></i>
                        <span>Bạn có muốn mình gợi ý các sản phẩm bán chạy không?</span>
                    </button>
                    <button type="button" class="haf-quick-btn" data-text="Bạn có muốn kiểm tra đơn hàng không? Nếu có hãy nhập mã đơn để mình kiểm tra nhé.">
                        <i class="bi bi-truck" aria-hidden="true"></i>
                        <span>Bạn có muốn kiểm tra đơn hàng không? Nếu có hãy nhập mã đơn để mình kiểm tra nhé.</span>
                    </button>
                    <button type="button" class="haf-quick-btn" data-text="Bạn muốn tìm kiếm sản phẩm nào? Hãy nhập tên giúp mình nhé.">
                        <i class="bi bi-search" aria-hidden="true"></i>
                        <span>Bạn muốn tìm kiếm sản phẩm nào? Hãy nhập tên giúp mình nhé.</span>
                    </button>
                </div>
            </div>
        </div>
    </div>

    <div class="haf-chat-input">
        <input type="text" id="hafInput" placeholder="Viết tin nhắn" aria-label="Ô nhập tin nhắn">
        <button class="haf-chat-send" id="hafSendBtn" type="button" aria-label="Gửi">
            <i class="bi bi-send-fill" aria-hidden="true"></i>
        </button>
    </div>
</section>

<script>
    const CHAT_PROXY = '<%= ResolveUrl("~/Proxy/ChatProxy.ashx") %>';

    // Back to top
    window.addEventListener('scroll', function () {
        var backToTop = document.getElementById('backToTop');
        if (window.pageYOffset > 300) backToTop.classList.add('show'); else backToTop.classList.remove('show');
    });
    function scrollToTop() { window.scrollTo({ top: 0, behavior: 'smooth' }); }

    // Helpers
    function escapeHtml(str) {
        return (str || '').replace(/[&<>"'`=\/]/g, function (s) {
            return ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;', '/': '&#x2F;', '`': '&#x60;', '=': '&#x3D;' })[s];
        });
    }
    function appendMsg(role, html) {
        const body = document.getElementById('hafChatBody');
        const wrap = document.createElement('div');
        wrap.className = 'haf-msg ' + role;
        const bubble = document.createElement('div');
        bubble.className = 'bubble';
        bubble.innerHTML = html;
        wrap.appendChild(bubble);
        body.appendChild(wrap);
        body.scrollTop = body.scrollHeight;
        return wrap;
    }
    function spinnerHtml() { return '<span class="haf-spinner" aria-hidden="true"></span>'; }

    // ---- formatter: **bold** và *"italic"* (nghiêng khi có asterisk bọc ngoài cặp ngoặc kép)
    function formatBotHtml(text) {
        let html = escapeHtml(text || '');

        // **đậm**
        html = html.replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>');

        // *"..."* với ngoặc kép thẳng (escape -> &quot;)
        html = html.replace(/\*&quot;([\s\S]*?)&quot;\*/g, '&quot;<em>$1</em>&quot;');

        // *“...”* với ngoặc cong unicode
        html = html.replace(/\*“([\s\S]*?)”\*/g, '“<em>$1</em>”');

        // *&ldquo;...&rdquo;* và *&#8220;...&#8221;*
        html = html.replace(/\*&ldquo;([\s\S]*?)&rdquo;\*/g, '&ldquo;<em>$1</em>&rdquo;');
        html = html.replace(/\*&#8220;([\s\S]*?)&#8221;\*/g, '&#8220;<em>$1</em>&#8221;');

        // xuống dòng
        html = html.replace(/\n/g, '<br>');

        return html;
    }

    // Typing indicator
    let typingNode = null;
    function showTyping() {
        if (typingNode) return;
        typingNode = appendMsg('bot', '<span class="typing" aria-label="Đang soạn..."><span class="dot"></span><span class="dot"></span><span class="dot"></span></span>');
    }
    function hideTyping() {
        if (typingNode && typingNode.parentNode) typingNode.parentNode.removeChild(typingNode);
        typingNode = null;
    }

    // fetch with timeout
    function fetchWithTimeout(resource, options = {}) {
        const { timeout = 20000 } = options;
        const controller = new AbortController();
        const id = setTimeout(() => controller.abort(), timeout);
        return fetch(resource, { ...options, signal: controller.signal })
            .finally(() => clearTimeout(id));
    }

    async function askChat(message) {
        const resp = await fetchWithTimeout(CHAT_PROXY + '?action=ask', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
            body: JSON.stringify({ message: message || '' }),
            cache: 'no-store',
            timeout: 20000
        });
        const data = await resp.json();
        if (!resp.ok || !data.Success) throw new Error(data.Message || ('HTTP ' + resp.status));
        return data.Reply || data.Message || '';
    }

    // Gửi text (từ nút hoặc ô input)
    async function sendText(text) {
        const bodyText = (text || '').trim();
        if (!bodyText) return;

        appendMsg('user', escapeHtml(bodyText));
        const sendBtn = document.getElementById('hafSendBtn');
        const input = document.getElementById('hafInput');

        input.value = '';
        sendBtn.disabled = true; sendBtn.innerHTML = spinnerHtml();

        try {
            showTyping();
            const reply = await askChat(bodyText);
            hideTyping();
            appendMsg('bot', formatBotHtml(reply));
        } catch (err) {
            hideTyping();
            appendMsg('bot', '❌ ' + escapeHtml(err.message || 'Gửi chat thất bại'));
        } finally {
            sendBtn.disabled = false; sendBtn.innerHTML = '<i class="bi bi-send-fill" aria-hidden="true"></i>';
            const body = document.getElementById('hafChatBody');
            body.scrollTop = body.scrollHeight;
        }
    }

    // NEW: kiểm tra đã có hội thoại chưa
    function hasConversation() {
        return document.querySelector('.haf-msg.user, .haf-msg.bot') !== null;
    }

    (function () {
        const launcher = document.getElementById('hafChatLauncher');
        const panel = document.getElementById('hafChatPanel');
        const closeBtn = document.getElementById('hafChatClose');
        const input = document.getElementById('hafInput');
        const sendBtn = document.getElementById('hafSendBtn');
        const chatBody = document.getElementById('hafChatBody');

        // UPDATED: lần đầu mở -> scrollTop = 0 (thấy phần chào), đã có chat -> xuống cuối
        function setOpen(isOpen) {
            panel.classList.toggle('is-open', isOpen);
            launcher.setAttribute('aria-expanded', String(isOpen));
            if (isOpen) {
                input.focus();
                if (hasConversation()) {
                    chatBody.scrollTop = chatBody.scrollHeight;
                } else {
                    chatBody.scrollTop = 0;
                }
            }
        }

        launcher.addEventListener('click', () => setOpen(!panel.classList.contains('is-open')));
        closeBtn.addEventListener('click', () => setOpen(false));
        document.addEventListener('keydown', (e) => { if (e.key === 'Escape') setOpen(false); });

        // Enter để gửi
        input.addEventListener('keydown', (e) => {
            if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                sendBtn.click();
            }
        });

        // Nút gửi
        sendBtn.addEventListener('click', () => {
            sendText(input.value);
        });

        // Click gợi ý nhanh -> gửi ngay
        chatBody.addEventListener('click', (e) => {
            const btn = e.target.closest('.haf-quick-btn');
            if (!btn) return;
            const text = btn.getAttribute('data-text') || btn.textContent.trim();
            sendText(text);
        });
    })();
</script>
