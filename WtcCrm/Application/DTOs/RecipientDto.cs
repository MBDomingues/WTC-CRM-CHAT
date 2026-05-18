namespace WtcCrm.Application.DTOs
{
    public record RecipientListResponse(
        string Id, 
        string Name, 
        string? ImageUrl, 
        bool IsGroup,
        string? SegmentId
    );
}