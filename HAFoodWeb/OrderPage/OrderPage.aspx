<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="OrderPage.aspx.cs"
    Inherits="HAFoodWeb.OrderPage" Async="true" %>

<%@ Register Src="~/Control/Header.ascx" TagPrefix="uc" TagName="Header" %>
<%@ Register Src="~/Control/Footer.ascx" TagPrefix="uc" TagName="Footer" %>

<!DOCTYPE html>
<html lang="vi">
<head runat="server">
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>Đơn hàng của tôi - HAFood</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />

  <style>
    body { background-color: #f8f9fa; font-family: 'Segoe UI', sans-serif; }
    .order-card { background: #fff; border-radius: .75rem; box-shadow: 0 .25rem .75rem rgba(0,0,0,.05); padding: 1.25rem; margin-bottom: 1rem; transition: box-shadow .2s ease; }
    .order-card:hover { box-shadow: 0 .5rem 1rem rgba(0,0,0,.08); }
    .order-header { font-weight: 600; font-size: 1rem; color: #333; }
    .order-meta { font-size: .9rem; color: #555; }
    .order-total { font-weight: 700; color: #e55a00 !important; margin-top: 0.25rem;}
    .status-badge { font-size: .8rem; padding: .35rem .6rem; border-radius: .5rem; font-weight: 600; display: inline-block; }
    .status-0 { background-color: #ffc10733; color: #c28a00; }
    .status-1 { background-color: #17a2b833; color: #0c5460; }
    .status-2 { background-color: #007bff33; color: #004085; }
    .status-3 { background-color: #28a74533; color: #155724; }
    .status-4 { background-color: #dc354533; color: #721c24; }
    .paging .btn { min-width: 40px; }
    .order-link { color: inherit; text-decoration: none; display:block; }
    .order-link:hover { text-decoration: none; }
  </style>
</head>

<body>
  <form id="form1" runat="server">
    <uc:Header ID="Header1" runat="server" />

    <div class="container my-4">
      <h2 class="mb-4 fw-semibold">Đơn hàng của tôi</h2>

      <asp:Literal ID="litDebug" runat="server" Visible="false" EnableViewState="false"></asp:Literal>

      <!-- Orders list -->
      <asp:Repeater ID="rpOrders" runat="server" OnItemDataBound="rpOrders_ItemDataBound">
        <ItemTemplate>
          <!-- use asp:HyperLink and ResolveUrl to build absolute path from application root -->
          <asp:HyperLink runat="server" CssClass="order-link"
            NavigateUrl='<%# ResolveUrl(String.Format("~/OrderPage/OrderDetail.aspx?id={0}", Eval("id"))) %>'>
            <div class="order-card">
              <div class="d-flex justify-content-between align-items-center mb-2">
                <div class="order-header">
                  Mã đơn: <strong><%# Eval("order_Code") %></strong>
                </div>
                <span id="statusBadge" runat="server"></span>
              </div>

              <div class="order-meta mb-2">
                Người nhận: <%# Eval("ship_Name") %><br />
                SĐT: <%# Eval("ship_Phone") %><br />
                Địa chỉ: <%# Eval("ship_Full_Address") %><br />
                Ngày đặt: <%# Eval("placed_At", "{0:HH:mm dd/MM/yyyy}") %>
              </div>

              <div class="order-total fw-bold">
                Tổng thanh toán:
                <%# string.Format(new System.Globalization.CultureInfo("vi-VN"), "{0:#,0}đ", Eval("pay_Total")) %>
              </div>
            </div>
          </asp:HyperLink>
        </ItemTemplate>
      </asp:Repeater>

      <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
        <div class="text-center text-muted py-5">Bạn chưa có đơn hàng nào.</div>
      </asp:Panel>

      <!-- Pagination panel -->
      <asp:Panel ID="pnlPagination" runat="server" CssClass="d-flex justify-content-center align-items-center gap-3 mt-4 paging" Visible="false">
        <asp:Button ID="btnPrev" runat="server" CssClass="btn btn-outline-secondary btn-sm" Text="← Trước" OnClick="btnPrev_Click" />
        <asp:Repeater ID="rpPaging" runat="server" OnItemCommand="rpPaging_ItemCommand">
          <ItemTemplate>
            <asp:LinkButton ID="lnkPage" runat="server"
              CssClass='<%# (int)Container.DataItem == CurrentPage ? "btn btn-sm btn-warning mx-1" : "btn btn-sm btn-outline-secondary mx-1" %>'
              CommandName="ChangePage"
              CommandArgument='<%# Container.DataItem %>'
              Text='<%# Container.DataItem %>'>
            </asp:LinkButton>
          </ItemTemplate>
        </asp:Repeater>
        <asp:Button ID="btnNext" runat="server" CssClass="btn btn-outline-secondary btn-sm" Text="Sau →" OnClick="btnNext_Click" />
      </asp:Panel>

    </div>

    <uc:Footer ID="Footer1" runat="server" />
  </form>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
