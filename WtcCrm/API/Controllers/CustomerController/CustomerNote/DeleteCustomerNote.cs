using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WtcCrm.API.Controllers.Handlers;
using WtcCrm.Application.Wrappers;
using WtcCrm.Domain.Interfaces;

namespace WtcCrm.API.Controllers.BaseCustomerController
{
    public partial class CustomerController
    {
        [HttpDelete("notes/{noteId}")]
        [Authorize(Roles = "Admin, Operator")]
        public async Task<IActionResult> DeleteCustomerNote(
            string noteId, 
            [FromServices] DeleteCustomerNoteHandler handler)
        {
            var response = await handler.HandleAsync(noteId);
            return response.IsSuccess ? Ok(response) : BadRequest(response);
        }
    }
}

namespace WtcCrm.API.Controllers.Handlers
{
    public class DeleteCustomerNoteHandler(
        ICustomerNoteRepository _noteRepository,
        IHttpContextAccessor _httpContextAccessor
    ) : BaseHandler(_httpContextAccessor)
    {
        public async Task<BaseResponse<bool>> HandleAsync(string noteId)
        {
            try
            {
                await CheckPermissionAsync();

                var note = await _noteRepository.GetNoteByIdAsync(noteId);
                if (note == null) return BaseResponse<bool>.Error("Nota não encontrada.");

                await _noteRepository.DeleteNoteAsync(noteId);
                return BaseResponse<bool>.Success(true);
            }
            catch (Exception ex)
            {
                return BaseResponse<bool>.Error($"Erro ao excluir nota: {ex.Message}");
            }
        }
    }
}