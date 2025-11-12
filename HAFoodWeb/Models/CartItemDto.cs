using System;

namespace HAFoodWeb.Models
{
    public class CartItemDto
    {
        public long id { get; set; }
        public long cart_Id { get; set; }
        public long variant_Id { get; set; }
        public string name_Variant { get; set; }
        public decimal price_Variant { get; set; }

        // NEW: map từ RS2 của usp_cart_view (price_effective AS price_effective)
        public decimal price_Effective { get; set; }   // <== THÊM DÒNG NÀY

        public string image_Variant { get; set; }
        public int quantity { get; set; }
        public int status { get; set; }
        public DateTime added_At { get; set; }
        public DateTime updated_At { get; set; }
        public string sku { get; set; }
        public string variant_Name { get; set; }
        public decimal variant_Retail_Price { get; set; }
        public int variant_Stock { get; set; }
        public long product_Id { get; set; }
        public string product_Name { get; set; }
        public string brand_Name { get; set; }
        public long category_Id { get; set; }
        public string image_Product { get; set; }
    }

}
