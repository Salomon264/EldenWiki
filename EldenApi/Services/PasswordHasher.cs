using System.Security.Cryptography;
using System.Text;

namespace EldenApi.Services;

/// <summary>Простое хеширование паролей (SHA-256) для хранения в поле password_hash.</summary>
public static class PasswordHasher
{
    public static string Hash(string password)
    {
        var bytes = Encoding.UTF8.GetBytes(password);
        var hash = SHA256.HashData(bytes);
        return Convert.ToHexString(hash).ToLowerInvariant();
    }
}
