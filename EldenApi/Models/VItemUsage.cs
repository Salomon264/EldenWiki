using System;
using System.Collections.Generic;

namespace EldenApi.Models;

public partial class VItemUsage
{
    public uint Id { get; set; }

    public string Name { get; set; } = null!;

    public string Category { get; set; } = null!;

    public long BuildsCount { get; set; }
}
