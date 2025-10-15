$(document).ready(function() {

  jQuery('.nav-toggle').click(function(event) {
    jQuery(this).toggleClass('active');
    event.stopPropagation();
    jQuery(' #tt-megamenu .tt-mega_menu').slideToggle("2000");
  });
  jQuery("#tt-megamenu .tt-mega_menu").on("click", function(event) {
    event.stopPropagation();
    jQuery(this).removeClass('active');
  });		

  jQuery(".filter-toggle").on("click" , function(e){
    e.preventDefault();
    jQuery(this).toggleClass("active");
    jQuery(".filter-toggle-wrap").slideToggle("is-visible");
  })

  /*---------------- End Blog UP/Down JS  ---------------- */ 

  //filter


  if(jQuery(".header_3.site-header").hasClass('disable_menutoggle')){
    jQuery("body").addClass("disable_menutoggle");
    if(jQuery(".header_3.site-header").hasClass('menu_left')){
      jQuery("body").addClass("menu_left");
    }
    if(jQuery(".header_3.site-header").hasClass('menu_right')){
      jQuery("body").addClass("menu_right");
    }
  }
  if(jQuery('.header_1 .wrapper-wrap').hasClass('logo_center'))  {
    jQuery('body').addClass('logo_center');
  }
  var w_width = $(window).width();
  $('.slider-content-main-wrap').css('width',w_width);
  if($('.site-header').hasClass('header_transaparent')){
    $('body.template-index').addClass('header_transaparent')
  }

  $(".header_1 .mini-cart-wrap").perfectScrollbar();

  var img_id = jQuery('.product-single__thumbs .slick-active.slick-current').find('.product-single__thumb').data('id');
  if(jQuery('.product-lightbox-btn').hasClass(img_id)){
    jQuery('.product-lightbox-btn.'+img_id).show();
  }

  jQuery(".filter-left").on("click" , function(e){
    e.preventDefault();
    jQuery(this).toggleClass("active");
    jQuery(".off-canvas.position-left").toggleClass("is-open");
    jQuery(".js-off-canvas-overlay.is-overlay-fixed").toggleClass("is-visible is-closable");
  });
  jQuery(".is-overlay-fixed").on("click" , function(e){
    e.preventDefault();
    jQuery(".filter-left").trigger('click');
    jQuery(".filter-right").trigger('click');
  });
  jQuery(".filter-right").on("click" , function(e){
    e.preventDefault();
    jQuery(this).toggleClass("active");
    jQuery(".off-canvas.position-right").toggleClass("is-open");
    jQuery(".js-off-canvas-overlay.is-overlay-fixed").toggleClass("is-visible is-closable");
  });
  $('.product-360-button a').magnificPopup({
    type: 'inline',
    mainClass: 'mfp-fade',
    removalDelay: 160,
    disableOn: false,
    preloader: false,
    fixedContentPos: false,
    callbacks: {
      open: function() {
        $(window).resize()
      }
    }
  });

  countDownIni('.flip-countdown,.js-flip-countdown');


  function megaMenu(){
    if(jQuery(window).width() < 992) {
      jQuery('body:not(.rtl) #tt-megamenu .tt_menus_ul > .tt_menu_item > .tt_sub_menu_wrap').each(function() {    
        jQuery(this).css('margin-left', + (0) + 'px');      
      });
      jQuery('body.rtl #tt-megamenu .tt_menus_ul > .tt_menu_item > .tt_sub_menu_wrap').each(function() {    
        jQuery(this).css('margin-left', + (0) + 'px');      
      });
    }
    else{
      jQuery('body:not(.rtl) #tt-megamenu .tt_menus_ul > .tt_menu_item > .tt_sub_menu_wrap').each(function() {
        var menu = jQuery('#tt-megamenu').offset();
        var dropdown = jQuery(this).parent().offset();
        var i = (dropdown.left + jQuery(this).outerWidth()) - (menu.left + jQuery('#tt-megamenu').outerWidth());
        if (i > 0) {
          jQuery(this).css('margin-left', '-' + (i + 10) + 'px');
        }
      });
      jQuery('body.rtl #tt-megamenu .tt_menus_ul > .tt_menu_item > .tt_sub_menu_wrap').each(function() {
        var menu = jQuery('#tt-megamenu').offset();
        var dropdown = jQuery(this).parent().offset();
        var i = (dropdown.left + jQuery(this).outerWidth()) - (menu.left + jQuery('#tt-megamenu').outerWidth());
        if (i > 0) {
          jQuery(this).css('margin-left', '-' + (i + 10) + 'px');
        }
      });
    }
    jQuery('#tt-megamenu .tt-mega_menu li.more_menu .tt_sub_menu_linklist .tt_menu_item .tt_sub_menu_wrap').css('margin','0');     
  }

  jQuery(document).ready(function() {
    megaMenu();
  });
  jQuery(window).resize(function() {
    megaMenu();
  });

  jQuery('#ttcmsabout2 .ttaboutbanner .ttabouts').hover(
    function(){ jQuery(this).addClass('active') },
    function(){ jQuery(this).removeClass('active') }
  )

  /*---  vvideo popup ----*/

  var p = jQuery(".popup_overlay");

  jQuery(".play-icone").click(function() {
    jQuery("body").addClass("popup-toggle");
    p.css("display", "block");

  });
  p.click(function(event) {
    e = event || window.event;
    if (e.target == this) {
      jQuery(p).css("display", "none");
      jQuery('body').removeClass('popup-toggle'); 
    }
  });
  jQuery(".popup_close,.flex-direction-nav li a").click(function() {
    p.css("display", "none");
    jQuery('body').removeClass('popup-toggle'); 
  });

  //video popup
  function toggleVideo(state) {
    // if state == 'hide', hide. Else: show video
    e = state || window.event;
    if (e.target == this) {
      var div = document.getElementById("popupVid");
      var iframe = div.getElementsByTagName("iframe")[0].contentWindow;
      //div.style.display = state == 'hide' ? 'none' : '';
      func = state == "hide" ? "pauseVideo" : "playVideo";
      iframe.postMessage(
        '{"event":"command","func":"' + func + '","args":""}',
        "*"
      );
    }
  }

  jQuery("#popup_toggle").click(function() {
    p.css("visibility", "visible").css("opacity", "1");
  });

  p.click(function(event) {
    e = event || window.event;
    if (e.target == this) {
      jQuery(p)
      .css("visibility", "hidden")
      .css("opacity", "0");
      toggleVideo("hide");
    }
  });

  jQuery(".popup_close,.flex-direction-nav li a").click(function() {
    p.css("visibility", "hidden").css("opacity", "0");
    toggleVideo("hide");
  });

  var iframe = jQuery("iframe")[0];

  /** popup Video **/

  $('.popup-video').magnificPopup({
    disableOn: 300,
    type: 'iframe',
    mainClass: 'mfp-fade',
    removalDelay: 160,
    preloader: false,
    fixedContentPos: false
  });

  /***/

  if ($('a.product-lightbox-btn').length > 0 || $('a.product-video-popup').length > 0) {
    $('.product-single__photos .gallery,.design_2 .product-img').magnificPopup({
      delegate: 'a', // child items selector, by clicking on it popup will open
      type: 'image',
      tLoading: '<div class="please-wait dark"><span></span><span></span><span></span></div>',
      removalDelay: 300,
      closeOnContentClick: true,
      gallery: {
        enabled: true,
        navigateByImgClick: false,
        preload: [0, 1]
      },
      image: {
        verticalFit: false,
        tError: '<a href="%url%">The image #%curr%</a> could not be loaded.'
      },
      callbacks: {
        beforeOpen: function() {
          var productVideo = $('.product-video-popup').attr('href');
          if (productVideo) {
            this.st.mainClass = 'has-product-video';
            var galeryPopup = $.magnificPopup.instance;
            galeryPopup.items.push({
              src: productVideo,
              type: 'iframe'
            });
            galeryPopup.updateItemHTML();
          }
        },
        open: function() {}
      }
      // other options
    });
  }
  $('.design_3 .product-img,.design_5 .pro_img').magnificPopup({
    delegate: 'a', // child items selector, by clicking on it popup will open
    type: 'image',
    tLoading: '<div class="please-wait dark"><span></span><span></span><span></span></div>',
    removalDelay: 300,
    closeOnContentClick: true,
    gallery: {
      enabled: true,
      navigateByImgClick: false,
      preload: [0, 1]
    },
    image: {
      verticalFit: false,
      tError: '<a href="%url%">The image #%curr%</a> could not be loaded.'
    },
    callbacks: {
      beforeOpen: function() {
        var productVideo = $('.product-video-popup').attr('href');
        if (productVideo) {
          this.st.mainClass = 'has-product-video';
          var galeryPopup = $.magnificPopup.instance;
          galeryPopup.items.push({
            src: productVideo,
            type: 'iframe'
          });
          galeryPopup.updateItemHTML();
        }
      },
      open: function() {}
    }
    // other options
  });
  $('body').on('click', '.product-lightbox-btn', function(e) {
    $('.product-wrapper-owlslider').find('.owl-item.active a').click();
    e.preventDefault();
  });

     $('.full_gallery_slider.owl-carousel').on('changed.owl.carousel',function(property){
    var currentItem=(property.item.index+1)-property.relatedTarget._clones.length/2;
    var totalItems=property.item.count;
    if (currentItem > totalItems || currentItem == 0) {
      currentItem = totalItems - (currentItem % totalItems);
    }
    $(".num").html(currentItem+'/'+totalItems)
  }); 
  
  $('body:not(.rtl) .full_gallery_slider.owl-carousel').owlCarousel({
    stagePadding: 200,
    loop:true,
    startPosition:0,
    center: true,
    dots:true,
    items:1,
    lazyLoad: true,
    nav:true,
    responsive:{
      0:{
        items:1,
        stagePadding: 60
      },
      600:{
        items:1,
        stagePadding: 150
      },
      768:{
        items:1,
        stagePadding: 180
      },
      868:{
        items:1,
        stagePadding: 250
      },
      1800:{
        items:1,
        stagePadding: 300
      }
    }
  });
  $('body.rtl .full_gallery_slider.owl-carousel').owlCarousel({
    stagePadding: 200,
    loop:true,
    startPosition:0,
    center: true,
    dots:true,
    items:1,
    rtl:true,
    lazyLoad: true,
    nav:true,
    responsive:{
      0:{
        items:1,
        stagePadding: 60
      },
      600:{
        items:1,
        stagePadding: 150
      },
      768:{
        items:1,
        stagePadding: 180
      },
      868:{
        items:1,
        stagePadding: 250
      },
      1800:{
        items:1,
        stagePadding: 300
      }
    }
  });

  jQuery(".fullscreen_header_toggle").on("click" , function(e){
    e.preventDefault();
    jQuery(this).toggleClass("active");   
    jQuery('#tt-megamenu').toggleClass("active");
    jQuery(".fullscreen_header").toggleClass("nav-open");
    jQuery("body").toggleClass("fullnav-open header_1");
  });

  /* style1 product thumb img*/
  jQuery('.product-single__thumbs img').on('click', function () {
    var src = jQuery(this).attr('src');

    if (src != '') {
      jQuery(this).closest('.product-wrapper').find('img.grid-view-item__image').first().attr('src', src);
    }
    jQuery(this).parent('.grid-item').addClass('open').siblings('.grid-item').removeClass('open');
  });

  /* start vertical js*/	
  if(jQuery(".leftmenu_header").length > 0){
    if(jQuery(".header_3 .leftmenu_header").length > 0){
      if(jQuery(".header_3 .leftmenu_header").hasClass('menu_left')){
        jQuery("body").addClass("menu_left");
      } 
      if(jQuery(".header_3 .leftmenu_header").hasClass('menu_right')){
        jQuery("body").addClass("menu_right");
      }
    }else if(jQuery(".leftmenu_header_fixed.leftmenu_header").length > 0){
      if(jQuery(".leftmenu_header_fixed.leftmenu_header").hasClass('menu_left')){
        jQuery("body").addClass("menu_left");
      } 
      if(jQuery(".leftmenu_header_fixed.leftmenu_header").hasClass('menu_right')){
        jQuery("body").addClass("menu_right");
      }
    }else{
      if(jQuery(".header_3 .leftmenu_header").parent().hasClass('menu_left')){
        jQuery("body").addClass("menu_left");
      }
      if(jQuery(".header_3 .leftmenu_header").hasClass('menu_right')){
        jQuery("body").addClass("menu_right");
      }
    }
    jQuery(".leftmenu_header").on("click" , function(e){
      e.preventDefault();
      jQuery(this).toggleClass("active");
      jQuery("body").toggleClass("nav-open");
    });

  }

  /* end vertical js*/

  $('.qtyplus').on('click',function(e){
    e.preventDefault();     
    var  input_val = jQuery(this).parents('.qty-box-set').find('.quantity');
    var currentVal = parseInt( jQuery(this).parents('.qty-box-set').find('.quantity').val());
    if (!isNaN(currentVal)) {
      jQuery(this).parents('.qty-box-set').find('.quantity').val(currentVal + 1);
    } else {
      jQuery(this).parents('.qty-box-set').find('.quantity').val(1);
    }

  });

  $(".qtyminus").on('click',function(e) {
    e.preventDefault();
    var  input_val = jQuery(this).parents('.qty-box-set').find('.quantity');
    var currentVal = parseInt( jQuery(this).parents('.qty-box-set').find('.quantity').val());
    if (!isNaN(currentVal) && currentVal > 1) {
      jQuery(this).parents('.qty-box-set').find('.quantity').val(currentVal - 1);
    } else {
      jQuery(this).parents('.qty-box-set').find('.quantity').val(1);
    }

  });
  $("#navToggle").on('click',function(e) {
    jQuery(this).next('.Site-navigation').slideToggle(500);
  });
  $(".menu_toggle_wrap #navToggle").on('click',function(e) {
    jQuery(this).parent().next('.Site-navigation').slideToggle(500);
  });

  // testimonial

  $('body:not(.rtl) .tt-testimonial-wrap .testimonials_wrap').owlCarousel({
    items: 1, //1 items above 1000px browser width
    nav: false,
    dots: true,
    loop: false,
    autoplay: true,
    autoplayHoverPause: true,
    responsive: {
      1279: {
        items: 1
      },
      1250: {
        items: 1
      },
      600: {
        items: 1
      }
    }
  });
  $('body.rtl .tt-testimonial-wrap .testimonials_wrap').owlCarousel({
    items: 1, //1 items above 1000px browser width
    nav: false,
    rtl: true,
    dots: true,
    autoplay: true,
    loop: false,
    autoplayHoverPause: true,
    responsive: {
      1279: {
        items: 1
      },
      1250: {
        items: 1
      },
      600: {
        items: 1
      }
    }
  });
  /*header-product*/
  $('body:not(.rtl) #tt-megamenu .list_product_menu_content').owlCarousel({
    items : 3, //1 items above 1000px browser width
    nav : true,
    autoPlay:true,
    autoplaySpeed:1000,
    stopOnHover: false,
    loop: false,
    dots : true,
    responsive: {
      768: {
        items: 3
      },
      481: {
        items: 2
      },
      100: {
        items: 1
      }
    }
  });
  $('body.rtl #tt-megamenu .list_product_menu_content').owlCarousel({
    items : 3, //1 items above 1000px browser width
    nav : true,
    autoPlay:true,
    autoplaySpeed:1000,
    rtl: true,
    stopOnHover: false,
    loop: false,
    dots : true,
    responsive: {
      768: {
        items: 3
      },
      481: {
        items: 2
      },
      100: {
        items: 1
      }
    }
  });
  /* service*/

  $('body:not(.rtl) .ttcmsservices .service-block').owlCarousel({
    items: 4, //1 items above 1000px browser width
    nav: false,
    dots: false,
    loop: false,
    autoplay: true,
    autoplayHoverPause: true,
    responsive: {
      0: {
        items: 1
      },
      480: {
        items: 2
      },
      768: {
        items: 3
      },
      992: {
        items: 4
      },
      1279: {
        items: 4
      }
    }
  });
  $('body.rtl .ttcmsservices .service-block').owlCarousel({
    items: 4, //1 items above 1000px browser width
    nav: false,
    rtl: true,
    dots: false,
    autoplay: true,
    loop: false,
    autoplayHoverPause: true,
    responsive: {
      0: {
        items: 1
      },
      480: {
        items: 2
      },
      768: {
        items: 3
      },
      992: {
        items: 4
      },
      1279: {
        items: 4
      }
    }
  });



  /*Scroll to top js*/
  jQuery("#GotoTop").on('click',function () {
    jQuery("html, body").animate({
      scrollTop: 0
    }, '1000');
    return false;
  });

  jQuery(".site-header__search.search-full .serach_icon").on('click',function(e){
    e.preventDefault();
    jQuery(this).toggleClass('active'); 
    jQuery('body').toggleClass('search_full_active'); 
    jQuery('.full-search-wrapper').addClass('search-overlap');
    jQuery(".search-bar > input").focus();
  });
  jQuery(".site-header__search.search-full .close-search").on('click',function(){
    jQuery('.site-header__search.search-full .serach_icon').removeClass('active');   
    jQuery('.full-search-wrapper').removeClass('search-overlap');   
    jQuery('body').removeClass('search_full_active'); 
  });

  jQuery(".site-header__search:not(.search-full) .serach_icon").on('click',function(){  
    jQuery('body').toggleClass('search-open');
    jQuery( "body" ).removeClass( 'myaccount_active' );
    jQuery('body').removeClass('cart_active');
    jQuery( ".search_wrapper" ).slideToggle( "fast" );
    jQuery( ".search-bar > input" ).focus();
    jQuery(this).toggleClass('active');
    jQuery( ".customer_account" ).slideUp( "fast" );    
    jQuery( "#slidedown-cart" ).slideUp( "fast" );
    jQuery( "#Sticky-slidedown-cart" ).slideUp( "fast" );
  });
  jQuery(".myaccount  .dropdown-toggle").on('click',function(event){   
    event.preventDefault();
    jQuery('body').toggleClass('myaccount_active');
    jQuery('body').removeClass('search-open');
    jQuery('body').removeClass('cart_active');
    if($(".currency-block")[0]){
      $(".currency-block > ul").css('display','none');                                  
      $(".header_currency .currency_wrapper.dropdown-toggle").removeClass('active'); 
    }
    if($(".language-block")[0]){
      $(".language-block > ul").css('display','none');                                  
      $(".header_language .language_wrapper.dropdown-toggle").removeClass('active'); 
    }

    jQuery( ".customer_account" ).slideToggle( "fast" );
    jQuery('.site-header__search:not(.search-full) .serach_icon').removeClass('active');
    jQuery('body').removeClass('search_full_active'); 
    jQuery( ".site-header .search_wrapper" ).slideUp( "fast" );
    jQuery( "#slidedown-cart" ).slideUp( "fast" );
    jQuery( "#Sticky-slidedown-cart" ).slideUp( "fast" );
  });

  $(".header_currency .currency_wrapper.dropdown-toggle").on("click", function (event) {     
    event.preventDefault();
    jQuery(".customer_account").stop(); 
    jQuery( ".currencies.flag-dropdown-menu" ).slideToggle( "fast" );
    jQuery( ".language.flag-dropdown-menu" ).slideUp( "fast" );
    $(this).toggleClass('active');  
    jQuery( ".customer_account" ).slideUp( "fast" );
    jQuery( "#slidedown-cart" ).slideUp( "fast" );
    jQuery( "#Sticky-slidedown-cart" ).slideUp( "fast" );
    jQuery( ".site-header .search_wrapper" ).slideUp( "fast" );
  });
  $(".header_language .language-block .language_wrapper.dropdown-toggle").on("click", function (event) {     
    event.preventDefault();
    jQuery(".customer_account").stop(); 
    jQuery( ".language.flag-dropdown-menu" ).slideToggle( "fast" );
    $(this).toggleClass('active');  
    jQuery( ".customer_account" ).slideUp( "fast" );
    jQuery( "#slidedown-cart" ).slideUp( "fast" );
    jQuery( ".currencies.flag-dropdown-menu" ).slideUp( "fast" );
    jQuery( "#Sticky-slidedown-cart" ).slideUp( "fast" );
    jQuery( ".site-header .search_wrapper" ).slideUp( "fast" );
  });

  var p_col = jQuery('.slider-specialproduct').data('col');
  if(jQuery("body").hasClass('disable_menutoggle')){
    $('body.disable_menutoggle .slider-specialproduct').owlCarousel({
      items : p_col, //10 items above 1000px browser width
      nav : true,
      dots : false,
      responsive: {
        100: {
          items: 1
        },
        470: {
          items: 2
        },
        768: {
          items: 3
        },
        992: {
          items: 3
        },
        1200: {
          items: p_col
        }
      }
    });
  }else{
    $('body .slider-specialproduct').owlCarousel({
      items : p_col, //10 items above 1000px browser width
      nav : true,
      dots : false,
      responsive: {
        100: {
          items: 1
        },
        470: {
          items: 2
        },
        768: {
          items: 3
        },
        992: {
          items: 3
        },
        1200: {
          items: p_col
        }
      }
    });
  }  

  $('.slider-specialproduct-wrap').each(function () { 
    if($(this).find('.owl-nav').hasClass('disabled')){
      $(this).find('.customNavigation').hide();
    }else{
      $(this).find('.customNavigation').show();
    }
  });
  $(".slider-specialproduct-wrap .customNavigation .next").click(function(){
    var wrap = $(this).closest('.slider-specialproduct-wrap');
    $(wrap).find('.slider-specialproduct').trigger('next.owl');
  });
  $(".slider-specialproduct-wrap .customNavigation .prev").click(function(){
    var wrap = $(this).closest('.slider-specialproduct-wrap');
    $(wrap).find('.slider-specialproduct').trigger('prev.owl');
  });
  $('.mobile-nav__sublist-trigger,.header_3 .mobile-nav__sublist-trigger').on('click', function(evt) {
    evt.preventDefault();
    var $el = $(this);
    $el.toggleClass('is-active');
    $el.parent().find('.tt_sub_menu_wrap').slideToggle(200);
  });

  // brands 

  var brandsowl = $("body:not(.rtl) #brands_list_slider");
  var  brandsowlrtl = $("body.rtl #brands_list_slider");
  brandsowl.owlCarousel({
    items : 5 , //10 items above 1000px browser width
    dots: false,
    loop: false,
    autoplay:true,
    autoplayHoverPause:true,
    nav: true,
    responsive: {
      100: {
        items: 2
      },
      320: {
        items: 2
      },
      544: {
        items: 3
      },
      992: {
        items: 4
      },
      1200: {
        items: 5
      }
    }
  });
  brandsowlrtl.owlCarousel({
    items : 5 , //10 items above 1000px browser width
    dots: false,
    loop: false,
    nav: true,
    autoplay:true,
    autoplayHoverPause:true,
    rtl: true,
    responsive: {
      100: {
        items: 2
      },
      320: {
        items: 2
      },
      544: {
        items: 3
      },
      992: {
        items: 4
      },
      1200: {
        items: 5
      }
    }
  });
  $(".brands_next").click(function(){
    brandsowl.trigger('owl.next');
  });
  $(".brands_prev").click(function(){
    brandsowl.trigger('owl.prev');
  });
  $(".brands_next").click(function(){
    brandsowlrtl.trigger('owl.next');
  });
  $(".brands_prev").click(function(){
    brandsowlrtl.trigger('owl.prev');
  });

  /* sidebar-bestsellers*/
  $('body:not(.rtl) .widget_top_rated_products .top-products').owlCarousel({
    items : 1, //1 items above 1000px browser width
    nav : true,
    dots : true,
    loop: true,
    autoplay:true,
    stopOnHover: true,
    rtl:false,
    responsive: {
      1279: {
        items: 1
      },
      1250: {
        items: 1
      },
      600: {
        items: 1
      }
    }
  });
  $('body.rtl .widget_top_rated_products .top-products').owlCarousel({
    items : 1, //1 items above 1000px browser width
    nav : true,
    dots : true,
    loop: true,
    autoplay:true,
    stopOnHover: true,
    rtl:true,
    responsive: {
      1279: {
        items: 1
      },
      1250: {
        items: 1
      },
      600: {
        items: 1
      }
    }
  });
  /*sidebar-category*/
  $(".dt-menu-expand").click(function(event){
    event.preventDefault();
    if( $(this).hasClass("dt-mean-clicked") ){
      $(this).text("+");
      if( $(this).prev('ul').length ) {
        $(this).prev('ul').slideUp(400);
      } else {
        $(this).prev('.megamenu-child-container').find('ul:first').slideUp(600);
      }
    } else {
      $(this).text("-");
      if( $(this).prev('ul').length ) {
        $(this).prev('ul').slideDown(400);
      } else{
        $(this).prev('.megamenu-child-container').find('ul:first').slideDown(2000);
      }
    }

    $(this).toggleClass("dt-mean-clicked");
    return false;
  });

  /* ttcollection-cms(categoryfeature)*/
  $('body:not(.rtl) .collection_cms_slider').owlCarousel({             
    nav : true,
    dots : false,
    autoplay:false,
    loop: false,
    responsive: {
      100: {
        items: 1
      },
      361: {
        items: 2
      },
      767: {
        items: 3
      },
      992: {
        items: 4
      },
      1200: {
        items: 4
      }
    }
  });
  $('body.rtl .collection_cms_slider').owlCarousel({
    nav : true,
    rtl:true,
    loop: false,
    autoplay:false,
    dots : false,
    responsive: {
      100: {
        items: 1
      },
      361: {
        items: 2
      },
      767: {
        items: 3
      },
      992: {
        items: 4
      },
      1200: {
        items: 4
      }
    }
  });

  if(jQuery(".collection_cms_slider .owl-nav").hasClass('disabled')){
    jQuery(".collection_cms_slider_wrap .customNavigation").hide();
  }else{
    jQuery(".collection_cms_slider_wrap .customNavigation").show();
  }
  jQuery(".collection_cms_slider_wrap .customNavigation .next").click(function(){
    jQuery('.collection_cms_slider_wrap .collection_cms_slider').trigger('next.owl');
  });
  jQuery(".collection_cms_slider_wrap .customNavigation .prev").click(function(){
    jQuery('.collection_cms_slider_wrap .collection_cms_slider').trigger('prev.owl');
  }); 

});


