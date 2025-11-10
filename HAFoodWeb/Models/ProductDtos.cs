using System;
using System.Collections.Generic;

namespace HAFoodWeb.Models
{


    // /api/products (list)
    public class ProductListItemDto
    {
        public long Product_Id { get; set; }
        public string Product_Name { get; set; }
        public string Brand_Name { get; set; }
        public long Category_Id { get; set; }
        public string Category_Name { get; set; }
        public byte Status { get; set; }
        public bool Is_Deleted { get; set; }
        public DateTime Created_At { get; set; }
        public DateTime Updated_At { get; set; }
        public int Total_Stock { get; set; }
        public decimal Min_Retail_Price { get; set; }
        public decimal Max_Retail_Price { get; set; }
        public int Has_Variants { get; set; }
    }

    public class PagedResult<T>
    {
        public IList<T> Items { get; set; }
        public int TotalCount { get; set; }
        public int Page { get; set; }
        public int PageSize { get; set; }
    }

    // /api/products/{id}
    public class VariantDto
    {
        public long Id { get; set; }
        public string Sku { get; set; }
        public string Name { get; set; }
        public string Image { get; set; }
        public string Meta_Data { get; set; }
        public int? Weight { get; set; }
        public decimal Cost_Price { get; set; }
        public decimal Finished_Cost { get; set; }
        public decimal Wholesale_Price { get; set; }
        public decimal Retail_Price { get; set; }
        public int Stock { get; set; }
        public byte Status { get; set; }
        public DateTime Created_At { get; set; }
        public DateTime Updated_At { get; set; }
    }

    public class ProductDetailDto
    {
        public long Id { get; set; }
        public long Category_Id { get; set; }
        public string Brand_Name { get; set; }
        public string Name { get; set; }
        public string Tag { get; set; }
        public string Product_Keyword { get; set; }
        public string Detail { get; set; }
        public string Image_Product { get; set; }
        public string Expiry { get; set; }
        public byte Status { get; set; }
        public DateTime Created_At { get; set; }
        public DateTime Updated_At { get; set; }
        public IList<VariantDto> Variants { get; set; }

        public ProductDetailDto()
        {
            Variants = new List<VariantDto>();
            Brand_Name = string.Empty;
            Name = string.Empty;
            Tag = string.Empty;
            Product_Keyword = string.Empty;
            Detail = string.Empty;
            Image_Product = string.Empty;
            Expiry = string.Empty;
        }
    }

    // C# 7.3 friendly type for weight ranges
    public class WeightRange
    {
        public int From { get; set; }
        public int? To { get; set; }
    }

    public sealed class ProductSearchRequest
    {
        public string Query { get; set; }
        public long? CategoryId { get; set; }
        public string Brand { get; set; }
        public double? MinPrice { get; set; }
        public double? MaxPrice { get; set; }
        public bool OnlyInStock { get; set; }
        public string Sort { get; set; }
        public int Page { get; set; }
        public int PageSize { get; set; }
        public int? Status { get; set; }

        // NEW: danh sách khoảng trọng lượng (gram). To = null nghĩa là open-ended.
        public List<WeightRange> WeightRanges { get; set; }

        public ProductSearchRequest()
        {
            Query = string.Empty;
            Brand = string.Empty;
            Sort = "updated_at:desc";
            Page = 1;
            PageSize = 20;
            WeightRanges = new List<WeightRange>();
        }
    }
}
