using Domain.Interfaces;
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
        [HttpPost("group")]
        [Authorize(Roles = "Admin, Operator")]
        public async Task<IActionResult> CreateGroup(
            [FromForm] CreateGroupRequest request, 
            [FromServices] CreateGroupHandler handler)
        {
            var response = await handler.HandleAsync(request);
            if (!response.IsSuccess) return BadRequest(response);
            return Ok(response);
        }
    }
}

namespace WtcCrm.API.Controllers.Handlers
{
    public class CreateGroupHandler(
        IHttpContextAccessor _httpContextAccessor,
        IChatGroupRepository _groupRepository,
        IStorageService _storageService,
        IHubContext<ChatHub> _hubContext
    ) : BaseHandler( _httpContextAccessor)
    {
        public async Task<BaseResponse<bool>> HandleAsync(CreateGroupRequest request)
        {
            try
            {
                var user = await CheckPermissionAsync();
                string? imageKey = null;

                if (request.Image != null && request.Image.Length > 0)
                {
                    using var stream = request.Image.OpenReadStream();
                    imageKey = await _storageService.UploadFileAsync(
                        stream,
                        request.Image.FileName,
                        request.Image.ContentType,
                        "group-profiles"
                    );
                }

                var members = request.MemberIds.Distinct().ToList();
                if (!members.Contains(user.Id))
                {
                    members.Add(user.Id);
                }

                var newGroup = new ChatGroup
                {
                    Name = request.Name,
                    Description = request.Description,
                    ImageKey = imageKey,
                    CreatedBy = user.Id,
                    MemberIds = members
                };

                await _groupRepository.CreateAsync(newGroup);

                foreach (var memberId in members)
                {
                    if (memberId != user.Id)
                    {
                        await _hubContext.Clients.User(memberId).SendAsync("GroupCreated", newGroup.Id, newGroup.Name);
                    }
                }

                return BaseResponse<bool>.Success(true);
            }
            catch (Exception ex)
            {
                return BaseResponse<bool>.Error($"Erro ao criar grupo: {ex.Message}");
            }
        }
    }
}


namespace WtcCrm.Application.DTOs
{
    public class CreateGroupRequest
    {
        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; }
        public IFormFile? Image { get; set; }         
        public List<string> MemberIds { get; set; } = new();
    }
}