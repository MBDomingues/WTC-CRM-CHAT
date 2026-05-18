namespace WtcCrm.Application.DTOs
{
    public record RegisterRequest(
        string Email, 
        string DocumentId, 
        string Password, 
        string ConfirmPassword, 
        string Name = "Usuário App");
    
    public record LoginRequest(string Email, string Password);
    public record AuthResponse(string Id, string Token, string Name, string Role, string? ImageUrl = null);
    public record UpdatePhotoResponse(string ImageUrl);

    public record UserCaracteristicsResponse(string Id,string Role);
}
