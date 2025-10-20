using System.Collections.Generic;
using HAFoodWeb.Models;

namespace HAFoodWeb.Models
{
    public class CartResponseDto
    {
        public CartHeaderDto header { get; set; }
        public List<CartItemDto> items { get; set; }
    }
}