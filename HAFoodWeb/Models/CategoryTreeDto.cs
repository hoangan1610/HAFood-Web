namespace HAFoodWeb.Models
{
    public class CategoryTreeDto
    {
        public long Id { get; set; }
        public long? Parent_Id { get; set; }
        public string Name { get; set; }
        public string Path { get; set; }
        public int Level { get; set; }
        public string Image_Url { get; set; }
        public string Tag { get; set; }
        public string Category_Code { get; set; }
        public string Description { get; set; }
        public byte? Status { get; set; }
        public int? Sort_Order { get; set; }
    }
}
