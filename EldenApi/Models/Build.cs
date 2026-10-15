using System;
using System.Collections.Generic;

namespace EldenApi.Models;

public partial class Build
{
    public uint Id { get; set; }

    public uint UserId { get; set; }

    public string Name { get; set; } = null!;

    public DateTime CreatedAt { get; set; }

    public virtual ICollection<BuildStat> BuildStats { get; set; } = new List<BuildStat>();

    public virtual User User { get; set; } = null!;

    public virtual ICollection<Item> Items { get; set; } = new List<Item>();
}
