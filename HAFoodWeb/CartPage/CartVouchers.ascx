<%@ Control Language="C#" AutoEventWireup="true"
    CodeBehind="CartVouchers.ascx.cs"
    Inherits="HAFoodWeb.Cart.CartVouchers" %>

<link rel="stylesheet" href="<%= ResolveUrl("~/assets/css/cart-voucher.css") %>" />

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

<script src="<%= ResolveUrl("~/assets/js/cart-voucher.js") %>"></script>

<script>
    (function () {
        if (!window.initCartVouchers) return;

        const opts = {
            apiBase: document.getElementById('<%= this.HidApiBase.ClientID %>').value || '',
        jwt: (document.getElementById('<%= this.HidJwt.ClientID %>')?.value || '').trim(),
        deviceUuid: document.getElementById('<%= this.HidDeviceUuid.ClientID %>').value || '',
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

        function ready() {
            const hasItems = document.querySelectorAll('.cart-item').length > 0;
            const hid = document.querySelector(opts.selectors.selectedLinesHidden);
            const hiddenHasValue = !!(hid && hid.value && hid.value.trim());
            if (hasItems || hiddenHasValue) { window.initCartVouchers(opts); return true; }
            return false;
        }
        if (!ready()) {
            if (document.readyState === 'loading') {
                document.addEventListener('DOMContentLoaded', () => { if (!ready()) setTimeout(ready, 120); });
            } else { setTimeout(ready, 120); }
        }
    })();
</script>
