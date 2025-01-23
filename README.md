# Logging Benchmarks

## Goal

The primary goal of this experiment is to __evaluate the performance implications of centralized logging__ in an ASP.NET Core application under high load. In many production environments, __centralized logging__ is essential, and Elasticsearch is a popular choice for log storage and analysis. Two frequently adopted approaches are:

1. __Direct Logging to Elasticsearch__ - https://www.elastic.co/guide/en/ecs-logging/dotnet/current/extensions-logging-data-shipper.html.
2. __Logging via the OpenTelemetry Collector, which handles reading, buffering, and forwarding logs to Elasticsearch__ - https://opentelemetry.io/docs/specs/otel/logs/.

By comparing these options (including a baseline with no logging at all), we aim to gather performance data (CPU, memory, and latencies) to help inform better architectural decisions regarding log processing pipelines.

## Setup

The application to be tested is located at https://github.com/drim-dev/logging-benchmarks/tree/main/backend.

It contains several endpoints. We will test the single POST endpoint that inserts a record into PostgreSQL and writes two log records. One record is written explicitly, while Entity Framework Core writes the other. https://github.com/drim-dev/logging-benchmarks/blob/main/backend/LoggingBenchmark.WebApp/Features/Projects/Requests/CreateProject.cs.

We use k6 to generate load. The default configuration sends 2000 requests per second for 10 minutes - https://github.com/drim-dev/logging-benchmarks/blob/main/k6/script.js. We use the open model. Read the article for details - https://grafana.com/docs/k6/latest/using-k6/scenarios/concepts/open-vs-closed/.

Node Exporter gathers app server metrics, which Prometheus pulls and stores. Grafana allows us to see metrics graphs. We are interested in two metrics:

* App server CPU utilization https://github.com/drim-dev/logging-benchmarks/blob/main/terraform/modules/grafana-stack/dashboards/server-utilization.json#L111

* App server memory utilization https://github.com/drim-dev/logging-benchmarks/blob/main/terraform/modules/grafana-stack/dashboards/server-utilization.json#L203

We use Elasticsearch for log storage and Kibana for log visualization.

The testing environment consists of 4 Azure virtual machines. The VM size is Standard_D4ads_v5, and it contains 4 vCPUs and 16 GB of RAM - https://github.com/drim-dev/logging-benchmarks/blob/main/terraform/modules/azure/virtual-machine/main.tf#L41.

_We use several servers to isolate components so they do not interfere with each other and distort the benchmark results._

## Benchmarks

We ran all benchmarks several times to ensure the results were stable and reproducible.

### No Logging

The application has logging disabled. We do not run OpenTelemetry Collector.

![No Logging Setup](docs/images//no-logging-setup.png)

#### App Server Utilization

![No Logging Server Utilization](docs/images/no-logging-utilization.png)

_CPU utilization is ~32%._

_Memory utilization is ~7.3%._

#### HTTP Requests Latencies

 avg      | min      | med      | p(90)    | p(95)    |  max
----------|----------|----------|----------|----------|----------
 13.17 ms | 1.67 ms  | 3.02 ms  | 7.89 ms  | 18.67 ms | 1.24 s

### Application to Elasticsearch

The application sends logs directly to Elasticsearch. We do not run OpenTelemetry Collector.

![App to Elasticsearch Setup](docs/images/app-to-elasticsearch-setup.png)

#### App Server Utilization

![App to Elasticsearch Server Utilization](docs/images/app-to-elasticsearch-utilization.png)

_CPU utilization is ~52%._

_Memory utilization is ~12%._

#### HTTP Requests Latencies

 avg      | min      | med      | p(90)    | p(95)    |  max
----------|----------|----------|----------|----------|----------
 11.27 ms | 1.74 ms  | 3.16 ms  | 8.77 ms  | 32.39 ms | 1.56 s

### OpenTelemetry Collector to Elasticsearch

The application writes logs in JSON format to the console. Docker writes logs from the console to a JSON file. We run OpenTelemetry Collector, which reads logs from the JSON file and sends them to Elasticsearch.

![OTel Collector Setup](docs/images/otel-collector-setup.png)

#### App Server Utilization

![OTel Collector to Elasticsearch Server Utilization](docs/images/otel-collector-to-elasticsearch-utilization.png)

_CPU utilization is ~55%._

_Memory utilization is ~8.5%._

#### HTTP Requests Latencies

 avg      | min      | med      | p(90)    | p(95)    |  max
----------|----------|----------|----------|----------|----------
 9.42 ms  | 1.71 ms  | 3.11 ms  | 6.14 ms  | 8.89 ms  | 1.18 s

### Summary Table

 Scenario             | CPU      | Memory   | avg      | min      | med      | p(90)    | p(95)    |  max
----------------------|----------|----------|----------|----------|----------|----------|----------|----------
 No Logging           | 32%      | 7.3%     | 13.17 ms | 1.67 ms  | 3.02 ms  | 7.89 ms  | 18.67 ms | 1.24 s
 Application to ES    | 52%      | 12%      | 11.27 ms | 1.74 ms  | 3.16 ms  | 8.77 ms  | 32.39 ms | 1.56 s
 OTel Collector to ES | 55%      | 8.5%     | 9.42 ms  | 1.71 ms  | 3.11 ms  | 6.14 ms  | 8.89 ms  | 1.18 s

## Key Conclusions

1. __Logging incurs significant overhead__. Both logging scenarios (direct to Elasticsearch and via the Collector) drive CPU utilization up from 32% to ~50–55%. This is a 65-75% CPU consumption increase, which is huge. Memory consumption increase is also high.

2. __OTel Collector offers better performance than direct sending to Elasticsearch__. Despite a slightly higher CPU usage (55% compared to 52%), the OTel Collector solution consistently provides the lowest latencies across all metrics (average, tail, and max). The memory consumption is significantly lower (8.5% compared to 12%). This setup seems to offload work from the application process itself, leading to more stable and predictable response times.

## How to Reproduce

### Local Environment

### Azure Environment
