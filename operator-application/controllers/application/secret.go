package applicationcontroller

import (
	"context"

	applicationsamplev1beta1 "github.com/nheidloff/operator-sample-go/operator-application/api/v1beta1"
	corev1 "k8s.io/api/core/v1"
	"k8s.io/apimachinery/pkg/api/errors"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/types"
	ctrl "sigs.k8s.io/controller-runtime"
	"sigs.k8s.io/controller-runtime/pkg/log"
)

func (reconciler *ApplicationReconciler) defineSecret(application *applicationsamplev1beta1.Application) *corev1.Secret {
	stringData := make(map[string]string)
	stringData[secretGreetingMessageLabel] = greetingMessage

	secret := &corev1.Secret{
		TypeMeta:   metav1.TypeMeta{APIVersion: "v1", Kind: "Secret"},
		ObjectMeta: metav1.ObjectMeta{Name: secretName, Namespace: application.Namespace},
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
	err := reconciler.Get(ctx, types.NamespacedName{Name: secretName, Namespace: application.Namespace}, secret)
	if err != nil {
		if errors.IsNotFound(err) {
			log.Info("Secret resource " + secretName + " not found. Creating or re-creating secret")
			err = reconciler.Create(ctx, secretDefinition)
			if err != nil {
				log.Info("Failed to create secret resource. Re-running reconcile.")
				return ctrl.Result{}, err
			}
		} else {
			log.Info("Failed to get secret resource " + secretName + ". Re-running reconcile.")
			return ctrl.Result{}, err
		}
	} else {
		// Note: For simplication purposes secrets are not updated - see deployment section
	}
	return ctrl.Result{}, nil
}
