<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="Footer.ascx.cs" Inherits="HAFoodWeb.Control.Footer" %>

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">

<style>
    .footer-container {
        background-color: #1a1a1a;
        color: #ffffff;
        padding: 60px 0 20px;
        margin-top: 80px;
    }
    
    .footer-logo {
        max-width: 120px;
        margin: 0 auto 30px;
        display: block;
        border-radius: 40%;
    }
    
    .footer-section h5 {
        font-size: 18px;
        font-weight: 600;
        margin-bottom: 25px;
        color: #ffffff;
    }
    
    .footer-links {
        list-style: none;
        padding: 0;
        margin: 0;
    }
    
    .footer-links li {
        margin-bottom: 12px;
    }
    
    .footer-links a {
        color: #b0b0b0;
        text-decoration: none;
        font-size: 14px;
        transition: color 0.3s ease;
    }
    
    .footer-links a:hover {
        color: #8bc34a;
    }
    
    .footer-contact-info p {
        color: #b0b0b0;
        font-size: 14px;
        margin-bottom: 15px;
        display: flex;
        align-items: flex-start;
        gap: 10px;
        justify-content: center;
    }
    
    .footer-contact-info i {
        color: #8bc34a;
        margin-top: 3px;
        font-size: 16px;
    }
    
    .social-links {
        display: flex;
        gap: 15px;
        margin-top: 20px;
    }
    
    .social-links a {
        width: 40px;
        height: 40px;
        background-color: #2a2a2a;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        color: #ffffff;
        font-size: 18px;
        transition: all 0.3s ease;
    }
    
    .social-links a:hover {
        background-color: #8bc34a;
        transform: translateY(-3px);
        color: #ffffff;
    }
    
    .social-links a:hover i {
        color: #ffffff;
    }
    
    .footer-bottom {
        border-top: 1px solid #333;
        margin-top: 40px;
        padding-top: 25px;
        text-align: center;
        color: #888;
        font-size: 14px;
    }
    
    .back-to-top {
        position: fixed;
        bottom: 30px;
        right: 30px;
        width: 50px;
        height: 50px;
        background-color: #8bc34a;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        color: #ffffff;
        font-size: 24px;
        cursor: pointer;
        transition: all 0.3s ease;
        opacity: 0;
        visibility: hidden;
        z-index: 1000;
        box-shadow: 0 4px 12px rgba(139, 195, 74, 0.4);
    }
    
    .back-to-top.show {
        opacity: 1;
        visibility: visible;
    }
    
    .back-to-top:hover {
        background-color: #7cb342;
        transform: translateY(-5px);
        box-shadow: 0 6px 16px rgba(139, 195, 74, 0.5);
    }
    
    @media (max-width: 768px) {
        .footer-container {
            padding: 40px 0 20px;
        }
        
        .footer-section {
            margin-bottom: 30px;
        }
        
        .back-to-top {
            width: 45px;
            height: 45px;
            bottom: 20px;
            right: 20px;
        }
    }
</style>

<footer class="footer-container">
    <div class="container">
        <div class="row">
            <!-- Products Section -->
            <div class="col-lg-3 col-md-6 footer-section">
                <h5>Products</h5>
                <ul class="footer-links">
                    <li><a href="#">Wishlist</a></li>
                    <li><a href="#">Blog</a></li>
                    <li><a href="#">Faq's</a></li>
                    <li><a href="#">Delivery</a></li>
                    <li><a href="#">Search</a></li>
                    <li><a href="#">Collection</a></li>
                </ul>
            </div>
            
            <!-- Company Info Section -->
            <div class="col-lg-6 col-md-6 footer-section">
                <img src="<%= ResolveUrl("~/images/HAFood_logo.png") %>" alt="HAFood Logo" class="footer-logo">
                <div class="footer-contact-info" style="text-align: center;">
                    <p>
                        <i class="bi bi-geo-alt-fill"></i>
                        <span>My School, 1 Vo Van Ngan Street, Thu Duc, TP. HCM</span>
                    </p>
                    <p>
                        <i class="bi bi-envelope-fill"></i>
                        <span>hafood123@gmail.com</span>
                    </p>
                    <p>
                        <i class="bi bi-telephone-fill"></i>
                        <span>(+84) 123-456-789</span>
                    </p>
                </div>
                <div class="social-links justify-content-center">
                    <a href="#" aria-label="Twitter"><i class="bi bi-twitter-x"></i></a>
                    <a href="#" aria-label="Facebook"><i class="bi bi-facebook"></i></a>
                    <a href="#" aria-label="Pinterest"><i class="bi bi-pinterest"></i></a>
                    <a href="#" aria-label="Instagram"><i class="bi bi-instagram"></i></a>
                </div>
            </div>
            
            <!-- Our Company Section -->
            <div class="col-lg-3 col-md-6 footer-section">
                <h5>Our Company</h5>
                <ul class="footer-links">
                    <li><a href="#">Contact Us</a></li>
                    <li><a href="#">Delivery</a></li>
                    <li><a href="#">Terms & Conditions Of Use</a></li>
                    <li><a href="#">About Us</a></li>
                    <li><a href="#">Legal Notice</a></li>
                </ul>
            </div>
        </div>
        
        <!-- Footer Bottom -->
        <div class="row">
            <div class="col-12">
                <div class="footer-bottom">
                    <p class="mb-0">
                        Copyright © 2025 Theme: Veggie (Password: 1) | Powered by Shopify
                    </p>
                </div>
            </div>
        </div>
    </div>
</footer>

<!-- Back to Top Button -->
<div class="back-to-top" id="backToTop" onclick="scrollToTop()">
    <i class="bi bi-arrow-up"></i>
</div>

<script>
    // Show/Hide Back to Top button
    window.addEventListener('scroll', function () {
        var backToTop = document.getElementById('backToTop');
        if (window.pageYOffset > 300) {
            backToTop.classList.add('show');
        } else {
            backToTop.classList.remove('show');
        }
    });

    // Smooth scroll to top
    function scrollToTop() {
        window.scrollTo({
            top: 0,
            behavior: 'smooth'
        });
    }
</script>