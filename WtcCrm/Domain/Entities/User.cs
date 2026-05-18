using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace WtcCrm.Domain.Entities
{
    public enum UserRole
    {
        User = 1,
        Admin = 2,
        Customer = 3,
        Operator = 4,
    }

    public class User
    {
        [BsonId]
        public Guid Id { get; set; }

        [BsonElement("name")] 
        public string Name { get; set; } = string.Empty;

        [BsonElement("email")]
        public string Email { get; set; } = string.Empty;

        [BsonElement("documentId")]
        public string DocumentId { get; set; } = string.Empty;

        [BsonElement("passwordHash")]
        public string PasswordHash { get; set; } = string.Empty;

        [BsonElement("role")]
        [BsonRepresentation(BsonType.String)]
        public UserRole Role { get; set; } = UserRole.User;

        [BsonElement("createdAt")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [BsonElement("profileImageKey")]
        public string? ProfileImageKey { get; set; }

        [BsonElement("isActive")]
        public bool IsActive { get; set; } = true;

        [BsonElement("score")]
        public int Score { get; set; } = 0;

        [BsonElement("status")]
        public string Status { get; set; } = "Lead"; 

        [BsonElement("segmentId")]
        [BsonRepresentation(BsonType.String)]
        public string? SegmentId { get; set; }
    }
}