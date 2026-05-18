using Domain.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WtcCrm.Application.DTOs;
using WtcCrm.Application.Wrappers;
using WtcCrm.Domain.Interfaces;
using WtcCrm.Domain.Entities;
using WtcCrm.API.Controllers.Handlers;

namespace WtcCrm.API.Controllers.BaseAnnounceController
{
    public partial class AnnounceController
    {
        [HttpGet("feed")]
        [Authorize]
        public async Task<IActionResult> GetMyAnnouncements(
            [FromServices] GetAnnouncementsHandler handler,
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 10)
        {
            var response = await handler.HandleAsync(page, pageSize);
            if (!response.IsSuccess) return BadRequest(response);
            return Ok(response);
        }
    }
}

namespace WtcCrm.API.Controllers.Handlers
{
    public class GetAnnouncementsHandler(
        IHttpContextAccessor _httpContextAccessor,
        IAnnouncementRepository _announceRepository,
        IAnnouncementDeliveryRepository _deliveryRepository,
        IStorageService _storageService
    ) : BaseHandler(_httpContextAccessor)
    {
        public async Task<BaseResponse<IEnumerable<AnnouncementListResponse>>> HandleAsync(int page, int pageSize)
        {
            try
            {
                var userRole = await GetUserRoleAsync();
                var userId = await GetUserIdAsync();

                IEnumerable<Announcement> announcements;
                
                if (userRole == "Admin" || userRole == "Customer")
                {
                    announcements = await _announceRepository.GetAllAnnouncementsAsync(page, pageSize);
                }
                else
                {
                    var myAnnouncementIds = await _deliveryRepository.GetMyAnnouncementIdsAsync(userId);

                    if (!myAnnouncementIds.Any())
                    {
                        return BaseResponse<IEnumerable<AnnouncementListResponse>>.Success(new List<AnnouncementListResponse>());
                    }

                    announcements = await _announceRepository.GetAnnouncementsByIdsAsync(myAnnouncementIds, page, pageSize);
                }

                var response = announcements.Select(a => new AnnouncementListResponse(
                    Id: a.Id,
                    Title: a.Title,
                    Description: a.Description,
                    Date: a.Date,
                    Location: a.Location,
                    ImageUrl: string.IsNullOrEmpty(a.ImageKey) 
                        ? null 
                        : _storageService.GetPresignedUrl(a.ImageKey),
                    CreatedAt: a.CreatedAt
                ));

                return BaseResponse<IEnumerable<AnnouncementListResponse>>.Success(response);
            }
            catch (Exception ex)
            {
                return BaseResponse<IEnumerable<AnnouncementListResponse>>.Error($"Erro ao carregar o feed de anúncios: {ex.Message}");
            }
        }
    }
}