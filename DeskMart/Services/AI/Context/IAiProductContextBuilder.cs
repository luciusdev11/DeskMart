namespace DeskMart.Services.AI.Context;

public interface IAiProductContextBuilder
{
    Task<string> BuildProductContextAsync(
        string? userMessage,
        int maxProducts = 8,
        CancellationToken cancellationToken = default);
}
