using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using DeskMart.Options;
using DeskMart.Services.AI.DTOs;
using Microsoft.Extensions.Options;

namespace DeskMart.Services.AI;

public class NestyAiService : INestyAiService
{
    private const string DefaultSystemPrompt =
        "You are DeskMart AI Advisor, a helpful PC hardware sales consultant. Help customers choose PC components based on budget, performance needs, compatibility, and stock availability. Do not invent store inventory, prices, or stock quantities. If product data is not provided, clearly say that live product data is not available yet.";

    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
        PropertyNameCaseInsensitive = true
    };

    private readonly HttpClient _httpClient;
    private readonly NestyAiOptions _options;
    private readonly ILogger<NestyAiService> _logger;

    public NestyAiService(
        HttpClient httpClient,
        IOptions<NestyAiOptions> options,
        ILogger<NestyAiService> logger)
    {
        _httpClient = httpClient;
        _options = options.Value;
        _logger = logger;
    }

    public Task<string> SendPromptAsync(string prompt, CancellationToken cancellationToken = default)
    {
        return SendChatAsync(DefaultSystemPrompt, prompt, cancellationToken);
    }

    public async Task<string> SendChatAsync(
        string systemPrompt,
        string userPrompt,
        CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(_options.BaseUrl))
        {
            _logger.LogInformation("NestyAI BaseUrl is not configured.");
            return "NestyAI BaseUrl is not configured yet.";
        }

        if (string.IsNullOrWhiteSpace(_options.ApiKey))
        {
            _logger.LogInformation("NestyAI API key is not configured.");
            return "NestyAI API key is not configured yet.";
        }

        var request = new NestyAiChatRequest
        {
            Model = _options.DefaultModel,
            Temperature = 0.4,
            Messages =
            [
                new NestyAiChatMessage { Role = "system", Content = systemPrompt },
                new NestyAiChatMessage { Role = "user", Content = userPrompt }
            ]
        };

        try
        {
            return await SendChatRequestAsync(request, cancellationToken);
        }
        catch (TaskCanceledException ex) when (!cancellationToken.IsCancellationRequested)
        {
            _logger.LogWarning(ex, "NestyAI request timed out after {TimeoutSeconds} seconds.", _options.TimeoutSeconds);
            return "DeskMart AI Advisor timed out. Please try again later.";
        }
        catch (TaskCanceledException)
        {
            throw;
        }
        catch (HttpRequestException ex)
        {
            _logger.LogWarning(ex, "NestyAI network request failed.");
            return "DeskMart AI Advisor could not reach the AI service. Please try again later.";
        }
        catch (JsonException ex)
        {
            _logger.LogWarning(ex, "NestyAI response could not be parsed.");
            return "DeskMart AI Advisor received an invalid response. Please try again later.";
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Unexpected error while calling NestyAI.");
            return "DeskMart AI Advisor is currently unavailable. Please try again later.";
        }
    }

    private async Task<string> SendChatRequestAsync(
        NestyAiChatRequest request,
        CancellationToken cancellationToken)
    {
        var requestUri = BuildChatCompletionsUri(_options.BaseUrl, _options.ChatCompletionsEndpoint);

        using var httpRequest = new HttpRequestMessage(HttpMethod.Post, requestUri);
        httpRequest.Headers.Authorization = new AuthenticationHeaderValue("Bearer", _options.ApiKey);
        httpRequest.Headers.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
        httpRequest.Content = new StringContent(
            JsonSerializer.Serialize(request, JsonOptions),
            Encoding.UTF8,
            "application/json");

        using var response = await _httpClient.SendAsync(httpRequest, cancellationToken);

        if (!response.IsSuccessStatusCode)
        {
            _logger.LogWarning(
                "NestyAI request failed with status {StatusCode} {ReasonPhrase}.",
                (int)response.StatusCode,
                response.ReasonPhrase);

            return "DeskMart AI Advisor is currently unavailable. Please try again later.";
        }

        var responseBody = await response.Content.ReadAsStringAsync(cancellationToken);

        NestyAiChatResponse? chatResponse;
        try
        {
            chatResponse = JsonSerializer.Deserialize<NestyAiChatResponse>(responseBody, JsonOptions);
        }
        catch (JsonException ex)
        {
            _logger.LogWarning(ex, "NestyAI success response could not be deserialized.");
            return "DeskMart AI Advisor received an invalid response. Please try again later.";
        }

        var content = chatResponse?.Choices?.FirstOrDefault()?.Message?.Content;

        if (string.IsNullOrWhiteSpace(content))
        {
            _logger.LogWarning("NestyAI returned an empty assistant message.");
            return "NestyAI returned an empty response.";
        }

        return content;
    }

    /// <summary>
    /// Combines BaseUrl and ChatCompletionsEndpoint so a leading slash on the endpoint
    /// does not discard the BaseUrl path segment (e.g. /api).
    /// </summary>
    internal static Uri BuildChatCompletionsUri(string baseUrl, string chatCompletionsEndpoint)
    {
        var normalizedBase = baseUrl.TrimEnd('/');
        var normalizedEndpoint = chatCompletionsEndpoint.TrimStart('/');

        if (string.IsNullOrEmpty(normalizedEndpoint))
        {
            return new Uri(normalizedBase + "/", UriKind.Absolute);
        }

        return new Uri($"{normalizedBase}/{normalizedEndpoint}", UriKind.Absolute);
    }
}
