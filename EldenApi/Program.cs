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
// Встроенный dev-ключ допускается, если окружение не задано явно (локальный запуск,
// docker run) либо задан Development — чтобы проект поднимался без настроек.
// При явном Production/Staging ключ обязателен: без него приложение не стартует.
const string devFallbackJwtKey = "dev-only-insecure-signing-key-change-me-0123456789";

var configuredEnvironment = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT");
var isStrictEnvironment =
    string.Equals(configuredEnvironment, "Production", StringComparison.OrdinalIgnoreCase)
    || string.Equals(configuredEnvironment, "Staging", StringComparison.OrdinalIgnoreCase);

var isDevFallbackJwtKey = false;
var jwtKey = builder.Configuration["Jwt:Key"];

if (string.IsNullOrWhiteSpace(jwtKey))
{
    if (isStrictEnvironment)
    {
        throw new InvalidOperationException(
            "Не задан ключ подписи JWT (Jwt:Key). Задайте переменную окружения Jwt__Key — "
            + "например, создайте файл .env со строкой JWT_KEY=... (см. .env.example) "
            + "или запустите стек командой 'docker compose up -d --build' из корня репозитория.");
    }

    jwtKey = devFallbackJwtKey;
    isDevFallbackJwtKey = true;

    // Значение доступно и JwtTokenService, и валидатору Bearer.
    builder.Configuration.AddInMemoryCollection(new Dictionary<string, string?>
    {
        ["Jwt:Key"] = jwtKey
    });
}

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

if (isDevFallbackJwtKey)
{
    app.Logger.LogWarning(
        "Ключ JWT не задан — используется встроенный dev-ключ. "
        + "Задайте Jwt__Key (см. .env.example) перед деплоем.");
}

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
