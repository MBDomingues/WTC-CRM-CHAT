using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace WtcCrm.Domain.Entities
{
    public enum MessageStatus
{
    Sent = 1,
    Delivered = 2,
    Read = 3,
    Failed = 4
}

    public class ChatMessage
    {
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        public string Id { get; set; } = ObjectId.GenerateNewId().ToString();

        [BsonElement("SenderId")]
        public string SenderId { get; set; } = string.Empty;
        
        [BsonElement("ReceiverId")]
        public string? ReceiverId { get; set; } 
        
        [BsonElement("GroupId")]
        public string? GroupId { get; set; }
        
        [BsonElement("Text")]
        public string Text { get; set; } = string.Empty;
        
        [BsonElement("Url")]
        public string? Url { get; set; }

        [BsonElement("CreatedAt")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [BsonElement("Title")]
        public string? Title { get; set; }

        [BsonElement("AnnouncementId")]
        public string? AnnouncementId { get; set; }

        [BsonElement("Status")]
        [BsonRepresentation(BsonType.String)]
        public MessageStatus Status { get; set; } = MessageStatus.Sent;

        [BsonElement("ReadBy")]
        public List<string>? ReadBy { get; set; } = new List<string>();
    }
}