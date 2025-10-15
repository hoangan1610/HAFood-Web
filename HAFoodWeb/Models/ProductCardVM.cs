using System.Collections.Generic;

namespace HAFoodWeb.Models
{
    // ViewModel cho thẻ sản phẩm
    public class ProductCardVM
    {
        public long Id { get; set; }
        public string Name { get; set; }
        public string ImageUrl { get; set; }

        // Giá min/max để dùng nếu cần
        public decimal MinRetail { get; set; }
        public decimal MaxRetail { get; set; }

        // HTML đã format sẵn để bind
        public string PriceRangeHtml { get; set; }
        public string DiscountBadgeHtml { get; set; }

        // Dropdown biến thể
        public IList<VariantOptionVM> Variants { get; set; }
    }

    public class VariantOptionVM
    {
        public long Id { get; set; }
        public string Label { get; set; } // "500g (42.000đ)"
    }
}
