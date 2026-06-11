namespace DeskMart.Services.AI.DTOs;

public class NestyAiChatResponse
{
    public List<NestyAiChatChoice>? Choices { get; set; }
}

public class NestyAiChatChoice
{
    public NestyAiChatMessage? Message { get; set; }
}
