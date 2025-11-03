using HAFoodWeb.Cart;
using HAFoodWeb.Models;
using HAFoodWeb.Services;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace HAFoodWeb
{
    public partial class CartPage : Page
    {
        private readonly ICartService _cartService = new CartService();
        private const decimal VAT_RATE = 0.08m;

        // Giữ địa chỉ hiện tại để render session
        protected AddressDto CurrentAddress;

        public class CheckoutDraftItem
        {
            public long VariantId { get; set; }
            public int Quantity { get; set; }
            public string ProductName { get; set; }
            public string VariantName { get; set; }
            public string ImageUrl { get; set; }
            public decimal Price { get; set; }
        }

        public class CheckoutDraft
        {
            public string ShipName { get; set; }
            public string ShipPhone { get; set; }
            public string ShipAddress { get; set; }
            public string PromoCode { get; set; }
            public string Note { get; set; }
            public long[] SelectedLineIds { get; set; }
            public (long variant_Id, int quantity)[] Items { get; set; }
            public string DeviceUuid { get; set; }
            public string CityCode { get; set; }
            public string WardCode { get; set; }

            public CheckoutDraftItem[] Snapshot { get; set; }
            public decimal SnapshotSubtotal { get; set; }
            public decimal SnapshotVat { get; set; }
            public decimal SnapshotShipping { get; set; }
            public decimal SnapshotGrand { get; set; }
        }

        protected async void Page_Load(object sender, EventArgs e)
        {
            Response.Cache.SetCacheability(System.Web.HttpCacheability.NoCache);
            Response.Cache.SetNoStore();
            Response.Cache.SetRevalidation(HttpCacheRevalidation.AllCaches);
            Response.Cache.SetExpires(DateTime.UtcNow.AddSeconds(-1));

            hidApiBase.Value = (ConfigurationManager.AppSettings["ApiBaseUrl"] ?? "").TrimEnd('/');

            var tracker = new DeviceTracker(Request, Response);
            var deviceUuid = tracker.GetOrCreateDeviceUuid();
            hidDeviceUuid.Value = deviceUuid;
            await tracker.SendAsync(null);

            hidIsAuth.Value = IsLoggedIn() ? "1" : "0";

            var host = Request.Url.Host?.ToLowerInvariant();
            if (host == "localhost" || host == "127.0.0.1")
            {
                var jwt = Session["JwtToken"] as string;
                if (!string.IsNullOrWhiteSpace(jwt))
                    hidJwt.Value = jwt;
            }

            if (!IsPostBack)
            {
                // Ưu tiên địa chỉ chọn ở AddressSelect
                var chosen = Session["selected_address_obj"] as AddressDto;
                if (chosen != null)
                {
                    CurrentAddress = chosen;
                    ApplyAddressToForm(chosen);
                }
                else if (IsLoggedIn())
                {
                    try
                    {
                        var token = Request.Cookies["AuthToken"]?.Value;
                        var list = await new AddressService().GetMyAddressesAsync(token, onlyActive: true);
                        var def = list?.FirstOrDefault(x => x.isDefault) ?? list?.FirstOrDefault();
                        if (def != null)
                        {
                            CurrentAddress = def;
                            ApplyAddressToForm(def);
                        }
                    }
                    catch { /* ignore */ }
                }

                SetupAddressSessionUI();
                await BindCart();
            }
        }

        /* ===== Helpers cho địa chỉ ===== */

        private static string NormalizeCity(string s)
        {
            if (string.IsNullOrWhiteSpace(s)) return "";
            s = s.Trim();
            s = Regex.Replace(s, @"^(tỉnh|thành\s*phố|tp\.?)\s*", "", RegexOptions.IgnoreCase);
            s = Regex.Replace(s, @"\s{2,}", " ");
            return s;
        }

        private static string NormalizeWard(string s)
        {
            if (string.IsNullOrWhiteSpace(s)) return "";
            s = s.Trim();
            s = Regex.Replace(s, @"\s*[-,–]\s*(quận|huyện|thị\s*xã|thành\s*phố|q\.|h\.|tx\.|tp\.).*$",
                              "", RegexOptions.IgnoreCase);
            s = Regex.Replace(s, @"\s*\(.*?\)\s*", "", RegexOptions.IgnoreCase);
            s = Regex.Replace(s, @"\b0+(\d)", "$1");
            s = Regex.Replace(s, @"\s{2,}", " ");
            return s;
        }

        private static void SplitFullAddress(string full, out string street, out string ward, out string city)
        {
            street = ward = city = "";
            var parts = (full ?? "").Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries)
                                    .Select(p => p.Trim())
                                    .ToArray();

            if (parts.Length == 0) return;

            if (parts.Length == 1) { street = parts[0]; return; }

            // city = phần cuối
            city = NormalizeCity(parts[parts.Length - 1]);

            if (parts.Length >= 4)
            {
                // cũ: street, ward, district, city
                ward = NormalizeWard(parts[parts.Length - 3]);
                street = string.Join(", ", parts.Take(parts.Length - 3));
            }
            else
            {
                // mới: street, ward (có thể kèm "- Quận …"), city
                ward = NormalizeWard(parts[1]);
                street = parts[0];
            }
        }

        private void ApplyAddressToForm(AddressDto a)
        {
            if (a == null) return;
            SplitFullAddress(a.fullAddress, out var street, out var ward, out var city);

            txtAddress.Text = street ?? "";
            txtReceiver.Text = a.fullName ?? "";
            txtPhone.Text = a.phone ?? "";

            // Prefill TEXT (để client luôn nhìn thấy) — JS sẽ map code sau
            txtCitySel.Text = city ?? "";
            txtWardSel.Text = ward ?? "";
            txtCityCode.Text = "";
            txtWardCode.Text = "";
        }

        private void SetupAddressSessionUI()
        {
            if (CurrentAddress != null)
            {
                pnlAddrSession.Visible = true;
                pnlNoAddr.Visible = false;
                lblAddrName.Text = CurrentAddress.fullName ?? "";
                lblAddrPhone.Text = CurrentAddress.phone ?? "";
                lblAddrDetail.Text = CurrentAddress.fullAddress ?? "";
            }
            else
            {
                pnlAddrSession.Visible = false;
                pnlNoAddr.Visible = true;
            }
        }

        /* ===== Cart binding / logic ===== */

        private async Task BindCart()
        {
            var tracker = new DeviceTracker(Request, Response);
            string deviceUuid = tracker.GetOrCreateDeviceUuid();
            var cart = await _cartService.GetCartAsync(deviceUuid);

            if (cart?.items == null || !cart.items.Any())
            {
                rptCart.DataSource = Enumerable.Empty<CartItemDto>();
                rptCart.DataBind();

                pnlEmpty.Style["display"] = "block";

                lblTotal.Text = "0 ₫";
                lblSumItems.Text = "0";
                lblTotalWeight.Text = "0";
                lblSubtotal.Text = "0 ₫";
                lblShipping.Text = "0 ₫";
                lblVat.Text = "0 ₫";
                lblGrandTotal.Text = "0 ₫";
            }
            else
            {
                pnlEmpty.Style["display"] = "none";
                rptCart.DataSource = cart.items;
                rptCart.DataBind();

                SelectAllCartItems(true);
                UpdateTotalsPanel();
            }

            updCart.Update();
            updSummary.Update();
        }

        private void SelectAllCartItems(bool selected)
        {
            foreach (RepeaterItem item in rptCart.Items)
            {
                var ci = item.FindControl("CartItemControl") as CartItem;
                if (ci != null) ci.Selected = selected;
            }
        }

        protected void rptCart_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item && e.Item.ItemType != ListItemType.AlternatingItem) return;

            var data = e.Item.DataItem as CartItemDto;
            var cartItem = (CartItem)e.Item.FindControl("CartItemControl");
            if (cartItem == null || data == null) return;

            cartItem.LineId = data.id;
            cartItem.VariantId = data.variant_Id;
            cartItem.ProductName = data.product_Name;
            cartItem.VariantName = data.variant_Name;
            cartItem.ImageUrl = data.image_Variant;
            cartItem.Price = data.price_Variant;
            cartItem.Quantity = data.quantity;
            cartItem.WeightPerUnit = 0m;
        }

        private void UpdateTotalsPanel()
        {
            decimal subtotal = 0m;
            int sumItems = 0;
            decimal shipping = 0m;
            decimal weight = 0m;

            foreach (RepeaterItem item in rptCart.Items)
            {
                var cartItem = (CartItem)item.FindControl("CartItemControl");
                if (cartItem != null && cartItem.Selected)
                {
                    subtotal += cartItem.Price * cartItem.Quantity;
                    sumItems += cartItem.Quantity;
                }
            }

            var vat = Math.Round(subtotal * VAT_RATE, 0, MidpointRounding.AwayFromZero);
            var grand = subtotal + shipping + vat;

            var viVN = System.Globalization.CultureInfo.GetCultureInfo("vi-VN");
            lblTotal.Text = string.Format(viVN, "{0:N0} ₫", subtotal);
            lblSumItems.Text = sumItems.ToString();
            lblTotalWeight.Text = string.Format("{0:N0}", weight);
            lblSubtotal.Text = string.Format(viVN, "{0:N0} ₫", subtotal);
            lblShipping.Text = string.Format(viVN, "{0:N0} ₫", shipping);
            lblVat.Text = string.Format(viVN, "{0:N0} ₫", vat);
            lblGrandTotal.Text = string.Format(viVN, "{0:N0} ₫", grand);
        }

        private static string MergeAddress(string street, string wardText, string cityText)
        {
            string[] parts = new[] { street, wardText, cityText };
            return string.Join(", ",
                parts.Where(s => !string.IsNullOrWhiteSpace(s))
                     .Select(s => s.Trim().Trim(',')));
        }

        private void AddPageError(string message)
        {
            var cv = new CustomValidator
            {
                IsValid = false,
                ErrorMessage = message,
                Display = ValidatorDisplay.None,
                EnableClientScript = false,
                ValidationGroup = "Checkout"
            };
            Page.Validators.Add(cv);
        }

        private bool IsLoggedIn()
        {
            var hasToken = Request.Cookies["AuthToken"] != null
                           && !string.IsNullOrWhiteSpace(Request.Cookies["AuthToken"].Value);
            return hasToken || (Context?.User?.Identity?.IsAuthenticated ?? false);
        }

        protected void cvPhone_ServerValidate(object source, ServerValidateEventArgs args)
        {
            var s = args.Value ?? "";
            s = Regex.Replace(s, @"[\s\.\-]", "");
            s = Regex.Replace(s, @"^\+840", "+84");
            args.IsValid = Regex.IsMatch(s, @"^(0\d{9}|\+84\d{9})$");
            if (args.IsValid) txtPhone.Text = s;
        }

        // RÀNG BUỘC: phải có CityCode/WardCode
        protected void cvCity_ServerValidate(object source, ServerValidateEventArgs args)
        {
            args.IsValid = !string.IsNullOrWhiteSpace(txtCityCode.Text);
        }

        protected void cvWard_ServerValidate(object source, ServerValidateEventArgs args)
        {
            args.IsValid = !string.IsNullOrWhiteSpace(txtWardCode.Text);
        }

        protected async void btnCheckout_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtCityCode.Text) || string.IsNullOrWhiteSpace(txtWardCode.Text))
            {
                AddPageError("Vui lòng chọn Tỉnh/Thành và Xã/Phường từ danh sách.");
                return;
            }
            if (!Page.IsValid) return;

            var rawSelected = hidSelectedLines.Value ?? "";
            var selectedLineIds = new HashSet<long>(
                rawSelected.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries)
                           .Select(s => long.TryParse(s, out var x) ? x : -1)
                           .Where(x => x > 0)
            );

            var tracker = new DeviceTracker(Request, Response);
            var deviceUuid = tracker.GetOrCreateDeviceUuid();
            var cartNow = await _cartService.GetCartAsync(deviceUuid);

            var items = new List<(long variant_Id, int quantity)>();
            var lineIds = new List<long>();

            var snapshot = new List<CheckoutDraftItem>();
            decimal subtotal = 0m, shipping = 0m;

            if (cartNow?.items != null)
            {
                foreach (var line in cartNow.items)
                {
                    if (!selectedLineIds.Contains(line.id)) continue;

                    lineIds.Add(line.id);
                    items.Add((line.variant_Id, line.quantity));

                    var price = line.price_Variant;
                    var qty = line.quantity;

                    snapshot.Add(new CheckoutDraftItem
                    {
                        VariantId = line.variant_Id,
                        Quantity = qty,
                        ProductName = line.product_Name,
                        VariantName = line.variant_Name,
                        ImageUrl = string.IsNullOrWhiteSpace(line.image_Variant) ? "/images/product-default.png" : line.image_Variant,
                        Price = price
                    });

                    subtotal += price * qty;
                }
            }

            if (items.Count == 0)
            {
                AddPageError("Vui lòng chọn ít nhất 1 sản phẩm để tiếp tục.");
                return;
            }

            var vat = Math.Round(subtotal * VAT_RATE, 0, MidpointRounding.AwayFromZero);
            var grand = subtotal + shipping + vat;

            string cityText = txtCitySel.Text?.Trim();
            string wardText = txtWardSel.Text?.Trim();
            string fullAddr = MergeAddress(txtAddress.Text, wardText, cityText);

            var draft = new CheckoutDraft
            {
                ShipName = txtReceiver.Text.Trim(),
                ShipPhone = txtPhone.Text.Trim(),
                ShipAddress = fullAddr,
                PromoCode = txtPromo?.Text?.Trim(),
                Note = txtNote?.Text?.Trim(),
                SelectedLineIds = lineIds.Count > 0 ? lineIds.ToArray() : null,
                Items = items.ToArray(),
                DeviceUuid = deviceUuid,
                CityCode = txtCityCode.Text?.Trim(),
                WardCode = txtWardCode.Text?.Trim(),
                Snapshot = snapshot.ToArray(),
                SnapshotSubtotal = subtotal,
                SnapshotVat = vat,
                SnapshotShipping = shipping,
                SnapshotGrand = grand
            };

            try
            {
                Session.Remove("pending_order_code");
                Session.Remove("pending_payment_url");
                Session.Remove("pending_payment_created_utc");
                Session.Remove("pending_payment_method");
            }
            catch { }

            Session["checkout_draft"] = draft;

            if (!IsLoggedIn())
            {
                var returnUrl = Server.UrlEncode(ResolveUrl("~/CartPage/CheckoutConfirm.aspx"));
                var loginUrl = ResolveUrl("~/AuthPage/Login.aspx") + "?returnUrl=" + returnUrl;

                Response.Redirect(loginUrl, false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            var url = ResolveUrl("~/CartPage/CheckoutConfirm.aspx");
            Response.Redirect(url, false);
            Context.ApplicationInstance.CompleteRequest();
        }
    }
}
