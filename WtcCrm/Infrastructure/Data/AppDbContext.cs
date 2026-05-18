using Microsoft.EntityFrameworkCore;
using MongoDB.EntityFrameworkCore.Extensions;
using WtcCrm.Domain.Entities;

namespace WtcCrm.Infrastructure.Data
{
    public class AppDbContext : DbContext
    {
        public DbSet<User> Users { get; init; }
        public DbSet<Announcement> Announcements { get; init; }
        public DbSet<AnnouncementDelivery> AnnouncementDeliveries { get; init; }
        public DbSet<AuditLog> AuditLogs { get; init; }
        public DbSet<ChatGroup> ChatGroups { get; init; }
        public DbSet<ChatMessage> ChatMessages { get; init; }
        public DbSet<CustomerNote> CustomerNotes { get; init; }
        public DbSet<Segment> Segments { get; init; }

        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            modelBuilder.Entity<User>().ToCollection("Users");
            modelBuilder.Entity<Announcement>().ToCollection("Announcements");
            modelBuilder.Entity<AnnouncementDelivery>().ToCollection("AnnouncementDeliveries");
            modelBuilder.Entity<AuditLog>().ToCollection("AuditLogs");
            modelBuilder.Entity<ChatGroup>().ToCollection("ChatGroups");
            modelBuilder.Entity<ChatMessage>().Property(a => a.Status).HasConversion<string>();
            modelBuilder.Entity<CustomerNote>().ToCollection("CustomerNotes");
            modelBuilder.Entity<Segment>().ToCollection("Segments");

            modelBuilder.Entity<User>().Property(a => a.Role).HasConversion<string>();
            modelBuilder.Entity<User>().HasIndex(a => a.Email).IsUnique();
            modelBuilder.Entity<User>().HasIndex(a => a.DocumentId).IsUnique();
            
            modelBuilder.Entity<AuditLog>().HasKey(a => a.Id);
        }
    }
}