package telemetry

import (
	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/metric"
)

func WithAttrSet(attrs attribute.Set) metric.MeasurementOption {
	return metric.WithAttributeSet(attrs)
}
