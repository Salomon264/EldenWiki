using EldenApi.Models;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Регистрация контроллеров.
builder.Services.AddControllers();

// Контекст базы данных (строка подключения задана в EldenwikiContext.OnConfiguring).
builder.Services.AddDbContext<EldenwikiContext>();

// Swagger / Swashbuckle для ручного тестирования API.
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(options =>
    {
        options.SwaggerEndpoint("/swagger/v1/swagger.json", "Elden Wiki API v1");
    });
}

app.UseHttpsRedirection();

app.MapControllers();

app.Run();
