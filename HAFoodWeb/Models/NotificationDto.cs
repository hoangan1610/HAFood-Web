using System;
using System.Collections.Generic;

namespace HAFoodWeb.Models
{
    public class NotificationDto
    {
        public long id { get; set; }
        public int type { get; set; }
        public int channel { get; set; }
        public string title { get; set; }
        public string body { get; set; }
        public string data { get; set; }          
        public int status { get; set; }
        public DateTime? deliveredAt { get; set; }
        public DateTime? readAt { get; set; }
        public DateTime createdAt { get; set; }
        public bool isRead { get; set; }
    }

    public class NotificationLatestResultDto
    {
        public List<NotificationDto> items { get; set; }
        public int totalUnread { get; set; }
    }

    public class NotificationLatestResultDtoApiOkResponse
    {
        public bool success { get; set; }
        public NotificationLatestResultDto data { get; set; }
        public string message { get; set; }
    }

    public class NotificationPagedResultDto
    {
        public int page { get; set; }
        public int pageSize { get; set; }
        public int totalRows { get; set; }
        public int totalUnread { get; set; }
        public List<NotificationDto> items { get; set; }
    }

    public class NotificationPagedResultDtoApiOkResponse
    {
        public bool success { get; set; }
        public NotificationPagedResultDto data { get; set; }
        public string message { get; set; }
    }
}
