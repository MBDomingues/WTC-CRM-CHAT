using System.Data;
using System.Security.Claims;
using WtcCrm.Application.DTOs;

namespace WtcCrm.API.Controllers.Handlers
{
    public class BaseHandler(IHttpContextAccessor _httpContextAccessor )
    {
         protected async Task<string> GetUserIdAsync()
        {
            var userId = _httpContextAccessor.HttpContext?.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(userId))
                throw new UnauthorizedAccessException("Não foi possível identificar o usuário logado no Token.");

            return userId;
        }
        protected async Task<string> GetUserRoleAsync()
        {
            var userRole = _httpContextAccessor.HttpContext?.User?.FindFirst(ClaimTypes.Role)?.Value;
            if (string.IsNullOrEmpty(userRole))
                throw new UnauthorizedAccessException("Não foi possível identificar o papel do usuário logado no Token.");

            return userRole;
        }

        protected async Task<UserCaracteristicsResponse>CheckPermissionAsync()
        {
            try 
            {
                var userRole = await GetUserRoleAsync();
                var userId = await GetUserIdAsync();
                
                if (userRole != "Admin" && userRole != "Operator")
                {
                    throw new UnauthorizedAccessException("Acesso negado: Apenas Administradores ou Operadores podem acessar este recurso.");
                }

                return new UserCaracteristicsResponse(userId, userRole);
            }
            catch (UnauthorizedAccessException)
            {
                throw new UnauthorizedAccessException("Acesso negado: Token inválido ou expirado.");
            }
        }
    }
}