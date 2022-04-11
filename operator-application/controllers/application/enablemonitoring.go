package applicationcontroller

import (
	"github.com/prometheus/client_golang/prometheus"
	"sigs.k8s.io/controller-runtime/pkg/metrics"
)

var (
	reconcile_counts = prometheus.NewCounter(
		prometheus.CounterOpts{
			Name: "reconcile_counts",
			Help: "Number of times reconcile proccessed",
		},
	)
	reconcile_counts_fails = prometheus.NewCounter(
		prometheus.CounterOpts{
			Name: "reconcile_counts_fails",
			Help: "Number of times reconcile call failed",
		},
	)
)

func prometheusinit() {
	// Register custom metrics with the global prometheus registry
	metrics.Registry.MustRegister(reconcile_counts, reconcile_counts_fails)
}
