using System;
using System.Linq;                  // Skip/Take + Enumerable.Range
using System.Threading.Tasks;
using System.Web;
using HAFoodWeb.Services;

namespace HAFoodWeb.UserAddress
{
    public partial class UserAddressList : System.Web.UI.Page
    {
        private readonly IAddressService _service = new AddressService();

        private const int PageSize = 6;

        protected int CurrentPage
        {
            get
            {
                if (ViewState["CurrentPage"] == null) return 1;
                return (int)ViewState["CurrentPage"];
            }
            set
            {
                ViewState["CurrentPage"] = value;
            }
        }

        protected async void Page_Load(object sender, EventArgs e)
        {
            if (Session == null || Session["UserId"] == null)
            {
                Response.Redirect("~/AuthPage/Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                CurrentPage = 1;
                await BindAsync();
            }
        }

        private async Task BindAsync()
        {
            var token = Request?.Cookies["AuthToken"]?.Value;

            var items = await _service.GetMyAddressesAsync(token, onlyActive: true);

            if (items == null || items.Count == 0)
            {
                phEmpty.Visible = true;
                pnlList.Visible = false;
                if (pnlPagination != null) pnlPagination.Visible = false;
            }
            else
            {
                phEmpty.Visible = false;
                pnlList.Visible = true;

                int totalCount = items.Count;
                int totalPages = Math.Max(1, (int)Math.Ceiling((double)totalCount / PageSize));

                if (CurrentPage < 1) CurrentPage = 1;
                if (CurrentPage > totalPages) CurrentPage = totalPages;

                var pagedItems = items
                    .Skip((CurrentPage - 1) * PageSize)
                    .Take(PageSize)
                    .ToList();

                rptAddresses.DataSource = pagedItems;
                rptAddresses.DataBind();

                if (pnlPagination != null)
                {
                    if (totalPages > 1)
                    {
                        rpPaging.DataSource = Enumerable.Range(1, totalPages);
                        rpPaging.DataBind();
                        pnlPagination.Visible = true;

                        btnPrev.Enabled = CurrentPage > 1;
                        btnNext.Enabled = CurrentPage < totalPages;
                    }
                    else
                    {
                        pnlPagination.Visible = false;
                    }
                }
            }

            Response.Cache.SetCacheability(HttpCacheability.NoCache);
            Response.Cache.SetNoStore();
            Response.Cache.SetExpires(DateTime.UtcNow.AddMinutes(-1));
        }

        protected async void rptAddresses_ItemCommand(object source, System.Web.UI.WebControls.RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "setDefault")
            {
                try
                {
                    var token = Request?.Cookies["AuthToken"]?.Value;
                    long id = Convert.ToInt64(e.CommandArgument);
                    await _service.SetDefaultAsync(token, id);
                    await BindAsync();
                }
                catch
                {
                    // TODO: log / hiển thị nếu cần
                }
            }
        }

        // ====== Phân trang ======
        protected async void rpPaging_ItemCommand(object source, System.Web.UI.WebControls.RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "ChangePage")
            {
                if (int.TryParse(e.CommandArgument?.ToString(), out int newPage))
                {
                    CurrentPage = newPage;
                    await BindAsync();
                }
            }
        }

        protected async void btnPrev_Click(object sender, EventArgs e)
        {
            if (CurrentPage > 1)
            {
                CurrentPage -= 1;
                await BindAsync();
            }
        }

        protected async void btnNext_Click(object sender, EventArgs e)
        {
            CurrentPage += 1;
            await BindAsync();
        }
    }
}
