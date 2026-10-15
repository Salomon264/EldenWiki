using System;
using System.Collections.Generic;

namespace EldenApi.Models;

public partial class ItemStat
{
    public uint ItemId { get; set; }

    public ushort StatId { get; set; }

    public string Purpose { get; set; } = null!;

    public decimal Value { get; set; }

    public virtual Item Item { get; set; } = null!;

    public virtual Stat Stat { get; set; } = null!;
}
