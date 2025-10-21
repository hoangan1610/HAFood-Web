namespace HAFoodWeb.Models
{
    public class CartAddRequest
    {
        public long variant_Id { get; set; }
        public int quantity { get; set; }
        public string name_Variant { get; set; }
        public decimal? price_Variant { get; set; } // decimal?
        public string image_Variant { get; set; }
    }


    public class CartUpdateQtyRequest
    {
        public int quantity { get; set; }
    }
}