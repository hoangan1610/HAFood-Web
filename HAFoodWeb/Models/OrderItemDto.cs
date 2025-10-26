using System;

namespace HAFoodWeb.Models
{
    public class OrderItemDto
    {
        public long id { get; set; }
        public long order_Id { get; set; }
        public long variant_Id { get; set; }
        public long product_Id { get; set; }
        public string sku { get; set; }
        public string name_Variant { get; set; }
        public decimal price_Variant { get; set; }
        public string image_Variant { get; set; }
        public int quantity { get; set; }
        public decimal line_Subtotal { get; set; }
        public DateTime created_At { get; set; }
        public DateTime updated_At { get; set; }
        public string brand_Name { get; set; }
        public string product_Name { get; set; }
        public string image_Product { get; set; }
    }
}
