namespace EldenApi.Dtos;

/// <summary>Краткая карточка статьи (предмета) для списков.</summary>
public record ArticleListItemDto(
    uint Id,
    string Name,
    string Category,
    string ItemType,
    decimal Weight);

/// <summary>Полная информация о статье (предмете).</summary>
public record ArticleDto(
    uint Id,
    string Name,
    uint TypeId,
    string ItemType,
    string Category,
    decimal Weight,
    ushort? DamageTypeId,
    string? DamageType,
    uint? SkillId,
    string? Skill,
    string? Effect,
    string? Obtain);

/// <summary>Данные для редактирования статьи.</summary>
public record UpdateArticleDto(
    string Name,
    uint TypeId,
    decimal Weight,
    ushort? DamageTypeId,
    uint? SkillId,
    string? Effect,
    string? Obtain);

/// <summary>Категория и количество относящихся к ней статей.</summary>
public record CategorySummaryDto(
    string Category,
    int Count);
