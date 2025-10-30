using System;

namespace HAFoodWeb.Models
{
    public class OrderItemDto
    {
        public long id { get; set; }
        public long order_Id { get; set; }
        public long variant_Id { get; set; }
        public long product_Id { get; set; }

        // C# 7.3: bỏ dấu ? vì reference type vốn đã nullable
        public string sku { get; set; }
        public string name_Variant { get; set; }
        public decimal price_Variant { get; set; }     // đúng kiểu tiền tệ
        public string image_Variant { get; set; }
        public int quantity { get; set; }
        public decimal line_Subtotal { get; set; }
        public DateTime created_At { get; set; }       // NOT NULL trong DB
        public DateTime updated_At { get; set; }       // NOT NULL trong DB

        // đúng thứ tự theo SELECT ở SP (brand_name, product_name, image_product)
        public string brand_Name { get; set; }
        public string product_Name { get; set; }
        public string image_Product { get; set; }
    }
}
