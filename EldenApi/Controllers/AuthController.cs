using EldenApi.Dtos;
using EldenApi.Models;
using EldenApi.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace EldenApi.Controllers;

[ApiController]
[Route("api/auth")]
public class AuthController(EldenwikiContext db, JwtTokenService tokens) : ControllerBase
{
    // Роль, которая назначается пользователю при самостоятельной регистрации (player).
    private const byte DefaultRoleId = 1;

    [HttpPost("register")]
    public async Task<ActionResult<AuthResponseDto>> Register(RegisterDto dto)
    {
        if (string.IsNullOrWhiteSpace(dto.Login))
        {
            return BadRequest("Логин обязателен.");
        }

        if (string.IsNullOrWhiteSpace(dto.Password))
        {
            return BadRequest("Пароль обязателен.");
        }

        if (await db.Users.AnyAsync(u => u.Login == dto.Login))
        {
            return Conflict($"Пользователь с логином '{dto.Login}' уже существует.");
        }

        var role = await db.Roles.FirstOrDefaultAsync(r => r.Id == DefaultRoleId);
        if (role is null)
        {
            return Problem($"Роль по умолчанию (id={DefaultRoleId}) не найдена.");
        }

        var user = new User
        {
            Login = dto.Login,
            PasswordHash = PasswordHasher.Hash(dto.Password),
            RoleId = role.Id,
            CreatedAt = DateTime.UtcNow
        };

        db.Users.Add(user);
        await db.SaveChangesAsync();

        var (token, expiresAt) = tokens.CreateToken(user, role.Name);

        return Ok(new AuthResponseDto(token, expiresAt, user.Id, user.Login, user.RoleId, role.Name));
    }

    [HttpPost("login")]
    public async Task<ActionResult<AuthResponseDto>> Login(LoginDto dto)
    {
        if (string.IsNullOrWhiteSpace(dto.Login) || string.IsNullOrWhiteSpace(dto.Password))
        {
            return BadRequest("Логин и пароль обязательны.");
        }

        var user = await db.Users
            .Include(u => u.Role)
            .FirstOrDefaultAsync(u => u.Login == dto.Login);

        if (user is null || user.PasswordHash != PasswordHasher.Hash(dto.Password))
        {
            return Unauthorized("Неверный логин или пароль.");
        }

        var (token, expiresAt) = tokens.CreateToken(user, user.Role.Name);

        return Ok(new AuthResponseDto(token, expiresAt, user.Id, user.Login, user.RoleId, user.Role.Name));
    }
}
