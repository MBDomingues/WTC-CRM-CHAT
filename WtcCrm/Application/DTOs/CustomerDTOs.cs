namespace WtcCrm.Application.DTOs
{
    public record ClientListResponse(
        string Id, 
        string Name, 
        string? ImageUrl);

    public record UpdateNoteRequest(
        string Text, 
        bool IsTask, 
        bool IsResolved);
}