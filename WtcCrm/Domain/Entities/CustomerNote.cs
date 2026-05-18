using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace WtcCrm.Domain.Entities
{
    public class CustomerNote
    {
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        public string Id { get; set; } = ObjectId.GenerateNewId().ToString();

        [BsonElement("CustomerId")]
        public string CustomerId { get; set; } = string.Empty;

        [BsonElement("OperatorId")]
        public string OperatorId { get; set; } = string.Empty;

        [BsonElement("Text")]
        public string Text { get; set; } = string.Empty;

        [BsonElement("IsTask")]
        public bool IsTask { get; set; } = false;

        [BsonElement("IsResolved")]
        public bool IsResolved { get; set; } = false;

        [BsonElement("CreatedAt")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [BsonElement("UpdatedAt")]
        public DateTime? UpdatedAt { get; set; }
        
        [BsonElement("IsDeleted")]
        public bool? IsDeleted { get; set; } = false;
    
    }
}