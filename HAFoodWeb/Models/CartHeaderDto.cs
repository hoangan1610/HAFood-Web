using System;

namespace HAFoodWeb.Models
{
    public class CartHeaderDto
    {
        public long cart_Id { get; set; }
        public long? user_Info_Id { get; set; }
        public long? device_Id { get; set; }
        public int status { get; set; }
        public DateTime created_At { get; set; }
        public DateTime updated_At { get; set; }
        public int item_Count { get; set; }
        public double subtotal { get; set; }
    }
}