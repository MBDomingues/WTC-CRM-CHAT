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
        [HttpPut("notes/{noteId}")]
        [Authorize(Roles = "Admin, Operator")]
        public async Task<IActionResult> UpdateCustomerNote(
            string noteId, 
            [FromBody] UpdateNoteRequest request, 
            [FromServices] UpdateCustomerNoteHandler handler)
        {
            var response = await handler.HandleAsync(noteId, request);
            return response.IsSuccess ? Ok(response) : BadRequest(response);
        }
    }
}

namespace WtcCrm.API.Controllers.Handlers
{
    public class UpdateCustomerNoteHandler(
        ICustomerNoteRepository _noteRepository,
        IHttpContextAccessor _httpContextAccessor
    ) : BaseHandler(_httpContextAccessor)
    {
        public async Task<BaseResponse<bool>> HandleAsync(string noteId, UpdateNoteRequest request)
        {
            try
            {
                await CheckPermissionAsync();

                var note = await _noteRepository.GetNoteByIdAsync(noteId);
                if (note == null) return BaseResponse<bool>.Error("Nota não encontrada.");

                note.Text = request.Text;
                note.IsTask = request.IsTask;
                note.IsResolved = request.IsResolved;
                note.UpdatedAt = DateTime.UtcNow;

                await _noteRepository.UpdateNoteAsync(note);
                return BaseResponse<bool>.Success(true);
            }
            catch (Exception ex)
            {
                return BaseResponse<bool>.Error($"Erro ao atualizar nota: {ex.Message}");
            }
        }
    }
}