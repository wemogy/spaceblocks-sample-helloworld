using Microsoft.AspNetCore.Mvc;
using SpaceBlocks.Libs.Sdk.Models;
using SpaceBlocks.Permissions.Server;
using SpaceBlocks.Permissions.Server.Model;

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
            "",
            "",
            "",
            "permissions:management:read permissions:management:write");

        _client = new PermissionsClient(
            new Uri("https://cdwjnx.permissions.eu1.spaceblocks.cloud"),
            "",
            auth);
    }

    [HttpGet(Name = "GetWeatherForecast")]
    public async Task<IEnumerable<WeatherForecast>> Get([FromQuery] string city, [FromQuery] string user)
    {
        await SeedAsync();

        // Check, which permissions the user has
        var permissions = await _client.PermissionApi.ListPermissionsAsync(
            tenantId: "default",
            resourceTypeId: "city", // "tenant" also doesn't work
            resourceId: city,
            subjectId: user);

        var canGetCurrentForecast = permissions["city"].Contains("get-current-forecast");
        var canGetFutureForecast = permissions["city"].Contains("get-future-forecast");

        if (!canGetCurrentForecast && !canGetFutureForecast)
        {
            throw new UnauthorizedAccessException("You don't have permissions to access this resource.");
        }

        return Enumerable.Range(1, canGetFutureForecast ? 5 : 1).Select(index => new WeatherForecast
        {
            Date = DateOnly.FromDateTime(DateTime.Now.AddDays(index)),
            TemperatureC = Random.Shared.Next(-20, 55),
            Summary = Summaries[Random.Shared.Next(Summaries.Length)],
            City = city
        })
        .ToArray();
    }

    private async Task SeedAsync()
    {
        // Create Tenant
        await ExecuteWithConflictTolerationAsync(() =>
            _client.TenantApi.CreateTenantAsync(new CreateTenantRequest("default", "Default")));
        
        // Create cities
        await ExecuteWithConflictTolerationAsync(() => _client.ResourceApi.CreateResourceAsync("default", "city",
            new CreateResourceRequest("cansas", new CreateResourceParent("default"))));
        await ExecuteWithConflictTolerationAsync(() => _client.ResourceApi.CreateResourceAsync("default", "city",
            new CreateResourceRequest("seattle", new CreateResourceParent("default"))));

        // Assign roles to cansas
        await _client.ResourceApi.PatchResourceMembersAsync(
            tenantId: "default",
            resourceTypeId: "city",
            id: "cansas",
            new ResourceMembers(new Dictionary<string, List<string>>() {
                    { "alice", [] },
                    { "linda", ["future-forecast-viewer"] }
            }));

        // Assign roles to seattle
        await _client.ResourceApi.PatchResourceMembersAsync(
            tenantId: "default",
            resourceTypeId: "city",
            id: "seattle",
            new ResourceMembers(new Dictionary<string, List<string>>() {
                    { "alice", ["current-forecast-viewer"] },
                    { "linda", ["future-forecast-viewer"] }
            }));
    }

    private async Task ExecuteWithConflictTolerationAsync(Func<Task> callback)
    {
        try
        {
            // Execute the callback
            await callback();
        }
        catch (SpaceBlocks.Permissions.Server.Client.ApiException ex)
        {
            if (ex.ErrorCode == 409)
            {
                // Already exists, ignore
                return;
            }

            throw;
        }
    }
}
