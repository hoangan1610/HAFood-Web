using HAFoodWeb.Models;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading.Tasks;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;

namespace HAFoodWeb
{
    public partial class OrderPage : Page
    {
        // State
        private int CurrentPage
        {
            get => (ViewState["p"] as int?) ?? 1;
            set => ViewState["p"] = value;
        }

        private byte? CurrentStatus
        {
            get => ViewState["st"] as byte?;
            set => ViewState["st"] = value;
        }

        private string CurrentCode
        {
            get => (ViewState["q"] as string) ?? "";
            set => ViewState["q"] = value ?? "";
        }

        protected async void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;

            // init from query if any
            if (int.TryParse(Request["page"], out var p) && p > 0) CurrentPage = p;

            var qs = Request["status"];
            if (!string.IsNullOrWhiteSpace(qs) && byte.TryParse(qs, out var st))
                CurrentStatus = st;
            else
                CurrentStatus = null;

            var qc = Request["order_code"];
            if (!string.IsNullOrWhiteSpace(qc))
                CurrentCode = qc.Trim();

            txtOrderCode.Text = CurrentCode;

            await LoadOrdersAsync();
        }

        protected async void btnFilter_Click(object sender, EventArgs e)
        {
            if (sender is Button b)
            {
                var arg = (b.CommandArgument ?? "").Trim();
                if (string.Equals(arg, "all", StringComparison.OrdinalIgnoreCase))
                    CurrentStatus = null;
                else if (byte.TryParse(arg, out var st))
                    CurrentStatus = st;
                else
                    CurrentStatus = null;
            }

            CurrentPage = 1;
            await LoadOrdersAsync();
        }

        protected async void btnSearchCode_Click(object sender, EventArgs e)
        {
            CurrentCode = (txtOrderCode.Text ?? "").Trim();
            CurrentPage = 1;
            await LoadOrdersAsync();
        }

        protected async void btnClearCode_Click(object sender, EventArgs e)
        {
            txtOrderCode.Text = "";
            CurrentCode = "";
            CurrentPage = 1;
            await LoadOrdersAsync();
        }

        protected async void btnPrev_Click(object sender, EventArgs e)
        {
            if (CurrentPage > 1) CurrentPage--;
            await LoadOrdersAsync();
        }

        protected async void btnNext_Click(object sender, EventArgs e)
        {
            CurrentPage++;
            await LoadOrdersAsync();
        }

