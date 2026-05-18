using Microsoft.EntityFrameworkCore;
using WtcCrm.Domain.Entities;
using WtcCrm.Domain.Interfaces;
using WtcCrm.Infrastructure.Data;

namespace WtcCrm.Infrastructure.Repositories
{
    public class AnnouncementRepository(AppDbContext _context) : IAnnouncementRepository
    {
        public async Task CreateAnnouncementAsync(Announcement announcement)
        {
            await _context.Announcements.AddAsync(announcement);
            await _context.SaveChangesAsync();
        }

        public async Task<Announcement?> GetByIdAsync(string id)
        {
            return await _context.Announcements.FirstOrDefaultAsync(a => a.Id == id);
        }

        public async Task<IEnumerable<Announcement>> GetAllAnnouncementsAsync(int page, int pageSize)
        {
            int skip = (page - 1) * pageSize;

            return await _context.Announcements
                .OrderByDescending(a => a.CreatedAt)
                .Skip(skip)
                .Take(pageSize)
                .ToListAsync();
        }

        public async Task<IEnumerable<Announcement>> GetAnnouncementsByIdsAsync(IEnumerable<string> ids, int page, int pageSize)
        {
            if (!ids.Any()) return new List<Announcement>();

            int skip = (page - 1) * pageSize;
            
            return await _context.Announcements
                .Where(a => ids.Contains(a.Id))
                .OrderByDescending(a => a.CreatedAt)
                .Skip(skip)
                .Take(pageSize)
                .ToListAsync();
        }
    }
}