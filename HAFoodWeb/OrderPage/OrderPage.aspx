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
    html, body { width:100%; max-width:100%; overflow-x:hidden; }
    body{ word-break:break-word; overflow-wrap:anywhere; margin:0; }
    body{
        font-family:'Segoe UI', system-ui, -apple-system, BlinkMacSystemFont, sans-serif;
        min-height:100%;
        background:#ffffff;
        overflow-x:hidden;
    }

    /* ✅ có thể giữ để dùng nếu cần */
    .d-none{ display:none !important; }

    .page-header{
        width:100%;
        max-width:100% !important;
        margin:16px 0 4px !important;
        padding:0 16px !important;
        background:transparent;
        box-shadow:none;
    }

    .wrap-inner{
        background:#fff;
        border-radius:1.25rem;
        padding:1.1rem 1.25rem 1.3rem;
        max-width:900px;
        width:calc(100% - 32px);
        margin:0 auto 20px;
        overflow-x:hidden;
        box-sizing:border-box;
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
    .btn-sm{ font-size:.86rem; height:34px; min-width:auto; padding:0 12px; }
    .btn-outline-dark{ background:#fff; color:#111; border-color:var(--border); }
    .btn-outline-dark.active{ background:#212529; color:#fff; box-shadow:0 .3rem 1rem rgba(15, 23, 42, 0.12); }
    .btn-outline-secondary{ background:rgba(255,255,255,.85); border-color:var(--border); color:#111; }

    /* Quick action button */
    .btn-quick-received{
      border-radius:999px;
      border:1px solid rgba(25,135,84,.28);
      background: linear-gradient(180deg, rgba(25,135,84,.08), rgba(25,135,84,.02));
      color:#198754;
      font-weight:800;
      height:32px;
      padding:0 12px;
      display:inline-flex;
      align-items:center;
      gap:.35rem;
      cursor:pointer;
      white-space:nowrap;
      user-select:none;
    }
    .btn-quick-received:hover{
      filter:brightness(.98);
      box-shadow:0 .35rem 1rem rgba(25,135,84,.10);
      transform: translateY(-1px);
    }
    .btn-quick-received:active{ transform: translateY(0); }
    .btn-quick-received[disabled]{ opacity:.6; cursor:not-allowed; transform:none !important; }

    /* ===== Search theo mã đơn ===== */
    .order-searchbar{ margin:.25rem 0 1rem; }
    .searchbox{
      display:flex; align-items:center; gap:.55rem;
      border:1px solid var(--border);
      border-radius:999px;
      padding:.35rem .5rem .35rem .8rem;
      background:rgba(255,255,255,.92);
      box-shadow:0 .25rem .75rem rgba(15, 23, 42, 0.08);
      overflow:hidden;
    }
    .searchbox i{ color:#6b7280; font-size:1rem; }
    .search-input{
      border:0; outline:0; flex:1;
      font-size:.92rem; padding:.35rem .25rem;
      background:transparent;
      min-width:140px;
    }
    .search-btn{
      height:34px;
      min-width:76px;
      border-radius:999px;
      border:1px solid #212529;
      background:#212529;
      color:#fff;
      font-weight:800;
      cursor:pointer;
      padding:0 14px;
      display:inline-flex; align-items:center; justify-content:center;
    }
    .search-btn:hover{ filter:brightness(.95); }
    .search-clear{
      border:0; background:transparent;
      color:#9aa0a6; text-decoration:none;
      padding:0 .2rem;
      display:inline-flex; align-items:center; justify-content:center;
    }
    .search-clear:hover{ color:#6b7280; }

    .filter-bar{
      display:flex; flex-wrap:wrap; justify-content:center; gap:8px; margin-bottom:1rem;
      background:rgba(255,255,255,.8); border-radius:999px; padding:.35rem;
      box-shadow:0 .25rem .75rem rgba(15, 23, 42, 0.12); overflow:hidden;
    }
    .filter-bar .btn{
      min-width:120px; border-radius:999px;
      font-weight:700;
      border-color:transparent; color:#495057;
      background-color:transparent; transition:all 0.2s ease; padding-block:.32rem; padding-inline:.85rem; font-size:.84rem;
    }
    .filter-bar .btn:hover{ background-color:rgba(33,37,41,.08); }
    .filter-bar .btn.active{ background:#212529; color:#fff; box-shadow:0 .3rem 1rem rgba(33,37,41,.35); }

    .order-card{
      background:#fff; border-radius:1rem; box-shadow:0 .35rem 1.25rem rgba(15,23,42,.08);
      padding:1.05rem 1.2rem; margin-bottom:0.7rem; transition:transform .15s ease, box-shadow .15s ease;
      border:1px solid rgba(0,0,0,.02); position:relative; overflow:hidden;
      cursor:pointer;
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
      font-size:.78rem; padding:.3rem .7rem; border-radius:999px; font-weight:700; display:inline-flex; align-items:center; gap:.35rem;
      border:1px solid transparent; background:#f8f9fa; color:#495057;
      white-space:nowrap;
    }
    .status-0{ background-color:#fff3cd; color:#856404; border-color:#ffeeba; }
    .status-1{ background-color:#d1ecf1; color:#0c5460; border-color:#bee5eb; }
    .status-2{ background-color:#cfe2ff; color:#084298; border-color:#b6d4fe; }
    .status-3{ background-color:#d4edda; color:#155724; border-color:#c3e6cb; }
    .status-4{ background-color:#f8d7da; color:#721c24; border-color:#f5c6cb; }
    .status-6{ background-color:#cfe2ff; color:#084298; border-color:#b6d4fe; } /* đang giao hàng */
    .status-7{ background-color:#d4edda; color:#155724; border-color:#c3e6cb; } /* đã nhận hàng */
    .status-9{ background-color:#f8d7da; color:#721c24; border-color:#f5c6cb; } /* huỷ đơn */

    .order-card-divider{ height:1px; background:radial-gradient(circle,rgba(0,0,0,.15) 0,transparent 70%); opacity:.35; margin-block:.5rem; }

    .pnl-empty{ background:rgba(255,255,255,.85); border-radius:1rem; padding:2.0rem 1.4rem; box-shadow:0 .25rem .9rem rgba(15,23,42,.08); }
    .pnl-empty-icon{ font-size:2rem; color:#ced4da; margin-bottom:.5rem; }

    .paging{
        display:flex; justify-content:center; align-items:center; gap:0.5rem; margin-top:1.0rem;
        overflow:hidden; width:100%;
        flex-wrap:wrap;
    }
    .paging .btn{ min-width:40px; border-radius:999px; font-size:.86rem; }
    .paging .btn-page-active{ background:#e5e7eb; border-color:#d1d5db; color:#111827; }
    .paging .btn-outline-secondary{ background:rgba(255,255,255,.85); }
    .paging .btn-prevnext{ min-width:72px; padding:0 16px; }
    .page-ellipsis{ padding:0 4px; font-weight:700; color:var(--muted); user-select:none; }

    /* Toast */
    .ha-toast{
      position:fixed; top:18px; right:18px;
      background:#16a34a; color:#fff; padding:10px 14px;
      border-radius:999px; box-shadow:0 .25rem .9rem rgba(0,0,0,.22);
      z-index:20000; display:none; font-weight:700; font-size:.92rem;
      max-width:min(92vw, 420px);
    }

    /* Custom modal */
    .ha-modal-backdrop{
  position: fixed !important;
  top: 0; left: 0; right: 0; bottom: 0;
  width: 100vw;
  height: 100vh;
  background: rgba(0,0,0,.45);
  display: none;
  z-index: 999999;               /* cao lên để không bị widget khác đè */
  align-items: center;
  justify-content: center;
  padding: 16px;
}

.ha-modal{
  width: min(520px, 100%);
  max-height: calc(100vh - 32px);
  overflow: auto;

  background:#fff;
  border-radius:16px;
  box-shadow:0 18px 60px rgba(0,0,0,.28);
  border:1px solid rgba(0,0,0,.06);
}

    .ha-modal-backdrop.is-open{ display:flex; }
    
    .ha-modal-header{
      padding:14px 16px;
      display:flex;
      align-items:center;
      justify-content:space-between;
      border-bottom:1px solid rgba(0,0,0,.06);
    }
    .ha-modal-title{
      font-weight:900;
      display:flex; align-items:center; gap:.55rem;
      color:#111827;
    }
    .ha-modal-body{ padding:14px 16px; }
    .ha-modal-footer{
      padding:12px 16px;
      border-top:1px solid rgba(0,0,0,.06);
      display:flex;
      justify-content:space-between;
      gap:10px;
      flex-wrap:wrap;
    }
    .ha-btn{
      height:36px; border-radius:999px; padding:0 14px;
      border:1px solid var(--border);
      font-weight:900;
      cursor:pointer;
      background:#f2f3f5;
      display:inline-flex; align-items:center; gap:.45rem;
    }
    .ha-btn-success{
      border-color: rgba(25,135,84,.25);
      color:#198754;
      background: linear-gradient(180deg, rgba(25,135,84,.10), rgba(25,135,84,.02));
    }
    .ha-btn-light{ background:#fff; }
    .ha-x{
      border:0; background:transparent; cursor:pointer;
      font-size:20px; line-height:1; padding:4px 6px; color:#6b7280;
    }
    .ha-x:hover{ color:#111; }

    @media (max-width:575.98px){
        .page-header{ margin:12px 0 6px !important; padding:0 16px !important; }
        .search-btn{ min-width:64px; padding:0 12px; }
    }
  </style>

  <% if ("1".Equals(Request["embed"])) { %>
    <style>
      html, body{
        background:#ffffff !important;
        background-image:none !important;
        min-height:auto !important;
        height:auto !important;
        overflow:visible !important;
      }
    </style>
  <% } %>
</head>

<body>
  <div id="haToast" class="ha-toast">Đã thực hiện</div>

  <form id="form1" runat="server">
    <script>
        window.__AUTH_TOKEN = '<%= Session["JwtToken"] != null ? Session["JwtToken"].ToString() : "" %>';
        window.__API_BASE = '<%= System.Configuration.ConfigurationManager.AppSettings["ApiBaseUrl"] ?? "" %>';
    </script>

    <div class="page-header">
        <div class="title-badge">
          <i class="bi bi-basket2"></i>
          HAFood - Lịch sử mua hàng
        </div>
        <h2 class="page-title mb-0">Đơn hàng của tôi</h2>
    </div>

    <div class="wrap-inner">

        <!-- ✅ SEARCH MÃ ĐƠN -->
        <asp:Panel ID="pnlSearch" runat="server" CssClass="order-searchbar" DefaultButton="btnSearchCode">
          <div class="searchbox">
            <i class="bi bi-search"></i>

            <asp:TextBox ID="txtOrderCode" runat="server"
              CssClass="search-input"
              placeholder="Nhập mã đơn (VD: 260106000001)"
              AutoCompleteType="Disabled" />

            <asp:Button ID="btnSearchCode" runat="server"
              CssClass="search-btn"
              Text="Tìm"
              OnClick="btnSearchCode_Click" />

            <asp:LinkButton ID="btnClearCode" runat="server"
              CssClass="search-clear"
              CausesValidation="false"
              OnClick="btnClearCode_Click"
              ToolTip="Xóa mã tìm kiếm">
              <i class="bi bi-x-circle"></i>
            </asp:LinkButton>
          </div>

          <div class="small text-muted mt-2">
            * Có thể nhập một phần mã để tìm nhanh.
          </div>
        </asp:Panel>

        <!-- Filter theo trạng thái -->
        <div class="filter-bar mt-2">
          <asp:Button ID="btnAll" runat="server" CssClass="btn btn-outline-dark btn-sm" Text="Tất cả" CommandArgument="all" OnClick="btnFilter_Click" />
          <asp:Button ID="btnPending" runat="server" CssClass="btn btn-outline-dark btn-sm" Text="Đã được tạo" CommandArgument="0" OnClick="btnFilter_Click" />
          <asp:Button ID="btnConfirmed" runat="server" CssClass="btn btn-outline-dark btn-sm" Text="Đã xác nhận" CommandArgument="1" OnClick="btnFilter_Click" />
          <asp:Button ID="btnShipping" runat="server" CssClass="btn btn-outline-dark btn-sm" Text="Đang giao" CommandArgument="2" OnClick="btnFilter_Click" />
          <asp:Button ID="btnDelivered" runat="server" CssClass="btn btn-outline-dark btn-sm" Text="Đã giao" CommandArgument="3" OnClick="btnFilter_Click" />
          <asp:Button ID="btnReceived" runat="server" CssClass="btn btn-outline-dark btn-sm" Text="Đã nhận hàng" CommandArgument="7" OnClick="btnFilter_Click" />
          <asp:Button ID="btnCanceled" runat="server" CssClass="btn btn-outline-dark btn-sm" Text="Đã huỷ" CommandArgument="4" OnClick="btnFilter_Click" />
        </div>

        <asp:Literal ID="litDebug" runat="server" Visible="false"></asp:Literal>

        <asp:Repeater ID="rpOrders" runat="server" OnItemDataBound="rpOrders_ItemDataBound">
          <ItemTemplate>
            <div class="order-card"
                 data-detail-url='<%# ResolveUrl(String.Format("~/OrderPage/OrderDetail.aspx?id={0}", Eval("id"))) %>'
                 data-order-id='<%# Eval("id") %>'
                 data-order-code='<%# Eval("order_Code") %>'
                 data-status='<%# Eval("status") %>'>

              <div class="d-flex justify-content-between align-items-start mb-1 flex-wrap gap-2">
                <div>
                  <div class="order-header">
                    Mã đơn: <strong><%# Eval("order_Code") %></strong>
                  </div>
                  <div class="text-muted" style="font-size:.8rem;">
                    Đặt lúc <%# Eval("placed_At", "{0:HH:mm dd/MM/yyyy}") %>
                  </div>
                </div>

                <div class="d-flex align-items-center gap-2 flex-wrap">

                  <!-- ✅ NÚT CHỈ RENDER KHI status=3 (KHÔNG phụ thuộc d-none) -->
                  <asp:PlaceHolder ID="phQuickReceived" runat="server">
                    <button type="button"
                            class="btn-quick-received"
                            data-action="confirm-received"
                            data-order-id='<%# Eval("id") %>'
                            data-order-code='<%# Eval("order_Code") %>'>
                      <i class="bi bi-check2-circle"></i> Đã nhận hàng
                    </button>
                  </asp:PlaceHolder>

                  <span id="statusBadge" runat="server" class="status-badge"></span>
                </div>
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
  </form>

  <!-- Custom modal Confirm Received -->
  <div id="receivedBackdrop" class="ha-modal-backdrop" aria-hidden="true">
    <div class="ha-modal" role="dialog" aria-modal="true" aria-labelledby="receivedTitle">
      <div class="ha-modal-header">
        <div class="ha-modal-title" id="receivedTitle">
          <i class="bi bi-check2-circle" style="color:#198754;"></i> Xác nhận đã nhận hàng
        </div>
        <button type="button" class="ha-x" id="btnCloseReceived" aria-label="Đóng">×</button>
      </div>

      <div class="ha-modal-body">
        <div class="small text-muted mb-2">Đơn hàng: <span id="rcOrderCode" class="fw-semibold"></span></div>
        <div style="border:1px solid rgba(25,135,84,.18); background:rgba(25,135,84,.06); padding:10px 12px; border-radius:12px;">
          Bạn chắc chắn đã <strong>nhận đủ hàng</strong> và muốn hoàn tất đơn này chứ?
        </div>
        <div class="small text-muted mt-2">
          * Sau khi xác nhận, đơn sẽ chuyển sang <strong>Đã nhận hàng</strong>.
        </div>
      </div>

      <div class="ha-modal-footer">
        <button type="button" class="ha-btn ha-btn-success" id="btnDoReceived">
          <i class="bi bi-check2-circle"></i> Xác nhận
        </button>
        <button type="button" class="ha-btn ha-btn-light" id="btnCancelReceived">
          Hủy
        </button>
      </div>
    </div>
  </div>

  <script>
    function showToast(msg, isError) {
      const el = document.getElementById('haToast'); if (!el) return;
      el.textContent = msg || 'Đã thực hiện';
      el.style.background = isError ? '#dc3545' : '#16a34a';
      el.style.display = 'block';
      setTimeout(() => { el.style.display = 'none'; }, 1800);
    }

    function mapConfirmErr(data) {
      const code = (data && (data.code || data.error_code)) ? String(data.code || data.error_code) : '';
      switch (code) {
        case 'ORDER_CANNOT_CONFIRM': return 'Đơn chưa đủ điều kiện xác nhận (chỉ xác nhận khi trạng thái = Đã giao).';
        case 'UNAUTHENTICATED': return 'Vui lòng đăng nhập lại.';
        case 'ORDER_NOT_FOUND': return 'Không tìm thấy đơn hàng.';
        default: return '';
      }
    }

    async function callConfirmReceivedApi(orderId) {
      const API_BASE = (window.__API_BASE || '').replace(/\/+$/, '');
      const token = window.__AUTH_TOKEN || '';
      if (!API_BASE) throw new Error('Thiếu cấu hình API');
      if (!token) throw new Error('Vui lòng đăng nhập để xác nhận');

      const resp = await fetch(`${API_BASE}/api/orders/${orderId}/confirm-received`, {
        method: 'POST',
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ' + token
        },
        credentials: 'include'
        // ✅ endpoint của bạn không cần body -> bỏ luôn
      });

      let data = null; try { data = await resp.json(); } catch { }
      if (resp.status === 401 || resp.status === 403) throw new Error('Vui lòng đăng nhập để xác nhận');

      if (!resp.ok) {
        const friendly = mapConfirmErr(data);
        throw new Error(friendly || (data && (data.message || data.detail)) || 'Không thể xác nhận nhận hàng.');
      }
      return data;
    }

    function setBadge(el, status) {
      if (!el) return;
      const s = parseInt(status || '0', 10);
      let text = 'Không rõ';
      switch (s) {
        case 0: text = 'Đã được tạo'; break;
        case 1: text = 'Đã xác nhận'; break;
        case 2: text = 'Đang giao'; break;
        case 3: text = 'Đã giao'; break;
        case 6: text = 'Đang giao hàng'; break;
        case 7: text = 'Đã nhận hàng'; break;
        case 4: text = 'Đã huỷ'; break;
        case 9: text = 'Huỷ đơn'; break;
      }
      el.textContent = text;
      el.className = `status-badge status-${s}`;
    }

    (function () {
      const backdrop = document.getElementById('receivedBackdrop');
      const btnClose = document.getElementById('btnCloseReceived');
      const btnCancel = document.getElementById('btnCancelReceived');
      const btnDo = document.getElementById('btnDoReceived');
      const rcOrderCode = document.getElementById('rcOrderCode');

      let current = null; // { orderId, orderCode, cardEl }

        function openModal() {
            if (!backdrop) return;

            if (backdrop.parentElement !== document.body) {
                document.body.appendChild(backdrop);
            }

            backdrop.classList.add('is-open');
            backdrop.setAttribute('aria-hidden', 'false');

            // khoá scroll trong iframe (ok)
            document.documentElement.style.overflow = 'hidden';
            document.body.style.overflow = 'hidden';

            // ✅ nhờ trang cha cuộn iframe vào giữa để modal chắc chắn thấy
            try {
                if (window.parent && window.parent !== window) {
                    window.parent.postMessage({ type: 'haf-scroll-iframe-into-view' }, '*');
                }
            } catch { }
        }


        function closeModal() {
            if (!backdrop) return;
            backdrop.classList.remove('is-open');
            backdrop.setAttribute('aria-hidden', 'true');
            current = null;

            // (tuỳ chọn) mở lại scroll
            document.documentElement.style.overflow = '';
            document.body.style.overflow = '';
        }


      btnClose?.addEventListener('click', closeModal);
      btnCancel?.addEventListener('click', closeModal);
      backdrop?.addEventListener('click', function (e) {
        if (e.target === backdrop) closeModal();
      });
      document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') closeModal();
      });

      // ✅ Event delegation:
      // - click quick action: không điều hướng
      // - click card: đi detail
      document.addEventListener('click', function (e) {
        const quickBtn = e.target.closest('button[data-action="confirm-received"]');
        if (quickBtn) {
          e.preventDefault();
          e.stopPropagation();

          const orderId = parseInt(quickBtn.getAttribute('data-order-id') || '0', 10);
          const orderCode = quickBtn.getAttribute('data-order-code') || '';
          const card = quickBtn.closest('.order-card');

          if (!orderId || !card) { showToast('Thiếu dữ liệu đơn hàng', true); return; }

          current = { orderId, orderCode, cardEl: card };
          if (rcOrderCode) rcOrderCode.textContent = orderCode || ('#' + orderId);
          openModal();
          return;
        }

        const card = e.target.closest('.order-card');
        if (!card) return;

        // nếu click vào control thì không điều hướng
        if (e.target.closest('button, a, input, textarea, select')) return;

        const url = card.getAttribute('data-detail-url');
        if (url) window.location.href = url;
      });

      btnDo?.addEventListener('click', async function () {
        if (!current) return;

        const { orderId, cardEl } = current;

        // ✅ chỉ cho confirm khi status=3
        const status = parseInt(cardEl.getAttribute('data-status') || '0', 10);
        if (status !== 3) { showToast('Đơn hàng chưa đủ điều kiện xác nhận.', true); closeModal(); return; }

        const oldHtml = btnDo.innerHTML;
        btnDo.disabled = true;
        btnDo.innerHTML = '<span style="width:14px;height:14px;border:2px solid #198754;border-right-color:transparent;border-radius:999px;display:inline-block;animation:spin .9s linear infinite;"></span> Đang xác nhận...';

        try {
          await callConfirmReceivedApi(orderId);

          // update UI at card
          cardEl.setAttribute('data-status', '7');
          const badge = cardEl.querySelector('.status-badge');
          setBadge(badge, 7);

          // ẩn quick button (nếu còn)
          const quick = cardEl.querySelector('button[data-action="confirm-received"]');
          if (quick) quick.remove();

          showToast('Đã xác nhận nhận hàng.');
          closeModal();
        } catch (err) {
          console.error(err);
          showToast((err && err.message) ? err.message : 'Có lỗi xảy ra, vui lòng thử lại.', true);
        } finally {
          btnDo.disabled = false;
          btnDo.innerHTML = oldHtml;
        }
      });

      // spinner keyframes
      const style = document.createElement('style');
      style.textContent = '@keyframes spin{from{transform:rotate(0)}to{transform:rotate(360deg)}}';
      document.head.appendChild(style);
    })();
  </script>

  <!-- ✅ embed=1: rewrite link + auto-height (giữ nguyên nếu bạn dùng iframe) -->
  <script>
      (function () {
          var isEmbed = /[?&]embed=1\b/.test(location.search) && window.parent && window.parent !== window;
          var params = new URLSearchParams(location.search);
          var TARGET = params.get('parentOrigin') || '*';

          if (isEmbed) {
              try {
                  document.querySelectorAll('a[href]').forEach(function (a) {
                      var href = a.getAttribute('href'); if (!href) return;
                      if (href.startsWith('#') || href.startsWith('javascript:')) return;
                      var u = new URL(href, location.href);
                      if (u.origin !== location.origin) return;
                      u.searchParams.set('embed', '1');
                      a.setAttribute('href', u.pathname + u.search + u.hash);
                  });
              } catch (e) { }
          }

          if (!isEmbed) return;

          function measure() {
              try {
                  var d = document, b = d.body, e = d.documentElement;
                  var h = Math.max(
                      b.scrollHeight || 0, e.scrollHeight || 0,
                      b.offsetHeight || 0, e.offsetHeight || 0,
                      b.clientHeight || 0, e.clientHeight || 0
                  );
                  if (!h || h < 350) h = 350;
                  window.parent.postMessage({ type: 'haf-embed-height', height: h }, TARGET);
              } catch (_) { }
          }

          function rafMeasure() { try { requestAnimationFrame(measure); } catch { measure(); } }

          document.addEventListener('DOMContentLoaded', function () { setTimeout(rafMeasure, 0); });
          window.addEventListener('load', function () { setTimeout(rafMeasure, 20); });
          if (document.fonts && document.fonts.ready) { document.fonts.ready.then(function () { setTimeout(rafMeasure, 20); }); }

          var ro = (typeof ResizeObserver !== 'undefined') ? new ResizeObserver(function () { rafMeasure(); }) : null;
          if (ro) { ro.observe(document.documentElement); ro.observe(document.body); }

          var mo = (typeof MutationObserver !== 'undefined') ? new MutationObserver(function () { rafMeasure(); }) : null;
          if (mo) { mo.observe(document.body, { childList: true, subtree: true, attributes: true, characterData: true }); }

          setTimeout(rafMeasure, 200);
          setTimeout(rafMeasure, 600);
          setTimeout(rafMeasure, 1200);
      })();
  </script>
</body>
</html>