        protected async void rpPaging_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "ChangePage")
            {
                var arg = (e.CommandArgument ?? "").ToString();
                if (int.TryParse(arg, out var p) && p > 0)
                {
                    CurrentPage = p;
                    await LoadOrdersAsync();
                }
            }
        }

        protected void rpOrders_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item && e.Item.ItemType != ListItemType.AlternatingItem) return;

            var dto = e.Item.DataItem as OrderHeaderDto;
            if (dto == null) return;

            // status badge
            var badge = e.Item.FindControl("statusBadge") as HtmlGenericControl;
            if (badge != null)
            {
                var st = dto.status;
                badge.Attributes["class"] = $"status-badge status-{st}";
                badge.InnerText = StatusText(st);
            }

            // ✅ quick action placeholder: chỉ visible khi status=3
            var phQuick = e.Item.FindControl("phQuickReceived") as PlaceHolder;
            if (phQuick != null)
            {
                phQuick.Visible = (dto.status == 3);
            }
        }

        private async Task LoadOrdersAsync()
        {
            var token = (Session["JwtToken"] as string) ?? "";
            var apiBase = (System.Configuration.ConfigurationManager.AppSettings["ApiBaseUrl"] ?? "").Trim().TrimEnd('/');

            if (string.IsNullOrWhiteSpace(apiBase))
            {
                pnlEmpty.Visible = true;
                pnlPagination.Visible = false;
                rpOrders.DataSource = new List<OrderHeaderDto>();
                rpOrders.DataBind();
                return;
            }

            int pageSize = 20;

            var qs = new List<string>
            {
                "page=" + CurrentPage,
                "page_size=" + pageSize
            };

            if (CurrentStatus.HasValue) qs.Add("status=" + CurrentStatus.Value);
            if (!string.IsNullOrWhiteSpace(CurrentCode)) qs.Add("order_code=" + Uri.EscapeDataString(CurrentCode));

            var url = apiBase + "/api/orders" + "?" + string.Join("&", qs);

            OrdersPageDto res;

            try
            {
                using (var http = new HttpClient())
                {
                    http.Timeout = TimeSpan.FromSeconds(20);

                    if (!string.IsNullOrWhiteSpace(token))
                        http.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);

                    var json = await http.GetStringAsync(url);

                    // ✅ FIX: WebForms/.NET Framework dùng Newtonsoft cho chắc
                    res = JsonConvert.DeserializeObject<OrdersPageDto>(json) ?? new OrdersPageDto();
                }
            }
            catch (Exception ex)
            {
                litDebug.Visible = true;
                litDebug.Text = "<pre style='white-space:pre-wrap;color:#b42318;'>LoadOrders error: " +
                                Server.HtmlEncode(ex.ToString()) + "</pre>";

                res = new OrdersPageDto();
            }

            var list = res.items ?? new List<OrderHeaderDto>();

            rpOrders.DataSource = list;
            rpOrders.DataBind();

            pnlEmpty.Visible = (list.Count == 0);
            SetupFilterActiveButtons();

            // ✅ FIX: OrdersPageDto có page_size + total
            SetupPaging(
                res.page > 0 ? res.page : CurrentPage,
                res.page_size > 0 ? res.page_size : pageSize,
                res.total > 0 ? res.total : list.Count
            );
        }

        private void SetupFilterActiveButtons()
        {
            var allBtns = new[] { btnAll, btnPending, btnConfirmed, btnShipping, btnDelivered, btnReceived, btnCanceled };
            foreach (var b in allBtns) b.CssClass = "btn btn-outline-dark btn-sm";

            if (!CurrentStatus.HasValue) btnAll.CssClass += " active";
            else
            {
                switch (CurrentStatus.Value)
                {
                    case 0: btnPending.CssClass += " active"; break;
                    case 1: btnConfirmed.CssClass += " active"; break;
                    case 2: btnShipping.CssClass += " active"; break;
                    case 3: btnDelivered.CssClass += " active"; break;
                    case 7: btnReceived.CssClass += " active"; break;
                    case 4: btnCanceled.CssClass += " active"; break;
                    default: btnAll.CssClass += " active"; break;
                }
            }
        }

        private void SetupPaging(int page, int pageSize, int total)
        {
            if (page < 1) page = 1;
            if (pageSize <= 0) pageSize = 20;

            var totalPages = (int)Math.Ceiling(total / (double)pageSize);
            if (totalPages <= 0) totalPages = 1;

            // clamp current page
            if (page > totalPages) { page = totalPages; CurrentPage = totalPages; }

            btnPrev.Enabled = page > 1;
            btnNext.Enabled = page < totalPages;

            var items = BuildPagingItems(page, totalPages);

            rpPaging.DataSource = items;
            rpPaging.DataBind();

            pnlPagination.Visible = totalPages > 1;
        }

        private List<string> BuildPagingItems(int page, int totalPages)
        {
            var result = new List<string>();
            void Add(string x) => result.Add(x);

            int window = 2;
            int left = Math.Max(1, page - window);
            int right = Math.Min(totalPages, page + window);

            Add("1");

            if (left > 2) Add("...");

            for (int i = left; i <= right; i++)
            {
                if (i == 1 || i == totalPages) continue;
                Add(i.ToString());
            }

            if (right < totalPages - 1) Add("...");

            if (totalPages > 1) Add(totalPages.ToString());

            // remove dup
            var cleaned = new List<string>();
            foreach (var x in result)
            {
                if (cleaned.Count == 0 || cleaned.Last() != x)
                    cleaned.Add(x);
            }
            return cleaned;
        }

        public bool IsEllipsis(object item)
        {
            return (item?.ToString() ?? "") == "...";
        }

        public string GetPageButtonCss(object item)
        {
            var s = item?.ToString() ?? "";
            if (!int.TryParse(s, out var p)) return "btn btn-outline-secondary btn-sm";
            return (p == CurrentPage)
                ? "btn btn-page-active btn-sm"
                : "btn btn-outline-secondary btn-sm";
        }

        public string BuildPaymentText(OrderHeaderDto h)
        {
            if (h == null) return "";
            if (h.payment_Method == null) return "Chưa chọn";

            switch (h.payment_Method.Value)
            {
                case 0: return "COD";
                case 1: return "MoMo";
                case 2: return "Pay2S";
                default: return "Khác";
            }
        }

        private string StatusText(byte st)
        {
            switch (st)
            {
                case 0: return "Đã được tạo";
                case 1: return "Đã xác nhận";
                case 2: return "Đang giao";
                case 3: return "Đã giao";
                case 6: return "Đang giao hàng";
                case 7: return "Đã nhận hàng";
                case 4: return "Đã huỷ";
                case 9: return "Huỷ đơn";
                default: return "Không rõ";
            }
        }
    }
}
