using Microsoft.EntityFrameworkCore;
using WtcCrm.Domain.Entities;
using WtcCrm.Domain.Interfaces;
using WtcCrm.Infrastructure.Data;

namespace WtcCrm.Infrastructure.Repositories
{
    public class ChatGroupRepository(AppDbContext _context) : IChatGroupRepository
    {
        public async Task CreateAsync(ChatGroup group)
        {
            await _context.ChatGroups.AddAsync(group);
            await _context.SaveChangesAsync();
        }

        public async Task<ChatGroup?> GetByIdAsync(string id)
        {
            return await _context.ChatGroups.FirstOrDefaultAsync(a => a.Id == id);
        }

        public async Task<IEnumerable<ChatGroup>> GetGroupsByUserIdAsync(string userId)
        {
            return await _context.ChatGroups
                .Where(a => a.MemberIds.Contains(userId))
                .ToListAsync();
        }

        public async Task UpdateAsync(ChatGroup group)
        {
            _context.ChatGroups.Update(group);
            await _context.SaveChangesAsync();
        }
    }
}