using WtcCrm.Domain.Entities;

namespace WtcCrm.Domain.Interfaces
{
    public interface IAnnouncementRepository
    {
        Task CreateAnnouncementAsync(Announcement announcement);
        Task<Announcement?> GetByIdAsync(string id);
        Task<IEnumerable<Announcement>> GetAnnouncementsByIdsAsync(IEnumerable<string> ids, int page, int pageSize);
        Task<IEnumerable<Announcement>> GetAllAnnouncementsAsync(int page, int pageSize);
    }
}