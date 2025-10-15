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
    }
}
