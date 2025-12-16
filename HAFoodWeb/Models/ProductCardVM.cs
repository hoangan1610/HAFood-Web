using System.Collections.Generic;

namespace HAFoodWeb.Models
{
    // ViewModel cho thẻ sản phẩm
    public class ProductCardVM
    {
        public long Id { get; set; }
        public string Name { get; set; }
        public string ImageUrl { get; set; }

        public decimal MinRetail { get; set; }
        public decimal MaxRetail { get; set; }

        public string PriceRangeHtml { get; set; }
        public string DiscountBadgeHtml { get; set; }

        public int TotalStock { get; set; }          // ✅ NEW
        public long DefaultVariantId { get; set; }   // ✅ NEW

        public IList<VariantOptionVM> Variants { get; set; }
    }

    public class VariantOptionVM
    {
        public long Id { get; set; }
        public string Label { get; set; }   // "Chai 500ml (45.000đ)"

        public string Name { get; set; }    // ✅ NEW
        public decimal Price { get; set; }  // ✅ NEW
        public string Image { get; set; }   // ✅ NEW (có thể rỗng)
    }

}
