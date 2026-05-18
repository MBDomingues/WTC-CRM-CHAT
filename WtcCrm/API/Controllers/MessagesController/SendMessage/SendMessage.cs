using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;
using WtcCrm.API.Controllers.Handlers;
using WtcCrm.API.Hubs;
using WtcCrm.Application.DTOs;
using WtcCrm.Application.Wrappers;
using WtcCrm.Domain.Entities;
using WtcCrm.Domain.Interfaces;

namespace WtcCrm.API.Controllers.BaseMessagesController
{
    public partial class MessagesController
    {
        [HttpPost("{participantId}")]
        [Authorize]
        public async Task<IActionResult> SendMessage(
            [FromRoute] string participantId, 
            [FromBody] SendMessageRequest request,
            [FromServices] SendMessageHandler handler)
        {
            var response = await handler.HandleAsync(participantId, request);
            if (!response.IsSuccess) return BadRequest(response);
            return Ok(response);
        }
    }
}

namespace WtcCrm.API.Controllers.Handlers
{
    public class SendMessageHandler(
        IHttpContextAccessor httpContextAccessor,
        IChatRepository chatRepository, 
        IChatGroupRepository groupRepository,
        IHubContext<ChatHub> hubContext
    ) : BaseHandler(httpContextAccessor)
    {
        public async Task<BaseResponse<MessageResponse>> HandleAsync(string participantOrGroupId, SendMessageRequest request)
        {
            try
            {
                var myUserId = await GetUserIdAsync();
                var targetGroup = await groupRepository.GetByIdAsync(participantOrGroupId);

                string? groupId = targetGroup != null ? targetGroup.Id : null;
                string? receiverId = targetGroup == null ? participantOrGroupId : null;
                
                var signalRTargets = targetGroup != null 
                    ? targetGroup.MemberIds.Where(a => a != myUserId).ToList()
                    : new List<string> { participantOrGroupId };

                var response = await BuildAndSendMessageAsync(
                    myUserId, receiverId, groupId, request.Text, signalRTargets);

                return BaseResponse<MessageResponse>.Success(response);
            }
            catch (Exception ex)
            {
                return BaseResponse<MessageResponse>.Error($"Erro ao enviar mensagem: {ex.Message}");
            }
        }

        private async Task<MessageResponse> BuildAndSendMessageAsync(
            string senderId, string? receiverId, string? groupId, string text, IEnumerable<string> signalRTargets)
        {
            var message = new ChatMessage
            {
                SenderId = senderId,
                ReceiverId = receiverId,
                GroupId = groupId,
                Text = text,
                CreatedAt = DateTime.UtcNow,
                Status = MessageStatus.Sent
            };

            await chatRepository.SaveMessageAsync(message);

            var response = new MessageResponse(
                message.Id,
                message.Text,
                message.CreatedAt.ToLocalTime().ToString("HH:mm"),
                true,
                null,
                null,
                null,
                null,
                message.Status.ToString()
            );

            var pushMessage = response with { IsSentByMe = false };

            foreach (var targetId in signalRTargets)
            {
                await hubContext.Clients.User(targetId).SendAsync("ReceiveNewMessage", pushMessage);
            }

            return response;
        }
    }
}