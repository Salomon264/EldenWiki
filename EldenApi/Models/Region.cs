using System;
using System.Collections.Generic;

namespace EldenApi.Models;

public partial class Region
{
    public uint Id { get; set; }

    public string Name { get; set; } = null!;

    public virtual ICollection<Location> Locations { get; set; } = new List<Location>();
}
