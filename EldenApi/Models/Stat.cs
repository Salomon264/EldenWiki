using System;
using System.Collections.Generic;

namespace EldenApi.Models;

public partial class Stat
{
    public ushort Id { get; set; }

    public string Name { get; set; } = null!;

    public string Kind { get; set; } = null!;

    public string? Description { get; set; }

    public virtual ICollection<BuildStat> BuildStats { get; set; } = new List<BuildStat>();

    public virtual ICollection<ItemStat> ItemStats { get; set; } = new List<ItemStat>();

    public virtual ICollection<Item> Items { get; set; } = new List<Item>();

    public virtual ICollection<Mechanic> Mechanics { get; set; } = new List<Mechanic>();
}
