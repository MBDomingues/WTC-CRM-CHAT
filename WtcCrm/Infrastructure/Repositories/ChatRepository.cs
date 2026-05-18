using Microsoft.EntityFrameworkCore;
using WtcCrm.Domain.Entities;
using WtcCrm.Domain.Interfaces;
using WtcCrm.Infrastructure.Data;

namespace WtcCrm.Infrastructure.Repositories
{
    public class ChatRepository(AppDbContext _context) : IChatRepository
    {
        public async Task<IEnumerable<ChatMessage>> GetChatHistoryAsync(string userId1, string userId2)
        {
            return await _context.ChatMessages
                .Where(a => (a.SenderId == userId1 && a.ReceiverId == userId2) ||
                            (a.SenderId == userId2 && a.ReceiverId == userId1))
                .OrderBy(a => a.CreatedAt)
                .ToListAsync();
        }

        public async Task SaveMessageAsync(ChatMessage message)
        {
            await _context.ChatMessages.AddAsync(message);
            await _context.SaveChangesAsync();
        }

        public async Task<IEnumerable<ChatMessage>> GetMyChatHistoryAsync(string userId)
        {
            return await _context.ChatMessages
                .Where(a => a.SenderId == userId || a.ReceiverId == userId)
                .OrderByDescending(a => a.CreatedAt)
                .ToListAsync();
        }

        public async Task<ChatMessage?> GetLastMessageByGroupIdAsync(string groupId)
        {
            return await _context.ChatMessages
                .Where(a => a.GroupId == groupId)
                .OrderByDescending(a => a.CreatedAt)
                .FirstOrDefaultAsync();
        }

        public async Task<IEnumerable<ChatMessage>> GetGroupChatHistoryAsync(string groupId)
        {
            return await _context.ChatMessages
                .Where(a => a.GroupId == groupId)
                .OrderBy(a => a.CreatedAt)
                .ToListAsync();
        }

        public async Task<IEnumerable<ChatMessage>> GetRecentMessagesAsync(string userId, int limit)
        {
            return await _context.ChatMessages
                .Where(a => a.SenderId == userId || a.ReceiverId == userId)
                .OrderByDescending(a => a.CreatedAt)
                .Take(limit)
                .ToListAsync();
        }

        public async Task<List<ChatMessage>> GetUnreadGroupMessagesAsync(string groupId, string myUserId)
        {
            return await _context.ChatMessages
                .Where(a => a.GroupId == groupId && a.SenderId != myUserId)
                .Where(a => !a.ReadBy.Contains(myUserId))
                .ToListAsync();
        }

        public async Task<List<ChatMessage>> GetUnreadPrivateMessagesAsync(string senderId, string receiverId, MessageStatus status)
        {
            return await _context.ChatMessages
                .Where(a => a.SenderId == senderId && a.ReceiverId == receiverId)
                .Where(a => a.Status != status)
                .ToListAsync();
        }

        public async Task UpdateMessagesAsync(IEnumerable<ChatMessage> messages)
        {
            _context.ChatMessages.UpdateRange(messages);
            await _context.SaveChangesAsync();
        }
    }
}