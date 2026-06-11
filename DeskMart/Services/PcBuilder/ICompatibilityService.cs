namespace DeskMart.Services.PcBuilder;

public interface ICompatibilityService
{
    Task<bool> AreCompatibleAsync(string componentA, string componentB, CancellationToken cancellationToken = default);
}
