namespace EldenApi.Dtos;

public record ArticleListItemDto(
    uint Id,
    string Name,
    string Category,
    string ItemType,
    decimal Weight);

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

public record UpdateArticleDto(
    string Name,
    uint TypeId,
    decimal Weight,
    ushort? DamageTypeId,
    uint? SkillId,
    string? Effect,
    string? Obtain);

public record CategorySummaryDto(
    string Category,
    int Count);
