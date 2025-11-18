<%@ Control Language="C#" AutoEventWireup="true"
    CodeBehind="CartVouchers.ascx.cs"
    Inherits="HAFoodWeb.Cart.CartVouchers" %>

<link rel="stylesheet" href="<%= ResolveUrl("~/assets/css/cart-voucher.css") %>" />
<div id="voucherNotice" class="voucher-notice" style="display:none"></div>

<div class="voucher-panel open"><%-- open chỉ để bo góc/đổ bóng --%>
  <div class="voucher-head">
    <div class="voucher-title">
      <i class="bi bi-ticket-perforated"></i>
      <span>Khuyến mãi áp dụng</span>
    </div>

    <div class="voucher-actions">
      <a href="#" id="lnkOpenVoucher" class="voucher-pick">Chọn hoặc nhập mã</a>
      <span id="voucherAppliedChip" class="voucher-chip" style="display:none" title="Đang áp dụng"></span>
    </div>
  </div>

  <!-- Host giữ aria-live (ẩn khi dùng modal-only) -->
  <div id="voucherHost" class="voucher-list" aria-live="polite"></div>
</div>

<%--<script src="<%= ResolveUrl("~/assets/js/cart-voucher.js") %>"></script>--%>

<script src="<%= ResolveUrl("~/assets/js/cart-voucher.js?v=20251119_2") %>"></script>

<script>
    (function () {
        function doInit() {
            // kiểm tra initCartVouchers có hay chưa
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

            console.log('[voucher] jwtHidden len =', jwtHidden.length,
                'jwtCookie len =', jwtCookie.length,
                'jwt len =', jwt.length);

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

            console.log('[voucher] opts.jwt =', opts.jwt);

            // 🌟 GỌI INIT Ở ĐÂY
            window.initCartVouchers(opts);
        }

        // Đợi DOM ready rồi mới init, tránh race với script src
        if (document.readyState === 'complete' || document.readyState === 'interactive') {
            setTimeout(doInit, 0);
        } else {
            document.addEventListener('DOMContentLoaded', function () {
                setTimeout(doInit, 0);
            });
        }
    })();

    function showVoucherNotice(msg) {
        const el = document.getElementById('voucherNotice');
        if (!el) return;
        el.textContent = msg || '';
        el.style.display = msg ? 'block' : 'none';
        if (msg) {
            setTimeout(() => {
                if (el.textContent === msg) el.style.display = 'none';
            }, 4000);
        }
    }

</script>

