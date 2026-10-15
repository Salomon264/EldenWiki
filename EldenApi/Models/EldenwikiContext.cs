using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;
using Pomelo.EntityFrameworkCore.MySql.Scaffolding.Internal;

namespace EldenApi.Models;

public partial class EldenwikiContext : DbContext
{
    public EldenwikiContext()
    {
    }

    public EldenwikiContext(DbContextOptions<EldenwikiContext> options)
        : base(options)
    {
    }

    public virtual DbSet<Build> Builds { get; set; }

    public virtual DbSet<BuildStat> BuildStats { get; set; }

    public virtual DbSet<Creature> Creatures { get; set; }

    public virtual DbSet<CreatureType> CreatureTypes { get; set; }

    public virtual DbSet<Item> Items { get; set; }

    public virtual DbSet<ItemStat> ItemStats { get; set; }

    public virtual DbSet<ItemType> ItemTypes { get; set; }

    public virtual DbSet<Location> Locations { get; set; }

    public virtual DbSet<Mechanic> Mechanics { get; set; }

    public virtual DbSet<Region> Regions { get; set; }

    public virtual DbSet<Role> Roles { get; set; }

    public virtual DbSet<Skill> Skills { get; set; }

    public virtual DbSet<Stat> Stats { get; set; }

    public virtual DbSet<Tutorial> Tutorials { get; set; }

    public virtual DbSet<User> Users { get; set; }

    public virtual DbSet<VCreatureLocation> VCreatureLocations { get; set; }

    public virtual DbSet<VDrop> VDrops { get; set; }

    public virtual DbSet<VItem> VItems { get; set; }

    public virtual DbSet<VItemUsage> VItemUsages { get; set; }

