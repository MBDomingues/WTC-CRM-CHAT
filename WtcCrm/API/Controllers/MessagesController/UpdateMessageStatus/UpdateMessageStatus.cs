using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WtcCrm.API.Controllers.Handlers;
using WtcCrm.Application.DTOs;
using WtcCrm.Application.Wrappers;
using WtcCrm.Domain.Interfaces;

namespace WtcCrm.API.Controllers.BaseMessagesController
{
    public partial class MessagesController
    {
        [HttpPatch("{id}/status")]
        [Authorize]
        public async Task<IActionResult> UpdateStatus(
            [FromRoute] string id,
            [FromBody] UpdateMessageStatusRequest request,
            [FromServices] UpdateMessageStatusHandler handler)
        {
            var response = await handler.HandleAsync(id, request);
            if (!response.IsSuccess) return BadRequest(response);
            
            return Ok(response);
        }
    }
}

namespace WtcCrm.API.Controllers.Handlers
{
    public class UpdateMessageStatusHandler(
        IHttpContextAccessor httpContextAccessor,
        IChatRepository chatRepository,
        IChatGroupRepository groupRepository
    ) : BaseHandler(httpContextAccessor)
    {
        public async Task<BaseResponse<bool>> HandleAsync(string targetChatId, UpdateMessageStatusRequest request)
        {
            try
            {
                var myUserId = await GetUserIdAsync(); 

                var targetGroup = await groupRepository.GetByIdAsync(targetChatId);

                if (targetGroup != null)
                {
                    var messages = await chatRepository.GetUnreadGroupMessagesAsync(targetChatId, myUserId);

                    foreach (var msg in messages)
                    {
                        msg.ReadBy ??= new List<string>(); 
                        msg.ReadBy.Add(myUserId);

                        int totalNecessario = targetGroup.MemberIds.Count - 1;
                        if (msg.ReadBy.Count >= totalNecessario)
                        {
                            msg.Status = request.Status;
                        }
                    }

                    if (messages.Any()) 
                        await chatRepository.UpdateMessagesAsync(messages);
                }
                else
                {
                    var messages = await chatRepository.GetUnreadPrivateMessagesAsync(targetChatId, myUserId, request.Status);

                    foreach (var msg in messages)
                    {
                        msg.Status = request.Status;
                    }

                    if (messages.Any()) 
                        await chatRepository.UpdateMessagesAsync(messages);
                }

                return BaseResponse<bool>.Success(true);
            }
            catch (Exception ex)
            {
                return BaseResponse<bool>.Error($"Erro ao atualizar status: {ex.Message}");
            }
        }
    }
}