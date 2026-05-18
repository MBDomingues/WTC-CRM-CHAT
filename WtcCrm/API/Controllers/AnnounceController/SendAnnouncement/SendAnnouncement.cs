using Domain.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;
using WtcCrm.API.Controllers.Handlers;
using WtcCrm.API.Hubs;
using WtcCrm.Application.Announce.DTOs;
using WtcCrm.Application.DTOs;
using WtcCrm.Application.Wrappers;
using WtcCrm.Domain.Entities;
using WtcCrm.Domain.Interfaces;

namespace WtcCrm.API.Controllers.BaseAnnounceController
{
    public partial class AnnounceController
    {
        [HttpPost("announce")]
        [Authorize(Roles = "Admin, Operator")]
        public async Task<IActionResult> SendAnnouncement(
            [FromForm] SendAnnouncementRequest request,
            [FromServices] SendAnnouncementHandler handler)
        {
            var response = await handler.HandleAsync(request);
            if (!response.IsSuccess) return BadRequest(response);
            return Ok(response);
        }
    }
}

namespace WtcCrm.API.Controllers.Handlers
{
    public class SendAnnouncementHandler(
        IHttpContextAccessor _httpContextAccessor,
        IChatRepository _chatRepository,
        IAnnouncementRepository _announceRepository,
        IChatGroupRepository _groupRepository, 
        IAnnouncementDeliveryRepository _deliveryRepository,
        IHubContext<ChatHub> _hubContext,
        IStorageService _storageService
    ) : BaseHandler(_httpContextAccessor)
    {
        public async Task<BaseResponse<bool>> HandleAsync(SendAnnouncementRequest request)
        {
            try
            {
                var user = await CheckPermissionAsync();

                string imageKey = string.Empty;
                
                if (request.Image != null && request.Image.Length > 0)
                {
                    using var stream = request.Image.OpenReadStream();
                    imageKey = await _storageService.UploadFileAsync(
                        stream,
                        request.Image.FileName,
                        request.Image.ContentType,
                        "announcements"
                    );
                }

                var newAnnouncement = new Announcement
                {
                    Title = request.Title,
                    Description = request.Description,
                    Date = request.Date,
                    Location = request.Location,
                    ImageKey = imageKey,
                    CreatedBy = user.Id
                };
                
                await _announceRepository.CreateAnnouncementAsync(newAnnouncement);

                var announcementText = $"📅 Data: {request.Date}\n📍 Local: {request.Location}\n\n📝 {request.Description}";
                var freshUrl = !string.IsNullOrEmpty(imageKey) ? _storageService.GetPresignedUrl(imageKey) : null;

                var finalUserIdsToDeliver = new HashSet<string>();

                foreach (var id in request.RecipientIds)
                {
                    var group = await _groupRepository.GetByIdAsync(id);

                    if (group != null)
                    {
                        var targets = group.MemberIds.Where(a => a != user.Id).ToList();
                        foreach (var memberId in targets) finalUserIdsToDeliver.Add(memberId);

                        await BuildAndSendMessageAsync(
                            senderId: user.Id,
                            receiverId: null,
                            groupId: group.Id,
                            title: request.Title,
                            text: announcementText,
                            imageKey: imageKey,
                            freshUrl: freshUrl,
                            announcementId: newAnnouncement.Id,
                            signalRTargets: targets
                        );
                    }
                    else
                    {
                        if (id != user.Id)
                        {
                            finalUserIdsToDeliver.Add(id);

                            await BuildAndSendMessageAsync(
                                senderId: user.Id,
                                receiverId: id,
                                groupId: null,
                                title: request.Title,
                                text: announcementText,
                                imageKey: imageKey,
                                freshUrl: freshUrl,
                                announcementId: newAnnouncement.Id,
                                signalRTargets: new[] { id }
                            );
                        }
                    }
                }

                if (finalUserIdsToDeliver.Any())
                {
                    var deliveries = finalUserIdsToDeliver.Select(a => new AnnouncementDelivery
                    {
                        AnnouncementId = newAnnouncement.Id,
                        UserId = a
                    }).ToList();

                    await _deliveryRepository.CreateDeliveriesAsync(deliveries);
                }

                return BaseResponse<bool>.Success(true);
            }
            catch (Exception ex)
            {
                return BaseResponse<bool>.Error($"Erro: {ex.Message}");
            }
        }

        private async Task BuildAndSendMessageAsync(
            string senderId,
            string? receiverId,
            string? groupId,
            string title,
            string text,
            string imageKey,
            string? freshUrl,
            string announcementId,
            IEnumerable<string> signalRTargets)
        {
            var message = new ChatMessage
            {
                SenderId = senderId,
                ReceiverId = receiverId,
                GroupId = groupId,
                Title = title,
                Text = text,
                Url = imageKey,
                AnnouncementId = announcementId,
                CreatedAt = DateTime.UtcNow
            };

            await _chatRepository.SaveMessageAsync(message);

            var pushMessage = new MessageResponse(
                message.Id,
                message.Text,
                message.CreatedAt.ToLocalTime().ToString("HH:mm"),
                false, 
                message.Title,
                freshUrl
            );

            foreach (var targetId in signalRTargets)
            {
                await _hubContext.Clients.User(targetId).SendAsync("ReceiveNewMessage", pushMessage);
            }
        }
    }
}

namespace WtcCrm.Application.Announce.DTOs
{
    public record class SendAnnouncementRequest
    (
         string Title,
         string Date,
         string Location,
         string Description,
         IFormFile? Image,
         List<string> RecipientIds
    );
}