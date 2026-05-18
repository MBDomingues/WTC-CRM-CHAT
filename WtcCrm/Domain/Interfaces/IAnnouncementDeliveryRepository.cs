using WtcCrm.Domain.Entities;

namespace WtcCrm.Domain.Interfaces
{
    public interface IAnnouncementDeliveryRepository
    {
        Task CreateDeliveriesAsync(IEnumerable<AnnouncementDelivery> deliveries);
        Task<IEnumerable<string>> GetMyAnnouncementIdsAsync(string userId);
        
    }
}