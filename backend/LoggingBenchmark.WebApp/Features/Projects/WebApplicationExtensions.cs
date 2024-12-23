using LoggingBenchmark.WebApp.Features.Projects.Requests;

namespace LoggingBenchmark.WebApp.Features.Projects;

public static class WebApplicationExtensions
{
    public static IEndpointRouteBuilder MapProjectsFeature(this IEndpointRouteBuilder builder)
    {
        new CreateProject.Endpoint().MapEndpoint(builder);
        new GetProject.Endpoint().MapEndpoint(builder);

        return builder;
    }
}
