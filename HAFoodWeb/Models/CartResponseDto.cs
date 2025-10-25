using HAFoodWeb.Models;
using System.Collections.Generic;

public class CartResponseDto
{
    public CartHeaderDto header { get; set; }
    public List<CartItemDto> items { get; set; }
}