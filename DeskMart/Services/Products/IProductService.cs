using DeskMart.Models.Catalog;

namespace DeskMart.Services.Products;

public interface IProductService
{
    Task<int> GetProductCountAsync(CancellationToken cancellationToken = default);

    Task<IReadOnlyList<Product>> GetFeaturedProductsAsync(int count = 8, CancellationToken cancellationToken = default);

    Task<IReadOnlyList<Product>> GetProductsAsync(CancellationToken cancellationToken = default);

    Task<Product?> GetByIdAsync(int id, CancellationToken cancellationToken = default);

    Task<IReadOnlyList<Product>> GetByCategoryAsync(string categorySlugOrName, CancellationToken cancellationToken = default);
}
