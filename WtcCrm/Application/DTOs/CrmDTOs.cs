namespace WtcCrm.Application.DTOs
{
    public record CustomerListResponse(
        string Id,
        string Name,
        string Email,
        string? PhotoUrl,
        int Score,
        string Status
    );

    public record AddNoteRequest(
        string Text,
        bool IsTask
    );

    public record UpdateCrmRequest(
        int Score, 
        string Status,
        string? SegmentId);

    public record Profile360Response(
        string Id,
        string Name,
        string Email,
        string Phone,
        string? PhotoUrl,
        string Status,
        int Score,
        string? SegmentId,
        List<NoteSnapshot> NotesAndTasks,
        List<MessageSnapshot> RecentMessages,
        List<CampaignSnapshot> RecentCampaigns
    );

    public record NoteSnapshot(
        string Id,
        string Text,
        string OperatorName,
        DateTime CreatedAt,
        bool IsTask,
        bool IsResolved
    );

    public record MessageSnapshot(
        string Id,
        string Text,
        bool IsFromOperator,
        DateTime CreatedAt
    );

    public record CampaignSnapshot(
        string AnnouncementId,
        string Title,
        DateTime DeliveredAt
    );
}