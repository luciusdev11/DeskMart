namespace DeskMart.Services.PcBuilder;

public class PcBuilderService : IPcBuilderService
{
    public Task<IReadOnlyList<string>> GetAvailableCategoriesAsync(CancellationToken cancellationToken = default)
    {
        return Task.FromResult<IReadOnlyList<string>>(Array.Empty<string>());
    }
}
