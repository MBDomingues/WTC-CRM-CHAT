using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WtcCrm.API.Controllers.Handlers;
using WtcCrm.Application.Wrappers;
using WtcCrm.Domain.Interfaces;

namespace WtcCrm.API.Controllers.BaseSegmentsController
{
    public partial class SegmentsController
    {
        [HttpDelete("{id:guid}")]
        [Authorize(Roles = "Admin, Operator")]
        public async Task<IActionResult> Delete(
            [FromRoute] Guid id,
            [FromServices] DeleteSegmentHandler handler)
        {
            var response = await handler.HandleAsync(id);
            if (!response.IsSuccess) return BadRequest(response);
            return Ok(response);
        }
    }
}

namespace WtcCrm.API.Controllers.Handlers
{
    public class DeleteSegmentHandler(
        IHttpContextAccessor _httpContextAccessor,
        ISegmentRepository _repository
    ) : BaseHandler(_httpContextAccessor)
    {
        public async Task<BaseResponse<bool>> HandleAsync(Guid id)
        {
            try
            {
                var user = await CheckPermissionAsync();
                if (user.Role != "Admin" && user.Role != "Operator")
                {
                    return BaseResponse<bool>.Error("Acesso negado: Apenas Administradores ou Operadores podem excluir segmentos.");
                }

                var segment = await _repository.GetByIdAsync(id);
                if (segment == null) return BaseResponse<bool>.Error("Segmento não encontrado.");
                
                await _repository.DeleteAsync(id);

                return BaseResponse<bool>.Success(true);
            }
            catch (Exception ex)
            {
                return BaseResponse<bool>.Error($"Erro ao deletar segmento: {ex.Message}");
            }
        }
    }
}