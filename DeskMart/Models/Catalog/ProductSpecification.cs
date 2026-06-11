namespace DeskMart.Models.Catalog;

public class ProductSpecification
{
    public int Id { get; set; }
    public int ProductId { get; set; }
    public Product? Product { get; set; }
    public string SpecKey { get; set; } = string.Empty;
    public string SpecValue { get; set; } = string.Empty;
    public string? Unit { get; set; }
    public int DisplayOrder { get; set; }
}
