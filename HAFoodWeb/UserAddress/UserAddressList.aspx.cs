using System;
using System.Threading.Tasks;
using System.Web; // để dùng HttpCacheability
using HAFoodWeb.Services;

namespace HAFoodWeb.UserAddress
{
    public partial class UserAddressList : System.Web.UI.Page
    {
        private readonly IAddressService _service = new AddressService();

        protected async void Page_Load(object sender, EventArgs e)
        {
            if (Session == null || Session["UserId"] == null)
            {
                Response.Redirect("~/AuthPage/Login.aspx");
                return;
            }

            if (!IsPostBack)
                await BindAsync();
        }

        private async Task BindAsync()
        {
            var token = Request?.Cookies["AuthToken"]?.Value;

            // ✅ Chỉ lấy địa chỉ đang active để không hiện item đã soft-delete
            var items = await _service.GetMyAddressesAsync(token, onlyActive: true);

            phEmpty.Visible = items == null || items.Count == 0;
            rptAddresses.DataSource = items;
            rptAddresses.DataBind();

            // ✅ Chống cache trang danh sách
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
                    // TODO: hiển thị thông báo nếu cần
                }
            }
        }
    }
}
