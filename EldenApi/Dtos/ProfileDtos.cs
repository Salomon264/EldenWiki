namespace EldenApi.Dtos;

public record ProfileDto(
    uint Id,
    string Login,
    byte RoleId,
    string Role,
    DateTime CreatedAt,
    int BuildsCount);

public record UpdateProfileDto(
    string Login,
    string? NewPassword);
