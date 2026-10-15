using System;
using System.Collections.Generic;

namespace EldenApi.Models;

public partial class Skill
{
    public uint Id { get; set; }

    public string Name { get; set; } = null!;

    public string? Description { get; set; }

    public virtual ICollection<Item> Items { get; set; } = new List<Item>();
}
