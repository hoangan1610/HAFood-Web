<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="Slideshow.ascx.cs" Inherits="HAFoodWeb.Control.SlideShow" %>

<style>
    .slide-container {
        position: relative;
        width: 100%;
        height: 550px;
        overflow: hidden;
        background: #6dbd6b;
    }
    .slide {
        position: absolute;
        width: 100%;
        height: 100%;
        opacity: 0;
        transition: opacity 1s ease-in-out;
        background-size: cover;
        background-position: center;
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: flex-start;
        padding-left: 150px;
        color: #fff;
    }
    .slide.active { opacity: 1; }
    .slide h1 {
        font-size: 60px;
        font-family: "Georgia", serif;
        font-weight: bold;
        line-height: 1.2;
    }
    .slide p {
        font-size: 20px;
        margin-top: 15px;
        max-width: 500px;
    }
</style>

<div class="slide-container">
    <div class="slide active" style='background-image: url("<%= ResolveUrl("~/images/slide1.png") %>");'>
        <h1>Daily Fresh & Organic</h1>
        <p>We believe that healthy eating starts with clean, natural ingredients and a fresh mindset.</p>
    </div>
    <div class="slide" style='background-image: url("<%= ResolveUrl("~/images/slide2.png") %>");'>
        <h1>Fresh Fruits Everyday</h1>
        <p>Discover the best seasonal fruits delivered straight to your door.</p>
    </div>
</div>

<script>
    // SLIDESHOW
    let slides = document.querySelectorAll(".slide");
    let index = 0;
    setInterval(() => {
        slides[index].classList.remove("active");
        index = (index + 1) % slides.length;
        slides[index].classList.add("active");
    }, 5000);
</script>