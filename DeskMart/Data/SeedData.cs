using DeskMart.Models.Catalog;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;

namespace DeskMart.Data;

public static class SeedData
{
    private static readonly string[] BrandNames =
    [
        "Intel",
        "AMD",
        "NVIDIA",
        "ASUS",
        "MSI",
        "Corsair",
        "Kingston",
        "Samsung"
    ];

    private static readonly (string Name, string Slug, string? IconName)[] Categories =
    [
        ("CPU", "cpu", "cpu"),
        ("GPU", "gpu", "gpu"),
        ("Motherboard", "motherboard", "motherboard"),
        ("RAM", "ram", "ram"),
        ("SSD", "ssd", "ssd"),
        ("PSU", "psu", "psu"),
        ("Case", "case", "case"),
        ("Cooler", "cooler", "cooler")
    ];

    public static async Task InitializeAsync(IServiceProvider serviceProvider)
    {
        var context = serviceProvider.GetRequiredService<ApplicationDbContext>();
        var logger = serviceProvider.GetRequiredService<ILoggerFactory>().CreateLogger("SeedData");

        if (!await context.Database.CanConnectAsync())
        {
            logger.LogInformation("Database is not available. Skipping seed data.");
            return;
        }

        await EnsureBrandsAndCategoriesAsync(context, logger);
    }

    private static async Task EnsureBrandsAndCategoriesAsync(
        ApplicationDbContext context,
        ILogger logger)
    {
        var utcNow = DateTime.UtcNow;
        var changed = false;

        if (!await context.Brands.AnyAsync())
        {
            foreach (var brandName in BrandNames)
            {
                context.Brands.Add(new Brand
                {
                    Name = brandName,
                    IsActive = true,
                    CreatedAt = utcNow
                });
            }

            changed = true;
            logger.LogInformation("Seeding {BrandCount} brands.", BrandNames.Length);
        }

        if (!await context.Categories.AnyAsync())
        {
            foreach (var (name, slug, iconName) in Categories)
            {
                context.Categories.Add(new Category
                {
                    Name = name,
                    Slug = slug,
                    IconName = iconName,
                    IsActive = true,
                    CreatedAt = utcNow
                });
            }

            changed = true;
            logger.LogInformation("Seeding {CategoryCount} categories.", Categories.Length);
        }

        if (changed)
        {
            await context.SaveChangesAsync();
        }
    }
}
