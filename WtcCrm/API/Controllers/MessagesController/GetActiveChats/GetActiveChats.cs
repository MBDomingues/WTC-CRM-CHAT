using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WtcCrm.API.Controllers.Handlers;
using WtcCrm.Application.DTOs;
using WtcCrm.Application.Wrappers;
using WtcCrm.Domain.Interfaces;
using Domain.Interfaces;
using WtcCrm.Domain.Entities;

namespace WtcCrm.API.Controllers.BaseMessagesController
{
    public partial class MessagesController
    {
        [HttpGet("chats")]
        [Authorize]
        public async Task<IActionResult> GetActiveChats([FromServices] GetActiveChatsHandler handler)
        {
            var response = await handler.HandleAsync();
            if (!response.IsSuccess) return BadRequest(response);
            return Ok(response);
        }
    }
}

namespace WtcCrm.API.Controllers.Handlers
{
    public class GetActiveChatsHandler(
        IHttpContextAccessor httpContextAccessor,
        IChatRepository chatRepository,
        IUserRepository userRepository,
        IChatGroupRepository groupRepository,
        IStorageService storageService
    ) : BaseHandler(httpContextAccessor)
    {
        public async Task<BaseResponse<IEnumerable<ChatListResponse>>> HandleAsync()
        {
            try
            {
                var myUserId = await GetUserIdAsync();
                var mixedChats = new List<(ChatListResponse Response, DateTime SortDate)>();

                var allMyMessages = await chatRepository.GetMyChatHistoryAsync(myUserId);
                var privateMessages = allMyMessages.Where(a => string.IsNullOrEmpty(a.GroupId)).ToList();

                var latestPrivateMessages = privateMessages
                    .GroupBy(a => a.SenderId == myUserId ? a.ReceiverId : a.SenderId)
                    .Select(a => a.OrderByDescending(b => b.CreatedAt).First())
                    .ToList();

                foreach (var msg in latestPrivateMessages)
                {
                    var otherUserId = msg.SenderId == myUserId ? msg.ReceiverId : msg.SenderId;
                    if (string.IsNullOrEmpty(otherUserId)) continue;

                    var otherUser = await userRepository.GetByIdAsync(otherUserId);
                    if (otherUser != null)
                    {
                        var chatItem = BuildChatListResponse(
                            otherUserId, otherUser.Name, msg.Text, msg.CreatedAt, 
                            otherUser.ProfileImageKey, msg.Status, msg.ReadBy, myUserId, msg.SenderId == myUserId, false);
                        
                        mixedChats.Add((chatItem, msg.CreatedAt));
                    }
                }

                var myGroups = await groupRepository.GetGroupsByUserIdAsync(myUserId);
                foreach (var group in myGroups)
                {
                    var lastGroupMsg = await chatRepository.GetLastMessageByGroupIdAsync(group.Id);
                    
                    var lastMsgText = lastGroupMsg != null ? lastGroupMsg.Text : "Grupo criado";
                    var sortDate = lastGroupMsg != null ? lastGroupMsg.CreatedAt : group.CreatedAt;
                    var status = lastGroupMsg != null ? lastGroupMsg.Status : MessageStatus.Read;
                    var isSentByMe = lastGroupMsg != null && lastGroupMsg.SenderId == myUserId;
                    var readBy = lastGroupMsg?.ReadBy ?? new List<string>();

                    var groupItem = BuildChatListResponse(
                            group.Id, group.Name, lastMsgText, sortDate, 
                            group.ImageKey, status, readBy, myUserId, isSentByMe, true);

                    mixedChats.Add((groupItem, sortDate));
                }

                var orderedList = mixedChats
                    .OrderByDescending(a => a.SortDate)
                    .Select(a => a.Response)
                    .ToList();

                return BaseResponse<IEnumerable<ChatListResponse>>.Success(orderedList);
            }
            catch (Exception ex)
            {
                return BaseResponse<IEnumerable<ChatListResponse>>.Error($"Erro ao carregar: {ex.Message}");
            }
        }

        private ChatListResponse BuildChatListResponse(
            string id, string name, string text, DateTime date, 
            string? imageKey, MessageStatus status, List<string>? readBy, string myUserId, bool isSentByMe, bool isGroup)
        {
            var picUrl = string.IsNullOrEmpty(imageKey) 
                ? null : storageService.GetPresignedUrl(imageKey);

            bool isRead = isSentByMe || 
                        (status == MessageStatus.Read) || 
                        (readBy != null && readBy.Contains(myUserId));
            
            return new ChatListResponse(
                Id: id,
                SenderName: name,
                LastMessage: text,
                Timestamp: date.ToLocalTime().ToString("HH:mm"),
                ProfilePicUrl: picUrl,
                IsRead: isRead,
                IsGroup: isGroup,
                LastMessageStatus: status.ToString(),
                IsLastMessageMine: isSentByMe
            );
        }
    }
}