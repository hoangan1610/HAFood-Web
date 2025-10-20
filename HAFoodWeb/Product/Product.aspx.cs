using HAFoodWeb.Models;
using HAFoodWeb.Services;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Globalization;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;

namespace HAFoodWeb
{
    public partial class Product : System.Web.UI.Page
    {
        private readonly IProductDetailService _detailService = new ProductDetailService();
        private readonly IProductCardService _cardService = new ProductCardService();
        private readonly ICartService _cartService = new CartService();

        protected async void Page_Load(object sender, EventArgs e)
        {
            if (!long.TryParse(Request.QueryString["id"], out var id) || id <= 0)
            {
                Response.StatusCode = 404;
                Response.End();
                return;
            }

            var dto = await _detailService.GetProductDetailAsync(id);
            if (dto == null || string.IsNullOrWhiteSpace(dto.Name))
            {
                Response.StatusCode = 404;
                Response.End();
                return;
            }

            if (!IsPostBack)
            {
                BindProduct(dto);
                await BindRelatedAsync();
            }
            else
            {
                var json = new JavaScriptSerializer().Serialize(
                    (dto.Variants ?? new List<VariantDto>()).Select(v => new
                    {
                        id = v.Id,
                        sku = v.Sku,
                        name = string.IsNullOrWhiteSpace(v.Name) ? v.Sku : v.Name,
                        retailPrice = v.Retail_Price,
                        stock = v.Stock,
                        image = v.Image
                    }).ToList());
                hVariantsJson.Value = json;
            }
        }

        private void BindProduct(ProductDetailDto d)
        {
            pageTitle.Text = d.Name + " - HAFood";
            litNameCrumb.Text = Server.HtmlEncode(d.Name);
            litName.Text = Server.HtmlEncode(d.Name);
            litBrand.Text = Server.HtmlEncode(d.Brand_Name ?? "");

            // gallery
            var gallery = new List<string>();
            if (d.Variants != null)
            {
                foreach (var v in d.Variants)
                    if (!string.IsNullOrWhiteSpace(v.Image) && v.Image.StartsWith("http", StringComparison.OrdinalIgnoreCase))
                        gallery.Add(v.Image);
            }
            if (!string.IsNullOrWhiteSpace(d.Image_Product) && d.Image_Product.StartsWith("http", StringComparison.OrdinalIgnoreCase))
                gallery.Add(d.Image_Product);
            if (gallery.Count == 0) gallery.Add("/images/product-default.png");

            imgMain.Src = gallery[0];
            rpThumbs.DataSource = gallery.Select(x => new { Url = x }).ToList();
            rpThumbs.DataBind();

            // dropdown
            decimal min = decimal.MaxValue, max = 0;
            var opts = new List<Tuple<long, string, VariantDto>>();
            foreach (var v in d.Variants ?? new List<VariantDto>())
            {
                if (v.Retail_Price < min) min = v.Retail_Price;
                if (v.Retail_Price > max) max = v.Retail_Price;
                var name = string.IsNullOrWhiteSpace(v.Name) ? v.Sku : v.Name;
                opts.Add(Tuple.Create(v.Id, $"{name} ({FormatVnd(v.Retail_Price)})", v));
            }
            if (min == decimal.MaxValue) min = 0;

            ddlVariant.DataSource = opts.Select(o => new { Id = o.Item1, Text = o.Item2 });
            ddlVariant.DataTextField = "Text";
            ddlVariant.DataValueField = "Id";
            ddlVariant.DataBind();

            litPrice.Text = (min == max || max == 0)
                ? FormatVnd(min)
                : $"{FormatVnd(min)} - {FormatVnd(max)}";

            var first = opts.FirstOrDefault()?.Item3;
            litSku.Text = first?.Sku ?? "";
            litStock.Text = (first?.Stock ?? 0).ToString();

            litDetail.Text = string.IsNullOrWhiteSpace(d.Detail)
                ? "Đang cập nhật mô tả sản phẩm."
                : d.Detail;

            var json = new JavaScriptSerializer().Serialize(
                (d.Variants ?? new List<VariantDto>()).Select(v => new
                {
                    id = v.Id,
                    sku = v.Sku,
                    name = string.IsNullOrWhiteSpace(v.Name) ? v.Sku : v.Name,
                    retailPrice = v.Retail_Price,
                    stock = v.Stock,
                    image = v.Image
                }).ToList());
            hVariantsJson.Value = json;
        }

