using Microsoft.AspNetCore.Mvc;
using WtcCrm.API.Controllers.Handlers;
using WtcCrm.Application.DTOs;
using WtcCrm.Application.Services;
using WtcCrm.Application.Wrappers;

namespace WtcCrm.API.Controllers.BaseAuthController
{
    public partial class AuthController
    {
        [HttpPost("register")]
        public async Task<IActionResult> Register(
            [FromBody] RegisterRequest request,
            [FromServices] RegisterHandler handler)
        {
            var response = await handler.HandleAsync(request);

            if (!response.IsSuccess) return BadRequest(response);
            
            return Ok(response);
        }
    }
}

namespace WtcCrm.API.Controllers.Handlers
{
    public class RegisterHandler(AuthService _authService)
    {
        public async Task<BaseResponse<AuthResponse>> HandleAsync(RegisterRequest request)
        {
            return await _authService.RegisterAsync(request);
        }
    }
}