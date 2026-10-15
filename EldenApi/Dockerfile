# syntax=docker/dockerfile:1

# --- Стадия сборки ---
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Сначала восстанавливаем зависимости отдельно, чтобы кэшировался слой restore.
COPY ["EldenApi.csproj", "./"]
RUN dotnet restore "EldenApi.csproj"

# Затем копируем исходники и публикуем приложение.
COPY . .
RUN dotnet publish "EldenApi.csproj" -c Release -o /app/publish /p:UseAppHost=false

# --- Стадия запуска ---
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app

# ASP.NET Core в контейнере слушает HTTP на порту 8080.
ENV ASPNETCORE_HTTP_PORTS=8080
EXPOSE 8080

COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "EldenApi.dll"]
