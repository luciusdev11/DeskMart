namespace DeskMart.ViewModels.PcBuilder;

public class AiBuildComponentContextItem
{
    public string SlotName { get; set; } = string.Empty;
    public int? ProductId { get; set; }
    public string ProductName { get; set; } = string.Empty;
    public string Category { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public int StockQuantity { get; set; }
    public string StockStatus { get; set; } = string.Empty;
    public string KeySpecs { get; set; } = string.Empty;
}
