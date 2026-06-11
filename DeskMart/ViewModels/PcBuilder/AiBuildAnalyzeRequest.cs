namespace DeskMart.ViewModels.PcBuilder;

public class AiBuildAnalyzeRequest
{
    public List<AiBuildComponentContextItem> Components { get; set; } = new();
    public decimal TotalPrice { get; set; }
    public List<string> CompatibilityWarnings { get; set; } = new();
    public List<AiStockWarning> StockWarnings { get; set; } = new();
    public int EstimatedPowerWatts { get; set; }
    public int RecommendedPsuWatts { get; set; }
}
