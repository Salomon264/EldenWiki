using EldenApi.Dtos;
using EldenApi.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace EldenApi.Controllers;

/// <summary>
/// Статьи (предметы) вики: просмотр списка с фильтром по категории,
/// просмотр одной статьи, редактирование и удаление.
/// </summary>
[ApiController]
[Route("api/articles")]
public class ArticlesController(EldenwikiContext db) : ControllerBase
{
    /// <summary>Список статей с фильтром по категории, типу предмета и поиском по названию.</summary>
    /// <param name="category">Категория предмета: weapon, shield, armor, talisman, spell, material.</param>
    /// <param name="typeId">Идентификатор конкретного типа предмета.</param>
    /// <param name="search">Подстрока для поиска по названию.</param>
    [HttpGet]
    public async Task<ActionResult<IEnumerable<ArticleListItemDto>>> GetArticles(
        [FromQuery] string? category,
        [FromQuery] uint? typeId,
        [FromQuery] string? search)
    {
        var query = db.Items.AsNoTracking().AsQueryable();

        if (!string.IsNullOrWhiteSpace(category))
        {
            query = query.Where(i => i.Type.Category == category);
        }

        if (typeId is not null)
        {
            query = query.Where(i => i.TypeId == typeId);
        }

        if (!string.IsNullOrWhiteSpace(search))
        {
            query = query.Where(i => i.Name.Contains(search));
        }

        var articles = await query
            .OrderBy(i => i.Name)
            .Select(i => new ArticleListItemDto(
                i.Id,
                i.Name,
                i.Type.Category,
                i.Type.Name,
                i.Weight))
            .ToListAsync();

        return Ok(articles);
    }

    /// <summary>Список категорий с количеством статей в каждой.</summary>
    [HttpGet("categories")]
    public async Task<ActionResult<IEnumerable<CategorySummaryDto>>> GetCategories()
    {
        var categories = await db.Items
            .AsNoTracking()
            .GroupBy(i => i.Type.Category)
            .Select(g => new CategorySummaryDto(g.Key, g.Count()))
            .ToListAsync();

        return Ok(categories);
    }

    /// <summary>Получить статью по идентификатору.</summary>
    [HttpGet("{id}")]
    public async Task<ActionResult<ArticleDto>> GetArticle(uint id)
    {
        var article = await db.Items
            .AsNoTracking()
            .Where(i => i.Id == id)
            .Select(i => new ArticleDto(
                i.Id,
                i.Name,
                i.TypeId,
                i.Type.Name,
                i.Type.Category,
                i.Weight,
                i.DamageTypeId,
                i.DamageType != null ? i.DamageType.Name : null,
                i.SkillId,
                i.Skill != null ? i.Skill.Name : null,
                i.Effect,
                i.Obtain))
            .FirstOrDefaultAsync();

        if (article is null)
        {
            return NotFound();
        }

        return Ok(article);
    }

    /// <summary>Отредактировать статью.</summary>
    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateArticle(uint id, UpdateArticleDto dto)
    {
        if (string.IsNullOrWhiteSpace(dto.Name))
        {
            return BadRequest("Название статьи обязательно.");
        }

        var article = await db.Items.FirstOrDefaultAsync(i => i.Id == id);
        if (article is null)
        {
            return NotFound();
        }

        if (!await db.ItemTypes.AnyAsync(t => t.Id == dto.TypeId))
        {
            return BadRequest($"Тип предмета с id={dto.TypeId} не найден.");
        }

        if (dto.DamageTypeId is not null && !await db.Stats.AnyAsync(s => s.Id == dto.DamageTypeId))
        {
            return BadRequest($"Тип урона с id={dto.DamageTypeId} не найден.");
        }

        if (dto.SkillId is not null && !await db.Skills.AnyAsync(s => s.Id == dto.SkillId))
        {
            return BadRequest($"Умение с id={dto.SkillId} не найдено.");
        }

        if (await db.Items.AnyAsync(i => i.Id != id && i.Name == dto.Name))
        {
            return Conflict($"Статья с названием '{dto.Name}' уже существует.");
        }

        article.Name = dto.Name;
        article.TypeId = dto.TypeId;
        article.Weight = dto.Weight;
        article.DamageTypeId = dto.DamageTypeId;
        article.SkillId = dto.SkillId;
        article.Effect = dto.Effect;
        article.Obtain = dto.Obtain;

        await db.SaveChangesAsync();

        return NoContent();
    }

    /// <summary>Удалить статью.</summary>
    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteArticle(uint id)
    {
        var article = await db.Items
            .Include(i => i.ItemStats)
            .FirstOrDefaultAsync(i => i.Id == id);

        if (article is null)
        {
            return NotFound();
        }

        db.ItemStats.RemoveRange(article.ItemStats);
        db.Items.Remove(article);

        try
        {
            await db.SaveChangesAsync();
        }
        catch (DbUpdateException ex)
        {
            return Conflict($"Не удалось удалить статью: {ex.InnerException?.Message ?? ex.Message}");
        }

        return NoContent();
    }
}
