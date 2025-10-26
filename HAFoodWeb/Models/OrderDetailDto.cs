using System.Collections.Generic;

namespace HAFoodWeb.Models
{
    public class OrderDetailDto
    {
        public OrderHeaderDto header { get; set; }
        public List<OrderItemDto> items { get; set; }
    }
}
