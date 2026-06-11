using Microsoft.AspNetCore.Mvc;

namespace DeskMart.Areas.Admin.Controllers;

[Area("Admin")]
public class DashboardController : Controller
{
    public IActionResult Index()
    {
        return View();
    }
}
