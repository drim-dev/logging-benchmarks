using LoggingBenchmark.WebApp.Domain;
using Microsoft.EntityFrameworkCore;

namespace LoggingBenchmark.WebApp.Database;

public class WebAppDbContext : DbContext
{
    public WebAppDbContext(DbContextOptions<WebAppDbContext> options) : base(options)
    {
    }

    public DbSet<Project> Projects { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Project>(builder =>
        {
            builder.HasKey(project => project.Id);
            builder.Property(project => project.Name).HasMaxLength(Project.NameMaxLength).IsRequired();
        });
    }
}
