using Microsoft.EntityFrameworkCore;
using WtcCrm.Domain.Entities;
using WtcCrm.Domain.Interfaces;
using WtcCrm.Infrastructure.Data;


namespace WtcCrm.Infrastructure.Repositories
{
    public class SegmentRepository(AppDbContext _context) : ISegmentRepository
    {
        public async Task<IEnumerable<Segment>> GetAllAsync() 
            => await _context.Segments
                .AsNoTracking()
                .Where(a => !a.IsDeleted)
                .OrderBy(a => a.Name)
                .ToListAsync();

        public async Task<Segment?> GetByIdAsync(Guid id) 
            => await _context.Segments
                .AsNoTracking()
                .FirstOrDefaultAsync(a => a.Id == id && !a.IsDeleted);

        public async Task AddAsync(Segment segment)
        {
            await _context.Segments.AddAsync(segment);
            await _context.SaveChangesAsync();
        }

        public async Task UpdateAsync(Segment segment)
        {
            _context.Segments.Update(segment);
            segment.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();
        }

        public async Task DeleteAsync(Guid id)
        {
            var segment = await GetByIdAsync(id);
            if (segment != null)
            {
                segment.IsDeleted = true;
                segment.UpdatedAt = DateTime.UtcNow;
                _context.Segments.Update(segment);
                await _context.SaveChangesAsync();
            }
        }
    }
}