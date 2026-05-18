using WtcCrm.Domain.Entities;

namespace WtcCrm.Domain.Interfaces
{
    public interface IChatGroupRepository
    {
        Task CreateAsync(ChatGroup group);
        Task<ChatGroup?> GetByIdAsync(string id);
        Task<IEnumerable<ChatGroup>> GetGroupsByUserIdAsync(string userId);
        Task UpdateAsync(ChatGroup group);
    }
}