using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using WtcCrm.Application.DTOs;
using WtcCrm.Domain.Entities;
using WtcCrm.Domain.Interfaces;
using WtcCrm.Application.Wrappers;
using WtcCrm.Application.Utils;
using Domain.Interfaces;

namespace WtcCrm.Application.Services
{
    public class AuthService(
        IUserRepository _userRepository, 
        IConfiguration _config, 
        IStorageService _storageService)
    {
        public async Task<BaseResponse<AuthResponse>> RegisterAsync(RegisterRequest request)
        {
            if (!ValidationUtils.IsValidEmail(request.Email))
                return BaseResponse<AuthResponse>.Error("O formato do e-mail é inválido.");

            if (!ValidationUtils.IsValidCpf(request.DocumentId))
                return BaseResponse<AuthResponse>.Error("CPF inválido.");

            var userByDocument = await _userRepository.GetByDocumentIdAsync(request.DocumentId);
            if (userByDocument != null)
                return BaseResponse<AuthResponse>.Error("Este CPF já está cadastrado no sistema.");

            if (request.Password != request.ConfirmPassword)
                return BaseResponse<AuthResponse>.Error("As senhas não conferem.");

            var existingUser = await _userRepository.GetByEmailAsync(request.Email);
            if (existingUser != null) 
                return BaseResponse<AuthResponse>.Error("E-mail já cadastrado.");

            var user = new User
            {
                Name = request.Name,
                Email = request.Email,
                DocumentId = request.DocumentId,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password),
                Role = UserRole.User
            };

            await _userRepository.AddAsync(user);

            var authData = new AuthResponse(user.Id.ToString(), GenerateJwtToken(user), user.Name, user.Role.ToString());
            
            return BaseResponse<AuthResponse>.Success(authData);
        }

        public async Task<BaseResponse<AuthResponse>> LoginAsync(LoginRequest request)
        {
            var user = await _userRepository.GetByEmailAsync(request.Email);

            if (user == null || !BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash))
                return BaseResponse<AuthResponse>.Error("Informações de login inválidas.");

            string? imageUrl = null;
            if (!string.IsNullOrEmpty(user.ProfileImageKey))
            {
                imageUrl = _storageService.GetPresignedUrl(user.ProfileImageKey);
            }

            var authData = new AuthResponse(user.Id.ToString(),GenerateJwtToken(user), user.Name, user.Role.ToString(), imageUrl);
            
            return BaseResponse<AuthResponse>.Success(authData);
        }

        private string GenerateJwtToken(User user)
        {
            var jwtSettings = _config.GetSection("JwtSettings");
            var secret = jwtSettings["Secret"];
            
            if (string.IsNullOrEmpty(secret)) 
                throw new Exception("JWT Secret não configurado no appsettings.");

            var key = Encoding.ASCII.GetBytes(secret);

            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(new[]
                {
                    new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
                    new Claim(ClaimTypes.Name, user.Name),
                    new Claim(ClaimTypes.Email, user.Email),
                    new Claim(ClaimTypes.Role, user.Role.ToString())
                }),
                Expires = DateTime.UtcNow.AddMinutes(double.Parse(jwtSettings["ExpirationMinutes"] ?? "120")),
                SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(key), SecurityAlgorithms.HmacSha256Signature)
            };

            var tokenHandler = new JwtSecurityTokenHandler();
            var token = tokenHandler.CreateToken(tokenDescriptor);
            return tokenHandler.WriteToken(token);
        }
    }
}