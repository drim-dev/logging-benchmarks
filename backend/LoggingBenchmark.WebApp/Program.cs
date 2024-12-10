using IdGen.DependencyInjection;
using LoggingBenchmark.WebApp.Features.Projects;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddOpenApi();

builder.Services.AddIdGen(1);

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.MapProjectsFeature();

app.Run();
