namespace EldenApi.Dtos;

public record RegisterDto(
    string Login,
    string Password);

public record LoginDto(
    string Login,
    string Password);

public record AuthResponseDto(
    string Token,
    DateTime ExpiresAt,
    uint Id,
    string Login,
    byte RoleId,
    string Role);
