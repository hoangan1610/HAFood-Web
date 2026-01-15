using Newtonsoft.Json;
using System.Collections.Generic;

namespace HAFoodWeb.Models
{
    public class OrdersPageDto
    {
        [JsonProperty("items")]
        public List<OrderHeaderDto> items { get; set; } = new List<OrderHeaderDto>();

        [JsonProperty("total")]
        public int total { get; set; }

        [JsonProperty("page")]
        public int page { get; set; }

        [JsonProperty("page_size")]
        public int page_size { get; set; }

        public OrdersPageDto() { }
    }
}
