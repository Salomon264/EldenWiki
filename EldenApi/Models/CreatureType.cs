using System;
using System.Collections.Generic;

namespace EldenApi.Models;

public partial class CreatureType
{
    public uint Id { get; set; }

    public string Name { get; set; } = null!;

    public string Role { get; set; } = null!;

    public virtual ICollection<Creature> Creatures { get; set; } = new List<Creature>();
}
