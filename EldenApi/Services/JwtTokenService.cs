using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using EldenApi.Models;
using Microsoft.IdentityModel.Tokens;

namespace EldenApi.Services;

/// <summary>
/// Генерирует JWT-токены для аутентифицированных пользователей.
/// Параметры берутся из секции конфигурации "Jwt"
/// (ключ можно переопределить переменной окружения Jwt__Key).
/// </summary>
public class JwtTokenService(IConfiguration configuration)
{
    public const string DefaultIssuer = "EldenWiki";
    public const string DefaultAudience = "EldenWiki";
    private const int DefaultLifetimeMinutes = 120;

    public (string Token, DateTime ExpiresAt) CreateToken(User user, string roleName)
    {
        var key = configuration["Jwt:Key"]
            ?? throw new InvalidOperationException(
                "Не задан ключ подписи JWT (Jwt:Key или переменная окружения Jwt__Key).");

        var issuer = configuration["Jwt:Issuer"] ?? DefaultIssuer;
        var audience = configuration["Jwt:Audience"] ?? DefaultAudience;
        var lifetimeMinutes = int.TryParse(configuration["Jwt:LifetimeMinutes"], out var minutes)
            ? minutes
            : DefaultLifetimeMinutes;

        var expiresAt = DateTime.UtcNow.AddMinutes(lifetimeMinutes);

        var claims = new List<Claim>
        {
            new(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
            new(ClaimTypes.NameIdentifier, user.Id.ToString()),
            new(ClaimTypes.Name, user.Login),
            new(ClaimTypes.Role, roleName),
            new(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
        };

        var credentials = new SigningCredentials(
            new SymmetricSecurityKey(Encoding.UTF8.GetBytes(key)),
            SecurityAlgorithms.HmacSha256);

        var token = new JwtSecurityToken(
            issuer: issuer,
            audience: audience,
            claims: claims,
            expires: expiresAt,
            signingCredentials: credentials);

        return (new JwtSecurityTokenHandler().WriteToken(token), expiresAt);
    }
}
