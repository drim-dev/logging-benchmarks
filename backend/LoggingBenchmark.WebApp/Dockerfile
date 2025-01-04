FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS base
WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src
COPY ["LoggingBenchmark.WebApp/LoggingBenchmark.WebApp.csproj", "LoggingBenchmark.WebApp/"]
COPY ["LoggingBenchmark.Resources/LoggingBenchmark.Resources.csproj", "LoggingBenchmark.Resources/"]
RUN dotnet restore "LoggingBenchmark.WebApp/LoggingBenchmark.WebApp.csproj"
COPY . .
WORKDIR "/src/LoggingBenchmark.WebApp"
RUN dotnet build "LoggingBenchmark.WebApp.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "LoggingBenchmark.WebApp.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "LoggingBenchmark.WebApp.dll"]
