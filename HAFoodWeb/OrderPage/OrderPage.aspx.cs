using HAFoodWeb.Models;
using HAFoodWeb.Services;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;

namespace HAFoodWeb
{
    public partial class OrderPage : Page
    {
        private readonly IOrderService _orderService = new OrderService();
        private const int PageSize = 3;

        protected int CurrentPage
        {
            get => (ViewState["CurrentPage"] == null) ? 1 : (int)ViewState["CurrentPage"];
            set => ViewState["CurrentPage"] = value;
        }

        protected int? CurrentStatus
        {
            get => ViewState["CurrentStatus"] as int?;
            set => ViewState["CurrentStatus"] = value;
        }

        // ✅ Search theo mã đơn (lưu ViewState)
        protected string CurrentOrderCode
        {
            get => (ViewState["CurrentOrderCode"] as string) ?? "";
            set => ViewState["CurrentOrderCode"] = value ?? "";
        }

        private static string NormalizeOrderCode(string raw)
        {
            raw = (raw ?? "").Trim();
            if (raw.Length == 0) return "";
            raw = raw.Replace(" ", "");
            return raw.ToUpperInvariant();
        }

        protected async void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // vẫn giữ check login theo session của bạn
                if (Session["UserId"] == null)
                {
                    Response.Redirect("~/AuthPage/Login.aspx", false);
                    Context.ApplicationInstance.CompleteRequest();
                    return;
                }

                CurrentPage = 1;
                CurrentStatus = null;
                CurrentOrderCode = "";

                ResetActiveFilter(btnAll);

                // sync UI
                if (txtOrderCode != null) txtOrderCode.Text = CurrentOrderCode;
                if (btnClearCode != null) btnClearCode.Visible = false;

                await BindOrdersAsync();
            }
        }

        // ✅ Click tìm mã đơn
        protected async void btnSearchCode_Click(object sender, EventArgs e)
        {
            CurrentOrderCode = NormalizeOrderCode(txtOrderCode?.Text);
            CurrentPage = 1;
            await BindOrdersAsync();
        }

        // ✅ Xoá mã tìm kiếm
        protected async void btnClearCode_Click(object sender, EventArgs e)
        {
            CurrentOrderCode = "";
            if (txtOrderCode != null) txtOrderCode.Text = "";
            CurrentPage = 1;
            await BindOrdersAsync();
        }

        private async Task BindOrdersAsync()
        {
            try
            {
                litDebug.Visible = false;

                if (Session["UserId"] == null)
                {
                    pnlEmpty.Visible = true;
                    rpOrders.Visible = false;
                    pnlPagination.Visible = false;

                    litDebug.Text = "<pre>⚠️ Chưa đăng nhập.</pre>";
                    litDebug.Visible = true;
                    return;
                }

                int page = CurrentPage;

                // ✅ luôn sync textbox theo ViewState
                if (txtOrderCode != null) txtOrderCode.Text = CurrentOrderCode;
                if (btnClearCode != null) btnClearCode.Visible = !string.IsNullOrWhiteSpace(CurrentOrderCode);

                string code = NormalizeOrderCode(CurrentOrderCode);

                Debug.WriteLine($"📦 Orders page={page}, status={(CurrentStatus.HasValue ? CurrentStatus.Value.ToString() : "null")}, code={(string.IsNullOrWhiteSpace(code) ? "null" : code)}");

                // ✅ NEW: gọi BE theo JWT (không userId nữa)
                var result = await _orderService.GetMyOrdersAsync(CurrentStatus, code, page, PageSize);

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
                    rpPaging.DataSource = BuildPageList(totalPages, page);
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
                Debug.WriteLine("❌ BindOrdersAsync ERROR: " + ex);

                litDebug.Text = "<pre>" + Server.HtmlEncode(ex.ToString()) + "</pre>";
                litDebug.Visible = true;

                pnlEmpty.Visible = true;
                rpOrders.Visible = false;
                pnlPagination.Visible = false;
            }
        }

        private List<int?> BuildPageList(int totalPages, int currentPage)
        {
            var pages = new List<int?>();

            if (totalPages <= 9)
            {
                for (int i = 1; i <= totalPages; i++) pages.Add(i);
                return pages;
            }

            if (currentPage <= 4)
            {
                pages.Add(1); pages.Add(2); pages.Add(3); pages.Add(4);
                pages.Add(null);
                pages.Add(totalPages - 2); pages.Add(totalPages - 1); pages.Add(totalPages);
            }
            else if (currentPage >= totalPages - 3)
            {
                pages.Add(1); pages.Add(2);
                pages.Add(null);
                pages.Add(totalPages - 3); pages.Add(totalPages - 2); pages.Add(totalPages - 1); pages.Add(totalPages);
            }
            else
            {
                pages.Add(1); pages.Add(2);
                pages.Add(null);
                pages.Add(currentPage - 1); pages.Add(currentPage); pages.Add(currentPage + 1);
                pages.Add(null);
                pages.Add(totalPages - 1); pages.Add(totalPages);
            }

            return pages;
        }

        protected bool IsEllipsis(object dataItem)
        {
            return dataItem == null || dataItem == DBNull.Value;
        }

        protected string GetPageButtonCss(object dataItem)
        {
            if (IsEllipsis(dataItem))
                return "btn btn-sm btn-outline-secondary";

            int page = Convert.ToInt32(dataItem);
            return page == CurrentPage
                ? "btn btn-sm btn-page-active"
                : "btn btn-sm btn-outline-secondary";
        }

        protected void rpOrders_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
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

        // ✅ FIX mapping METHOD IDs: 0=COD, 1=MOMO, 2=PAY2S, 9=ZALOPAY
        private static string GetPaymentMethodLabel(string paymentProvider, byte? paymentMethod, string paymentStatus)
        {
            // payment_status = Unpaid => COD (trường hợp COD)
            if (!string.IsNullOrWhiteSpace(paymentStatus) &&
                paymentStatus.Trim().Equals("unpaid", StringComparison.OrdinalIgnoreCase))
            {
                return "COD";
            }

            if (paymentMethod.HasValue)
            {
                switch (paymentMethod.Value)
                {
                    case 0: return "COD";
                    case 1: return "MoMo";
                    case 2: return "Pay2S";
                    case 9: return "ZaloPay";
                }
            }

            if (!string.IsNullOrWhiteSpace(paymentProvider))
            {
                var p = paymentProvider.Trim().ToUpperInvariant();
                if (p == "PAY2S") return "Pay2S";
                if (p == "MOMO") return "MoMo";
                if (p == "ZALOPAY") return "ZaloPay";
                return HttpUtility.HtmlDecode(paymentProvider);
            }

            return string.Empty;
        }

        protected string BuildPaymentText(OrderHeaderDto h)
        {
            var label = GetPaymentMethodLabel(h.payment_Provider, h.payment_Method, h.payment_Status);
            return string.IsNullOrWhiteSpace(label) ? "" : label;
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

        private string GetStatusText(int status)
        {
            switch (status)
            {
                case 0: return "Đã được tạo";
                case 1: return "Xác nhận";
                case 2: return "Đang giao";
                case 3: return "Đã giao";
                case 4: return "Đã hủy";
                default: return "Không rõ";
            }
        }
    }
}
