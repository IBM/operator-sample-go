package applicationcontroller

import (
	"github.com/prometheus/client_golang/prometheus"
	"sigs.k8s.io/controller-runtime/pkg/metrics"
)

var (
	goobers = prometheus.NewCounter(
		prometheus.CounterOpts{
			Name: "goobers_total",
			Help: "Number of goobers proccessed",
		},
	)
	gooberFailures = prometheus.NewCounter(
		prometheus.CounterOpts{
			Name: "goober_failures_total",
			Help: "Number of failed goobers",
		},
	)
)

func init() {
	// Register custom metrics with the global prometheus registry
	metrics.Registry.MustRegister(goobers, gooberFailures)
}
