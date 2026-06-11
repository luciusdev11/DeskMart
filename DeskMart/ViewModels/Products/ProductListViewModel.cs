namespace DeskMart.ViewModels.Products;

public class ProductListViewModel
{
    public IReadOnlyList<ProductCardViewModel> Products { get; set; } = Array.Empty<ProductCardViewModel>();
    public IReadOnlyList<(string Name, string Slug)> CategoryOptions { get; set; } = Array.Empty<(string Name, string Slug)>();
    public string? Category { get; set; }
    public string? Search { get; set; }
    public string? StockStatus { get; set; }
    public int TotalCount { get; set; }
}
