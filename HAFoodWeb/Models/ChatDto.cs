namespace HAFoodWeb.Models
{
    public class AskRequest
    {
        public string message { get; set; }
    }

    // Phản hồi từ ChatService (đã normalize)
    public class ChatAskResponse : ApiBaseResponse
    {
        public string Reply { get; set; }
        public string RawBody { get; set; }
    }

    // Phản hồi upload ảnh (đã normalize)
    public class FilesImageUploadResponse : ApiBaseResponse
    {
        public string Url { get; set; }
        public string UrlW { get; set; }
        public string UrlT { get; set; }
        public string UrlP { get; set; }

        public string RawBody { get; set; }
    }
}
