using Microsoft.AspNetCore.Mvc;
using SpaceBlocks.Libs.Sdk.Models;
using SpaceBlocks.Permissions.Server;

namespace SimplePermissions.Controllers;

[ApiController]
[Route("[controller]")]
public class WeatherForecastController : ControllerBase
{
    private static readonly string[] Summaries = new[]
    {
        "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
    };

    private readonly ILogger<WeatherForecastController> _logger;
    private readonly PermissionsClient _client;

    public WeatherForecastController(ILogger<WeatherForecastController> logger)
    {
        _logger = logger;
        var auth = new AuthenticationOptions(
            "<YOUR_API_KEY>",
            "<YOUR_CLIENT_ID>",
            "<YOUR_CLIENT_SECRET>",
            "permissions:management:read permissions:management:write");

        _client = new PermissionsClient(
            new Uri("<YOUR_PERMISSIONS_URL>"),
            "<YOUR_API_KEY>",
            auth);
    }

    [HttpGet(Name = "GetWeatherForecast")]
    public async Task<IEnumerable<WeatherForecast>> Get([FromQuery] string city, [FromQuery] string user)
    {
        // Check, which permissions the user has
        var permissions = await _client.PermissionApi.ListPermissionsAsync(
            tenantId: "default",
            resourceTypeId: "city", // "tenant" also doesn't work
            resourceId: city,
            subjectId: user);

        // Get permissions for the user
        var canGetCurrentForecast = permissions["city"].Contains("get-current-forecast");
        var canGetFutureForecast = permissions["city"].Contains("get-future-forecast");
        if (!canGetCurrentForecast && !canGetFutureForecast)
        {
            throw new UnauthorizedAccessException("You don't have permissions to access this resource.");
        }

        // Depending on the permissions, return the forecast for 1 or 5 days
        var forecastDays = canGetFutureForecast ? 5 : 1;

        // Generate the forecast
        return Enumerable.Range(1, forecastDays).Select(index => new WeatherForecast
        {
            Date = DateOnly.FromDateTime(DateTime.Now.AddDays(index)),
            TemperatureC = Random.Shared.Next(-20, 55),
            Summary = Summaries[Random.Shared.Next(Summaries.Length)],
            City = city
        })
        .ToArray();
    }
}
