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
        [HttpPut("{id}/crm")]
        [Authorize(Roles = "Admin, Operator")]
        public async Task<IActionResult> UpdateCrm(
            string id, 
            [FromBody] UpdateCrmRequest request, 
            [FromServices] UpdateCustomerCrmHandler handler)
        {
            var response = await handler.HandleAsync(id, request);
            return response.IsSuccess ? Ok(response) : BadRequest(response);
        }
    }
}

namespace WtcCrm.API.Controllers.Handlers
{
    public class UpdateCustomerCrmHandler(
        IUserRepository _userRepository,
        IHttpContextAccessor _httpContextAccessor
        ) : BaseHandler(_httpContextAccessor)
    {
        public async Task<BaseResponse<bool>> HandleAsync(string customerId, UpdateCrmRequest request)
        {
            await CheckPermissionAsync();

            var user = await _userRepository.GetByIdAsync(customerId);
            if (user == null) return BaseResponse<bool>.Error("Cliente não encontrado.");

            user.Score = request.Score;
            user.Status = request.Status;
            user.SegmentId = request.SegmentId;

            await _userRepository.UpdateAsync(user);
            return BaseResponse<bool>.Success(true);
        }
    }
    
}