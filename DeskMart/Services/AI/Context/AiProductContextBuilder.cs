using System.Globalization;
using System.Text;
using DeskMart.Models.Catalog;
using DeskMart.Services.Products;

namespace DeskMart.Services.AI.Context;

public class AiProductContextBuilder : IAiProductContextBuilder
{
    private readonly IProductService _productService;

    public AiProductContextBuilder(IProductService productService)
    {
        _productService = productService;
    }

    public async Task<string> BuildProductContextAsync(
        string? userMessage,
        int maxProducts = 8,
        CancellationToken cancellationToken = default)
    {
        var allProducts = await _productService.GetProductsAsync(cancellationToken);
        if (allProducts.Count == 0)
        {
            return "DeskMart live product context: No product data is currently available.";
        }

        var selectedProducts = await SelectRelevantProductsAsync(
            allProducts,
            userMessage,
            maxProducts,
            cancellationToken);

        if (selectedProducts.Count == 0)
        {
            return "DeskMart live product context: No product data is currently available.";
        }

        var contextItems = selectedProducts.Select(MapToContextItem).ToList();
        return BuildContextText(contextItems);
    }

    private async Task<IReadOnlyList<Product>> SelectRelevantProductsAsync(
        IReadOnlyList<Product> allProducts,
        string? userMessage,
        int maxProducts,
        CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(userMessage))
        {
            return await _productService.GetFeaturedProductsAsync(maxProducts, cancellationToken);
        }

        var keywords = ExtractKeywords(userMessage);
        if (keywords.Count == 0)
        {
            return await _productService.GetFeaturedProductsAsync(maxProducts, cancellationToken);
        }

        var matchedProducts = allProducts
            .Select(product => new { Product = product, Score = ScoreProduct(product, keywords) })
            .Where(result => result.Score > 0)
            .OrderByDescending(result => result.Score)
            .ThenBy(result => result.Product.Name)
            .Take(maxProducts)
            .Select(result => result.Product)
            .ToList();

        if (matchedProducts.Count > 0)
        {
            return matchedProducts;
        }

        return await _productService.GetFeaturedProductsAsync(maxProducts, cancellationToken);
    }

    private static AiProductContextItem MapToContextItem(Product product)
    {
        return new AiProductContextItem
        {
            ProductId = product.Id,
            Name = product.Name,
            Category = product.Category?.Name ?? string.Empty,
            Brand = product.Brand?.Name ?? string.Empty,
            Price = product.Price,
            StockQuantity = product.StockQuantity,
            StockStatus = product.StockStatus,
            ShortSpecs = BuildShortSpecs(product)
        };
    }

    private static string BuildContextText(IReadOnlyList<AiProductContextItem> items)
    {
        var builder = new StringBuilder();
        builder.AppendLine("DeskMart live product context:");

        foreach (var item in items)
        {
            builder.Append("* [ID: ");
            builder.Append(item.ProductId);
            builder.Append("] ");
            builder.Append(item.Name);
            builder.Append(" | Category: ");
            builder.Append(item.Category);
            builder.Append(" | Brand: ");
            builder.Append(item.Brand);
            builder.Append(" | Price: ");
            builder.Append(FormatVnd(item.Price));
            builder.Append(" | Stock: ");
            builder.Append(item.StockStatus);
            builder.Append(" (");
            builder.Append(item.StockQuantity);
            builder.Append(" units) | Specs: ");
            builder.Append(string.IsNullOrWhiteSpace(item.ShortSpecs) ? "N/A" : item.ShortSpecs);
            builder.AppendLine();
        }

        return builder.ToString().TrimEnd();
    }

    private static string BuildShortSpecs(Product product)
    {
        return string.Join("; ", product.Specifications
            .OrderBy(spec => spec.DisplayOrder)
            .Take(3)
            .Select(spec => $"{spec.SpecKey}: {spec.SpecValue}"));
    }

    private static List<string> ExtractKeywords(string userMessage)
    {
        return userMessage
            .Split([' ', ',', '.', ';', ':', '?', '!', '(', ')', '[', ']', '/', '\\', '-', '_'], StringSplitOptions.RemoveEmptyEntries)
            .Select(word => word.Trim())
            .Where(word => word.Length >= 2)
            .Distinct(StringComparer.OrdinalIgnoreCase)
            .ToList();
    }

    private static int ScoreProduct(Product product, IReadOnlyList<string> keywords)
    {
        var score = 0;

        foreach (var keyword in keywords)
        {
            if (product.Name.Contains(keyword, StringComparison.OrdinalIgnoreCase))
            {
                score += 3;
            }

            if (product.Brand?.Name.Contains(keyword, StringComparison.OrdinalIgnoreCase) ?? false)
            {
                score += 2;
            }

            if (product.Category?.Name.Contains(keyword, StringComparison.OrdinalIgnoreCase) ?? false)
            {
                score += 2;
            }

            foreach (var specification in product.Specifications)
            {
                if (specification.SpecKey.Contains(keyword, StringComparison.OrdinalIgnoreCase) ||
                    specification.SpecValue.Contains(keyword, StringComparison.OrdinalIgnoreCase))
                {
                    score += 1;
                }
            }
        }

        return score;
    }

    private static string FormatVnd(decimal amount)
    {
        return string.Format(CultureInfo.InvariantCulture, "{0:N0} VND", amount);
    }
}