function headerToggle() {
  $('.site-header.header_2 .mobile-nav__sublist-trigger').on('click', function(evt) {
    evt.preventDefault();
    var $el = $(this);
    $el.toggleClass('is-active');
    $el.parent().next('.mobile-nav__sublist').slideToggle(200);
  });
}
jQuery(document).ready(function() {
  headerToggle();
});
jQuery(window).resize(function() {
  headerToggle();
});

/* related-products*/

function relatedowljs(){
  var related_count = $('.related-products .item-row').length;
  if(related_count > 5) { $('.related_navigation').css('display','block');}
  else {$('.related_navigation').css('display','none');}
  var related = $("body:not(.rtl) .related-products");
  var relatedrtl = $("body.rtl .related-products");
  related.owlCarousel({
    items: 4,
    slidesToScroll:1,
    loop: false,
    responsive: {
      100: {
        items: 1
      },
      410: {
        items: 2
      },
      768: {
        items: 3
      },
      1200: {
        items: 4
      }
    },
    responsiveRefreshRate: 200,
    responsiveBaseWidth: window,
    autoPlay: false,
    stopOnHover: true,
    nav: true,
    dots:false
  });
  if($('.related-products-container').find('.owl-nav').hasClass('disabled')){
    $('.related-products-container').find('.customNavigation').hide();
  }else{
    $('.related-products-container').find('.customNavigation').show();
  }
  // Custom Navigation Events
  $(".related_navigation .next").click(function(){
    related.trigger('next.owl');
  })
  $(".related_navigation .prev").click(function(){
    related.trigger('prev.owl');
  }) 

  relatedrtl.owlCarousel({
    items: 4,
    loop: false,
    rtl: true,
    responsive: {
      100: {
        items: 1
      },
      410: {
        items: 2
      },
      768: {
        items: 3
      },
      1200: {
        items: 4
      }
    },
    responsiveRefreshRate: 200,
    responsiveBaseWidth: window,
    autoPlay: false,
    stopOnHover: true,
    nav: true,
    dots:false
  });
  // Custom Navigation Events
  $(".related_navigation .next").click(function(){
    relatedrtl.trigger('next.owl');
  })
  $(".related_navigation .prev").click(function(){
    relatedrtl.trigger('prev.owl');
  }) 
}
$(document).ready(function(){
  relatedowljs();      
});
$(window).resize(function(){
  relatedowljs(); 
});


