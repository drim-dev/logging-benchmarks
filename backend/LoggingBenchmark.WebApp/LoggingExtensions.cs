using Elastic.Extensions.Logging;
using OpenTelemetry;
using OpenTelemetry.Logs;

namespace LoggingBenchmark.WebApp;

public static class LoggingExtensions
{
    public static void AddLogging(this WebApplicationBuilder builder)
    {
        builder.Logging.ClearProviders();

        var benchmarkType = builder.Configuration.GetValue<BenchmarkType>("BenchmarkType");

        switch (benchmarkType)
        {
            case BenchmarkType.OtelConsole:
                builder.AddOtelConsoleLogging();
                break;
            case BenchmarkType.ElasticsearchHttpClient:
                builder.AddElasticsearchHttpClientLogging();
                break;
        }

        builder.UseOtlpExporterIfAspire();
    }

    private static ILoggingBuilder AddOtelConsoleLogging(this WebApplicationBuilder builder)
    {
        return builder.Logging
            .AddOpenTelemetry(options =>
            {
                options.IncludeFormattedMessage = true;
                options.IncludeScopes = true;
                options.AddConsoleExporter();
            });
    }

    private static ILoggingBuilder AddElasticsearchHttpClientLogging(this WebApplicationBuilder builder)
    {
        return builder.Logging.AddElasticsearch();
    }

    private static void UseOtlpExporterIfAspire(this WebApplicationBuilder builder)
    {
        bool useAspire = builder.Configuration.GetValue<bool>("AspireRuntime");
        if (useAspire)
        {
            builder.Services.AddOpenTelemetry().UseOtlpExporter();
        }
    }
}

public enum BenchmarkType
{
    OtelConsole = 1,
    ElasticsearchHttpClient = 2
}
