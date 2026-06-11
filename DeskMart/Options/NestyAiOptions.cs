namespace DeskMart.Options;

public class NestyAiOptions
{
    public const string SectionName = "NestyAI";

    public string BaseUrl { get; set; } = string.Empty;
    public string ApiKey { get; set; } = string.Empty;
    public string ChatCompletionsEndpoint { get; set; } = "/v1/chat/completions";
    public string DefaultModel { get; set; } = "nesty-combined-1.0";
    public int TimeoutSeconds { get; set; } = 60;
}