/*--------- Start js for menu-left-right -------------*/


jQuery(window).scroll(function () {
  if(jQuery(document).height() > jQuery(window).height()){
    var scroll = jQuery(window).scrollTop();
    if (scroll > 100) {
      jQuery("#GotoTop").fadeIn();
    } else {
      jQuery("#GotoTop").fadeOut();
    }
  }
});

function responsiveMenu(){
  if(jQuery(window).width() < 992) {

    jQuery("#shopify-section-TT-megamenu").insertAfter( ".nav-toggle" );
    jQuery('.sub-nav__dropdown').css('display','none');
    jQuery(".header_2 .wrapper-wrap.logo_center .nav-menu-wrap .contact-info").insertAfter('.header_2 .tt-mega-menu #tt-megamenu .tt-mega_menu ul.tt_menus_ul');
    jQuery(".header_3 .nav-menu-wrap .site-header__cart").appendTo('.header_3 .menu_toggle_wrap');
    jQuery(".header_3 .nav-menu-wrap .delivery-service").insertAfter('.header_3 .tt-mega-menu #tt-megamenu .tt-mega_menu ul.tt_menus_ul');
    jQuery(".header_3 .menu_wrapper .menu-block").insertAfter('.header_3 .fixed-header > .container .header-Top');
    jQuery(".header_3 .nav-menu-wrap .contact-info").insertAfter('.header_3 .delivery-service');    
    jQuery("#shopify-section-footer-model-3 .footer-wrap .footer-cms.block_newsletter").insertAfter( "#shopify-section-footer-model-3 .footer-bottom-wrap .footer-bottom .footer-column.footer-menu" );
  }
  else {
    jQuery("#shopify-section-TT-megamenu").prependTo(".header_2 .menu_wrapper");
    jQuery("#shopify-section-TT-megamenu").appendTo(".header_1_wrapper");   
    jQuery(".header_3 .fixed-header > .container .menu-block").insertBefore('.header_3 .menu_toggle_wrap');
    jQuery(".header_3 .fixed-header .menu_toggle_wrap #shopify-section-TT-megamenu").appendTo( ".header_3 .fixed-header .menu_wrapper.sticky_header .menu-block" ); 
    jQuery(".header_2 .tt-mega-menu #tt-megamenu .tt-mega_menu .contact-info").insertBefore('.header_2 .wrapper-wrap .nav-menu-wrap .header-logo');
    jQuery(".header_3 .tt-mega-menu #tt-megamenu .delivery-service").appendTo('.header_3 .tt-nav-right-div');
    jQuery(".header_3 .tt-mega-menu #tt-megamenu .contact-info").insertAfter('.header_3 .tt-nav-right-div .delivery-service');
    jQuery(".header_3 .menu_toggle_wrap .site-header__cart").insertAfter('.header_3 .tt-nav-right-div .contact-info');
    jQuery("#shopify-section-footer-model-3 .footer-bottom-wrap .footer-bottom .footer-cms.block_newsletter").insertAfter( "#shopify-section-footer-model-3 .footer-wrap .footer-cms.footer-logo" );
  }
}

