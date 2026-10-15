using System;
using System.Collections.Generic;

namespace EldenApi.Models;

public partial class VDrop
{
    public string Creature { get; set; } = null!;

    public string Item { get; set; } = null!;

    public string ItemCategory { get; set; } = null!;
}
