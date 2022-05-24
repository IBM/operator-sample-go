package applicationcontroller

import (
	"context"

	applicationsamplev1beta1 "github.com/ibm/operator-sample-go/operator-application/api/v1beta1"
	"github.com/ibm/operator-sample-go/operator-application/variables"
	corev1 "k8s.io/api/core/v1"
	"k8s.io/apimachinery/pkg/api/errors"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/types"
	ctrl "sigs.k8s.io/controller-runtime"
	"sigs.k8s.io/controller-runtime/pkg/log"
)

func (reconciler *ApplicationReconciler) defineSecret(application *applicationsamplev1beta1.Application) *corev1.Secret {
	stringData := make(map[string]string)
	stringData[variables.SecretGreetingMessageLabel] = variables.GreetingMessage

	secret := &corev1.Secret{
		TypeMeta:   metav1.TypeMeta{APIVersion: "v1", Kind: "Secret"},
		ObjectMeta: metav1.ObjectMeta{Name: variables.SecretName, Namespace: application.Namespace},
		Immutable:  new(bool),
		Data:       map[string][]byte{},
		StringData: stringData,
		Type:       "Opaque",
	}

	ctrl.SetControllerReference(application, secret, reconciler.Scheme)
	return secret
}

func (reconciler *ApplicationReconciler) reconcileSecret(ctx context.Context, application *applicationsamplev1beta1.Application) (ctrl.Result, error) {
	log := log.FromContext(ctx)
	secret := &corev1.Secret{}
	secretDefinition := reconciler.defineSecret(application)
	err := reconciler.Get(ctx, types.NamespacedName{Name: variables.SecretName, Namespace: application.Namespace}, secret)
	if err != nil {
		if errors.IsNotFound(err) {
			log.Info("Secret resource " + variables.SecretName + " not found. Creating or re-creating secret")
			err = reconciler.Create(ctx, secretDefinition)
			if err != nil {
				log.Info("failed to create secret resource. re-running reconcile.")
				return ctrl.Result{}, err
			}
		} else {
			log.Info("failed to get secret resource " + variables.SecretName + ". re-running reconcile.")
			return ctrl.Result{}, err
		}
	} else {
		// Note: For simplication purposes secrets are not updated - see deployment section
		log.Info("")
	}
	return ctrl.Result{}, nil
}
