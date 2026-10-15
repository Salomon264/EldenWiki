namespace EldenApi.Dtos;

/// <summary>Карточка сотрудника для списков.</summary>
public record EmployeeListItemDto(
    uint Id,
    string Login,
    byte RoleId,
    string Role,
    DateTime CreatedAt);

/// <summary>Полная информация о сотруднике.</summary>
public record EmployeeDto(
    uint Id,
    string Login,
    byte RoleId,
    string Role,
    DateTime CreatedAt);

/// <summary>Данные для создания сотрудника.</summary>
public record CreateEmployeeDto(
    string Login,
    string Password,
    byte RoleId);

/// <summary>Данные для редактирования сотрудника (пароль меняется только если указан).</summary>
public record UpdateEmployeeDto(
    string Login,
    string? Password,
    byte RoleId);
