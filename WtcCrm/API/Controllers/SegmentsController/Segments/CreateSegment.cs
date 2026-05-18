using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WtcCrm.API.Controllers.Handlers;
using WtcCrm.Application.Wrappers;
using WtcCrm.Domain.Entities;
using WtcCrm.Domain.Interfaces;

namespace WtcCrm.API.Controllers.BaseSegmentsController
{
    public partial class SegmentsController
    {
        [HttpPost]
        [Authorize(Roles = "Admin, Operator")]
        public async Task<IActionResult> Create(
            [FromBody] CreateSegmentRequest request,
            [FromServices] CreateSegmentHandler handler)
        {
            var response = await handler.HandleAsync(request);
            if (!response.IsSuccess) return BadRequest(response);
            return Ok(response);
        }
    }
}

namespace WtcCrm.API.Controllers.Handlers
{
    public record CreateSegmentRequest(string Name, string Description);

    public class CreateSegmentHandler(
        IHttpContextAccessor _httpContextAccessor,
        ISegmentRepository _repository
    ) : BaseHandler(_httpContextAccessor)
    {
        public async Task<BaseResponse<Guid>> HandleAsync(CreateSegmentRequest request)
        {
            try
            {
                await CheckPermissionAsync();

                var segment = new Segment
                {
                    Id = Guid.NewGuid(),
                    Name = request.Name,
                    Description = request.Description
                };

                await _repository.AddAsync(segment);
                return BaseResponse<Guid>.Success(segment.Id);
            }
            catch (Exception ex)
            {
                return BaseResponse<Guid>.Error($"Erro ao criar segmento: {ex.Message}");
            }
        }
    }
}