namespace DeskMart.ViewModels.PcBuilder;

public class AiStockWarning
{
    public int? ProductId { get; set; }
    public string ProductName { get; set; } = string.Empty;
    public string Message { get; set; } = string.Empty;
    public string Severity { get; set; } = string.Empty;
}
