namespace EldenApi.Dtos;

/// <summary>Информация о профиле пользователя.</summary>
public record ProfileDto(
    uint Id,
    string Login,
    byte RoleId,
    string Role,
    DateTime CreatedAt,
    int BuildsCount);

/// <summary>Данные для редактирования профиля (пароль меняется только если указан).</summary>
public record UpdateProfileDto(
    string Login,
    string? NewPassword);
