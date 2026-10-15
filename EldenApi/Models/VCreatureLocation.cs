using System;
using System.Collections.Generic;

namespace EldenApi.Models;

public partial class VCreatureLocation
{
    public string Creature { get; set; } = null!;

    public string CreatureType { get; set; } = null!;

    public string Location { get; set; } = null!;

    public string Region { get; set; } = null!;
}
