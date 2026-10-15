using System;
using System.Collections.Generic;

namespace EldenApi.Models;

public partial class VItem
{
    public uint Id { get; set; }

    public string Name { get; set; } = null!;

    public string Category { get; set; } = null!;

    public string ItemType { get; set; } = null!;

    public string? DamageType { get; set; }

    public string? Skill { get; set; }

    public decimal Weight { get; set; }

    public string? Effect { get; set; }

    public string? Obtain { get; set; }
}
