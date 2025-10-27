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

        private const int PageSize = 5;

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

        protected int? CurrentStatus
        {
            get => ViewState["CurrentStatus"] as int?;
            set => ViewState["CurrentStatus"] = value;
        }

        protected async void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Session["UserId"] == null)
                {
                    Response.Redirect("~/AuthPage/Login.aspx", false);
                    Context.ApplicationInstance.CompleteRequest();
                    return;
                }

                CurrentPage = 1;
                CurrentStatus = null;
                ResetActiveFilter(btnAll);

                await BindOrdersAsync();
            }
        }

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
                Debug.WriteLine($"📦 Lấy đơn hàng userId={userId}, page={page}, status={(CurrentStatus.HasValue ? CurrentStatus.Value.ToString() : "null")}");

                var result = await _orderService.GetOrdersByUserAsync(userId, CurrentStatus, page, PageSize);

                if (result == null || result.items == null || !result.items.Any())
                {
                    rpOrders.DataSource = null;
                    rpOrders.DataBind();
                    pnlEmpty.Visible = true;
                    rpOrders.Visible = false;
                    pnlPagination.Visible = false;
                    return;
                }

                rpOrders.DataSource = result.items;
                rpOrders.DataBind();
                pnlEmpty.Visible = false;
                rpOrders.Visible = true;

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

        protected void rpOrders_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                var order = (OrderHeaderDto)e.Item.DataItem;

                // Badge trạng thái
                var badge = (HtmlGenericControl)e.Item.FindControl("statusBadge");
                if (badge != null)
                {
                    badge.InnerText = GetStatusText(order.status);
                    badge.Attributes["class"] = $"status-badge status-{order.status}";
                }

                // Hiển thị phương thức thanh toán
                var litPayment = (Literal)e.Item.FindControl("litPayment");
                if (litPayment != null)
                {
                    litPayment.Text = BuildPaymentText(order);
                }
            }
        }

        protected string BuildPaymentText(OrderHeaderDto h)
        {
            string paymentText = "";

            if (!string.IsNullOrWhiteSpace(h.payment_Provider))
            {
                if (!string.IsNullOrWhiteSpace(h.payment_Status))
                    paymentText = "💳 " + h.payment_Provider + " – " + GetPaymentStatusText(h.payment_Status);
                else
                    paymentText = "💳 " + h.payment_Provider;
            }
            else if (!string.IsNullOrWhiteSpace(h.payment_Status))
            {
                paymentText = "💳 " + GetPaymentStatusText(h.payment_Status);
            }
            else if (h.payment_Method.HasValue)
            {
                switch (h.payment_Method.Value)
                {
                    case 1:
                        paymentText = "Thanh toán khi nhận hàng (COD)";
                        break;
                    case 2:
                        paymentText = "Thanh toán qua VNPAY";
                        break;
                    default:
                        paymentText = "Phương thức #" + h.payment_Method.Value;
                        break;
                }
            }

            return paymentText;
        }

        private string GetPaymentStatusText(string status)
        {
            switch (status)
            {
                case "Pending":
                    return "Đang chờ thanh toán";
                case "Paid":
                    return "Đã thanh toán";
                case "Failed":
                    return "Thanh toán thất bại";
                case "Canceled":
                    return "Thanh toán bị hủy";
                default:
                    return !string.IsNullOrWhiteSpace(status) ? status : "Không rõ";
            }
        }

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

        protected async void btnFilter_Click(object sender, EventArgs e)
        {
            var clickedBtn = sender as Button;
            if (clickedBtn == null) return;

            string arg = clickedBtn.CommandArgument ?? "all";

            if (arg == "all")
                CurrentStatus = null;
            else if (int.TryParse(arg, out int s))
                CurrentStatus = s;
            else
                CurrentStatus = null;

            CurrentPage = 1;

            await BindOrdersAsync();
            ResetActiveFilter(clickedBtn);
        }

        private void ResetActiveFilter(Button activeButton)
        {
            var allButtons = new[] { btnAll, btnPending, btnConfirmed, btnShipping, btnDelivered, btnCanceled };

            foreach (var btn in allButtons)
            {
                if (btn == null) continue;
                btn.CssClass = "btn btn-outline-dark btn-sm";
            }

            if (activeButton != null)
                activeButton.CssClass = "btn btn-outline-dark btn-sm active";
        }

        private string GetStatusText(int status) { 
            switch (status) 
            { 
                case 0: return "Chờ xác nhận"; 
                case 1: return "Đã xác nhận"; 
                case 2: return "Đang giao"; 
                case 3: return "Đã giao"; 
                case 4: return "Đã hủy"; 
                default: return "Không rõ"; 
            } 
        }
    }
}
