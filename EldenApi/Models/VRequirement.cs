using System;
using System.Collections.Generic;

namespace EldenApi.Models;

public partial class VRequirement
{
    public uint Id { get; set; }

    public string Name { get; set; } = null!;

    public string Category { get; set; } = null!;

    public decimal Str { get; set; }

    public decimal Dex { get; set; }

    public decimal Intel { get; set; }

    public decimal Fai { get; set; }

    public decimal Arc { get; set; }
}
