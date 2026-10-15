using EldenApi.Dtos;
using EldenApi.Models;
using EldenApi.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace EldenApi.Controllers;

/// <summary>
/// Профиль пользователя: просмотр и редактирование.
/// </summary>
[ApiController]
[Route("api/profile")]
public class ProfileController(EldenwikiContext db) : ControllerBase
{
    /// <summary>Просмотр профиля по идентификатору пользователя.</summary>
    [HttpGet("{id}")]
    public async Task<ActionResult<ProfileDto>> GetProfile(uint id)
    {
        var profile = await db.Users
            .AsNoTracking()
            .Where(u => u.Id == id)
            .Select(u => new ProfileDto(
                u.Id,
                u.Login,
                u.RoleId,
                u.Role.Name,
                u.CreatedAt,
                u.Builds.Count))
            .FirstOrDefaultAsync();

        if (profile is null)
        {
            return NotFound();
        }

        return Ok(profile);
    }

    /// <summary>Редактирование профиля (пароль меняется только если он указан).</summary>
    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateProfile(uint id, UpdateProfileDto dto)
    {
        if (string.IsNullOrWhiteSpace(dto.Login))
        {
            return BadRequest("Логин обязателен.");
        }

        var user = await db.Users.FirstOrDefaultAsync(u => u.Id == id);
        if (user is null)
        {
            return NotFound();
        }

        if (await db.Users.AnyAsync(u => u.Id != id && u.Login == dto.Login))
        {
            return Conflict($"Логин '{dto.Login}' уже занят.");
        }

        user.Login = dto.Login;

        if (!string.IsNullOrWhiteSpace(dto.NewPassword))
        {
            user.PasswordHash = PasswordHasher.Hash(dto.NewPassword);
        }

        await db.SaveChangesAsync();

        return NoContent();
    }
}
