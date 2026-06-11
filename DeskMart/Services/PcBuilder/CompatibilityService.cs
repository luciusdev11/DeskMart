namespace DeskMart.Services.PcBuilder;

public class CompatibilityService : ICompatibilityService
{
    public Task<bool> AreCompatibleAsync(string componentA, string componentB, CancellationToken cancellationToken = default)
    {
        return Task.FromResult(true);
    }
}
