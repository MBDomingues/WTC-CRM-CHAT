using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WtcCrm.API.Controllers.Handlers;
using WtcCrm.Application.Wrappers;
using WtcCrm.Domain.Interfaces;

namespace WtcCrm.API.Controllers.BaseSegmentsController
{
    public partial class SegmentsController
    {
        [HttpPut("{id:guid}")]
        [Authorize(Roles = "Admin, Operator")]
        public async Task<IActionResult> Update(
            [FromRoute] Guid id,
            [FromBody] UpdateSegmentRequest request,
            [FromServices] UpdateSegmentHandler handler)
        {
            var response = await handler.HandleAsync(id, request);
            if (!response.IsSuccess) return BadRequest(response);
            return Ok(response);
        }
    }
}

namespace WtcCrm.API.Controllers.Handlers
{
    public record UpdateSegmentRequest(string Name, string Description);

    public class UpdateSegmentHandler(
        IHttpContextAccessor _httpContextAccessor,
        ISegmentRepository _repository
    ) : BaseHandler(_httpContextAccessor)
    {
        public async Task<BaseResponse<bool>> HandleAsync(Guid id, UpdateSegmentRequest request)
        {
            try
            {
                await CheckPermissionAsync();

                var segment = await _repository.GetByIdAsync(id);
                if (segment == null) return BaseResponse<bool>.Error("Segmento não encontrado.");

                segment.Name = request.Name;
                segment.Description = request.Description;

                await _repository.UpdateAsync(segment);
                return BaseResponse<bool>.Success(true);
            }
            catch (Exception ex)
            {
                return BaseResponse<bool>.Error($"Erro ao atualizar segmento: {ex.Message}");
            }
        }
    }
}