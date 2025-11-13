<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="OrderPage.aspx.cs"
    Inherits="HAFoodWeb.OrderPage" Async="true" %>

<!DOCTYPE html>
<html lang="vi">
<head runat="server">
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>Đơn hàng của tôi - HAFood</title>

  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet" />

  <style>
    body {
      background: radial-gradient(circle at top left, #ffe8cc 0, #f8f9fa 40%, #e9ecef 100%);
      font-family: 'Segoe UI', system-ui, -apple-system, BlinkMacSystemFont, sans-serif;
      min-height: 100vh;
    }

    .orders-page {
      max-width: 1080px;
    }

    .page-title {
      font-weight: 700;
      font-size: 1.7rem;
      color: #212529;
    }

    .page-subtitle {
      font-size: .9rem;
      color: #6c757d;
    }

    .title-badge {
      font-size: .75rem;
      letter-spacing: .08em;
      text-transform: uppercase;
      font-weight: 700;
      color: #fd7e14;
      background: rgba(253, 126, 20, .08);
      padding: .26rem .7rem;
      border-radius: 999px;
      display: inline-flex;
      align-items: center;
      gap: .35rem;
      margin-bottom: .25rem;
    }

    .title-badge i {
      font-size: .9rem;
    }

    .filter-bar {
      display: flex;
      flex-wrap: wrap;
      justify-content: center; /* căn giữa các nút lọc */
      gap: 10px;
      margin-bottom: 1.5rem;
      background: rgba(255, 255, 255, .8);
      border-radius: 999px;
      padding: .4rem;
      box-shadow: 0 .25rem .75rem rgba(15, 23, 42, .08);
    }

    .filter-bar .btn {
      min-width: 130px;
      border-radius: 999px;
      font-weight: 500;
      border-color: transparent;
      color: #495057;
      background-color: transparent;
      transition: all 0.2s ease;
      padding-block: .35rem;
      padding-inline: .9rem;
      font-size: .86rem;
    }

    .filter-bar .btn:hover {
      background-color: rgba(33, 37, 41, .08);
    }

    .filter-bar .btn.active {
      background: #212529;
      color: #fff;
      box-shadow: 0 .3rem 1rem rgba(33, 37, 41, .35);
    }

    .order-link {
      color: inherit;
      text-decoration: none;
      display: block;
    }

    .order-link:hover {
      text-decoration: none;
    }

    .order-card {
      background: #fff;
      border-radius: 1rem;
      box-shadow: 0 .35rem 1.25rem rgba(15, 23, 42, .08);
      padding: 1.25rem 1.4rem;
      margin-bottom: 1rem;
      transition: transform .15s ease, box-shadow .15s ease;
      border: 1px solid rgba(0, 0, 0, .02);
      position: relative;
      overflow: hidden;
    }

    .order-card::before {
      content: "";
      position: absolute;
      inset: 0;
      background: linear-gradient(120deg, rgba(253, 126, 20, .06), transparent 30%);
      opacity: 0;
      transition: opacity .2s ease;
      pointer-events: none;
    }

    .order-card:hover {
      transform: translateY(-3px);
      box-shadow: 0 .6rem 1.6rem rgba(15, 23, 42, .14);
    }

    .order-card:hover::before {
      opacity: 1;
    }

    .order-header {
      font-weight: 600;
      font-size: 1rem;
      color: #333;
    }

    .order-header strong {
      font-weight: 700;
    }

    .order-meta {
      font-size: .86rem;
      color: #555;
      line-height: 1.5;
    }

    .order-meta strong {
      font-weight: 600;
    }

    .order-total {
      font-weight: 700;
      color: #e55a00 !important;
      margin-top: 0.25rem;
      font-size: 1.02rem;
    }

    .status-badge {
      font-size: .78rem;
      padding: .3rem .7rem;
      border-radius: 999px;
      font-weight: 600;
      display: inline-flex;
      align-items: center;
      gap: .35rem;
      border: 1px solid transparent;
      background: #f8f9fa;
      color: #495057;
    }

    .status-badge i {
      font-size: .9rem;
    }

    .status-0 { background-color: #fff3cd; color: #856404; border-color: #ffeeba; }
    .status-1 { background-color: #d1ecf1; color: #0c5460; border-color: #bee5eb; }
    .status-2 { background-color: #cfe2ff; color: #084298; border-color: #b6d4fe; }
    .status-3 { background-color: #d4edda; color: #155724; border-color: #c3e6cb; }
    .status-4 { background-color: #f8d7da; color: #721c24; border-color: #f5c6cb; }

    .status-0 i { content: "\f254"; }
    .status-1 i { content: "\f26a"; }
    .status-2 i { content: "\f135"; }
    .status-3 i { content: "\f26a"; }
    .status-4 i { content: "\f623"; }

    .order-card-divider {
      height: 1px;
      background: radial-gradient(circle, rgba(0, 0, 0, .15) 0, transparent 70%);
      opacity: .35;
      margin-block: .6rem;
    }

    .pnl-empty {
      background: rgba(255, 255, 255, .85);
      border-radius: 1rem;
      padding: 2.5rem 1.5rem;
      box-shadow: 0 .25rem .9rem rgba(15, 23, 42, .08);
    }

    .pnl-empty-icon {
      font-size: 2rem;
      color: #ced4da;
      margin-bottom: .5rem;
    }

    .paging {
      display: flex;
      justify-content: center;
      align-items: center;
      gap: 0.5rem;
      margin-top: 1.75rem;
    }

    .paging .btn {
      min-width: 40px;
      border-radius: 999px;
      font-size: .86rem;
    }

    .paging .btn-warning {
      border-radius: 999px;
      font-weight: 700;
    }

    .paging .btn-outline-secondary {
      background: rgba(255, 255, 255, .85);
    }

    @media (max-width: 767.98px) {
      .filter-bar {
        border-radius: 1rem;
        justify-content: center;
      }

      .order-card {
        padding: 1.05rem 1.1rem;
      }
    }
  </style>
</head>

<body>
  <form id="form1" runat="server">
    <div class="container orders-page my-4">
      <!-- HEADER -->
      <div class="mb-3">
        <div class="title-badge">
          <i class="bi bi-basket2"></i>
          HAFood - Lịch sử mua hàng
        </div>
        <h2 class="page-title mb-0">Đơn hàng của tôi</h2>
        <!-- ĐÃ BỎ DÒNG SUBTITLE Ở ĐÂY -->
      </div>

      <!-- Bộ lọc -->
      <div class="filter-bar mt-3">
        <asp:Button ID="btnAll" runat="server" CssClass="btn btn-outline-dark btn-sm active" Text="Tất cả" CommandArgument="all" OnClick="btnFilter_Click" />
        <asp:Button ID="btnPending" runat="server" CssClass="btn btn-outline-dark btn-sm" Text="Chờ xác nhận" CommandArgument="0" OnClick="btnFilter_Click" />
        <asp:Button ID="btnConfirmed" runat="server" CssClass="btn btn-outline-dark btn-sm" Text="Đã xác nhận" CommandArgument="1" OnClick="btnFilter_Click" />
        <asp:Button ID="btnShipping" runat="server" CssClass="btn btn-outline-dark btn-sm" Text="Đang giao" CommandArgument="2" OnClick="btnFilter_Click" />
        <asp:Button ID="btnDelivered" runat="server" CssClass="btn btn-outline-dark btn-sm" Text="Đã giao" CommandArgument="3" OnClick="btnFilter_Click" />
        <asp:Button ID="btnCanceled" runat="server" CssClass="btn btn-outline-dark btn-sm" Text="Đã hủy" CommandArgument="4" OnClick="btnFilter_Click" />
      </div>

      <asp:Literal ID="litDebug" runat="server" Visible="false"></asp:Literal>

      <!-- Danh sách đơn -->
      <asp:Repeater ID="rpOrders" runat="server" OnItemDataBound="rpOrders_ItemDataBound">
        <ItemTemplate>
          <asp:HyperLink runat="server" CssClass="order-link"
            NavigateUrl='<%# ResolveUrl(String.Format("~/OrderPage/OrderDetail.aspx?id={0}", Eval("id"))) %>'>
            <div class="order-card">
              <div class="d-flex justify-content-between align-items-start mb-2 flex-wrap gap-2">
                <div>
                  <div class="order-header">
                    Mã đơn: <strong><%# Eval("order_Code") %></strong>
                  </div>
                  <div class="meta-small text-muted" style="font-size:.8rem;">
                    Đặt lúc <%# Eval("placed_At", "{0:HH:mm dd/MM/yyyy}") %>
                  </div>
                </div>
                <span id="statusBadge" runat="server" class="status-badge">
                  <!-- nội dung + class trạng thái sẽ set trong code-behind -->
                </span>
              </div>

              <div class="order-card-divider"></div>

              <div class="order-meta mb-2">
                <div><strong>Người nhận:</strong> <%# Eval("ship_Name") %></div>
                <div><strong>SĐT:</strong> <%# Eval("ship_Phone") %></div>
                <div><strong>Địa chỉ:</strong> <%# Eval("ship_Full_Address") %></div>
                <div>
                  <strong>Thanh toán:</strong>
                  <span class="text-dark">
                    <%# BuildPaymentText((HAFoodWeb.Models.OrderHeaderDto)Container.DataItem) %>
                  </span>
                </div>
              </div>

              <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                <div class="order-total">
                  Tổng thanh toán:
                  <%# string.Format(new System.Globalization.CultureInfo("vi-VN"), "{0:#,0}đ", Eval("pay_Total")) %>
                </div>
                <div class="text-muted small d-flex align-items-center gap-1">
                  <i class="bi bi-arrow-right-short"></i>
                  Nhấn để xem chi tiết
                </div>
              </div>
            </div>
          </asp:HyperLink>
        </ItemTemplate>
      </asp:Repeater>

      <!-- Không có đơn -->
      <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
        <div class="text-center text-muted py-5 pnl-empty">
          <div class="pnl-empty-icon">
            <i class="bi bi-bag-x"></i>
          </div>
          <div class="fw-semibold mb-1">Bạn chưa có đơn hàng nào.</div>
          <div class="small">Hãy khám phá các món ngon và đặt đơn đầu tiên tại HAFood nhé!</div>
        </div>
      </asp:Panel>

      <!-- Phân trang -->
      <asp:Panel ID="pnlPagination" runat="server" CssClass="paging" Visible="false">
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
  </form>
</body>
</html>