    public virtual DbSet<VRequirement> VRequirements { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        // Строка подключения берётся из переменной окружения ConnectionStrings__Default
        // (стандартное имя для .NET configuration), с откатом на локальное значение.
        var connectionString = Environment.GetEnvironmentVariable("ConnectionStrings__Default")
            ?? "server=localhost;database=eldenwiki;user=root;password=AlikGumerov8g";

        optionsBuilder.UseMySql(connectionString, ServerVersion.Parse("9.5.0-mysql"));
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder
            .UseCollation("utf8mb4_unicode_ci")
            .HasCharSet("utf8mb4");

        modelBuilder.Entity<Build>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PRIMARY");

            entity.ToTable("builds");

            entity.HasIndex(e => e.UserId, "idx_builds_user");

            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp")
                .HasColumnName("created_at");
            entity.Property(e => e.Name)
                .HasMaxLength(150)
                .HasColumnName("name");
            entity.Property(e => e.UserId).HasColumnName("user_id");

            entity.HasOne(d => d.User).WithMany(p => p.Builds)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("builds_ibfk_1");

            entity.HasMany(d => d.Items).WithMany(p => p.Builds)
                .UsingEntity<Dictionary<string, object>>(
                    "BuildItem",
                    r => r.HasOne<Item>().WithMany()
                        .HasForeignKey("ItemId")
                        .OnDelete(DeleteBehavior.ClientSetNull)
                        .HasConstraintName("build_items_ibfk_2"),
                    l => l.HasOne<Build>().WithMany()
                        .HasForeignKey("BuildId")
                        .HasConstraintName("build_items_ibfk_1"),
                    j =>
                    {
                        j.HasKey("BuildId", "ItemId")
                            .HasName("PRIMARY")
                            .HasAnnotation("MySql:IndexPrefixLength", new[] { 0, 0 });
                        j.ToTable("build_items");
                        j.HasIndex(new[] { "ItemId" }, "idx_bi_item");
                        j.IndexerProperty<uint>("BuildId").HasColumnName("build_id");
                        j.IndexerProperty<uint>("ItemId").HasColumnName("item_id");
                    });
        });

        modelBuilder.Entity<BuildStat>(entity =>
        {
            entity.HasKey(e => new { e.BuildId, e.StatId })
                .HasName("PRIMARY")
                .HasAnnotation("MySql:IndexPrefixLength", new[] { 0, 0 });

            entity.ToTable("build_stats");

            entity.HasIndex(e => e.StatId, "stat_id");

            entity.Property(e => e.BuildId).HasColumnName("build_id");
            entity.Property(e => e.StatId).HasColumnName("stat_id");
            entity.Property(e => e.Value).HasColumnName("value");

            entity.HasOne(d => d.Build).WithMany(p => p.BuildStats)
                .HasForeignKey(d => d.BuildId)
                .HasConstraintName("build_stats_ibfk_1");

            entity.HasOne(d => d.Stat).WithMany(p => p.BuildStats)
                .HasForeignKey(d => d.StatId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("build_stats_ibfk_2");
        });

        modelBuilder.Entity<Creature>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PRIMARY");

            entity.ToTable("creatures");

            entity.HasIndex(e => e.TypeId, "idx_creatures_type");

            entity.HasIndex(e => e.Name, "name").IsUnique();

            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.Description)
                .HasColumnType("text")
                .HasColumnName("description");
            entity.Property(e => e.Name)
                .HasMaxLength(150)
                .HasColumnName("name");
            entity.Property(e => e.Tactics)
                .HasColumnType("text")
                .HasColumnName("tactics");
            entity.Property(e => e.TypeId).HasColumnName("type_id");

            entity.HasOne(d => d.Type).WithMany(p => p.Creatures)
                .HasForeignKey(d => d.TypeId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("creatures_ibfk_1");

            entity.HasMany(d => d.Items).WithMany(p => p.Creatures)
                .UsingEntity<Dictionary<string, object>>(
                    "Drop",
                    r => r.HasOne<Item>().WithMany()
                        .HasForeignKey("ItemId")
                        .OnDelete(DeleteBehavior.ClientSetNull)
                        .HasConstraintName("drops_ibfk_2"),
                    l => l.HasOne<Creature>().WithMany()
                        .HasForeignKey("CreatureId")
                        .OnDelete(DeleteBehavior.ClientSetNull)
                        .HasConstraintName("drops_ibfk_1"),
                    j =>
                    {
                        j.HasKey("CreatureId", "ItemId")
                            .HasName("PRIMARY")
                            .HasAnnotation("MySql:IndexPrefixLength", new[] { 0, 0 });
                        j.ToTable("drops");
                        j.HasIndex(new[] { "ItemId" }, "idx_drops_item");
                        j.IndexerProperty<uint>("CreatureId").HasColumnName("creature_id");
                        j.IndexerProperty<uint>("ItemId").HasColumnName("item_id");
                    });

            entity.HasMany(d => d.Locations).WithMany(p => p.Creatures)
                .UsingEntity<Dictionary<string, object>>(
                    "CreatureLocation",
                    r => r.HasOne<Location>().WithMany()
                        .HasForeignKey("LocationId")
                        .OnDelete(DeleteBehavior.ClientSetNull)
                        .HasConstraintName("creature_locations_ibfk_2"),
                    l => l.HasOne<Creature>().WithMany()
                        .HasForeignKey("CreatureId")
                        .OnDelete(DeleteBehavior.ClientSetNull)
                        .HasConstraintName("creature_locations_ibfk_1"),
                    j =>
                    {
                        j.HasKey("CreatureId", "LocationId")
                            .HasName("PRIMARY")
                            .HasAnnotation("MySql:IndexPrefixLength", new[] { 0, 0 });
                        j.ToTable("creature_locations");
                        j.HasIndex(new[] { "LocationId" }, "idx_cl_location");
                        j.IndexerProperty<uint>("CreatureId").HasColumnName("creature_id");
                        j.IndexerProperty<uint>("LocationId").HasColumnName("location_id");
                    });
        });

        modelBuilder.Entity<CreatureType>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PRIMARY");

            entity.ToTable("creature_types");

            entity.HasIndex(e => e.Name, "name").IsUnique();

            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.Name)
                .HasMaxLength(100)
                .HasColumnName("name");
            entity.Property(e => e.Role)
                .HasColumnType("enum('npc','enemy')")
                .HasColumnName("role");
        });

        modelBuilder.Entity<Item>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PRIMARY");

            entity.ToTable("items");

            entity.HasIndex(e => e.DamageTypeId, "idx_items_damage");

            entity.HasIndex(e => e.TypeId, "idx_items_type");

            entity.HasIndex(e => e.Name, "name").IsUnique();

            entity.HasIndex(e => e.SkillId, "skill_id");

            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.DamageTypeId).HasColumnName("damage_type_id");
            entity.Property(e => e.Effect)
                .HasColumnType("text")
                .HasColumnName("effect");
            entity.Property(e => e.Name)
                .HasMaxLength(150)
                .HasColumnName("name");
            entity.Property(e => e.Obtain)
                .HasColumnType("text")
                .HasColumnName("obtain");
            entity.Property(e => e.SkillId).HasColumnName("skill_id");
            entity.Property(e => e.TypeId).HasColumnName("type_id");
            entity.Property(e => e.Weight)
                .HasPrecision(5, 1)
                .HasColumnName("weight");

            entity.HasOne(d => d.DamageType).WithMany(p => p.Items)
                .HasForeignKey(d => d.DamageTypeId)
                .HasConstraintName("items_ibfk_2");

            entity.HasOne(d => d.Skill).WithMany(p => p.Items)
                .HasForeignKey(d => d.SkillId)
                .HasConstraintName("items_ibfk_3");

            entity.HasOne(d => d.Type).WithMany(p => p.Items)
                .HasForeignKey(d => d.TypeId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("items_ibfk_1");
        });

        modelBuilder.Entity<ItemStat>(entity =>
        {
            entity.HasKey(e => new { e.ItemId, e.Purpose, e.StatId })
                .HasName("PRIMARY")
                .HasAnnotation("MySql:IndexPrefixLength", new[] { 0, 0, 0 });

            entity.ToTable("item_stats");

            entity.HasIndex(e => new { e.StatId, e.Purpose, e.Value }, "idx_istats_search");

            entity.Property(e => e.ItemId).HasColumnName("item_id");
            entity.Property(e => e.Purpose)
                .HasColumnType("enum('req','bonus','atk','def','res','cost')")
                .HasColumnName("purpose");
            entity.Property(e => e.StatId).HasColumnName("stat_id");
            entity.Property(e => e.Value)
                .HasPrecision(6, 1)
                .HasColumnName("value");

            entity.HasOne(d => d.Item).WithMany(p => p.ItemStats)
                .HasForeignKey(d => d.ItemId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("item_stats_ibfk_1");

            entity.HasOne(d => d.Stat).WithMany(p => p.ItemStats)
                .HasForeignKey(d => d.StatId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("item_stats_ibfk_2");
        });

        modelBuilder.Entity<ItemType>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PRIMARY");

            entity.ToTable("item_types");

            entity.HasIndex(e => new { e.Category, e.Name }, "uq_type").IsUnique();

            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.Category)
                .HasColumnType("enum('weapon','shield','armor','talisman','spell','material')")
                .HasColumnName("category");
            entity.Property(e => e.Name)
                .HasMaxLength(100)
                .HasColumnName("name");
        });

        modelBuilder.Entity<Location>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PRIMARY");

            entity.ToTable("locations");

            entity.HasIndex(e => new { e.RegionId, e.Name }, "uq_location").IsUnique();

            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.Description)
                .HasColumnType("text")
                .HasColumnName("description");
            entity.Property(e => e.Name)
                .HasMaxLength(150)
                .HasColumnName("name");
            entity.Property(e => e.RegionId).HasColumnName("region_id");

            entity.HasOne(d => d.Region).WithMany(p => p.Locations)
                .HasForeignKey(d => d.RegionId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("locations_ibfk_1");
        });

        modelBuilder.Entity<Mechanic>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PRIMARY");

            entity.ToTable("mechanics");

            entity.HasIndex(e => e.StatId, "stat_id");

            entity.HasIndex(e => new { e.TutorialId, e.Name }, "uq_mech").IsUnique();

            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.Description)
                .HasColumnType("text")
                .HasColumnName("description");
            entity.Property(e => e.Name)
                .HasMaxLength(150)
                .HasColumnName("name");
            entity.Property(e => e.StatId).HasColumnName("stat_id");
            entity.Property(e => e.TutorialId).HasColumnName("tutorial_id");

            entity.HasOne(d => d.Stat).WithMany(p => p.Mechanics)
                .HasForeignKey(d => d.StatId)
                .HasConstraintName("mechanics_ibfk_2");

            entity.HasOne(d => d.Tutorial).WithMany(p => p.Mechanics)
                .HasForeignKey(d => d.TutorialId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("mechanics_ibfk_1");
        });

        modelBuilder.Entity<Region>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PRIMARY");

            entity.ToTable("regions");

            entity.HasIndex(e => e.Name, "name").IsUnique();

            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.Name)
                .HasMaxLength(150)
                .HasColumnName("name");
        });

        modelBuilder.Entity<Role>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PRIMARY");

            entity.ToTable("roles");

            entity.HasIndex(e => e.Name, "name").IsUnique();

            entity.Property(e => e.Id)
                .ValueGeneratedOnAdd()
                .HasColumnName("id");
            entity.Property(e => e.Name)
                .HasMaxLength(30)
                .HasColumnName("name");
        });

        modelBuilder.Entity<Skill>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PRIMARY");

            entity.ToTable("skills");

            entity.HasIndex(e => e.Name, "name").IsUnique();

            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.Description)
                .HasColumnType("text")
                .HasColumnName("description");
            entity.Property(e => e.Name)
                .HasMaxLength(100)
                .HasColumnName("name");
        });

        modelBuilder.Entity<Stat>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PRIMARY");

            entity.ToTable("stats");

            entity.HasIndex(e => e.Name, "name").IsUnique();

            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.Description)
                .HasColumnType("text")
                .HasColumnName("description");
            entity.Property(e => e.Kind)
                .HasColumnType("enum('attribute','damage','resistance','other')")
                .HasColumnName("kind");
            entity.Property(e => e.Name)
                .HasMaxLength(100)
                .HasColumnName("name");
        });

        modelBuilder.Entity<Tutorial>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PRIMARY");

            entity.ToTable("tutorials");

            entity.HasIndex(e => e.Name, "name").IsUnique();

            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.Description)
                .HasColumnType("text")
                .HasColumnName("description");
            entity.Property(e => e.Name)
                .HasMaxLength(150)
                .HasColumnName("name");
        });

        modelBuilder.Entity<User>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PRIMARY");

            entity.ToTable("users");

            entity.HasIndex(e => e.Login, "login").IsUnique();

            entity.HasIndex(e => e.RoleId, "role_id");

            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp")
                .HasColumnName("created_at");
            entity.Property(e => e.Login)
                .HasMaxLength(50)
                .HasColumnName("login");
            entity.Property(e => e.PasswordHash)
                .HasMaxLength(255)
                .HasColumnName("password_hash");
            entity.Property(e => e.RoleId)
                .HasDefaultValueSql("'1'")
                .HasColumnName("role_id");

            entity.HasOne(d => d.Role).WithMany(p => p.Users)
                .HasForeignKey(d => d.RoleId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("users_ibfk_1");
        });

        modelBuilder.Entity<VCreatureLocation>(entity =>
        {
            entity
                .HasNoKey()
                .ToView("v_creature_locations");

            entity.Property(e => e.Creature)
                .HasMaxLength(150)
                .HasColumnName("creature");
            entity.Property(e => e.CreatureType)
                .HasMaxLength(100)
                .HasColumnName("creature_type");
            entity.Property(e => e.Location)
                .HasMaxLength(150)
                .HasColumnName("location");
            entity.Property(e => e.Region)
                .HasMaxLength(150)
                .HasColumnName("region");
        });

        modelBuilder.Entity<VDrop>(entity =>
        {
            entity
                .HasNoKey()
                .ToView("v_drops");

            entity.Property(e => e.Creature)
                .HasMaxLength(150)
                .HasColumnName("creature");
            entity.Property(e => e.Item)
                .HasMaxLength(150)
                .HasColumnName("item");
            entity.Property(e => e.ItemCategory)
                .HasColumnType("enum('weapon','shield','armor','talisman','spell','material')")
                .HasColumnName("item_category");
        });

        modelBuilder.Entity<VItem>(entity =>
        {
            entity
                .HasNoKey()
                .ToView("v_items");

            entity.Property(e => e.Category)
                .HasColumnType("enum('weapon','shield','armor','talisman','spell','material')")
                .HasColumnName("category");
            entity.Property(e => e.DamageType)
                .HasMaxLength(100)
                .HasColumnName("damage_type");
            entity.Property(e => e.Effect)
                .HasColumnType("text")
                .HasColumnName("effect");
            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.ItemType)
                .HasMaxLength(100)
                .HasColumnName("item_type");
            entity.Property(e => e.Name)
                .HasMaxLength(150)
                .HasColumnName("name");
            entity.Property(e => e.Obtain)
                .HasColumnType("text")
                .HasColumnName("obtain");
            entity.Property(e => e.Skill)
                .HasMaxLength(100)
                .HasColumnName("skill");
            entity.Property(e => e.Weight)
                .HasPrecision(5, 1)
                .HasColumnName("weight");
        });

        modelBuilder.Entity<VItemUsage>(entity =>
        {
            entity
                .HasNoKey()
                .ToView("v_item_usage");

            entity.Property(e => e.BuildsCount).HasColumnName("builds_count");
            entity.Property(e => e.Category)
                .HasColumnType("enum('weapon','shield','armor','talisman','spell','material')")
                .HasColumnName("category");
            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.Name)
                .HasMaxLength(150)
                .HasColumnName("name");
        });

        modelBuilder.Entity<VRequirement>(entity =>
        {
            entity
                .HasNoKey()
                .ToView("v_requirements");

            entity.Property(e => e.Arc)
                .HasPrecision(6, 1)
                .HasColumnName("arc");
            entity.Property(e => e.Category)
                .HasColumnType("enum('weapon','shield','armor','talisman','spell','material')")
                .HasColumnName("category");
            entity.Property(e => e.Dex)
                .HasPrecision(6, 1)
                .HasColumnName("dex");
            entity.Property(e => e.Fai)
                .HasPrecision(6, 1)
                .HasColumnName("fai");
            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.Intel)
                .HasPrecision(6, 1)
                .HasColumnName("intel");
            entity.Property(e => e.Name)
                .HasMaxLength(150)
                .HasColumnName("name");
            entity.Property(e => e.Str)
                .HasPrecision(6, 1)
                .HasColumnName("str");
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
