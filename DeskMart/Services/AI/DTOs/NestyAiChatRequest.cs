namespace DeskMart.Services.AI.DTOs;

public class NestyAiChatRequest
{
    public string Model { get; set; } = string.Empty;
    public List<NestyAiChatMessage> Messages { get; set; } = new();
    public double Temperature { get; set; } = 0.4;
}
