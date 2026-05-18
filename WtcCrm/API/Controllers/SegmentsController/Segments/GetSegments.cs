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
        [HttpGet]
        [Authorize(Roles = "Admin, Operator")]
        public async Task<IActionResult> GetAll([FromServices] GetSegmentsHandler handler)
        {
            var response = await handler.HandleAsync();
            if (!response.IsSuccess) return BadRequest(response);
            return Ok(response);
        }
    }
}

namespace WtcCrm.API.Controllers.Handlers
{
    public class GetSegmentsHandler(
        IHttpContextAccessor _httpContextAccessor,
        ISegmentRepository _repository
    ) : BaseHandler(_httpContextAccessor)
    {
        public async Task<BaseResponse<IEnumerable<Segment>>> HandleAsync()
        {
            try
            {
                await CheckPermissionAsync();

                var segments = await _repository.GetAllAsync();
                return BaseResponse<IEnumerable<Segment>>.Success(segments);
            }
            catch (Exception ex)
            {
                return BaseResponse<IEnumerable<Segment>>.Error($"Erro ao buscar segmentos: {ex.Message}");
            }
        }
    }
}