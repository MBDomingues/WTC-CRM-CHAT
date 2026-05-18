namespace WtcCrm.Application.DTOs
{
    public record CreateSegmentRequest(
        string Name, 
        string Description);
    public record UpdateSegmentRequest(
        string Name, 
        string Description);
}