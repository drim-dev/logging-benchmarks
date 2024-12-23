using IdGen;
using LoggingBenchmark.WebApp.Database;
using LoggingBenchmark.WebApp.Domain;
using LoggingBenchmark.WebApp.Features.Projects.Models;
using Microsoft.AspNetCore.Http.HttpResults;

namespace LoggingBenchmark.WebApp.Features.Projects.Requests;

public class CreateProject
{
    public class Endpoint
    {
        public void MapEndpoint(IEndpointRouteBuilder builder)
        {
            builder.MapPost("/project/", async Task<Ok<ProjectModel>> (
                CreateProjectRequest request,
                ILogger<CreateProject> logger,
                IdGenerator idGenerator,
                WebAppDbContext dbContext,
                CancellationToken cancellationToken) =>
            {
                var project =
                    await dbContext.Projects.AddAsync(new Project { Id = idGenerator.CreateId(), Name = request.Name },
                        cancellationToken);
                await dbContext.SaveChangesAsync(cancellationToken);

                var projectModel = new ProjectModel(project.Entity.Id, project.Entity.Name);

                logger.LogInformation("Project created with id: {projectId}", projectModel.Id);

                return TypedResults.Ok(projectModel);
            });
        }
    }

    public record CreateProjectRequest(string Name);
}
