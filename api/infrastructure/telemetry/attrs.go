package telemetry

import (
	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/metric"
)

func CommandAttrSet(name string, err error) metric.MeasurementOption {
	status := "success"
	if err != nil {
		status = "error"
	}
	return metric.WithAttributeSet(attribute.NewSet(
		attribute.String("command.name", name),
		attribute.String("status", status),
	))
}

func QueryAttrSet(name string, err error) metric.MeasurementOption {
	status := "success"
	if err != nil {
		status = "error"
	}
	return metric.WithAttributeSet(attribute.NewSet(
		attribute.String("query.name", name),
		attribute.String("status", status),
	))
}
