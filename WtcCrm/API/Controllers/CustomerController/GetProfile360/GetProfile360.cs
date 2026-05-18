using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WtcCrm.API.Controllers.Handlers;
using WtcCrm.Application.DTOs;
using WtcCrm.Application.Wrappers;
using WtcCrm.Domain.Interfaces;

namespace WtcCrm.API.Controllers.BaseCustomerController
{
    public partial class CustomerController
    {
        [HttpGet("{id}/profile360")]
        [Authorize(Roles = "Admin, Operator")]
        public async Task<IActionResult> GetProfile360(
            [FromRoute] string id,
            [FromServices] GetProfile360Handler handler)
        {
            var response = await handler.HandleAsync(id);
            if (!response.IsSuccess) return BadRequest(response);
            
            return Ok(response);
        }
    }
}

namespace WtcCrm.API.Controllers.Handlers
{
    public class GetProfile360Handler(
        IUserRepository _userRepository,
        ICustomerNoteRepository _noteRepository,
        IChatRepository _chatRepository, 
        IAnnouncementDeliveryRepository _deliveryRepository,
        IHttpContextAccessor _httpContextAccessor
    ) : BaseHandler(_httpContextAccessor)
    {
        public async Task<BaseResponse<Profile360Response>> HandleAsync(string customerId)
        {
            try
            {
                
                await CheckPermissionAsync();

                var customer = await _userRepository.GetByIdAsync(customerId);
                if (customer == null) return BaseResponse<Profile360Response>.Error("Cliente não encontrado.");

                var notesTask = _noteRepository.GetNotesByCustomerIdAsync(customerId);
   
                var messagesTask = _chatRepository.GetRecentMessagesAsync(customerId, limit: 5); 
                
                var deliveriesTask = _deliveryRepository.GetMyAnnouncementIdsAsync(customerId);

                await Task.WhenAll(notesTask, messagesTask, deliveriesTask);

                var notes = await notesTask;
                var messages = await messagesTask;
                var campaignIds = await deliveriesTask;

                var notesSnapshot = notes.Select(a => new NoteSnapshot(
                    Id: a.Id,
                    Text: a.Text,
                    OperatorName: "Operador",
                    CreatedAt: a.CreatedAt,
                    IsTask: a.IsTask,
                    IsResolved: a.IsResolved
                )).ToList();

                var messageSnapshot = messages.Select(a => new MessageSnapshot(
                    Id: a.Id,
                    Text: a.Text,
                    IsFromOperator: a.SenderId != customerId,
                    CreatedAt: a.CreatedAt
                )).ToList();

                var response = new Profile360Response(
                    Id: customer.Id.ToString(),
                    Name: customer.Name,
                    Email: customer.Email,
                    Phone: customer.DocumentId,
                    PhotoUrl: customer.ProfileImageKey,
                    Status: customer.Status,
                    Score: customer.Score,
                    NotesAndTasks: notesSnapshot,
                    SegmentId: customer.SegmentId,
                    RecentMessages: messageSnapshot,
                    RecentCampaigns: new List<CampaignSnapshot>()
                );

                return BaseResponse<Profile360Response>.Success(response);
            }
            catch (Exception ex)
            {
                return BaseResponse<Profile360Response>.Error($"Erro ao gerar Perfil 360: {ex.Message}");
            }
        }
    }
}
