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
    :root{
      --ha-ink:#111827;
      --ha-muted:#6b7280;
      --ha-accent:#28a745;
      --ha-orange:#fd7e14;
      --ha-card:#ffffff;
      --ha-border:rgba(148,163,184,.25);
    }

    body{
      background: radial-gradient(1100px 600px at 10% 0%, rgba(253,126,20,.10), transparent 55%),
                  radial-gradient(900px 520px at 85% 10%, rgba(40,167,69,.12), transparent 55%),
                  linear-gradient(180deg,#fff7ea 0%, #fff 38%, #f6f7fb 100%);
      color: var(--ha-ink);
    }

    /* ===== Title + Badge ===== */
    .page-title{
      font-weight: 800;
      font-size: 2rem;
      color: #111827;
      margin: .15rem 0 0;
      letter-spacing: -.02em;
      line-height: 1.08;
    }
    .page-subtitle{ font-size: .95rem; color: #6c757d; }

    .title-badge{
      font-size: .75rem;
      letter-spacing: .08em;
      text-transform: uppercase;
      font-weight: 800;
      color: var(--ha-orange);
      background: rgba(253, 126, 20, .10);
      border: 1px solid rgba(253, 126, 20, .18);
      padding: .28rem .8rem;
      border-radius: 999px;
      display: inline-flex;
      align-items: center;
      gap: .45rem;
      margin-bottom: .25rem;
      width: fit-content;
    }
    .title-badge i{ font-size: .95rem; }

    /* ===== Hero ===== */
    .ha-hero{
      border-radius: 18px;
      background:
        radial-gradient(900px 420px at 20% 10%, rgba(40,167,69,.14), transparent 55%),
        radial-gradient(900px 420px at 85% 0%, rgba(253,126,20,.12), transparent 55%),
        #fff;
      border:1px solid var(--ha-border);
      box-shadow: 0 18px 40px rgba(15,23,42,.10);
    }

    /* ===== Post cards ===== */
    .ha-post{
      height:100%;
      border-radius: 16px;
      overflow:hidden;
      border:1px solid var(--ha-border);
      background: var(--ha-card);
      transition: transform .15s ease, box-shadow .15s ease, border-color .15s ease;
    }
    .ha-post:hover{
      transform: translateY(-4px);
      box-shadow: 0 18px 38px rgba(15,23,42,.14);
      border-color: rgba(40,167,69,.42);
    }
    .ha-cover{
      height:190px;
      width:100%;
      object-fit:cover;
      display:block;
      background:#f3f4f6;
    }
    .line-2{ display:-webkit-box; -webkit-line-clamp:2; -webkit-box-orient:vertical; overflow:hidden; }
    .line-3{ display:-webkit-box; -webkit-line-clamp:3; -webkit-box-orient:vertical; overflow:hidden; }

    /* ===== Search ===== */
    .blog-page .ha-search{
      width: 70%;
      max-width: 760px;
      min-height: 58px;
      padding: 10px 14px;

      display: flex;
      align-items: center;
      gap: 12px;

      border-radius: 999px;
      background: #fff;
      border: 2px solid #28a745;
      box-shadow: 0 10px 24px rgba(15,23,42,.08);

      transition: box-shadow .18s ease, transform .18s ease;
    }

    .blog-page .ha-search:focus-within{
      box-shadow:
        0 14px 34px rgba(15,23,42,.12),
        0 0 0 4px rgba(40,167,69,.10);
      transform: translateY(-1px);
    }

    .blog-page .ha-search-input{
      flex: 1;
      border: 0 !important;
      outline: 0 !important;
      box-shadow: none !important;
      background: transparent !important;

      font-size: 1.05rem;
      color: #111827;
      padding-left: 6px;
    }

    .blog-page .ha-search-input::placeholder{ color: #94a3b8; }

    .blog-page .ha-search-btn{
      width: 40px;
      height: 40px;
      border-radius: 999px;

      display: inline-flex;
      align-items: center;
      justify-content: center;

      border: 2px solid rgba(40,167,69,.45);
      background: rgba(40,167,69,.10);
      text-decoration: none !important;

      transition: transform .12s ease, box-shadow .15s ease, background .15s ease, border-color .15s ease;
    }

    .blog-page .ha-search-btn i{
      font-size: 1.15rem;
      color: #28a745;
    }

    .blog-page .ha-search-btn:hover{
      transform: translateY(-1px);
      border-color: rgba(40,167,69,.65);
      background: rgba(40,167,69,.14);
      box-shadow: 0 10px 22px rgba(40,167,69,.18);
    }

    .blog-page .ha-search-btn:active{
      transform: translateY(0);
      box-shadow: 0 6px 16px rgba(40,167,69,.14);
    }

    /* ===== Pagination: chữ đen đậm - nền trắng (scoped) ===== */
    .blog-page .ha-pager .pagination{
      gap: 8px;
      padding: 8px;
      border-radius: 999px;
      background: #fff;
      border: 1px solid rgba(148,163,184,.35);
      box-shadow: 0 12px 26px rgba(15,23,42,.08);
    }

    .blog-page .ha-pager .page-link{
      min-width: 38px;
      height: 38px;
      padding: 0 12px;

      display: inline-flex;
      align-items: center;
      justify-content: center;

      border-radius: 999px !important;
      border: 1px solid rgba(148,163,184,.45);
      background: #fff;

      color: #111827;
      font-weight: 800;

      transition: transform .12s ease, border-color .15s ease, box-shadow .15s ease;
    }

    .blog-page .ha-pager .page-link:hover{
      transform: translateY(-1px);
      border-color: rgba(17,24,39,.55);
      box-shadow: 0 10px 18px rgba(15,23,42,.08);
    }

    .blog-page .ha-pager .page-item.active .page-link{
      background: #fff !important;
      color: #111827 !important;
      border-color: #111827;
      box-shadow: 0 12px 22px rgba(15,23,42,.10);
      transform: none;
    }

    .blog-page .ha-pager .page-item.disabled .page-link{
      opacity: .55;
      background: #fff;
      border-color: rgba(148,163,184,.28);
      box-shadow: none;
      transform: none;
    }
  </style>
</head>

<body>
<form runat="server">
  <uc:Header ID="Header1" runat="server" />

  <!-- WRAP để scope CSS, không đụng Header -->
  <div class="blog-page">
    <div class="container py-4">

      <div class="ha-hero p-3 p-lg-4 mb-4">
        <div class="d-flex flex-column gap-3">
          <div>
            <div class="title-badge">
              <i class="bi bi-person-fill"></i>
              HAFood - Bài viết
            </div>

            <div class="d-flex flex-wrap align-items-end justify-content-between gap-3">
              <div class="me-lg-3">
                <h1 class="page-title">Bài viết của cửa hàng</h1>
                <div class="page-subtitle">Giới thiệu đồ ăn vặt, mẹo chọn hàng, khuyến mãi và cập nhật mới.</div>
              </div>

              <!-- Search trong Blog (không ảnh hưởng search header) -->
              <div class="ha-search ms-lg-auto">
                <asp:TextBox ID="txtQ" runat="server" CssClass="ha-search-input" placeholder="Tìm bài viết..." />
                <asp:LinkButton ID="btnSearch" runat="server" CssClass="ha-search-btn"
                                OnClick="btnSearch_Click" CausesValidation="false" aria-label="Tìm kiếm">
                  <i class="bi bi-search"></i>
                </asp:LinkButton>
              </div>
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

      <div class="d-none">
        <asp:Literal ID="litInfo" runat="server" />
      </div>

      <div class="d-flex align-items-center justify-content-end mt-4">
        <asp:Literal ID="litPager" runat="server" />
      </div>

    </div>
  </div>
  <!-- END WRAP -->

  <uc:Footer ID="Footer1" runat="server" />
</form>
</body>
</html>
