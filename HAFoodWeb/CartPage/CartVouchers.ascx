<%@ Control Language="C#" AutoEventWireup="true"
    CodeBehind="CartVouchers.ascx.cs"
    Inherits="HAFoodWeb.Cart.CartVouchers" %>

<link rel="stylesheet" href="<%= ResolveUrl("~/assets/css/cart-voucher.css") %>" />

<!-- NOTICE cảnh báo (giống hình bạn gửi) -->
<div id="voucherNotice" class="voucher-notice" style="display:none"></div>

<style>
  /* ===== FORCE: chip "Đang áp dụng" xuống dòng dưới title ===== */
  .voucher-head{
    display:flex !important;
    flex-direction:column !important;
    gap:10px !important;
  }
  .voucher-head-row{
    display:flex !important;
    align-items:center !important;
    justify-content:space-between !important;
    gap:12px !important;
  }
  /* Canh chip nằm dưới chữ "Khuyến mãi áp dụng" (thụt vào theo icon) */
  .voucher-applied-row{
    padding-left:28px; /* icon + gap */
  }

  /* ===== NOTICE style giống hình ===== */
  .voucher-notice{
    margin:0 0 12px 0;
    padding:12px 14px;
    border-radius:14px;
    background:#fff;
    border:1px solid rgba(16,24,40,.06);
    box-shadow:0 12px 30px rgba(16,24,40,.08);
    color:#111827;
    font-weight:600;
    line-height:1.5;
    word-break:break-word;
  }
</style>

<div class="voucher-panel open"><%-- open chỉ để bo góc/đổ bóng --%>

  <div class="voucher-head">
    <!-- ROW 1: title trái + link phải -->
    <div class="voucher-head-row">
      <div class="voucher-title">
        <i class="bi bi-ticket-perforated"></i>
        <span>Khuyến mãi áp dụng</span>
      </div>

      <div class="voucher-actions">
        <a href="#" id="lnkOpenVoucher" class="voucher-pick">Chọn hoặc nhập mã</a>
      </div>
    </div>

    <!-- ROW 2: chip xuống dòng dưới title -->
    <div class="voucher-applied-row">
      <span id="voucherAppliedChip" class="voucher-chip" style="display:none" title="Đang áp dụng"></span>
    </div>
  </div>

  <!-- Host giữ aria-live (ẩn khi dùng modal-only) -->
  <div id="voucherHost" class="voucher-list" aria-live="polite"></div>
</div>

<script src="<%= ResolveUrl("~/assets/js/cart-voucher.js?v=20251119_6") %>"></script>

<script>
    (function () {
        function doInit() {
            if (typeof window.initCartVouchers !== 'function') {
                console.warn('[voucher] initCartVouchers NOT FOUND ở doInit');
                return;
            }

            var apiBaseHid = document.getElementById('<%= this.HidApiBase.ClientID %>');
            var jwtHid = document.getElementById('<%= this.HidJwt.ClientID %>');
            var deviceHid = document.getElementById('<%= this.HidDeviceUuid.ClientID %>');

            var jwtHidden = (jwtHid && jwtHid.value || '').trim();

            // thử lấy từ cookie (phòng khi sau login quay lại)
            var m = document.cookie.match(/(?:^|;\s*)AuthToken=([^;]+)/);
            var jwtCookie = m ? m[1] : '';

            var jwt = (jwtHidden || jwtCookie || '').trim();

            const opts = {
                apiBase: (apiBaseHid && apiBaseHid.value || '').trim(),
                jwt: jwt,
                deviceUuid: deviceHid && deviceHid.value || '',
                channel: 1,
                selectors: {
                    listEl: '#voucherHost',
                    txtPromo: '#<%= this.TxtPromoClientId %>',
                    lblSubtotal: '#<%= this.LblSubtotalClientId %>',
                    lblVat: '#<%= this.LblVatClientId %>',
                    lblShipping: '#<%= this.LblShippingClientId %>',
                    lblDiscount: '#<%= this.LblDiscountClientId %>',
                    lblGrandTotal: '#<%= this.LblGrandClientId %>',
                    selectedLinesHidden: '#<%= this.HidSelectedLinesClientId %>',
                    hidPromoCode: '#<%= this.HidPromoCodeClientId %>',
                    hidPromoDiscount: '#<%= this.HidPromoDiscountClientId %>',
                    hidPromoMetaJson: '#<%= this.HidPromoMetaJsonClientId %>'
                },
                formSelector: 'form#form1'
            };

            window.initCartVouchers(opts);
        }

        if (document.readyState === 'complete' || document.readyState === 'interactive') {
            setTimeout(doInit, 0);
        } else {
            document.addEventListener('DOMContentLoaded', function () {
                setTimeout(doInit, 0);
            });
        }
    })();

    // NOTICE show/hide (để CartPage.aspx gọi)
    function showVoucherNotice(msg) {
        const el = document.getElementById('voucherNotice');
        if (!el) return;

        const text = (msg || '').toString().trim();
        if (!text) {
            el.textContent = '';
            el.style.display = 'none';
            return;
        }

        el.textContent = text;
        el.style.display = 'block';

        // auto-hide nhẹ (bạn có thể bỏ nếu muốn giữ nguyên)
        setTimeout(() => {
            if (el.textContent === text) {
                el.style.display = 'none';
                el.textContent = '';
            }
        }, 6000);
    }
</script>
