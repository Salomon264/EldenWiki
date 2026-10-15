using System;
using System.Collections.Generic;

namespace EldenApi.Models;

public partial class BuildStat
{
    public uint BuildId { get; set; }

    public ushort StatId { get; set; }

    public ushort Value { get; set; }

    public virtual Build Build { get; set; } = null!;

    public virtual Stat Stat { get; set; } = null!;
}
