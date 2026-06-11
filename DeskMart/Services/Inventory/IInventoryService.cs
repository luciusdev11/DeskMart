using DeskMart.Models.Catalog;

namespace DeskMart.Services.Inventory;

public interface IInventoryService
{
    Task<int> GetStockQuantityAsync(int productId, CancellationToken cancellationToken = default);

    Task<string> GetStockStatusAsync(int productId, CancellationToken cancellationToken = default);

    Task<bool> IsInStockAsync(int productId, int requestedQuantity = 1, CancellationToken cancellationToken = default);

    Task<IReadOnlyList<Product>> GetLowStockProductsAsync(CancellationToken cancellationToken = default);

    Task<IReadOnlyList<Product>> GetOutOfStockProductsAsync(CancellationToken cancellationToken = default);
}
