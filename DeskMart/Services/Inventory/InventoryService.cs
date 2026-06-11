using DeskMart.Data;
using DeskMart.Models.Catalog;
using Microsoft.EntityFrameworkCore;

namespace DeskMart.Services.Inventory;

public class InventoryService : IInventoryService
{
    private readonly ApplicationDbContext _context;

    public InventoryService(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<int> GetStockQuantityAsync(int productId, CancellationToken cancellationToken = default)
    {
        var product = await FindActiveProductAsync(productId, cancellationToken);
        return product?.StockQuantity ?? 0;
    }

    public async Task<string> GetStockStatusAsync(int productId, CancellationToken cancellationToken = default)
    {
        var product = await FindActiveProductAsync(productId, cancellationToken);
        return product?.StockStatus ?? "Out of Stock";
    }

    public async Task<bool> IsInStockAsync(
        int productId,
        int requestedQuantity = 1,
        CancellationToken cancellationToken = default)
    {
        if (requestedQuantity <= 0)
        {
            return false;
        }

        var product = await FindActiveProductAsync(productId, cancellationToken);
        return product is not null && product.StockQuantity >= requestedQuantity;
    }

    public async Task<IReadOnlyList<Product>> GetLowStockProductsAsync(CancellationToken cancellationToken = default)
    {
        return await ActiveProductsQuery()
            .Where(p => p.StockQuantity > 0 && p.StockQuantity <= p.LowStockThreshold)
            .OrderBy(p => p.StockQuantity)
            .ThenBy(p => p.Name)
            .ToListAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<Product>> GetOutOfStockProductsAsync(CancellationToken cancellationToken = default)
    {
        return await ActiveProductsQuery()
            .Where(p => p.StockQuantity <= 0)
            .OrderBy(p => p.Name)
            .ToListAsync(cancellationToken);
    }

    private Task<Product?> FindActiveProductAsync(int productId, CancellationToken cancellationToken)
    {
        return _context.Products
            .AsNoTracking()
            .FirstOrDefaultAsync(p => p.Id == productId && p.IsActive, cancellationToken);
    }

    private IQueryable<Product> ActiveProductsQuery()
    {
        return _context.Products
            .AsNoTracking()
            .Include(p => p.Brand)
            .Include(p => p.Category)
            .Where(p => p.IsActive);
    }
}
