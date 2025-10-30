using System.Collections.Generic;

namespace HAFoodWeb.Models
{
    public class OrderPageDto
    {
        public List<OrderHeaderDto> items { get; set; } = new List<OrderHeaderDto>();
        public int totalCount { get; set; }
        public int page { get; set; }
        public int pageSize { get; set; }
    }
}
