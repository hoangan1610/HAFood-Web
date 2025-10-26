using HAFoodWeb.Models;
using HAFoodWeb.Services;
using System;
using System.Diagnostics;
using System.Linq;
using System.Threading.Tasks;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;

namespace HAFoodWeb
{
    public partial class OrderPage : Page
    {
        private readonly IOrderService _orderService = new OrderService();

        // Thay đổi pageSize tuỳ bạn (mặc định 5)
        private const int PageSize = 5;

        // CurrentPage lưu trong ViewState để giữ trạng thái giữa postback
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
            if (!IsPostBack)
            {
                // Kiểm tra đăng nhập
                if (Session["UserId"] == null)
                {
                    Response.Redirect("~/AuthPage/Login.aspx", false);
                    Context.ApplicationInstance.CompleteRequest();
                    return;
                }

                CurrentPage = 1;
                await BindOrdersAsync();
            }
        }

        // Load orders theo CurrentPage
        private async Task BindOrdersAsync()
        {
            try
            {
                if (Session["UserId"] == null || !long.TryParse(Session["UserId"].ToString(), out long userId))
                {
                    pnlEmpty.Visible = true;
                    litDebug.Text = "<pre>⚠️ Không tìm thấy UserId trong session.</pre>";
                    litDebug.Visible = true;
                    return;
                }

                int page = CurrentPage;

                Debug.WriteLine($"📦 Gọi API lấy đơn hàng cho userId={userId}, page={page}");

                var result = await _orderService.GetOrdersByUserAsync(userId, null, page, PageSize);

                if (result == null)
                {
                    litDebug.Text = "<pre>❌ API trả về null hoặc lỗi.</pre>";
                    litDebug.Visible = true;
                    pnlEmpty.Visible = true;
                    pnlPagination.Visible = false;
                    return;
                }

                // Nếu không có items
                if (result.items == null || !result.items.Any())
                {
                    rpOrders.DataSource = null;
                    rpOrders.DataBind();
                    pnlEmpty.Visible = true;
                    rpOrders.Visible = false;
                    pnlPagination.Visible = false;
                    return;
                }

                // Bind danh sách
                rpOrders.DataSource = result.items;
                rpOrders.DataBind();
                pnlEmpty.Visible = false;
                rpOrders.Visible = true;

                // Tạo phân trang
                int totalPages = Math.Max(1, (int)Math.Ceiling((double)result.totalCount / PageSize));
                if (totalPages > 1)
                {
                    rpPaging.DataSource = Enumerable.Range(1, totalPages);
                    rpPaging.DataBind();
                    pnlPagination.Visible = true;
                }
                else
                {
                    pnlPagination.Visible = false;
                }

                // Bật/tắt Prev/Next
                btnPrev.Enabled = page > 1;
                btnNext.Enabled = page < totalPages;
            }
            catch (Exception ex)
            {
                Debug.WriteLine("❌ Lỗi BindOrdersAsync: " + ex);
                litDebug.Text = "<pre>" + Server.HtmlEncode(ex.ToString()) + "</pre>";
                litDebug.Visible = true;
                pnlEmpty.Visible = true;
                pnlPagination.Visible = false;
            }
        }

        // Gắn badge trạng thái khi lặp từng item
        protected void rpOrders_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == System.Web.UI.WebControls.ListItemType.Item || e.Item.ItemType == System.Web.UI.WebControls.ListItemType.AlternatingItem)
            {
                var order = (OrderHeaderDto)e.Item.DataItem;
                var badge = (HtmlGenericControl)e.Item.FindControl("statusBadge");

                if (badge != null)
                {
                    badge.InnerText = GetStatusText(order.status);
                    badge.Attributes["class"] = $"status-badge status-{order.status}";
                }
            }
        }

        // Handler khi bấm số trang
        protected async void rpPaging_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "ChangePage")
            {
                if (int.TryParse(e.CommandArgument?.ToString(), out int newPage))
                {
                    CurrentPage = newPage;
                    await BindOrdersAsync();
                }
            }
        }

        // Prev / Next
        protected async void btnPrev_Click(object sender, EventArgs e)
        {
            if (CurrentPage > 1)
            {
                CurrentPage -= 1;
                await BindOrdersAsync();
            }
        }

        protected async void btnNext_Click(object sender, EventArgs e)
        {
            CurrentPage += 1;
            await BindOrdersAsync();
        }

        // Hàm hiển thị text theo status (dạng switch truyền thống)
        private string GetStatusText(int status)
        {
            switch (status)
            {
                case 0:
                    return "Chờ xác nhận";
                case 1:
                    return "Đã xác nhận";
                case 2:
                    return "Đang giao";
                case 3:
                    return "Đã giao";
                case 4:
                    return "Đã hủy";
                default:
                    return "Không rõ";
            }
        }
    }
}