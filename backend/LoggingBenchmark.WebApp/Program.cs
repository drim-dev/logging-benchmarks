using IdGen.DependencyInjection;
using LoggingBenchmark.Resources;
using LoggingBenchmark.WebApp;
using LoggingBenchmark.WebApp.Database;
using LoggingBenchmark.WebApp.Features.Projects;

var builder = WebApplication.CreateBuilder(args);

builder.AddLogging();

builder.Services.AddOpenApi();

builder.AddNpgsqlDbContext<WebAppDbContext>(ResourceName.WebAppDb);
builder.Services.AddHostedService<SetupHostedService>();

builder.Services.AddIdGen(1);

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.MapProjectsFeature();

app.Run();
