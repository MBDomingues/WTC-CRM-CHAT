using Domain.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WtcCrm.API.Controllers.Handlers;
using WtcCrm.Application.DTOs;
using WtcCrm.Application.Wrappers;
using WtcCrm.Domain.Interfaces;

namespace WtcCrm.API.Controllers.BaseAnnounceController
{
    public partial class AnnounceController
    {
        [HttpGet("recipients")]
        [Authorize(Roles = "Admin, Operator")]
        public async Task<IActionResult> GetRecipients(
            [FromServices] GetAnnounceRecipientsHandler handler,
            [FromQuery] string? search, 
            [FromQuery] List<string>? segmentIds)
        {
            var response = await handler.HandleAsync(search, segmentIds);
            if (!response.IsSuccess) return BadRequest(response);
            return Ok(response);
        }
    }
}


namespace WtcCrm.API.Controllers.Handlers
{
    public class GetAnnounceRecipientsHandler(
        IHttpContextAccessor _httpContextAccessor,
        IUserRepository _userRepository, 
        IChatGroupRepository _groupRepository,
        IStorageService _storageService
    ) : BaseHandler(_httpContextAccessor)
    {
        public async Task<BaseResponse<List<RecipientListResponse>>> HandleAsync(string? search, List<string>? segmentId)
        {
            try
            {
                var user = await CheckPermissionAsync();
                
                var recipientsList = new List<RecipientListResponse>();

                var customers = await _userRepository.GetAllActiveUsersAsync();
                var filteredCustomers = customers.Where(a => a.Id.ToString() != user.Id);

                if (segmentId != null && segmentId.Count > 0)
                {
                    filteredCustomers = filteredCustomers.Where(a => segmentId.Contains(a.SegmentId));
                }
                if (!string.IsNullOrWhiteSpace(search))
                {
                    filteredCustomers = filteredCustomers.Where(a => 
                        a.Name.Contains(search, StringComparison.OrdinalIgnoreCase));
                }

                foreach (var customer in filteredCustomers)
                {
                    recipientsList.Add(new RecipientListResponse(
                        Id: customer.Id.ToString(),
                        Name: customer.Name,
                        ImageUrl: string.IsNullOrEmpty(customer.ProfileImageKey) 
                            ? null 
                            : _storageService.GetPresignedUrl(customer.ProfileImageKey),
                        IsGroup: false,
                        SegmentId: customer.SegmentId 
                    ));
                }

                if (segmentId == null || segmentId.Count == 0)
                {
                    var myGroups = await _groupRepository.GetGroupsByUserIdAsync(user.Id);
                    var filteredGroups = myGroups.AsEnumerable();

                    if (!string.IsNullOrWhiteSpace(search))
                    {
                        filteredGroups = filteredGroups.Where(a => 
                            a.Name.Contains(search, StringComparison.OrdinalIgnoreCase));
                    }

                    foreach (var group in filteredGroups)
                    {
                        recipientsList.Add(new RecipientListResponse
                        (
                            Id: group.Id,
                            Name: group.Name,
                            ImageUrl: !string.IsNullOrEmpty(group.ImageKey) 
                                       ? _storageService.GetPresignedUrl(group.ImageKey) 
                                       : null,
                            IsGroup: true,
                            SegmentId: null
                        ));
                    }
                }

                var sortedList = recipientsList.OrderBy(a => a.Name).ToList();

                return BaseResponse<List<RecipientListResponse>>.Success(sortedList);
            }
            catch (Exception ex)
            {
                return BaseResponse<List<RecipientListResponse>>.Error($"Erro ao carregar destinatários: {ex.Message}");
            }
        }
    }
}