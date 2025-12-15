using System;
using System.Collections.Generic;

namespace HAFoodWeb.Models
{
    public sealed class ArticleListResponseDto
    {
        public int page { get; set; }
        public int pageSize { get; set; }
        public int total { get; set; }
        public List<ArticleListItemDto> items { get; set; } = new List<ArticleListItemDto>();
    }

    public sealed class ArticleListItemDto
    {
        public long id { get; set; }
        public string title { get; set; } = "";
        public string slug { get; set; } = "";
        public string excerpt { get; set; }
        public string cover_Image_Url { get; set; }
        public DateTime? published_At_Utc { get; set; }
    }

    public sealed class ArticlePublicDto
    {
        public long id { get; set; }
        public string title { get; set; } = "";
        public string slug { get; set; } = "";
        public string excerpt { get; set; }
        public string cover_Image_Url { get; set; }

        // ✅ mới: nhận HTML từ API
        public string content_Html { get; set; }

        public string content_Json { get; set; } = "{\"time\":0,\"blocks\":[],\"version\":\"2\"}";
        public DateTime? published_At_Utc { get; set; }
        public List<ArticleCardDto> cards { get; set; } = new List<ArticleCardDto>();
    }


    public sealed class ArticleCardDto
    {
        public int sort_Order { get; set; }
        public long product_Id { get; set; }
        public string product_Name { get; set; } = "";
        public string product_Image { get; set; }
        public long? variant_Id { get; set; }
        public string variant_Name { get; set; }
        public decimal? retail_Price { get; set; }
        public int? stock { get; set; }
    }
}
