using Microsoft.AspNetCore.Mvc;
using WtcCrm.API.Controllers.Handlers;
using WtcCrm.Application.DTOs;
using WtcCrm.Application.Services;
using WtcCrm.Application.Wrappers;

namespace WtcCrm.API.Controllers.BaseAuthController
{
    public partial class AuthController
    {
        [HttpPost("login")]
        public async Task<IActionResult> Login(
            [FromBody] LoginRequest request,
            [FromServices] LoginHandler handler)
        {
            var response = await handler.HandleAsync(request);
            
            if (!response.IsSuccess) return Unauthorized(response);
            
            return Ok(response);
        }
    }
}

namespace WtcCrm.API.Controllers.Handlers
{
    public class LoginHandler(AuthService _authService)
    {
        public async Task<BaseResponse<AuthResponse>> HandleAsync(LoginRequest request)
        {
            return await _authService.LoginAsync(request);
        }
    }
}