namespace DeskMart.Services.PcBuilder;

public interface IPcBuilderService
{
    Task<IReadOnlyList<string>> GetAvailableCategoriesAsync(CancellationToken cancellationToken = default);
}
