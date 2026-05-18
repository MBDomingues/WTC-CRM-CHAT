using WtcCrm.Domain.Entities;

namespace WtcCrm.Domain.Interfaces
{
    public interface IChatRepository
    {
        Task<IEnumerable<ChatMessage>> GetChatHistoryAsync(string userId1, string userId2);
        Task SaveMessageAsync(ChatMessage message);
        Task<ChatMessage?> GetLastMessageByGroupIdAsync(string groupId);
        Task<IEnumerable<ChatMessage>> GetMyChatHistoryAsync(string userId);
        Task<IEnumerable<ChatMessage>> GetGroupChatHistoryAsync(string groupId);
        Task<IEnumerable<ChatMessage>> GetRecentMessagesAsync(string userId, int limit);
        Task<List<ChatMessage>> GetUnreadGroupMessagesAsync(string groupId, string myUserId);
        Task<List<ChatMessage>> GetUnreadPrivateMessagesAsync(string senderId, string receiverId, MessageStatus status);
        Task UpdateMessagesAsync(IEnumerable<ChatMessage> messages);
    }
}