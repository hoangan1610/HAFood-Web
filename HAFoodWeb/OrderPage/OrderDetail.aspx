<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="OrderDetail.aspx.cs" Inherits="HAFoodWeb.OrderDetail" Async="true" %>
<%@ Register Src="~/Control/Header.ascx" TagPrefix="uc" TagName="Header" %>
<%@ Register Src="~/Control/Footer.ascx" TagPrefix="uc" TagName="Footer" %>

<!DOCTYPE html>
<html lang="vi">
<head runat="server">
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>Chi tiết đơn hàng - HAFood</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
  <style>
    body { font-family: 'Segoe UI', sans-serif; background:#f8f9fa; }
    .card-order { background:#fff; padding:1rem; border-radius:.75rem; box-shadow:0 .25rem .5rem rgba(0,0,0,.05); }
    .item-row { border-bottom:1px solid #eee; padding:12px 0; }
    .item-row:last-child { border-bottom: none; }
    .img-thumb { width:80px; height:80px; object-fit:cover; border-radius:6px; background:#f4f4f4; }
    .meta-small { color:#666; font-size:.9rem; }
    .label { color:#666; font-size:.9rem; }
    .value { font-weight:600; }
    .summary-line { display:flex; justify-content:space-between; gap:12px; padding:6px 0; font-weight: 700; }
  </style>
</head>
<body>
  <form id="form1" runat="server">
    <uc:Header ID="Header1" runat="server" />

    <div class="container my-4">
      <a runat="server" id="lnkBack" href="OrderPage.aspx" class="btn btn-outline-secondary btn-sm mb-3">&larr; Quay lại</a>

      <asp:Literal ID="litDebug" runat="server" Visible="false"></asp:Literal>

      <!-- HEADER: code, ship info, note (no total here) -->
      <asp:Panel ID="pnlHeader" runat="server" Visible="false" CssClass="card-order mb-3">
        <div class="d-flex justify-content-between">
          <div>
            <h4 id="litOrderCode" runat="server"></h4>
            <div class="meta-small">Người nhận: <span id="litShipName" runat="server"></span></div>
            <div class="meta-small">SĐT: <span id="litShipPhone" runat="server"></span></div>
            <div class="meta-small">Địa chỉ: <span id="litShipAddress" runat="server"></span></div>
            <div class="meta-small">Ghi chú: <span id="litNote" runat="server"></span></div>

            <!-- PAYMENT được đặt ngay dưới Ghi chú -->
            <asp:Panel ID="pnlPayment" runat="server" Visible="false" CssClass="mt-2">
              <div class="meta-small">Phương thức: <span id="litPayment" runat="server"></span></div>
            </asp:Panel>
          </div>

          <!-- RIGHT column: chỉ show trạng thái (không show tổng ở đây nữa) -->
          <div class="text-end">
            <div class="meta-small">Trạng thái: <span id="litStatus" runat="server"></span></div>
            <!-- tổng tạm bỏ khỏi header -->
          </div>
        </div>
      </asp:Panel>

      <!-- Items -->
      <asp:Panel ID="pnlItems" runat="server" Visible="false" CssClass="card-order mb-3">
        <h5 class="mb-3">Sản phẩm</h5>
        <asp:Repeater ID="rpItems" runat="server">
          <ItemTemplate>
            <div class="d-flex item-row align-items-center">
              <img src='<%# Eval("image_Variant") ?? Eval("image_Product") ?? "/images/product-default.png" %>' class="img-thumb me-3" onerror="this.src='/images/product-default.png';" />
              <div class="flex-grow-1">
                <div class="fw-semibold"><%# Eval("product_Name") ?? Eval("name_Variant") %></div>
                <div class="meta-small"><%# Eval("sku") %> · Số lượng: <%# Eval("quantity") %></div>
              </div>
              <div class="text-end">
                <div class="fw-semibold"><%# string.Format(new System.Globalization.CultureInfo("vi-VN"), "{0:#,0}đ", Eval("line_Subtotal")) %></div>
                <div class="meta-small"><%# string.Format(new System.Globalization.CultureInfo("vi-VN"), "{0:#,0}đ", Eval("price_Variant")) %></div>
              </div>
            </div>
          </ItemTemplate>
        </asp:Repeater>
      </asp:Panel>

      <!-- Summary: totals (only place showing totals) -->
      <asp:Panel ID="pnlSummary" runat="server" Visible="false" CssClass="card-order">
        <h5 class="mb-3">Tóm tắt</h5>
        <div class="summary-line"><div class="label">Thành tiền</div><div class="value"><asp:Literal ID="litSubtotal" runat="server" /></div></div>
        <div class="summary-line"><div class="label">Giảm giá</div><div class="value"><asp:Literal ID="litDiscount" runat="server" /></div></div>
        <div class="summary-line"><div class="label">Phí vận chuyển</div><div class="value"><asp:Literal ID="litShipping" runat="server" /></div></div>
        <div class="summary-line"><div class="label">VAT</div><div class="value"><asp:Literal ID="litVat" runat="server" /></div></div>
        <hr />
        <div class="summary-line"><div class="label">Tổng thanh toán</div><div class="value"><asp:Literal ID="litPayTotal" runat="server" /></div></div>
      </asp:Panel>

    </div>

    <uc:Footer ID="Footer1" runat="server" />
  </form>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>