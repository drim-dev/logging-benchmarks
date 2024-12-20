using IdGen;
using LoggingBenchmark.WebApp.Database;
using LoggingBenchmark.WebApp.Features.Projects.Models;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.EntityFrameworkCore;

namespace LoggingBenchmark.WebApp.Features.Projects.Requests;

public class GetProject
{
    public class Endpoint
    {
        public void MapEndpoint(IEndpointRouteBuilder builder)
        {
            builder.MapGet("/project/{projectId}", async Task<Results<Ok<ProjectModel>, NotFound>> (
                long projectId,
                ILogger<GetProject> logger,
                IdGenerator idGenerator,
                WebAppDbContext dbContext,
                CancellationToken cancellationToken) =>
            {
                logger.LogInformation("Request project {projectId}", projectId);

                var project = await dbContext.Projects
                    .SingleOrDefaultAsync(o => o.Id == projectId, cancellationToken);

                if (project == null)
                {
                    return TypedResults.NotFound();
                }

                var projectModel = new ProjectModel(project.Id, project.Name);

                return TypedResults.Ok(projectModel);
            });
        }
    }
}
