package applicationcontroller

import (
	"context"
	"time"

	applicationsamplev1beta1 "github.com/ibm/operator-sample-go/operator-application/api/v1beta1"
	"github.com/ibm/operator-sample-go/operator-application/variables"
	monitoringv1 "github.com/prometheus-operator/prometheus-operator/pkg/apis/monitoring/v1"
	"k8s.io/apimachinery/pkg/api/errors"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/types"
	ctrl "sigs.k8s.io/controller-runtime"
	"sigs.k8s.io/controller-runtime/pkg/log"
)

func (reconciler *ApplicationReconciler) defineMonitor(application *applicationsamplev1beta1.Application) *monitoringv1.ServiceMonitor {
	labels := map[string]string{variables.LabelKey: variables.ContainerName}
	monitor := &monitoringv1.ServiceMonitor{
		TypeMeta: metav1.TypeMeta{
			APIVersion: "v1",
			Kind:       "ServiceMonitor"},
		ObjectMeta: metav1.ObjectMeta{
			Name:      variables.MonitorName,
			Namespace: application.Namespace,
			Labels:    labels,
		},
		Spec: monitoringv1.ServiceMonitorSpec{
			Endpoints: []monitoringv1.Endpoint{{
				Path: "/q/metrics",
			}},
			Selector: metav1.LabelSelector{
				MatchLabels: labels,
			},
		},
	}
	ctrl.SetControllerReference(application, monitor, reconciler.Scheme)
	return monitor
}

func (reconciler *ApplicationReconciler) reconcileMonitor(ctx context.Context, application *applicationsamplev1beta1.Application) (ctrl.Result, error) {
	log := log.FromContext(ctx)
	monitor := &monitoringv1.ServiceMonitor{}
	monitorDefinition := reconciler.defineMonitor(application)
	err := reconciler.Get(ctx, types.NamespacedName{Name: variables.MonitorName, Namespace: application.Namespace}, monitor)
	if err != nil {
		if errors.IsNotFound(err) {
			log.Info("Monitor resource " + variables.MonitorName + " not found. Creating or re-creating monitor")
			err = reconciler.Create(ctx, monitorDefinition)
			if err != nil {
				log.Info("Failed to create monitor resource. Re-running reconcile.")
				return ctrl.Result{}, err
			} else {
				return ctrl.Result{RequeueAfter: time.Second * 1}, nil
			}
		} else {
			log.Info("Failed to get monitor resource " + variables.MonitorName + ". Re-running reconcile.")
			return ctrl.Result{}, err
		}
	}
	return ctrl.Result{}, nil
}
