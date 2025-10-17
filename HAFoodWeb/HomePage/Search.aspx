<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Search.aspx.cs"
    Inherits="HAFoodWeb.SearchPage.SearchPage" Async="true" %>

<%@ Register Src="~/Control/Header.ascx" TagPrefix="uc" TagName="Header" %>
<%@ Register Src="~/Control/Footer.ascx" TagPrefix="uc" TagName="Footer" %>

<!DOCTYPE html>
<html lang="vi">
<head runat="server">
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>Kết quả tìm kiếm | HAFood</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
  <style>
    .text-truncate-2{display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden}
    .of-contain{object-fit:contain}
    .product-card{transition:transform .15s ease, box-shadow .15s ease}
    .product-card:hover{transform:translateY(-3px);box-shadow:0 .5rem 1rem rgba(0,0,0,.06)}
  </style>
</head>
<body>
<form runat="server">
  <asp:ScriptManager ID="sm" runat="server" />
  <uc:Header ID="Header1" runat="server" />

  <div class="container my-4">
    <div class="d-flex align-items-center justify-content-between mb-3">
      <h3 class="m-0"><asp:Literal ID="ltTitle" runat="server" /></h3>
      <small class="text-muted"><asp:Literal ID="ltSummary" runat="server" /></small>
    </div>

    <div class="row gx-3 gy-4">
      <!-- Sidebar filter -->
      <div class="col-lg-3">
        <div class="border rounded-3 p-3">
          <h6 class="mb-3">Bộ lọc</h6>

          <div class="mb-3">
            <label class="form-label">Từ khóa</label>
            <asp:TextBox ID="tbQ" runat="server" CssClass="form-control" />
          </div>

          <div class="row g-2 mb-3">
            <div class="col-6">
              <label class="form-label">Giá từ</label>
              <asp:TextBox ID="tbMin" runat="server" CssClass="form-control" TextMode="Number" />
            </div>
            <div class="col-6">
              <label class="form-label">đến</label>
              <asp:TextBox ID="tbMax" runat="server" CssClass="form-control" TextMode="Number" />
            </div>
          </div>

          <div class="mb-3">
            <label class="form-label">Thương hiệu</label>
            <asp:TextBox ID="tbBrand" runat="server" CssClass="form-control" />
          </div>

          <asp:HiddenField ID="hfCate" runat="server" />

          <asp:Button ID="btnApply" runat="server" CssClass="btn btn-success w-100" Text="Áp dụng"
                      OnClick="btnApply_Click" />
        </div>
      </div>

      <!-- Results -->
      <div class="col-lg-9">
        <asp:Repeater ID="rp" runat="server">
          <HeaderTemplate><div class="row gx-3 gy-4"></HeaderTemplate>
          <ItemTemplate>
            <div class="col-12 col-sm-6 col-lg-4">
              <div class="card product-card h-100 shadow-sm">
                <div class="ratio ratio-4x3 bg-light">
                  <img src="<%# Eval("ImageUrl") %>" alt="<%# Eval("Name") %>"
                       class="w-100 h-100 of-contain p-2"
                       onerror="this.src='/images/product-default.png'" />
                </div>
                <div class="card-body d-flex flex-column">
                  <h6 class="text-truncate-2 mb-1"><%# Eval("Name") %></h6>
                  <div class="mb-2"><%# Eval("PriceRangeHtml") %></div>
                  <%# Eval("DiscountBadgeHtml") %>
                  <a class="btn btn-warning btn-sm mt-auto" href='<%# Eval("Id", "/product.aspx?id={0}") %>'>Xem & Mua</a>
                </div>
              </div>
            </div>
          </ItemTemplate>
          <FooterTemplate></div></FooterTemplate>
        </asp:Repeater>

        <asp:PlaceHolder ID="phEmpty" runat="server" Visible="false">
          <div class="alert alert-info">Không có sản phẩm phù hợp.</div>
        </asp:PlaceHolder>

        <!-- Pagination -->
        <nav class="mt-4">
          <ul class="pagination justify-content-center">
            <asp:PlaceHolder ID="phPaging" runat="server" />
          </ul>
        </nav>
      </div>
    </div>
  </div>

  <uc:Footer ID="Footer1" runat="server" />
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</form>
</body>
</html>