jQuery(document).ready(function() {
  responsiveMenu();

  jQuery(".product-write-review").on('click',function(e) {
    e.preventDefault();
    $('a[href=\'#tab-2\']').trigger('click');
    jQuery('html, body').animate({
      scrollTop: jQuery(".product_tab_wrapper").offset().top-150
    }, 1000);
  });
});
jQuery(document).load(function() { 
  //var menu_wrapper = jQuery('.menu_wrapper.logo_left').height();
});
jQuery(window).resize(function() {
  responsiveMenu();
  var w_width = $(window).width();
  $('.slider-content-main-wrap').css('width',w_width);
});

function productcartsticky() {
  if (jQuery(window).width() > 319) {
    if (jQuery(this).scrollTop() > 550) {
      jQuery('.add-to-cart-sticky').addClass("fixed");

    } else {
      jQuery('.add-to-cart-sticky').removeClass("fixed");
    }
  } else {
    jQuery('.add-to-cart-sticky').removeClass("fixed");
  }
}

$(document).ready(function() {
  productcartsticky();
});
jQuery(window).resize(function() {
  productcartsticky();
});
jQuery(window).scroll(function() {
  productcartsticky();
});

function footerToggle() {

  if(jQuery( window ).width() < 992) { 
    if(jQuery('.site-footer').hasClass('fixed_footer'))  {
      jQuery('.page-wrapper').css('margin-bottom','0px');
    }
    jQuery('.left-sidebar.sidebar').insertAfter('.collection_wrapper');
    jQuery('.sidebar .collection_sidebar .sidebar-block').insertAfter('.filter-wrapper');
    jQuery(".site-footer .footer-column h5").addClass( "toggle" );
    jQuery(".site-footer .footer-column").children(':nth-child(2)').css( 'display', 'none' );
    jQuery(".site-footer .footer-column.active").children(':nth-child(2)').css( 'display', 'block' );
    jQuery(".site-footer .footer-column h5.toggle").unbind("click");
    jQuery(".site-footer .footer-column h5.toggle").on('click',function() {
      jQuery(this).parent().toggleClass('active').children(':nth-child(2)').slideToggle( "fast" );
    });   
    jQuery(".right-sidebar.sidebar .widget > h4,.left-sidebar.sidebar .widget > h4,.blog-section .sidebar .widget > h4").addClass( "toggle" );
    jQuery(".right-sidebar.sidebar .widget,.left-sidebar.sidebar .widget,.blog-section .sidebar .widget").children(':nth-child(2)').css( 'display', 'none' );
    jQuery(".right-sidebar.sidebar .widget.active,.left-sidebar.sidebar .widget.active,.blog-section .sidebar .widget.active").children(':nth-child(2)').css( 'display', 'block' );
    jQuery(".right-sidebar.sidebar .widget > h4.toggle,.left-sidebar.sidebar .widget > h4.toggle,.blog-section .sidebar .widget > h4.toggle").unbind("click");
    jQuery(".right-sidebar.sidebar .widget > h4.toggle,.left-sidebar.sidebar .widget > h4.toggle,.blog-section .sidebar .widget > h4.toggle").on('click',function() {
      jQuery(this).parent().toggleClass('active').children(':nth-child(2)').slideToggle( "fast" );
    });   
    jQuery(".collection_right .sidebar-block .widget > h4,.collection_left .sidebar-block .widget > h4,.filter-toggle-wrap .sidebar-block .widget > h4").addClass( "toggle" );
    jQuery(".collection_right .sidebar-block .widget,.collection_left .sidebar-block .widget,.filter-toggle-wrap .sidebar-block .widget ").children(':nth-child(2)').css( 'display', 'none' );
    jQuery(".collection_right .sidebar-block .widget.active,.collection_left .sidebar-block .widget.active,.filter-toggle-wrap .sidebar-block .widget.active").children(':nth-child(2)').css( 'display', 'block' );
    jQuery(".collection_right .sidebar-block .widget > h4.toggle,.collection_left .sidebar-block .widget > h4.toggle,.filter-toggle-wrap .sidebar-block .widget > h4.toggle").unbind("click");
    jQuery(".collection_right .sidebar-block .widget > h4.toggle,.collection_left .sidebar-block .widget > h4.toggle,.filter-toggle-wrap .sidebar-block .widget > h4.toggle").on('click',function() {
      jQuery(this).parent().toggleClass('active').children(':nth-child(2)').slideToggle( "fast" );
    });  
  }else{
    jQuery('.sidebar-block').prependTo('.collection_sidebar');
    if(jQuery('.site-footer').hasClass('fixed_footer'))  {
      var footer_h = jQuery('.site-footer.fixed_footer').height();
      jQuery('.page-wrapper').css('margin-bottom',footer_h+'px');
    }
    jQuery('.left-sidebar.sidebar').insertBefore('.collection_wrapper');
    jQuery(".sidebar .widget > h4,.sidebar-block .widget > h4").unbind("click");
    jQuery(".sidebar .widget > h4,.sidebar-block .widget > h4").removeClass( "toggle" );
    jQuery(".sidebar .widget,.sidebar-block .widget").children(':nth-child(2)').css( 'display', 'block' );

    jQuery(".site-footer .footer-column h5").unbind("click");
    jQuery(".site-footer .footer-column h5").removeClass( "toggle" );
    jQuery(".site-footer .footer-column").children(':nth-child(2)').css( 'display', 'block' );

  }
  if(jQuery( window ).width() < 767) {     
    $(".lookbook_wrap_item").each(function (i) {
      var app_div = jQuery(this).find('.grid-img-wrap');
      jQuery(this).find('.lookbook-content.text-center').insertAfter(app_div);

    });
  }else{    
    $(".lookbook_wrap_item").each(function (i) {
      var app_div = jQuery(this);
      jQuery(this).find('.lookbook-content.text-center').prependTo(app_div);        
    });
  }

}
jQuery(document).ready(function() {
  footerToggle();
  /*sidebarsticky();*/
});
jQuery(window).resize(function() {
  footerToggle();
});


