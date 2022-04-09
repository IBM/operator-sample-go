package databaseclustercontroller

import (
	"context"

	databasesamplev1alpha1 "github.com/ibm/operator-sample-go/operator-database/api/v1alpha1"
	variables "github.com/ibm/operator-sample-go/operator-database/variablesdatabasecluster"

	corev1 "k8s.io/api/core/v1"
	"k8s.io/apimachinery/pkg/api/errors"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/types"
	ctrl "sigs.k8s.io/controller-runtime"
	"sigs.k8s.io/controller-runtime/pkg/log"
)

func (reconciler *DatabaseClusterReconciler) defineService(databasecluster *databasesamplev1alpha1.DatabaseCluster) *corev1.Service {
	labels := map[string]string{variables.LabelKey: variables.LabelValue}

	service := &corev1.Service{
		TypeMeta:   metav1.TypeMeta{APIVersion: "v1", Kind: "Service"},
		ObjectMeta: metav1.ObjectMeta{Name: variables.ServiceName, Namespace: databasecluster.Namespace, Labels: labels},
		Spec: corev1.ServiceSpec{
			Type:      corev1.ServiceTypeClusterIP,
			ClusterIP: "None",
			Ports: []corev1.ServicePort{{
				Port: variables.Port,
			}},
			Selector: labels,
		},
	}

	ctrl.SetControllerReference(databasecluster, service, reconciler.Scheme)
	return service
}

func (reconciler *DatabaseClusterReconciler) reconcileService(ctx context.Context, databasecluster *databasesamplev1alpha1.DatabaseCluster) (ctrl.Result, error) {
	log := log.FromContext(ctx)
	serviceDefinition := reconciler.defineService(databasecluster)
	service := &corev1.Service{}
	err := reconciler.Get(ctx, types.NamespacedName{Name: variables.ServiceName, Namespace: databasecluster.Namespace}, service)
	if err != nil {
		if errors.IsNotFound(err) {
			log.Info("Service resource " + variables.ServiceName + " not found. Creating or re-creating service")
			err = reconciler.Create(ctx, serviceDefinition)
			if err != nil {
				log.Info("Failed to create service resource. Re-running reconcile.")
				return ctrl.Result{}, err
			}
		} else {
			log.Info("Failed to get service resource " + variables.ServiceName + ". Re-running reconcile.")
			return ctrl.Result{}, err
		}
	} else {
		// Note: For simplication purposes services are not updated - see deployment section
	}
	return ctrl.Result{}, nil
}
