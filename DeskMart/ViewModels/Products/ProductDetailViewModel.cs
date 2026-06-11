namespace DeskMart.ViewModels.Products;

public class ProductDetailViewModel
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Slug { get; set; } = string.Empty;
    public string BrandName { get; set; } = string.Empty;
    public string CategoryName { get; set; } = string.Empty;
    public string CategorySlug { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public string? ImageUrl { get; set; }
    public int StockQuantity { get; set; }
    public string StockStatus { get; set; } = string.Empty;
    public string? Description { get; set; }
    public IReadOnlyList<ProductSpecificationViewModel> Specifications { get; set; } = Array.Empty<ProductSpecificationViewModel>();
}

public class ProductSpecificationViewModel
{
    public string SpecKey { get; set; } = string.Empty;
    public string SpecValue { get; set; } = string.Empty;
    public string? Unit { get; set; }
}
