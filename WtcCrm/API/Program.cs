using Amazon.S3;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using Domain.Interfaces;
using Infrastructure.Services;
using WtcCrm.API.Hubs;
using WtcCrm.API.Middleware;
using WtcCrm.Application.Services;
using WtcCrm.Domain.Interfaces;
using WtcCrm.Infrastructure.Data;
using WtcCrm.Infrastructure.Repositories;
using WtcCrm.API.Controllers.Handlers;

var builder = WebApplication.CreateBuilder(args);

// --- 1. Base Services ---
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddHttpContextAccessor();
builder.Services.AddSignalR();

// --- 2. Database Setup (MongoDB) ---
var mongoConnectionString = builder.Configuration.GetConnectionString("MongoConnection") 
    ?? throw new InvalidOperationException("Connection string not found.");
var databaseName = builder.Configuration.GetSection("DatabaseConfig:Name").Value 
    ?? "WTC-Chat";

// EF Core Configuration
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseMongoDB(mongoConnectionString, databaseName));

// Native Driver Configuration (Required for ChatRepository)
builder.Services.AddSingleton<MongoDB.Driver.IMongoClient>(sp => 
    new MongoDB.Driver.MongoClient(mongoConnectionString));

builder.Services.AddScoped<MongoDB.Driver.IMongoDatabase>(sp => 
{
    var client = sp.GetRequiredService<MongoDB.Driver.IMongoClient>();
    return client.GetDatabase(databaseName);
});

// --- 3. External Services (MinIO / S3) ---
var minioSettings = builder.Configuration.GetSection("Minio");
builder.Services.AddSingleton<IAmazonS3>(sp => 
{
    var config = new AmazonS3Config 
    {
        ServiceURL = minioSettings["Endpoint"],
        ForcePathStyle = true
    };
    return new AmazonS3Client(minioSettings["AccessKey"], minioSettings["SecretKey"], config);
});
builder.Services.AddScoped<IStorageService, S3StorageService>();

// --- 4. Authentication (JWT) ---
var jwtSettings = builder.Configuration.GetSection("JwtSettings");
var secretKey = jwtSettings["Secret"] 
    ?? throw new Exception("JWT Secret não encontrada no appsettings.json");
var key = Encoding.ASCII.GetBytes(secretKey);

builder.Services.AddAuthentication(a =>
{
    a.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    a.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(a =>
{
    a.RequireHttpsMetadata = false;
    a.SaveToken = true;
    a.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuerSigningKey = true,
        IssuerSigningKey = new SymmetricSecurityKey(key),
        ValidateIssuer = false,
        ValidateAudience = false,
        ClockSkew = TimeSpan.Zero
    };
});

// --- CORS (Allow All for Simplicity) ---
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()    // Permite qualquer site (bom para dev)
              .AllowAnyMethod()    // Permite GET, POST, PUT, DELETE...
              .AllowAnyHeader();   // Permite qualquer header (ex: Authorization)
    });
});

// --- 5. Dependency Injection (DI) ---
// Repositories & Application Services
builder.Services.AddScoped<IUserRepository, UserRepository>();
builder.Services.AddScoped<IChatRepository, ChatRepository>();
builder.Services.AddScoped<AuthService>();
builder.Services.AddScoped<IAnnouncementRepository, AnnouncementRepository>();
builder.Services.AddScoped<IChatGroupRepository, ChatGroupRepository>();
builder.Services.AddScoped<IAnnouncementDeliveryRepository, AnnouncementDeliveryRepository>();
builder.Services.AddScoped<ICustomerNoteRepository, CustomerNoteRepository>();
builder.Services.AddScoped<ISegmentRepository, SegmentRepository>();
// builder.Services.AddScoped<IAuditService, AuditService>(); 

// Handlers
builder.Services.AddScoped<RegisterHandler>();
builder.Services.AddScoped<LoginHandler>();
builder.Services.AddScoped<UpdatePhotoHandler>();
builder.Services.AddScoped<GetCustomersHandler>();
builder.Services.AddScoped<SendMessageHandler>();
builder.Services.AddScoped<GetChatMessagesHandler>();
builder.Services.AddScoped<GetActiveChatsHandler>();
builder.Services.AddScoped<SendAnnouncementHandler>();
builder.Services.AddScoped<CreateGroupHandler>();
builder.Services.AddScoped<GetAnnounceRecipientsHandler>();
builder.Services.AddScoped<GetAnnouncementsHandler>();
builder.Services.AddScoped<GetProfile360Handler>();
builder.Services.AddScoped<CreateCustomerNoteHandler>();
builder.Services.AddScoped<UpdateCustomerCrmHandler>();
builder.Services.AddScoped<GetSegmentsHandler>();
builder.Services.AddScoped<CreateSegmentHandler>();
builder.Services.AddScoped<UpdateSegmentHandler>();
builder.Services.AddScoped<DeleteSegmentHandler>();
builder.Services.AddScoped<UpdateMessageStatusHandler>();
builder.Services.AddScoped<GetCustomerNotesHandler>();
builder.Services.AddScoped<UpdateCustomerNoteHandler>();
builder.Services.AddScoped<DeleteCustomerNoteHandler>();

// --- 6. Pipeline Configuration ---
var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthentication();
app.UseAuthorization(); 

app.UseMiddleware<AuditMiddleware>(); 

app.MapControllers();
app.MapHub<ChatHub>("/chatHub"); 

app.Run();