using Domain.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WtcCrm.API.Controllers.Handlers;
using WtcCrm.Application.DTOs;
using WtcCrm.Application.Services;
using WtcCrm.Application.Wrappers;
using WtcCrm.Domain.Interfaces;

namespace WtcCrm.API.Controllers.BaseCustomerController
{
    public partial class CustomerController
    {
        [HttpGet("searchCustomer")]
        [Authorize(Roles = "Admin, Operator")]
        public async Task<IActionResult> Search(
            [FromServices] GetCustomersHandler handler,
            [FromQuery] string? search, 
            [FromQuery] string? status, 
            [FromQuery] int page = 1, 
            [FromQuery] int pageSize = 15)
        {
            var response = await handler.HandleAsync(search, status, page, pageSize);
            
            if (!response.IsSuccess)
                return BadRequest(response);

            return Ok(response);
        }
    }
}

namespace WtcCrm.API.Controllers.Handlers
{
    public class GetCustomersHandler(
        IUserRepository _userRepository,
        IStorageService _storageService,
        IHttpContextAccessor _httpContextAccessor
    ) : BaseHandler(_httpContextAccessor)
    {
        public async Task<BaseResponse<IEnumerable<CustomerListResponse>>> HandleAsync(
            string? search,
            string? status, 
            int page = 1, 
            int pageSize = 15)
        {
            try
            {
                await CheckPermissionAsync();

                var customers = await _userRepository.SearchCustomersAsync(search, status, page, pageSize);

                var response = customers.Select(a => new CustomerListResponse(
                    Id: a.Id.ToString(),
                    Name: a.Name,
                    Email: a.Email,
                    PhotoUrl: string.IsNullOrEmpty(a.ProfileImageKey) 
                        ? null 
                        : _storageService.GetPresignedUrl(a.ProfileImageKey),
                    Score: a.Score,
                    Status: a.Status
                ));

                return BaseResponse<IEnumerable<CustomerListResponse>>.Success(response);
            }
            catch (Exception ex)
            {
                return BaseResponse<IEnumerable<CustomerListResponse>>.Error($"Erro ao localizar clientes: {ex.Message}");
            }
        }
    }
}