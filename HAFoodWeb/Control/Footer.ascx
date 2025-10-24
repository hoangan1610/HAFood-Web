<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="Footer.ascx.cs" Inherits="HAFoodWeb.Control.Footer" %>

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">

<style>
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
    .back-to-top {
        position: fixed; bottom: 30px; right: 30px; width: 50px; height: 50px; background-color: #8bc34a;
        border-radius: 50%; display: flex; align-items: center; justify-content: center; color: #ffffff;
        font-size: 24px; cursor: pointer; transition: all 0.3s ease; opacity: 0; visibility: hidden; z-index: 1000;
        box-shadow: 0 4px 12px rgba(139, 195, 74, 0.4);
    }
    .back-to-top.show { opacity: 1; visibility: visible; }
    .back-to-top:hover { background-color: #7cb342; transform: translateY(-5px); box-shadow: 0 6px 16px rgba(139, 195, 74, 0.5); }
    @media (max-width: 768px) {
        .footer-container { padding: 40px 0 20px; }
        .footer-section { margin-bottom: 30px; }
        .back-to-top { width: 45px; height: 45px; bottom: 20px; right: 20px; }
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
                    <a href="#" aria-label="Facebook"><i class="bi bi-facebook"></i></a>
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
    <i class="bi bi-arrow-up"></i>
</div>

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
</script>
