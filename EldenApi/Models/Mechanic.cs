using System;
using System.Collections.Generic;

namespace EldenApi.Models;

public partial class Mechanic
{
    public uint Id { get; set; }

    public uint TutorialId { get; set; }

    public ushort? StatId { get; set; }

    public string Name { get; set; } = null!;

    public string? Description { get; set; }

    public virtual Stat? Stat { get; set; }

    public virtual Tutorial Tutorial { get; set; } = null!;
}
