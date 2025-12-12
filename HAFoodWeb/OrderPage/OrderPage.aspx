<%@ Page Language="C#" AutoEventWireup="true"
    CodeBehind="OrderPage.aspx.cs"
    Inherits="HAFoodWeb.OrderPage" Async="true" %>

<!DOCTYPE html>
<html lang="vi">
<head runat="server">
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>Đơn hàng của tôi - HAFood</title>

  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet" />

  <style>
    :root{ --accent:#ff7a45; --border:#e5e7eb; --muted:#6b7280; }

    /* Khóa tràn ngang + bẻ chuỗi */
    html, body { width:100%; max-width:100%; overflow-x:hidden; }
    body{ word-break:break-word; overflow-wrap:anywhere; }

    body{
        font-family:'Segoe UI', system-ui, -apple-system, BlinkMacSystemFont, sans-serif;
        margin:0;
        min-height:100%;
        background:#ffffff; /* <-- NỀN TRẮNG */
        overflow-x:hidden;
    }

    .page-header{
        width:100%;
        max-width:100% !important;
        margin:16px 0 4px !important;
        padding:0 16px !important;
        background:transparent;
        box-shadow:none;
    }

    .wrap{
        max-width:900px;
        margin:0 auto 20px;
        padding:0 16px 16px;
        overflow-x:hidden;
        width:100%;
    }
    .wrap-inner{
        background:#fff;
        border-radius:1.25rem;
        box-shadow:0 .75rem 1.8rem rgba(15,23,42,.14);
        padding:1.1rem 1.25rem 1.3rem;
        max-width:100%;
        overflow-x:hidden;
    }

    .mb-0{ margin-bottom:0; } .mb-1{ margin-bottom:0.25rem; } .mb-2{ margin-bottom:0.5rem; }
    .mt-2{ margin-top:0.5rem; } .text-center{ text-align:center; } .text-muted{ color:var(--muted); }
    .small{ font-size:.875rem; } .fw-semibold{ font-weight:600; } .py-5{ padding-top:3rem; padding-bottom:3rem; }
    .d-flex{ display:flex; } .flex-wrap{ flex-wrap:wrap; } .justify-content-between{ justify-content:space-between; }
    .align-items-start{ align-items:flex-start; } .align-items-center{ align-items:center; }
    .gap-1{ gap:.25rem; } .gap-2{ gap:.5rem; }

    .page-title{ font-weight:700; font-size:1.6rem; color:#212529; margin:0 0 .2rem; }

    .title-badge{
      font-size:.75rem; letter-spacing:.08em; text-transform:uppercase; font-weight:700;
      color:#fd7e14; background:rgba(253,126,20,.08); padding:.26rem .7rem; border-radius:999px;
      display:inline-flex; align-items:center; gap:.35rem; margin-bottom:.25rem;
    }
    .title-badge i{ font-size:.9rem; }

    .btn{
        height:36px; min-width:120px; border:1px solid var(--border); border-radius:10px; padding:0 14px;
        font-weight:700; cursor:pointer; background:#f2f3f5; color:#111; text-decoration:none;
        display:inline-flex; align-items:center; justify-content:center; text-align:center;
    }
    .btn-sm{ font-size:.86rem; }
    .btn-outline-dark{ background:#fff; color:#111; border-color:var(--border); }
    .btn-outline-dark.active{ background:#212529; color:#fff; box-shadow:0 .3rem 1rem rgba(33,37,41,.35); }
    .btn-outline-secondary{ background:rgba(255,255,255,.85); border-color:var(--border); color:#111; }

    .filter-bar{
      display:flex; flex-wrap:wrap; justify-content:center; gap:8px; margin-bottom:1rem;
      background:rgba(255,255,255,.8); border-radius:999px; padding:.35rem;
      box-shadow:0 .25rem .75rem rgba(15,23,42,.08); overflow:hidden;
    }
    .filter-bar .btn{
      min-width:120px; border-radius:999px; font-weight:500; border-color:transparent; color:#495057;
      background-color:transparent; transition:all 0.2s ease; padding-block:.32rem; padding-inline:.85rem; font-size:.84rem;
    }
    .filter-bar .btn:hover{ background-color:rgba(33,37,41,.08); }
    .filter-bar .btn.active{ background:#212529; color:#fff; box-shadow:0 .3rem 1rem rgba(33,37,41,.35); }

    .order-link{ color:inherit; text-decoration:none; display:block; }
    .order-link:hover{ text-decoration:none; }

    .order-card{
      background:#fff; border-radius:1rem; box-shadow:0 .35rem 1.25rem rgba(15,23,42,.08);
      padding:1.05rem 1.2rem; margin-bottom:0.7rem; transition:transform .15s ease, box-shadow .15s ease;
      border:1px solid rgba(0,0,0,.02); position:relative; overflow:hidden;
    }
    .order-card::before{ content:""; position:absolute; inset:0; background:linear-gradient(120deg,rgba(253,126,20,.06),transparent 30%); opacity:0; transition:opacity .2s ease; pointer-events:none; }
    .order-card:hover{ transform:translateY(-2px); box-shadow:0 .55rem 1.5rem rgba(15,23,42,.13); }
    .order-card:hover::before{ opacity:1; }

    .order-header{ font-weight:600; font-size:1rem; color:#333; }
    .order-header strong{ font-weight:700; }

    .order-meta{ font-size:.86rem; color:#555; line-height:1.45; }
    .order-meta strong{ font-weight:600; }

    .order-total{ font-weight:700; color:#e55a00 !important; margin-top:0.15rem; font-size:1.02rem; }

    .status-badge{
      font-size:.78rem; padding:.3rem .7rem; border-radius:999px; font-weight:600; display:inline-flex; align-items:center; gap:.35rem;
      border:1px solid transparent; background:#f8f9fa; color:#495057;
    }
    .status-0{ background-color:#fff3cd; color:#856404; border-color:#ffeeba; }
    .status-1{ background-color:#d1ecf1; color:#0c5460; border-color:#bee5eb; }
    .status-2{ background-color:#cfe2ff; color:#084298; border-color:#b6d4fe; }
    .status-3{ background-color:#d4edda; color:#155724; border-color:#c3e6cb; }
    .status-4{ background-color:#f8d7da; color:#721c24; border-color:#f5c6cb; }

    .order-card-divider{ height:1px; background:radial-gradient(circle,rgba(0,0,0,.15) 0,transparent 70%); opacity:.35; margin-block:.5rem; }

    .pnl-empty{ background:rgba(255,255,255,.85); border-radius:1rem; padding:2.0rem 1.4rem; box-shadow:0 .25rem .9rem rgba(15,23,42,.08); }
    .pnl-empty-icon{ font-size:2rem; color:#ced4da; margin-bottom:.5rem; }

    .paging{
        display:flex; justify-content:center; align-items:center; gap:0.5rem; margin-top:1.0rem;
        overflow:hidden; width:100%;
    }
    .paging .btn{ min-width:40px; border-radius:999px; font-size:.86rem; }
    .paging .btn-page-active{ background:#e5e7eb; border-color:#d1d5db; color:#111827; }
    .paging .btn-outline-secondary{ background:rgba(255,255,255,.85); }
    .paging .btn-prevnext{ min-width:72px; padding:0 16px; }
    .page-ellipsis{ padding:0 4px; font-weight:700; color:var(--muted); user-select:none; }

    @media (max-width:575.98px){
        .page-header{ margin:12px 0 6px !important; padding:0 16px !important; }
    }
  </style>
</head>

<body>
  <form id="form1" runat="server">

    <div class="page-header">
        <div class="title-badge">
          <i class="bi bi-basket2"></i>
          HAFood - Lịch sử mua hàng
        </div>
        <h2 class="page-title mb-0">Đơn hàng của tôi</h2>
    </div>

    <div class="wrap">
      <div class="wrap-inner">

        <div class="filter-bar mt-2">
          <asp:Button ID="btnAll" runat="server" CssClass="btn btn-outline-dark btn-sm active" Text="Tất cả" CommandArgument="all" OnClick="btnFilter_Click" />
          <asp:Button ID="btnPending" runat="server" CssClass="btn btn-outline-dark btn-sm" Text="Đã được tạo" CommandArgument="0" OnClick="btnFilter_Click" />
          <asp:Button ID="btnConfirmed" runat="server" CssClass="btn btn-outline-dark btn-sm" Text="Xác nhận" CommandArgument="1" OnClick="btnFilter_Click" />
          <asp:Button ID="btnShipping" runat="server" CssClass="btn btn-outline-dark btn-sm" Text="Đang giao" CommandArgument="2" OnClick="btnFilter_Click" />
          <asp:Button ID="btnDelivered" runat="server" CssClass="btn btn-outline-dark btn-sm" Text="Đã giao" CommandArgument="3" OnClick="btnFilter_Click" />
          <asp:Button ID="btnCanceled" runat="server" CssClass="btn btn-outline-dark btn-sm" Text="Đã hủy" CommandArgument="4" OnClick="btnFilter_Click" />
        </div>

        <asp:Literal ID="litDebug" runat="server" Visible="false"></asp:Literal>

        <asp:Repeater ID="rpOrders" runat="server" OnItemDataBound="rpOrders_ItemDataBound">
          <ItemTemplate>
            <asp:HyperLink runat="server" CssClass="order-link"
              NavigateUrl='<%# ResolveUrl(String.Format("~/OrderPage/OrderDetail.aspx?id={0}", Eval("id"))) %>'>
              <div class="order-card">
                <div class="d-flex justify-content-between align-items-start mb-1 flex-wrap gap-2">
                  <div>
                    <div class="order-header">
                      Mã đơn: <strong><%# Eval("order_Code") %></strong>
                    </div>
                    <div class="meta-small text-muted" style="font-size:.8rem;">
                      Đặt lúc <%# Eval("placed_At", "{0:HH:mm dd/MM/yyyy}") %>
                    </div>
                  </div>
                  <span id="statusBadge" runat="server" class="status-badge"></span>
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

        <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
          <div class="text-center text-muted py-5 pnl-empty">
            <div class="pnl-empty-icon"><i class="bi bi-bag-x"></i></div>
            <div class="fw-semibold mb-1">Bạn chưa có đơn hàng nào.</div>
            <div class="small">Hãy khám phá các món ngon và đặt đơn đầu tiên tại HAFood nhé!</div>
          </div>
        </asp:Panel>

        <asp:Panel ID="pnlPagination" runat="server" CssClass="paging" Visible="false">
          <asp:Button ID="btnPrev" runat="server" CssClass="btn btn-outline-secondary btn-sm btn-prevnext" Text="← Trước" OnClick="btnPrev_Click" />
          <asp:Repeater ID="rpPaging" runat="server" OnItemCommand="rpPaging_ItemCommand">
            <ItemTemplate>
              <asp:PlaceHolder ID="phPage" runat="server" Visible='<%# !IsEllipsis(Container.DataItem) %>'>
                <asp:LinkButton ID="lnkPage" runat="server"
                  CssClass='<%# GetPageButtonCss(Container.DataItem) %>'
                  CommandName="ChangePage"
                  CommandArgument='<%# Container.DataItem %>'
                  Text='<%# Container.DataItem %>'>
                </asp:LinkButton>
              </asp:PlaceHolder>

              <asp:PlaceHolder ID="phDots" runat="server" Visible='<%# IsEllipsis(Container.DataItem) %>'>
                <span class="page-ellipsis">...</span>
              </asp:PlaceHolder>
            </ItemTemplate>
          </asp:Repeater>
          <asp:Button ID="btnNext" runat="server" CssClass="btn btn-outline-secondary btn-sm btn-prevnext" Text="Sau →" OnClick="btnNext_Click" />
        </asp:Panel>

      </div>
    </div>

  </form>

  <!-- Dọn text-node rơi ra DOM -->
  <script>
      (function () {
          try {
              var nodes = Array.from(document.body.childNodes);
              nodes.forEach(function (n) {
                  if (n.nodeType === 3 && /ResizeObserver|ro\.observe|measure\(\)/.test(n.nodeValue || '')) {
                      n.remove();
                  }
              });
          } catch (e) { }
      })();
  </script>
</body>
</html>
