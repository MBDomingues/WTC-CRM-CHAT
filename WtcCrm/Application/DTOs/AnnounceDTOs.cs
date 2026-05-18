namespace WtcCrm.Application.DTOs
{
    public record AnnouncementListResponse(
        string Id,
        string Title,
        string Description,
        string Date,
        string Location,
        string? ImageUrl,
        DateTime CreatedAt
    );
}