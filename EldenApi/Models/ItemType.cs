using System;
using System.Collections.Generic;

namespace EldenApi.Models;

public partial class ItemType
{
    public uint Id { get; set; }

    public string Name { get; set; } = null!;

    public string Category { get; set; } = null!;

    public virtual ICollection<Item> Items { get; set; } = new List<Item>();
}
