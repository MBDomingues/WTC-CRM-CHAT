using MongoDB.Bson.Serialization.Attributes;

namespace WtcCrm.Domain.Entities
{
    public class AuditLog
    {
        [BsonId]
        public Guid Id { get; set; } = Guid.NewGuid();
        
        [BsonElement("userEmail")]
        public string UserEmail { get; set; } = "Anonymous";

        [BsonElement("action")]
        public string Action { get; set; } = string.Empty;

        [BsonElement("statusCode")]
        public int StatusCode { get; set; }

        [BsonElement("timestamp")]
        public DateTime Timestamp { get; set; } = DateTime.UtcNow;

        [BsonElement("ipAddress")]
        public string IpAddress { get; set; } = string.Empty;

        [BsonElement("requestBody")]
        public string? RequestBody { get; set; }

        [BsonElement("exceptionMessage")]
        public string? ExceptionMessage { get; set; }

        [BsonElement("responseBody")]
        public string? ResponseBody { get; set; }

        [BsonElement("stackTrace")]
        public string? StackTrace { get; set; }
    }
}