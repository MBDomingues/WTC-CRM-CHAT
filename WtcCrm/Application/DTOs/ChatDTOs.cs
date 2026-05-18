using System.Text.Json.Serialization;
using WtcCrm.Domain.Entities;

namespace WtcCrm.Application.DTOs
{
    public record SendMessageRequest(string Text);

    public record MessageResponse(
        string Id,
        string Text,
        string Timestamp,
        bool IsSentByMe,
        string? Title = null,
        string? Url = null,
        string? SenderName = null,
        string? SenderPhotoUrl = null,
        string? Status = null,
        bool IsReadByMe = false
    );

    public record ChatListResponse(
        string Id,
        string SenderName,
        string LastMessage,
        string Timestamp,
        string? ProfilePicUrl,
        bool IsRead,
        bool IsGroup,
        string LastMessageStatus,
        bool IsLastMessageMine
    );

    public record UpdateMessageStatusRequest(
        [property: JsonConverter(typeof(JsonStringEnumConverter))]
        MessageStatus Status);
}