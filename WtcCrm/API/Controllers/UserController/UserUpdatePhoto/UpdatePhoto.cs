using Domain.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WtcCrm.API.Controllers.Handlers;
using WtcCrm.Application.DTOs;
using WtcCrm.Application.Wrappers;
using WtcCrm.Domain.Interfaces;

namespace WtcCrm.API.Controllers.BaseAuthController
{
    public partial class AuthController
    {
        [HttpPatch("update-photo")]
        [Authorize]
        public async Task<IActionResult> UpdatePhoto(
            [FromForm] UpdatePhotoRequest request,
            [FromServices] UpdatePhotoHandler handler)
        {
            var response = await handler.HandleAsync(request.Photo);

            if (!response.IsSuccess) return BadRequest(response);
            
            return Ok(response);
        }
    }
}

namespace WtcCrm.API.Controllers.Handlers
{
    public class UpdatePhotoHandler(
        IHttpContextAccessor _httpContextAccessor,
        IStorageService _storageService, 
        IUserRepository _userRepository
    ) : BaseHandler(_httpContextAccessor)
    {
        public async Task<BaseResponse<UpdatePhotoResponse>> HandleAsync(IFormFile photo)
        {
            if (photo == null || photo.Length == 0)
                return BaseResponse<UpdatePhotoResponse>.Error("Envie uma imagem válida.");

            try
            {
                var userId = await GetUserIdAsync(); 

                using var stream = photo.OpenReadStream();
                var imageKey = await _storageService.UploadFileAsync(
                    stream, 
                    photo.FileName, 
                    photo.ContentType, 
                    "profiles"
                );

                await _userRepository.UpdateUserImageAsync(userId, imageKey);

                var presignedUrl = _storageService.GetPresignedUrl(imageKey);

                return BaseResponse<UpdatePhotoResponse>.Success(new UpdatePhotoResponse(presignedUrl));
            }
            catch (Exception ex)
            {
                return BaseResponse<UpdatePhotoResponse>.Error($"Erro ao processar upload: {ex.Message}");
            }
        }
    }
}

namespace WtcCrm.Application.DTOs
{
    public record class UpdatePhotoRequest(IFormFile Photo);
    
}