using System.Text;
using EldenApi.Models;
using EldenApi.Services;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;

var builder = WebApplication.CreateBuilder(args);

// Регистрация контроллеров.
builder.Services.AddControllers();

// Контекст базы данных (строка подключения задана в EldenwikiContext.OnConfiguring).
builder.Services.AddDbContext<EldenwikiContext>();

// Сервис генерации JWT-токенов.
builder.Services.AddScoped<JwtTokenService>();

// Аутентификация по JWT-токену (Bearer). Ключ подписи берётся из секции "Jwt"
// или из переменной окружения Jwt__Key.
var jwtKey = builder.Configuration["Jwt:Key"]
    ?? throw new InvalidOperationException(
        "Не задан ключ подписи JWT (Jwt:Key или переменная окружения Jwt__Key).");

builder.Services
    .AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = builder.Configuration["Jwt:Issuer"] ?? JwtTokenService.DefaultIssuer,
            ValidAudience = builder.Configuration["Jwt:Audience"] ?? JwtTokenService.DefaultAudience,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey))
        };
    });

builder.Services.AddAuthorization();

// Swagger / Swashbuckle для ручного тестирования API.
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(options =>
    {
        options.SwaggerEndpoint("/swagger/v1/swagger.json", "Elden Wiki API v1");
    });
}

app.UseHttpsRedirection();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();
