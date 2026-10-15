using System;
using System.Collections.Generic;

namespace EldenApi.Models;

public partial class User
{
    public uint Id { get; set; }

    public string Login { get; set; } = null!;

    public string PasswordHash { get; set; } = null!;

    public byte RoleId { get; set; }

    public DateTime CreatedAt { get; set; }

    public virtual ICollection<Build> Builds { get; set; } = new List<Build>();

    public virtual Role Role { get; set; } = null!;
}
