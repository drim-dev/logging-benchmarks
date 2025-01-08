using LoggingBenchmark.Resources;
using Projects;

var builder = DistributedApplication.CreateBuilder(args);

var elasticsearch = builder
    .AddContainer("elasticsearch", "elasticsearch", "8.16.1")
    .WithEnvironment("discovery.type", "single-node")
    .WithEnvironment("bootstrap.memory_lock", "true")
    .WithEnvironment("xpack.security.enabled", "false")
    .WithEnvironment("cluster.routing.allocation.disk.threshold_enabled", "false")
    .WithHttpEndpoint(targetPort: 9200)
    .WithLifetime(ContainerLifetime.Persistent);

builder
    .AddContainer("kibana", "kibana", "8.16.1")
    .WithEnvironment("ELASTICSEARCH_HOSTS", elasticsearch.GetEndpoint("http"))
    .WithHttpEndpoint(targetPort: 5601, port: 61679)
    .WithLifetime(ContainerLifetime.Persistent);

var postgres = builder
    .AddPostgres("postgres")
    .WithImageTag("17.2")
    .WithPgAdmin()
    .WithLifetime(ContainerLifetime.Persistent);

var webAppDb = postgres.AddDatabase(ResourceName.WebAppDb);

builder.AddProject<LoggingBenchmark_WebApp>("web-app")
    .WithEnvironment("AspireRuntime", true.ToString())
    .WithEnvironment("BenchmarkType", "OtelConsole")
    .WithEnvironment("Logging__Elasticsearch__ShipTo__NodeUris__0", elasticsearch.GetEndpoint("http"))
    .WithEnvironment("Logging__Elasticsearch__Index__Format", "web-app-{0:yyyy.MM.dd}")
    .WaitFor(webAppDb)
    .WithReference(webAppDb);

builder.Build().Run();
