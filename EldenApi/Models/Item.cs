using System;
using System.Collections.Generic;

namespace EldenApi.Models;

public partial class Item
{
    public uint Id { get; set; }

    public string Name { get; set; } = null!;

    public uint TypeId { get; set; }

    public decimal Weight { get; set; }

    public ushort? DamageTypeId { get; set; }

    public uint? SkillId { get; set; }

    public string? Effect { get; set; }

    public string? Obtain { get; set; }

    public virtual Stat? DamageType { get; set; }

    public virtual ICollection<ItemStat> ItemStats { get; set; } = new List<ItemStat>();

    public virtual Skill? Skill { get; set; }

    public virtual ItemType Type { get; set; } = null!;

    public virtual ICollection<Build> Builds { get; set; } = new List<Build>();

    public virtual ICollection<Creature> Creatures { get; set; } = new List<Creature>();
}
