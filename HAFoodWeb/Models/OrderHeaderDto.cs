using System;

namespace HAFoodWeb.Models
{
    public class OrderHeaderDto
    {
        public long id { get; set; }
        public long user_Info_Id { get; set; }
        public long? address_Id { get; set; }
        public string order_Code { get; set; }
        public string ship_Name { get; set; }
        public string ship_Full_Address { get; set; }
        public string ship_Phone { get; set; }
        public int status { get; set; }
        public double sub_Total { get; set; }
        public double discount_Total { get; set; }
        public double shipping_Total { get; set; }
        public double vat_Total { get; set; }
        public double pay_Total { get; set; }
        public string ip { get; set; }
        public long? device_Id { get; set; }
        public int? payment_Method { get; set; }
        public DateTime? placed_At { get; set; }
        public DateTime? confirmed_At { get; set; }
        public DateTime? shipped_At { get; set; }
        public DateTime? delivered_At { get; set; }
        public DateTime? canceled_At { get; set; }
        public string note { get; set; }
        public DateTime? created_At { get; set; }
        public DateTime? updated_At { get; set; }
        public long? cart_Id { get; set; }
        public string payment_Status { get; set; }
        public string payment_Provider { get; set; }
        public string payment_Ref { get; set; }
        public DateTime? paid_At { get; set; }
    }
}