        private async Task BindRelatedAsync()
        {
            var cards = await _cardService.GetRecommendedCardsAsync(8);
            rpRelated.DataSource = cards;
            rpRelated.DataBind();
        }

        private static string FormatVnd(decimal v)
        {
            var vi = CultureInfo.GetCultureInfo("vi-VN");
            return string.Format(vi, "{0:#,0}đ", v);
        }

        protected async void btnAddToCart_Click(object sender, EventArgs e)
        {
            try
            {
                if (!long.TryParse(ddlVariant.SelectedValue, out var variantId)) return;
                if (!int.TryParse(Request.Form["qty"], out var quantity) || quantity <= 0) return;

                var serializer = new JavaScriptSerializer();
                var variants = serializer.Deserialize<List<Dictionary<string, object>>>(hVariantsJson.Value);
                var variantInfo = variants.FirstOrDefault(v =>
                    v.ContainsKey("id") && Convert.ToInt64(v["id"]) == variantId);
                if (variantInfo == null) return;

                var req = new CartAddRequest
                {
                    variant_Id = variantId,
                    quantity = quantity,
                    name_Variant = variantInfo.ContainsKey("name") ? variantInfo["name"].ToString() : "",
                    price_Variant = variantInfo.ContainsKey("retailPrice") ? Convert.ToDouble(variantInfo["retailPrice"]) : 0,
                    image_Variant = variantInfo.ContainsKey("image") ? variantInfo["image"].ToString() : ""
                };

                var deviceId = GetOrCreateDeviceId();
                var res = await _cartService.AddCartItemAsync(deviceId, req);

                if (res?.items != null)
                {
                    System.Diagnostics.Debug.WriteLine($"✅ Đã thêm variant {req.variant_Id} ({req.name_Variant}) x{req.quantity} vào giỏ.");

                    // LƯU cartId vào Session + Cookie nếu backend trả
                    try
                    {
                        long cartId = 0;
                        if (res.header != null)
                        {
                            // cart_Id theo DTO
                            cartId = res.header.cart_Id;
                        }

                        if (cartId > 0)
                        {
                            // Lưu Session
                            try { Session["CartId"] = cartId; } catch { }

                            // Lưu Cookie HACartId (HttpOnly = false để JS/test có thể đọc)
                            var cookie = new HttpCookie("HACartId", cartId.ToString())
                            {
                                HttpOnly = false,
                                Secure = Request.IsSecureConnection,
                                Expires = DateTime.UtcNow.AddYears(1)
                            };
                            Response.Cookies.Remove("HACartId");
                            Response.Cookies.Add(cookie);
                        }
                    }
                    catch (Exception ex)
                    {
                        System.Diagnostics.Debug.WriteLine("SaveCartId failed: " + ex);
                    }

                    // 👉 Sau khi thêm thành công, gọi hàm JS để cập nhật badge
                    ScriptManager.RegisterStartupScript(
                        this, GetType(),
                        "UpdateCartBadge",
                        "updateCartBadge();",
                        true
                    );
                }
                else
                {
                    System.Diagnostics.Debug.WriteLine("❌ Thêm giỏ hàng thất bại.");
                }

                upAddCart.Update();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("❌ Lỗi khi thêm vào giỏ hàng: " + ex);
            }
        }

        private long GetOrCreateDeviceId()
        {
            const string cookieName = "HADeviceId";
            var cookie = Request.Cookies[cookieName];

            if (cookie != null && long.TryParse(cookie.Value, out var existingId))
            {
                return existingId;
            }

            // ✅ Tạo deviceId mới dạng long (dựa trên ticks để đảm bảo duy nhất)
            var newId = DateTime.UtcNow.Ticks;

            var newCookie = new HttpCookie(cookieName, newId.ToString())
            {
                HttpOnly = false,
                Secure = Request.IsSecureConnection,
                Expires = DateTime.UtcNow.AddYears(10)
            };
            Response.Cookies.Add(newCookie);

            return newId;
        }
    }
}
