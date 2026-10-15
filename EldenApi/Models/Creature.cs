using System;
using System.Collections.Generic;

namespace EldenApi.Models;

public partial class Creature
{
    public uint Id { get; set; }

    public string Name { get; set; } = null!;

    public uint TypeId { get; set; }

    public string? Description { get; set; }

    public string? Tactics { get; set; }

    public virtual CreatureType Type { get; set; } = null!;

    public virtual ICollection<Item> Items { get; set; } = new List<Item>();

    public virtual ICollection<Location> Locations { get; set; } = new List<Location>();
}
