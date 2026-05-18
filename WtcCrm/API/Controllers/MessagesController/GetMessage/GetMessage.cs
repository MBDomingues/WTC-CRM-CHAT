using Domain.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WtcCrm.API.Controllers.Handlers;
using WtcCrm.Application.DTOs;
using WtcCrm.Application.Wrappers;
using WtcCrm.Domain.Entities;
using WtcCrm.Domain.Interfaces;

namespace WtcCrm.API.Controllers.BaseMessagesController
{
    public partial class MessagesController
    {
        [HttpGet("{participantId}")]
        [Authorize]
        public async Task<IActionResult> GetMessages(
            [FromRoute] string participantId, 
            [FromServices] GetChatMessagesHandler handler)
        {
            var response = await handler.HandleAsync(participantId);
            if (!response.IsSuccess) return BadRequest(response);
            return Ok(response);
        }
    }
}

namespace WtcCrm.API.Controllers.Handlers
{
    public class GetChatMessagesHandler(
        IHttpContextAccessor httpContextAccessor, 
        IChatRepository chatRepository,
        IUserRepository userRepository,
        IChatGroupRepository groupRepository,
        IStorageService storageService
    ) : BaseHandler(httpContextAccessor)
    {
       public async Task<BaseResponse<IEnumerable<MessageResponse>>> HandleAsync(string participantOrGroupId)
        {
            try
            {
                var myUserId = await GetUserIdAsync();
                IEnumerable<ChatMessage> messages;

                var targetGroup = await groupRepository.GetByIdAsync(participantOrGroupId);
                bool isGroup = targetGroup != null;

                messages = isGroup
                    ? await chatRepository.GetGroupChatHistoryAsync(participantOrGroupId)
                    : await chatRepository.GetChatHistoryAsync(myUserId, participantOrGroupId);

                var usersMap = new Dictionary<string, User>(); 

                if (isGroup && messages.Any())
                {
                    var uniqueSenderIds = messages.Select(a => a.SenderId).Where(b => b != myUserId).Distinct().ToList();
                    if (uniqueSenderIds.Any())
                    {
                        var senders = await userRepository.GetUsersByIdsAsync(uniqueSenderIds);
                        usersMap = senders.ToDictionary(a => a.Id.ToString(), a => a);
                    }
                }

                var response = messages.Select(a => 
                    BuildMessageResponse(a, myUserId, isGroup, usersMap));

                return BaseResponse<IEnumerable<MessageResponse>>.Success(response);
            }
            catch (Exception ex)
            {
                return BaseResponse<IEnumerable<MessageResponse>>.Error($"Erro ao carregar o histórico: {ex.Message}");
            }
        }

       private MessageResponse BuildMessageResponse(
            ChatMessage msg, string myUserId, bool isGroup, Dictionary<string, User> usersMap)
        {
            string? freshUrl = string.IsNullOrEmpty(msg.Url) 
                ? null : storageService.GetPresignedUrl(msg.Url);

            string? senderName = null;
            string? senderPhoto = null;

            if (isGroup && msg.SenderId != myUserId)
            {
                if (usersMap.TryGetValue(msg.SenderId, out var user))
                {
                    senderName = user.Name;
                    senderPhoto = string.IsNullOrEmpty(user.ProfileImageKey) 
                        ? null : storageService.GetPresignedUrl(user.ProfileImageKey);
                }
            }
            bool isReadByMe = msg.SenderId == myUserId || (msg.ReadBy != null && msg.ReadBy.Contains(myUserId));

            return new MessageResponse(
                msg.Id,
                msg.Text,
                msg.CreatedAt.ToLocalTime().ToString("HH:mm"), 
                msg.SenderId == myUserId,
                msg.Title,
                freshUrl,
                senderName,
                senderPhoto,
                msg.Status.ToString(),
                isReadByMe
            );
        }
    }
}