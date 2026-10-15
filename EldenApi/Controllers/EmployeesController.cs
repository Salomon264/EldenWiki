using EldenApi.Dtos;
using EldenApi.Models;
using EldenApi.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace EldenApi.Controllers;

[ApiController]
[Route("api/employees")]
public class EmployeesController(EldenwikiContext db) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<IEnumerable<EmployeeListItemDto>>> GetEmployees()
    {
        var employees = await db.Users
            .AsNoTracking()
            .OrderBy(u => u.Login)
            .Select(u => new EmployeeListItemDto(
                u.Id,
                u.Login,
                u.RoleId,
                u.Role.Name,
                u.CreatedAt))
            .ToListAsync();

        return Ok(employees);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<EmployeeDto>> GetEmployee(uint id)
    {
        var employee = await db.Users
            .AsNoTracking()
            .Where(u => u.Id == id)
            .Select(u => new EmployeeDto(
                u.Id,
                u.Login,
                u.RoleId,
                u.Role.Name,
                u.CreatedAt))
            .FirstOrDefaultAsync();

        if (employee is null)
        {
            return NotFound();
        }

        return Ok(employee);
    }

    [HttpPost]
    public async Task<ActionResult<EmployeeDto>> CreateEmployee(CreateEmployeeDto dto)
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
            return Conflict($"Сотрудник с логином '{dto.Login}' уже существует.");
        }

        if (!await db.Roles.AnyAsync(r => r.Id == dto.RoleId))
        {
            return BadRequest($"Роль с id={dto.RoleId} не найдена.");
        }

        var user = new User
        {
            Login = dto.Login,
            PasswordHash = PasswordHasher.Hash(dto.Password),
            RoleId = dto.RoleId,
            CreatedAt = DateTime.UtcNow
        };

        db.Users.Add(user);
        await db.SaveChangesAsync();

        var roleName = await db.Roles
            .Where(r => r.Id == user.RoleId)
            .Select(r => r.Name)
            .FirstAsync();

        var result = new EmployeeDto(user.Id, user.Login, user.RoleId, roleName, user.CreatedAt);

        return CreatedAtAction(nameof(GetEmployee), new { id = user.Id }, result);
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateEmployee(uint id, UpdateEmployeeDto dto)
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
            return Conflict($"Сотрудник с логином '{dto.Login}' уже существует.");
        }

        if (!await db.Roles.AnyAsync(r => r.Id == dto.RoleId))
        {
            return BadRequest($"Роль с id={dto.RoleId} не найдена.");
        }

        user.Login = dto.Login;
        user.RoleId = dto.RoleId;

        if (!string.IsNullOrWhiteSpace(dto.Password))
        {
            user.PasswordHash = PasswordHasher.Hash(dto.Password);
        }

        await db.SaveChangesAsync();

        return NoContent();
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteEmployee(uint id)
    {
        var user = await db.Users.FirstOrDefaultAsync(u => u.Id == id);
        if (user is null)
        {
            return NotFound();
        }

        db.Users.Remove(user);

        try
        {
            await db.SaveChangesAsync();
        }
        catch (DbUpdateException ex)
        {
            return Conflict($"Не удалось удалить сотрудника: {ex.InnerException?.Message ?? ex.Message}");
        }

        return NoContent();
    }
}
