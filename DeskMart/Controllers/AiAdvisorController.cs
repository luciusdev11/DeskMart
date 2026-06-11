using DeskMart.Services.AI;

using DeskMart.Services.AI.Context;

using DeskMart.ViewModels;

using Microsoft.AspNetCore.Mvc;



namespace DeskMart.Controllers;



public class AiAdvisorController : Controller

{

    private const string SystemPrompt =

        "You are DeskMart AI Advisor, a helpful PC hardware sales consultant for a PC components e-commerce website. Help customers choose PC components based on budget, performance needs, compatibility, and stock availability. Be practical and concise. You may only recommend DeskMart products that are included in the provided product context. Do not invent DeskMart inventory, prices, stock quantities, or alternative products. If the provided context does not contain enough product data, clearly say so and give general guidance only.";



    private readonly INestyAiService _nestyAiService;

    private readonly IAiProductContextBuilder _productContextBuilder;

    private readonly ILogger<AiAdvisorController> _logger;



    public AiAdvisorController(

        INestyAiService nestyAiService,

        IAiProductContextBuilder productContextBuilder,

        ILogger<AiAdvisorController> logger)

    {

        _nestyAiService = nestyAiService;

        _productContextBuilder = productContextBuilder;

        _logger = logger;

    }



    [HttpGet]

    public IActionResult Index()

    {

        return View();

    }



    [HttpPost]

    public async Task<IActionResult> Ask([FromBody] AiAdvisorAskRequest request, CancellationToken cancellationToken)

    {

        if (request is null || string.IsNullOrWhiteSpace(request.Message))

        {

            return Json(new AiAdvisorAskResponse

            {

                Success = false,

                Reply = "Please enter a question for DeskMart AI Advisor."

            });

        }



        try

        {

            var trimmedMessage = request.Message.Trim();

            var productContext = await BuildProductContextSafeAsync(trimmedMessage, cancellationToken);

            var userPrompt = BuildUserPrompt(trimmedMessage, productContext);



            var aiReply = await _nestyAiService.SendChatAsync(

                SystemPrompt,

                userPrompt,

                cancellationToken);



            return Json(new AiAdvisorAskResponse

            {

                Success = true,

                Reply = aiReply

            });

        }

        catch (Exception ex)

        {

            _logger.LogError(ex, "Unexpected error in AI Advisor Ask action.");



            return Json(new AiAdvisorAskResponse

            {

                Success = false,

                Reply = "DeskMart AI Advisor is currently unavailable. Please try again later."

            });

        }

    }



    private async Task<string> BuildProductContextSafeAsync(string userMessage, CancellationToken cancellationToken)

    {

        try

        {

            return await _productContextBuilder.BuildProductContextAsync(

                userMessage,

                cancellationToken: cancellationToken);

        }

        catch (Exception ex)

        {

            _logger.LogWarning(ex, "Failed to build AI product context. Proceeding without product context.");

            return "DeskMart live product context: No product data is currently available.";

        }

    }



    private static string BuildUserPrompt(string message, string productContext)

    {

        return $"""

            Customer question:

            {message}



            {productContext}



            Please answer using only the DeskMart products listed above when making store-specific recommendations.

            """;

    }

}


