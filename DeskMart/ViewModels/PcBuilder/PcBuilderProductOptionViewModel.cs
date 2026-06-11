namespace DeskMart.ViewModels.PcBuilder;

public class PcBuilderProductOptionViewModel
{
    public int ProductId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Category { get; set; } = string.Empty;
    public string Brand { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public int StockQuantity { get; set; }
    public string StockStatus { get; set; } = string.Empty;
    public string KeySpecs { get; set; } = string.Empty;
    public string? Socket { get; set; }
    public string? RamType { get; set; }
    public int? PowerWatts { get; set; }
    public int? Wattage { get; set; }
    public string? FormFactor { get; set; }
    public string? GpuClearance { get; set; }
}
