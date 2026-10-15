using System;
using System.Collections.Generic;

namespace EldenApi.Models;

public partial class Location
{
    public uint Id { get; set; }

    public uint RegionId { get; set; }

    public string Name { get; set; } = null!;

    public string? Description { get; set; }

    public virtual Region Region { get; set; } = null!;

    public virtual ICollection<Creature> Creatures { get; set; } = new List<Creature>();
}
