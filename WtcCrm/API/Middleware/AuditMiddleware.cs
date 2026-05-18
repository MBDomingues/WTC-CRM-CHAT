using System.Security.Claims;
using System.Text;
using WtcCrm.Domain.Entities;
using WtcCrm.Infrastructure.Data;

namespace WtcCrm.API.Middleware
{
    public class AuditMiddleware
    {
        private readonly RequestDelegate _next;

        public AuditMiddleware(RequestDelegate next)
        {
            _next = next;
        }

        public async Task InvokeAsync(HttpContext context, AppDbContext dbContext)
        {
            if (!context.Request.Path.StartsWithSegments("/api"))
            {
                await _next(context);
                return;
            }

            context.Request.EnableBuffering();
            var requestBody = await ReadRequestBody(context.Request);

            var originalBodyStream = context.Response.Body;
            using var responseBodyMemoryStream = new MemoryStream();
            context.Response.Body = responseBodyMemoryStream;

            Exception? capturedException = null;

            try
            {
                await _next(context);
            }
            catch (Exception ex)
            {
                capturedException = ex;
                context.Response.StatusCode = 500; 
                throw;
            }
            finally
            {
                responseBodyMemoryStream.Seek(0, SeekOrigin.Begin);
                var responseBodyText = await new StreamReader(responseBodyMemoryStream).ReadToEndAsync();
                responseBodyMemoryStream.Seek(0, SeekOrigin.Begin);

                if (requestBody.Contains("password", StringComparison.OrdinalIgnoreCase)) 
                {
                    requestBody = "Conteúdo oculto por segurança (contém senhas)";
                }

                if (responseBodyText.Contains("password", StringComparison.OrdinalIgnoreCase)) 
                {
                    responseBodyText = "Conteúdo oculto por segurança (contém senhas)";
                }

                var userIdentifier = context.User.FindFirst(ClaimTypes.Email)?.Value 
                                  ?? context.User.FindFirst(ClaimTypes.NameIdentifier)?.Value 
                                  ?? "Anonymous";

                var auditLog = new AuditLog
                {
                    Action = $"{context.Request.Method} {context.Request.Path}",
                    StatusCode = context.Response.StatusCode,
                    IpAddress = context.Connection.RemoteIpAddress?.ToString() ?? "Unknown",
                    UserEmail = userIdentifier,
                    RequestBody = requestBody,
                    ResponseBody = responseBodyText,
                    ExceptionMessage = capturedException?.Message,
                    StackTrace = capturedException?.StackTrace,
                    Timestamp = DateTime.UtcNow
                };

                dbContext.AuditLogs.Add(auditLog);
                await dbContext.SaveChangesAsync();

                await responseBodyMemoryStream.CopyToAsync(originalBodyStream);
                context.Response.Body = originalBodyStream;
            }
        }

        private async Task<string> ReadRequestBody(HttpRequest request)
        {
            request.Body.Position = 0;
            using var reader = new StreamReader(request.Body, Encoding.UTF8, true, 1024, true);
            var body = await reader.ReadToEndAsync();
            request.Body.Position = 0;
            return body;
        }
    }
}