namespace LoggingBenchmark.WebApp.Domain;

public class Project
{
    public const int NameMaxLength = 100;
    public long Id { get; init; }
    public required string Name { get; init; }
}
