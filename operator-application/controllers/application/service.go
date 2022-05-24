package applicationcontroller

import (
	"context"

	applicationsamplev1beta1 "github.com/ibm/operator-sample-go/operator-application/api/v1beta1"
	"github.com/ibm/operator-sample-go/operator-application/variables"
	corev1 "k8s.io/api/core/v1"
	"k8s.io/apimachinery/pkg/api/errors"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/types"
	"k8s.io/apimachinery/pkg/util/intstr"
	ctrl "sigs.k8s.io/controller-runtime"
	"sigs.k8s.io/controller-runtime/pkg/log"
)

func (reconciler *ApplicationReconciler) defineService(application *applicationsamplev1beta1.Application) *corev1.Service {
	labels := map[string]string{variables.LabelKey: variables.ContainerName}

	service := &corev1.Service{
		TypeMeta: metav1.TypeMeta{
			APIVersion: "v1",
			Kind:       "Service"},
		ObjectMeta: metav1.ObjectMeta{
			Name:      variables.ServiceName,
			Namespace: application.Namespace,
			Labels:    labels},
		Spec: corev1.ServiceSpec{
			Type: corev1.ServiceTypeNodePort,
			Ports: []corev1.ServicePort{{
				Port:     variables.Port,
				NodePort: variables.NodePort,
				Protocol: "TCP",
				TargetPort: intstr.IntOrString{
					IntVal: variables.Port,
				},
			}},
			Selector: labels,
		},
	}

	ctrl.SetControllerReference(application, service, reconciler.Scheme)
	return service
}

func (reconciler *ApplicationReconciler) reconcileService(ctx context.Context, application *applicationsamplev1beta1.Application) (ctrl.Result, error) {
	log := log.FromContext(ctx)
	serviceDefinition := reconciler.defineService(application)
	service := &corev1.Service{}
	err := reconciler.Get(ctx, types.NamespacedName{Name: variables.ServiceName, Namespace: application.Namespace}, service)
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
		// Note: For simplication purposes secrets are not updated - see deployment section
		log.Info("")
	}
	return ctrl.Result{}, nil
}
