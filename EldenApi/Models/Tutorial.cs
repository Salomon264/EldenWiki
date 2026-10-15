using System;
using System.Collections.Generic;

namespace EldenApi.Models;

public partial class Tutorial
{
    public uint Id { get; set; }

    public string Name { get; set; } = null!;

    public string? Description { get; set; }

    public virtual ICollection<Mechanic> Mechanics { get; set; } = new List<Mechanic>();
}
