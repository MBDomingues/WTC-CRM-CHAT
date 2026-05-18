
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WtcCrm.API.Controllers.Handlers;
using WtcCrm.Application.DTOs;
using WtcCrm.Application.Wrappers;
using WtcCrm.Domain.Entities;
using WtcCrm.Domain.Interfaces;

namespace WtcCrm.API.Controllers.BaseCustomerController
{
    public partial class CustomerController
    {
        [HttpPost("{id}/notes")]
        [Authorize(Roles = "Admin, Operator")]
        public async Task<IActionResult> CreateCustomerNote(string id, [FromBody] AddNoteRequest request, [FromServices] CreateCustomerNoteHandler handler)
        {
            var response = await handler.HandleAsync(id, request);
            return response.IsSuccess ? Ok(response) : BadRequest(response);
        }
    }
}

namespace WtcCrm.API.Controllers.Handlers
{
    public class CreateCustomerNoteHandler(
        ICustomerNoteRepository _noteRepository,
        IHttpContextAccessor _httpContextAccessor
    ) : BaseHandler(_httpContextAccessor)
    {
        public async Task<BaseResponse<bool>> HandleAsync(string customerId, AddNoteRequest request)
        {
            try
            {
                var user = await CheckPermissionAsync();

                var note = new CustomerNote {
                    CustomerId = customerId,
                    OperatorId = user.Id,
                    Text = request.Text,
                    IsTask = request.IsTask, 
                    CreatedAt = DateTime.UtcNow
                };

                await _noteRepository.CreateNoteAsync(note);
                return BaseResponse<bool>.Success(true);
            }
            catch (Exception ex)
            {
                return BaseResponse<bool>.Error($"Erro ao salvar nota: {ex.Message}");
            }
        }
    }
}