function splitStr(string,seperator){
  return string.split(seperator);
}

function countDownIni(countdown) {
  $(countdown).each(function() {
    var countdown = $(this);
    var promoperiod;
    if (countdown.attr('data-promoperiod')) {
      promoperiod = new Date().getTime() + parseInt(countdown.attr('data-promoperiod'), 10)
    } else if (countdown.attr('data-countdown')) {
      promoperiod = countdown.attr('data-countdown')
    }
    if (Date.parse(promoperiod) - Date.parse(new Date()) > 0) {
      $(this).addClass('countdown-block');
      $(this).parent().addClass('countdown-enable');
      console.log();
      countdown.countdown(promoperiod, function(event) {
        countdown.html(event.strftime('<span><span class="left-txt">LEFT</span><span>%D</span><span class="time-txt">days</span></span>' + '<span><span>%H</span><span class="time-txt">hours</span></span>' + '<span><span>%M</span><span class="time-txt">min</span></span>' + '<span><span class="second">%S</span><span class="time-txt">sec</span></span>'))
      })
    }
  })
}

function hb_animated_contents() {
  $(".hb-animate-element:in-viewport").each(function (i) {
    var $this = $(this);
    if (!$this.hasClass('hb-in-viewport')) {
      setTimeout(function () {
        $this.addClass('hb-in-viewport');
      }, 180 * i);
    }
  });
}

$(window).scroll(function () {
  hb_animated_contents();
});
$(window).load(function () {
  hb_animated_contents();
});


function sidebarsticky() { 
  if ($(document).width() <= 1199) {
    jQuery('.left-sidebar.sidebar,.right-sidebar.sidebar').theiaStickySidebar({
      additionalMarginBottom: 30,
      additionalMarginTop: 30
    });
  } 
  else if ($(document).width() >= 1200) {
    jQuery('.left-sidebar.sidebar,.right-sidebar.sidebar').theiaStickySidebar({
      additionalMarginBottom: 30,
      additionalMarginTop: 130
    });
  }
}
jQuery(window).resize(function() {
  sidebarsticky();
});


