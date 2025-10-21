using System.Collections.Generic;


namespace HAFoodWeb.Models
{
    public class CartResponseDto
    {
        public CartHeaderDto header { get; set; }
        public List<CartItemDto> items { get; set; }
    }
}