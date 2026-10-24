package main

import (
	"context"
	"errors"
	"fmt"
	"os"

	"go.opentelemetry.io/otel/exporters/otlp/otlpmetric/otlpmetrichttp"
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracehttp"
	sdkmetric "go.opentelemetry.io/otel/sdk/metric"
	"go.opentelemetry.io/otel/sdk/resource"
	sdktrace "go.opentelemetry.io/otel/sdk/trace"
	semconv "go.opentelemetry.io/otel/semconv/v1.40.0"
)

// observability holds the trace and metric providers. Every request gets a
// trace id (REQ-API-001); spans and RED metrics leave the process only when
// OTEL_EXPORTER_OTLP_ENDPOINT names the collector sidecar (§15 D86).
type observability struct {
	tracer *sdktrace.TracerProvider
	meter  *sdkmetric.MeterProvider
}

func newObservability(ctx context.Context, sampleRatio float64, env string) (*observability, error) {
	res := resource.NewWithAttributes(semconv.SchemaURL,
		semconv.ServiceName("control-plane"),
		semconv.DeploymentEnvironmentName(env),
	)
	traceOpts := []sdktrace.TracerProviderOption{
		sdktrace.WithResource(res),
		sdktrace.WithSampler(sdktrace.ParentBased(sdktrace.TraceIDRatioBased(sampleRatio))),
	}
	meterOpts := []sdkmetric.Option{sdkmetric.WithResource(res)}
	if os.Getenv("OTEL_EXPORTER_OTLP_ENDPOINT") != "" {
		spans, err := otlptracehttp.New(ctx)
		if err != nil {
			return nil, fmt.Errorf("trace exporter: %w", err)
		}
		metrics, err := otlpmetrichttp.New(ctx)
		if err != nil {
			return nil, fmt.Errorf("metric exporter: %w", err)
		}
		traceOpts = append(traceOpts, sdktrace.WithBatcher(spans))
		meterOpts = append(meterOpts, sdkmetric.WithReader(sdkmetric.NewPeriodicReader(metrics)))
	}
	return &observability{tracer: sdktrace.NewTracerProvider(traceOpts...), meter: sdkmetric.NewMeterProvider(meterOpts...)}, nil
}

func (o *observability) shutdown(ctx context.Context) error {
	return errors.Join(o.tracer.Shutdown(ctx), o.meter.Shutdown(ctx))
}
