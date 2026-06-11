using DeskMart.Data;
using DeskMart.Models.Catalog;
using Microsoft.EntityFrameworkCore;

namespace DeskMart.Services.Products;

public class ProductService : IProductService
{
    private readonly ApplicationDbContext _context;

    public ProductService(ApplicationDbContext context)
    {
        _context = context;
    }

    public Task<int> GetProductCountAsync(CancellationToken cancellationToken = default)
    {
        return _context.Products
            .AsNoTracking()
            .CountAsync(p => p.IsActive, cancellationToken);
    }

    public async Task<IReadOnlyList<Product>> GetFeaturedProductsAsync(
        int count = 8,
        CancellationToken cancellationToken = default)
    {
        return await ActiveProductsQuery()
            .OrderByDescending(p => p.CreatedAt)
            .ThenBy(p => p.Name)
            .Take(count)
            .ToListAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<Product>> GetProductsAsync(CancellationToken cancellationToken = default)
    {
        return await ActiveProductsQuery()
            .OrderBy(p => p.Category!.Name)
            .ThenBy(p => p.Name)
            .ToListAsync(cancellationToken);
    }

    public Task<Product?> GetByIdAsync(int id, CancellationToken cancellationToken = default)
    {
        return ActiveProductsQuery()
            .FirstOrDefaultAsync(p => p.Id == id, cancellationToken);
    }

    public async Task<IReadOnlyList<Product>> GetByCategoryAsync(
        string categorySlugOrName,
        CancellationToken cancellationToken = default)
    {
        var normalized = categorySlugOrName.Trim().ToLowerInvariant();

        return await ActiveProductsQuery()
            .Where(p =>
                p.Category!.Slug.ToLower() == normalized ||
                p.Category.Name.ToLower() == normalized)
            .OrderBy(p => p.Name)
            .ToListAsync(cancellationToken);
    }

    private IQueryable<Product> ActiveProductsQuery()
    {
        return _context.Products
            .AsNoTracking()
            .Include(p => p.Brand)
            .Include(p => p.Category)
            .Include(p => p.Specifications.OrderBy(s => s.DisplayOrder))
            .Where(p => p.IsActive);
    }
}
