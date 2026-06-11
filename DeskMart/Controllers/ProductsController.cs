using DeskMart.Models.Catalog;
using DeskMart.Services.Products;
using DeskMart.ViewModels.Products;
using Microsoft.AspNetCore.Mvc;

namespace DeskMart.Controllers;

public class ProductsController : Controller
{
    private readonly IProductService _productService;

    public ProductsController(IProductService productService)
    {
        _productService = productService;
    }

    [HttpGet]
    public async Task<IActionResult> Index(
        string? category,
        string? search,
        string? stockStatus,
        CancellationToken cancellationToken)
    {
        var allProducts = await _productService.GetProductsAsync(cancellationToken);

        var categoryOptions = allProducts
            .Where(p => p.Category is not null)
            .Select(p => (p.Category!.Name, p.Category.Slug))
            .DistinctBy(c => c.Slug)
            .OrderBy(c => c.Name)
            .ToList();

        IEnumerable<Product> filteredProducts = allProducts;

        if (!string.IsNullOrWhiteSpace(category))
        {
            var normalizedCategory = category.Trim();
            filteredProducts = filteredProducts.Where(p =>
                p.Category is not null &&
                (p.Category.Slug.Equals(normalizedCategory, StringComparison.OrdinalIgnoreCase) ||
                 p.Category.Name.Equals(normalizedCategory, StringComparison.OrdinalIgnoreCase)));
        }

        if (!string.IsNullOrWhiteSpace(search))
        {
            var normalizedSearch = search.Trim();
            filteredProducts = filteredProducts.Where(p =>
                p.Name.Contains(normalizedSearch, StringComparison.OrdinalIgnoreCase) ||
                (p.Brand?.Name.Contains(normalizedSearch, StringComparison.OrdinalIgnoreCase) ?? false) ||
                (p.Category?.Name.Contains(normalizedSearch, StringComparison.OrdinalIgnoreCase) ?? false) ||
                p.Specifications.Any(s =>
                    s.SpecKey.Contains(normalizedSearch, StringComparison.OrdinalIgnoreCase) ||
                    s.SpecValue.Contains(normalizedSearch, StringComparison.OrdinalIgnoreCase)));
        }

        if (!string.IsNullOrWhiteSpace(stockStatus))
        {
            var normalizedStockStatus = stockStatus.Trim();
            filteredProducts = filteredProducts.Where(p =>
                p.StockStatus.Equals(normalizedStockStatus, StringComparison.OrdinalIgnoreCase));
        }

        var productCards = filteredProducts
            .Select(MapToCardViewModel)
            .ToList();

        var viewModel = new ProductListViewModel
        {
            Products = productCards,
            CategoryOptions = categoryOptions,
            Category = category,
            Search = search,
            StockStatus = stockStatus,
            TotalCount = productCards.Count
        };

        return View(viewModel);
    }

    [HttpGet]
    public async Task<IActionResult> Details(int id, CancellationToken cancellationToken)
    {
        var product = await _productService.GetByIdAsync(id, cancellationToken);
        if (product is null)
        {
            return NotFound();
        }

        return View(MapToDetailViewModel(product));
    }

    private static ProductCardViewModel MapToCardViewModel(Product product)
    {
        return new ProductCardViewModel
        {
            Id = product.Id,
            Name = product.Name,
            Slug = product.Slug,
            CategoryName = product.Category?.Name ?? string.Empty,
            CategorySlug = product.Category?.Slug ?? string.Empty,
            BrandName = product.Brand?.Name ?? string.Empty,
            Price = product.Price,
            ImageUrl = product.ImageUrl,
            StockQuantity = product.StockQuantity,
            StockStatus = product.StockStatus,
            ShortSpecs = BuildShortSpecs(product)
        };
    }

    private static ProductDetailViewModel MapToDetailViewModel(Product product)
    {
        return new ProductDetailViewModel
        {
            Id = product.Id,
            Name = product.Name,
            Slug = product.Slug,
            BrandName = product.Brand?.Name ?? string.Empty,
            CategoryName = product.Category?.Name ?? string.Empty,
            CategorySlug = product.Category?.Slug ?? string.Empty,
            Price = product.Price,
            ImageUrl = product.ImageUrl,
            StockQuantity = product.StockQuantity,
            StockStatus = product.StockStatus,
            Description = product.Description,
            Specifications = product.Specifications
                .OrderBy(s => s.DisplayOrder)
                .Select(s => new ProductSpecificationViewModel
                {
                    SpecKey = s.SpecKey,
                    SpecValue = s.SpecValue,
                    Unit = s.Unit
                })
                .ToList()
        };
    }

    private static string BuildShortSpecs(Product product)
    {
        var specs = product.Specifications
            .OrderBy(s => s.DisplayOrder)
            .Take(3)
            .Select(s => $"{s.SpecKey}: {s.SpecValue}")
            .ToList();

        return string.Join(" • ", specs);
    }
}
