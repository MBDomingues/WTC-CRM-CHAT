using WtcCrm.Domain.Entities;

namespace WtcCrm.Domain.Interfaces
{
    public interface ISegmentRepository
    {
        Task<IEnumerable<Segment>> GetAllAsync();
        Task<Segment?> GetByIdAsync(Guid id);
        Task AddAsync(Segment segment);
        Task UpdateAsync(Segment segment);
        Task DeleteAsync(Guid id);
    }
}