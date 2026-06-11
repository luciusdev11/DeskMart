namespace DeskMart.Services.AI;

public interface INestyAiService
{
    Task<string> SendPromptAsync(string prompt, CancellationToken cancellationToken = default);

    Task<string> SendChatAsync(
        string systemPrompt,
        string userPrompt,
        CancellationToken cancellationToken = default);
}
