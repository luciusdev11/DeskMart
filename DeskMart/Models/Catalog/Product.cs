using System.ComponentModel.DataAnnotations.Schema;

namespace DeskMart.Models.Catalog;

public class Product
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Slug { get; set; } = string.Empty;
    public string? Description { get; set; }
    public decimal Price { get; set; }
    public string? ImageUrl { get; set; }
    public int CategoryId { get; set; }
    public Category? Category { get; set; }
    public int BrandId { get; set; }
    public Brand? Brand { get; set; }
    public int StockQuantity { get; set; }
    public int LowStockThreshold { get; set; } = 5;
    public bool IsActive { get; set; } = true;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? UpdatedAt { get; set; }

    public ICollection<ProductSpecification> Specifications { get; set; } = new List<ProductSpecification>();

    [NotMapped]
    public string StockStatus
    {
        get
        {
            if (StockQuantity <= 0)
            {
                return "Out of Stock";
            }

            if (StockQuantity <= LowStockThreshold)
            {
                return "Low Stock";
            }

            return "In Stock";
        }
    }
}
