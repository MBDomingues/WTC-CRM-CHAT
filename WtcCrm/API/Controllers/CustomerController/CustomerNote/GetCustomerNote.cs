using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WtcCrm.API.Controllers.Handlers;
using WtcCrm.Application.Wrappers;
using WtcCrm.Domain.Entities;
using WtcCrm.Domain.Interfaces;

namespace WtcCrm.API.Controllers.BaseCustomerController
{
    public partial class CustomerController
    {
        [HttpGet("{id}/notes")]
        [Authorize(Roles = "Admin, Operator")]
        public async Task<IActionResult> GetCustomerNotes(
            string id, 
            [FromServices] GetCustomerNotesHandler handler)
        {
            var response = await handler.HandleAsync(id);
            return response.IsSuccess ? Ok(response) : BadRequest(response);
        }
    }
}

namespace WtcCrm.API.Controllers.Handlers
{
    public class GetCustomerNotesHandler(
        ICustomerNoteRepository _noteRepository,
        IHttpContextAccessor _httpContextAccessor
    ) : BaseHandler(_httpContextAccessor)
    {
        public async Task<BaseResponse<IEnumerable<CustomerNote>>> HandleAsync(string customerId)
        {
            try
            {
                await CheckPermissionAsync();

                var notes = await _noteRepository.GetNotesByCustomerIdAsync(customerId);
                
                var sortedNotes = notes.OrderByDescending(a => a.CreatedAt);

                return BaseResponse<IEnumerable<CustomerNote>>.Success(sortedNotes);
            }
            catch (Exception ex)
            {
                return BaseResponse<IEnumerable<CustomerNote>>.Error($"Erro ao listar notas: {ex.Message}");
            }
        }
    }
}