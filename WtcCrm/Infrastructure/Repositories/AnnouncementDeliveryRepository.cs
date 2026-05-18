using Microsoft.EntityFrameworkCore;
using WtcCrm.Domain.Entities;
using WtcCrm.Domain.Interfaces;
using WtcCrm.Infrastructure.Data;

namespace WtcCrm.Infrastructure.Repositories
{
    public class AnnouncementDeliveryRepository(AppDbContext _context) : IAnnouncementDeliveryRepository
    {
        public async Task CreateDeliveriesAsync(IEnumerable<AnnouncementDelivery> deliveries)
        {
            if (deliveries.Any())
            {
                await _context.AnnouncementDeliveries.AddRangeAsync(deliveries);
                await _context.SaveChangesAsync();
            }
        }

        public async Task<IEnumerable<string>> GetMyAnnouncementIdsAsync(string userId)
        {
            return await _context.AnnouncementDeliveries
                .Where(a => a.UserId == userId)
                .Select(a => a.AnnouncementId)
                .Distinct()
                .ToListAsync();
        }
    }
}