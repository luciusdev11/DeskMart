using System.Globalization;
using System.Text;
using System.Text.RegularExpressions;
using DeskMart.Models.Catalog;
using DeskMart.Services.AI;
using DeskMart.Services.Products;
using DeskMart.ViewModels.PcBuilder;
using Microsoft.AspNetCore.Mvc;

namespace DeskMart.Controllers;

public class PcBuilderController : Controller
{
    private static readonly string[] BuilderSlots =
    [
        "CPU",
        "Motherboard",
        "RAM",
        "GPU",
        "SSD",
        "PSU",
        "Case",
        "Cooler"
    ];

    private const string SystemPrompt =
        "You are DeskMart AI Build Analyst, a practical PC hardware expert for a PC components e-commerce website. Analyze the selected PC build based on component balance, gaming/work performance, compatibility warnings, estimated power usage, PSU recommendation, upgrade path, and stock availability. Be concise but useful. Do not invent DeskMart inventory, prices, stock quantities, or alternative products. If alternative product context is not provided, clearly say that alternatives require live store product data.";

    private readonly INestyAiService _nestyAiService;
    private readonly IProductService _productService;
    private readonly ILogger<PcBuilderController> _logger;

    public PcBuilderController(
        INestyAiService nestyAiService,
        IProductService productService,
        ILogger<PcBuilderController> logger)
    {
        _nestyAiService = nestyAiService;
        _productService = productService;
        _logger = logger;
    }

    [HttpGet]
    public IActionResult Index()
    {
        return View();
    }

