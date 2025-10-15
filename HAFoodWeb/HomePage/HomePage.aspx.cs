using HAFoodWeb.Models;
using HAFoodWeb.Services;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Web.UI;

namespace HAFoodWeb.HomePage
{
    public partial class HomePage : Page
    {
        private ICategoryService _categories;
        private IProductCardService _productCards;
        private DeviceTracker _deviceTracker;

        protected void Page_Init(object sender, EventArgs e)
        {
            _categories = new CategoryService();
            _productCards = new ProductCardService();
            _deviceTracker = new DeviceTracker(Request, Response);
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                RegisterAsyncTask(new PageAsyncTask(LoadFeaturedCategoriesAsync));
                RegisterAsyncTask(new PageAsyncTask(LoadRecommendedProductsAsync));
                RegisterAsyncTask(new PageAsyncTask(LoadNewAsync));
                RegisterAsyncTask(new PageAsyncTask(SendDeviceInfoAsync));
            }
        }

        private async Task LoadFeaturedCategoriesAsync()
        {
            try
            {
                var list = await _categories.GetFeaturedAsync();
                var view = new List<object>(list.Count);
                foreach (var c in list)
                    view.Add(new { c.Id, c.Name, ImageUrlComputed = _categories.BuildImageUrl(c) });

                rpCategories.DataSource = view;
                rpCategories.DataBind();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("[HomePage] Categories error: " + ex);
                rpCategories.DataSource = Array.Empty<object>();
                rpCategories.DataBind();
            }
        }

        private async Task LoadRecommendedProductsAsync()
        {
            try
            {
                var cards = await _productCards.GetRecommendedCardsAsync(12);
                rpProducts.DataSource = cards;
                rpProducts.DataBind();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("[HomePage] Recommended error: " + ex);
                rpProducts.DataSource = Array.Empty<object>();
                rpProducts.DataBind();
            }
        }

        // “Mới về” – hiện 1 dải cuộn ngang (không phân trang AJAX)
        private async Task LoadNewAsync()
        {
            try
            {
                var cards = await _productCards.GetRecommendedCardsAsync(12); // tạm dùng updated_at:desc
                rpNew.DataSource = cards;
                rpNew.DataBind();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("[HomePage] New arrivals error: " + ex);
                rpNew.DataSource = Array.Empty<object>();
                rpNew.DataBind();
            }
        }

        private async Task SendDeviceInfoAsync()
        {
            try
            {
                int? userInfoId = null;
                if (Session["UserId"] != null && int.TryParse(Session["UserId"].ToString(), out var id))
                    userInfoId = id;

                await _deviceTracker.SendAsync(userInfoId);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("[HomePage] DeviceTracker error: " + ex);
            }
        }
    }
}
