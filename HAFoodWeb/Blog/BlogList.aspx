<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="BlogList.aspx.cs" Inherits="HAFoodWeb.Blog.BlogList" Async="true" %>
<%@ Register Src="~/Control/Header.ascx" TagPrefix="uc" TagName="Header" %>
<%@ Register Src="~/Control/Footer.ascx" TagPrefix="uc" TagName="Footer" %>

<!DOCTYPE html>
<html lang="vi">
<head runat="server">
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>Blog - HAFood</title>

  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet" />

  <style>
    :root{ --ha-ink:#111827; --ha-muted:#6b7280; --ha-accent:#28a745; }
    body{
      background: linear-gradient(180deg,#fff7ea 0%, #fff 35%, #f6f7fb 100%);
      color: var(--ha-ink);
    }
    .ha-hero{
      border-radius: 18px;
      background:
        radial-gradient(900px 420px at 20% 10%, rgba(40,167,69,.16), transparent 55%),
        radial-gradient(900px 420px at 85% 0%, rgba(249,115,22,.14), transparent 55%),
        #fff;
      border:1px solid rgba(148,163,184,.25);
      box-shadow: 0 18px 40px rgba(15,23,42,.10);
    }
    .ha-title{ font-weight: 900; letter-spacing:-.02em; }
    .ha-search{
      border-radius: 999px;
      border:2px solid rgba(40,167,69,.35);
      background:#fff;
      box-shadow: 0 10px 25px rgba(15,23,42,.06);
      padding: 10px 12px;
      display:flex; gap:10px; align-items:center;
    }
    .ha-search input{ border:0 !important; outline:0 !important; box-shadow:none !important; }
    .ha-post{
      height:100%;
      border-radius: 16px;
      overflow:hidden;
      border:1px solid rgba(148,163,184,.25);
      background:#fff;
      transition: transform .15s ease, box-shadow .15s ease, border-color .15s ease;
    }
    .ha-post:hover{
      transform: translateY(-4px);
      box-shadow: 0 18px 38px rgba(15,23,42,.14);
      border-color: rgba(40,167,69,.45);
    }
    .ha-cover{ height:190px; width:100%; object-fit:cover; display:block; background:#f3f4f6; }
    .line-2{ display:-webkit-box; -webkit-line-clamp:2; -webkit-box-orient:vertical; overflow:hidden; }
    .line-3{ display:-webkit-box; -webkit-line-clamp:3; -webkit-box-orient:vertical; overflow:hidden; }
  </style>
</head>

<body>
<form runat="server">
  <uc:Header ID="Header1" runat="server" />

  <div class="container py-4">

    <div class="ha-hero p-3 p-lg-4 mb-4">
      <div class="row g-3 align-items-center">
        <div class="col-lg-7">
          <h1 class="ha-title display-6 mb-1">Blog HAFood</h1>
          <div class="text-muted">Review đồ ăn vặt, mẹo chọn hàng, khuyến mãi và cập nhật mới.</div>
        </div>

        <div class="col-lg-5">
          <div class="ha-search">
            <i class="bi bi-search text-success"></i>
            <asp:TextBox ID="txtQ" runat="server" CssClass="form-control border-0 p-0" placeholder="Tìm bài viết..." />
            <asp:Button ID="btnSearch" runat="server" CssClass="btn btn-success btn-sm rounded-pill px-3"
                        Text="Tìm" OnClick="btnSearch_Click" />
          </div>
        </div>
      </div>
    </div>

    <asp:Literal ID="litEmpty" runat="server" />

    <asp:Repeater ID="rpArticles" runat="server">
      <HeaderTemplate><div class="row g-3"></HeaderTemplate>

      <ItemTemplate>
        <div class="col-12 col-md-6 col-lg-4">
          <a href="/blog/<%# Eval("slug") %>" class="text-decoration-none">
            <div class="ha-post">
              <img class="ha-cover"
                   src="<%# Eval("cover_Image_Url") %>"
                   alt=""
                   loading="lazy"
                   onerror="this.src='/images/blog-cover-default.png';" />

              <div class="p-3">
                <div class="fw-bold line-2" style="color:#111827">
                  <%# SafeText(Eval("title"), 120) %>
                </div>

                <div class="text-muted small mt-2 line-3">
                  <%# SafeText(Eval("excerpt"), 180) %>
                </div>

                <div class="mt-3">
                  <span class="small text-success" style="font-weight:800">
                    Đọc tiếp <i class="bi bi-arrow-right"></i>
                  </span>
                </div>
              </div>
            </div>
          </a>
        </div>
      </ItemTemplate>

      <FooterTemplate></div></FooterTemplate>
    </asp:Repeater>

    <div class="d-flex align-items-center justify-content-between mt-4">
      <asp:Literal ID="litInfo" runat="server" />
      <asp:Literal ID="litPager" runat="server" />
    </div>

  </div>

  <uc:Footer ID="Footer1" runat="server" />
</form>
</body>
</html>
