using System.Collections.Generic;

namespace HAFoodWeb.Models
{
    public class OrderPageDto
    {
        public List<OrderHeaderDto> items { get; set; }
        public int totalCount { get; set; }
        public int page { get; set; }
        public int pageSize { get; set; }
    }
}
