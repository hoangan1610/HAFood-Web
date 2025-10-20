namespace HAFoodWeb.Models
{
    public class CartAddRequest
    {
        public long variant_Id { get; set; }
        public int quantity { get; set; }
        public string name_Variant { get; set; }
        public double? price_Variant { get; set; }
        public string image_Variant { get; set; }
    }

    public class CartUpdateQtyRequest
    {
        public int quantity { get; set; }
    }
}
