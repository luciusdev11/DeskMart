using System.Globalization;

namespace DeskMart.ViewModels.Products;

public static class ProductDisplayHelper
{
    public static string FormatVnd(decimal price)
    {
        return string.Format(CultureInfo.InvariantCulture, "{0:N0} VND", price);
    }

    public static string GetStockBadgeClass(string stockStatus)
    {
        return stockStatus switch
        {
            "In Stock" => "text-bg-success",
            "Low Stock" => "text-bg-warning",
            "Out of Stock" => "text-bg-danger",
            _ => "text-bg-secondary"
        };
    }
}
