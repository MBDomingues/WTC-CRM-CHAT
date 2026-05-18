using Microsoft.EntityFrameworkCore;
using WtcCrm.Domain.Entities;
using WtcCrm.Domain.Interfaces;
using WtcCrm.Infrastructure.Data;

namespace WtcCrm.Infrastructure.Repositories
{
    public class CustomerNoteRepository(AppDbContext _context) : ICustomerNoteRepository
    {
        public async Task CreateNoteAsync(CustomerNote note)
        {
            await _context.CustomerNotes.AddAsync(note);
            await _context.SaveChangesAsync();
        }

        public async Task<IEnumerable<CustomerNote>> GetNotesByCustomerIdAsync(string customerId)
        {
            return await _context.CustomerNotes
                .Where(a => a.CustomerId == customerId)
                .OrderByDescending(a => a.CreatedAt)
                .ToListAsync();
        }

        public async Task<CustomerNote?> GetNoteByIdAsync(string noteId)
        {
            return await _context.CustomerNotes.FirstOrDefaultAsync(a => a.Id == noteId);
        }

        public async Task UpdateNoteAsync(CustomerNote note)
        {
            _context.CustomerNotes.Update(note);
            await _context.SaveChangesAsync();
        }

        public async Task DeleteNoteAsync(string noteId)
        {
            var note = await GetNoteByIdAsync(noteId);
            if (note != null)
            {
                note.IsDeleted = true;
                note.UpdatedAt = DateTime.UtcNow;
                _context.CustomerNotes.Update(note);
                await _context.SaveChangesAsync();
            }
        }
    }
}