    [HttpGet]
    public async Task<IActionResult> GetProductsForBuilder(CancellationToken cancellationToken)
    {
        try
        {
            var products = await _productService.GetProductsAsync(cancellationToken);
            var productsBySlot = CreateEmptySlotDictionary();

            foreach (var product in products)
            {
                var slot = product.Category?.Name;
                if (string.IsNullOrWhiteSpace(slot) || !productsBySlot.ContainsKey(slot))
                {
                    continue;
                }

                productsBySlot[slot].Add(MapToBuilderOption(product));
            }

            foreach (var slot in BuilderSlots)
            {
                productsBySlot[slot] = productsBySlot[slot]
                    .OrderBy(p => p.Name)
                    .ToList();
            }

            return Json(new
            {
                success = true,
                productsBySlot
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to load PC Builder products.");

            return Json(new
            {
                success = false,
                message = "Unable to load PC Builder products."
            });
        }
    }

    [HttpPost]
    public async Task<IActionResult> AnalyzeWithAi(
        [FromBody] AiBuildAnalyzeRequest request,
        CancellationToken cancellationToken)
    {
        if (request is null || request.Components.Count == 0)
        {
            return Json(new AiBuildAnalyzeResponse
            {
                Success = false,
                Analysis = "Please select at least one PC component before asking AI to analyze the build."
            });
        }

        try
        {
            var userPrompt = BuildUserPrompt(request);
            var analysis = await _nestyAiService.SendChatAsync(SystemPrompt, userPrompt, cancellationToken);

            return Json(new AiBuildAnalyzeResponse
            {
                Success = true,
                Analysis = analysis
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Unexpected error in PC Builder AnalyzeWithAi action.");

            return Json(new AiBuildAnalyzeResponse
            {
                Success = false,
                Analysis = "DeskMart AI Build Analyst is currently unavailable. Please try again later."
            });
        }
    }

    private static Dictionary<string, List<PcBuilderProductOptionViewModel>> CreateEmptySlotDictionary()
    {
        return BuilderSlots.ToDictionary(slot => slot, _ => new List<PcBuilderProductOptionViewModel>());
    }

    private static PcBuilderProductOptionViewModel MapToBuilderOption(Product product)
    {
        var tdpValue = GetSpecValue(product, "TDP");
        var wattageValue = GetSpecValue(product, "Wattage");

        return new PcBuilderProductOptionViewModel
        {
            ProductId = product.Id,
            Name = product.Name,
            Category = product.Category?.Name ?? string.Empty,
            Brand = product.Brand?.Name ?? string.Empty,
            Price = product.Price,
            StockQuantity = product.StockQuantity,
            StockStatus = product.StockStatus,
            KeySpecs = BuildKeySpecs(product),
            Socket = GetSpecValue(product, "Socket"),
            RamType = GetSpecValue(product, "RAM Type"),
            PowerWatts = ParseWatts(tdpValue),
            Wattage = ParseWatts(wattageValue),
            FormFactor = GetSpecValue(product, "Form Factor"),
            GpuClearance = GetSpecValue(product, "GPU Clearance")
        };
    }

    private static string? GetSpecValue(Product product, string specKey)
    {
        return product.Specifications
            .FirstOrDefault(spec => spec.SpecKey.Equals(specKey, StringComparison.OrdinalIgnoreCase))
            ?.SpecValue;
    }

    private static int? ParseWatts(string? value)
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            return null;
        }

        var match = Regex.Match(value, @"(\d+)");
        return match.Success && int.TryParse(match.Groups[1].Value, out var watts)
            ? watts
            : null;
    }

    private static string BuildKeySpecs(Product product)
    {
        var specs = product.Specifications
            .OrderBy(spec => spec.DisplayOrder)
            .Take(3)
            .Select(spec => $"{spec.SpecKey}: {spec.SpecValue}")
            .ToList();

        return string.Join(" • ", specs);
    }

    private static string BuildUserPrompt(AiBuildAnalyzeRequest request)
    {
        var builder = new StringBuilder();
        builder.AppendLine("Analyze the following DeskMart PC build:");
        builder.AppendLine();
        builder.AppendLine("Selected components:");

        foreach (var component in request.Components)
        {
            builder.AppendLine($"- Slot: {component.SlotName}");
            builder.AppendLine($"  Product: {component.ProductName}");

            if (component.ProductId.HasValue)
            {
                builder.AppendLine($"  Product ID: {component.ProductId.Value}");
            }

            builder.AppendLine($"  Category: {component.Category}");
            builder.AppendLine($"  Price: {FormatVnd(component.Price)}");
            builder.AppendLine($"  Stock quantity: {component.StockQuantity}");
            builder.AppendLine($"  Stock status: {component.StockStatus}");
            builder.AppendLine($"  Key specs: {component.KeySpecs}");
            builder.AppendLine();
        }

        builder.AppendLine($"Total build price: {FormatVnd(request.TotalPrice)}");
        builder.AppendLine($"Estimated power usage: {request.EstimatedPowerWatts} W");
        builder.AppendLine($"Recommended PSU wattage: {request.RecommendedPsuWatts} W");
        builder.AppendLine();

        builder.AppendLine("Compatibility warnings:");
        if (request.CompatibilityWarnings.Count == 0)
        {
            builder.AppendLine("- None reported");
        }
        else
        {
            foreach (var warning in request.CompatibilityWarnings)
            {
                builder.AppendLine($"- {warning}");
            }
        }

        builder.AppendLine();
        builder.AppendLine("Stock warnings:");
        if (request.StockWarnings.Count == 0)
        {
            builder.AppendLine("- None reported");
        }
        else
        {
            foreach (var warning in request.StockWarnings)
            {
                var productId = warning.ProductId.HasValue ? warning.ProductId.Value.ToString() : "N/A";
                builder.AppendLine(
                    $"- [{warning.Severity}] {warning.ProductName} (Product ID: {productId}): {warning.Message}");
            }
        }

        builder.AppendLine();
        builder.AppendLine(
            "Provide a practical analysis covering component balance, expected performance, compatibility concerns, power/PSU fit, upgrade path, and stock availability.");

        return builder.ToString();
    }

    private static string FormatVnd(decimal amount)
    {
        return string.Format(CultureInfo.InvariantCulture, "{0:N0} VND", amount);
    }
}
