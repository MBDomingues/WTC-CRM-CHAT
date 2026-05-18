using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace WtcCrm.Domain.Entities
{
    public class ChatGroup
    {
        [BsonId]
        [BsonRepresentation(BsonType.String)]
        public string Id { get; set; } = Guid.NewGuid().ToString();

        [BsonElement("Name")]
        public string Name { get; set; } = string.Empty;

        [BsonElement("Description")]
        public string? Description { get; set; }

        [BsonElement("ImageKey")]
        public string? ImageKey { get; set; }

        [BsonElement("CreatedBy")]
        public string CreatedBy { get; set; } = string.Empty;

        [BsonElement("MemberIds")]
        public List<string> MemberIds { get; set; } = new();

        [BsonElement("CreatedAt")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [BsonElement("IsActive")]
        public bool IsActive { get; set; } = true;
    }
}