namespace EldenApi.Dtos;

public record EmployeeListItemDto(
    uint Id,
    string Login,
    byte RoleId,
    string Role,
    DateTime CreatedAt);

public record EmployeeDto(
    uint Id,
    string Login,
    byte RoleId,
    string Role,
    DateTime CreatedAt);

public record CreateEmployeeDto(
    string Login,
    string Password,
    byte RoleId);

public record UpdateEmployeeDto(
    string Login,
    string? Password,
    byte RoleId);
