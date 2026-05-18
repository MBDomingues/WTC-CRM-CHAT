using WtcCrm.Domain.Entities;

namespace WtcCrm.Domain.Interfaces
{
    public interface IUserRepository
    {
        Task<User?> GetByEmailAsync(string email); 
        Task AddAsync(User user);
        Task UpdateAsync(User user);
        Task<User?> GetByDocumentIdAsync(string documentId);
        Task UpdateUserImageAsync(String userId, string imageKey);
        Task<IEnumerable<User>> SearchUsersByRoleAsync(string role, string? search);
        Task<User?> GetByIdAsync(string userId);
        Task<IEnumerable<User>> GetAllActiveUsersAsync();
        Task<IEnumerable<User>> GetUsersByIdsAsync(IEnumerable<string> userIds);
        Task<IEnumerable<User>> SearchCustomersAsync(string? query, string? status, int page, int pageSize);
    } 
}
