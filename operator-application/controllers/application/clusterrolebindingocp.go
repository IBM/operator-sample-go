package applicationcontroller

import (
	"context"

	applicationsamplev1beta1 "github.com/ibm/operator-sample-go/operator-application/api/v1beta1"
	variables "github.com/ibm/operator-sample-go/operator-application/variables"

	v1 "k8s.io/api/rbac/v1"

	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"

	"k8s.io/apimachinery/pkg/api/errors"
	"k8s.io/apimachinery/pkg/types"
	ctrl "sigs.k8s.io/controller-runtime"
	"sigs.k8s.io/controller-runtime/pkg/log"
)

func (reconciler *ApplicationReconciler) defineClusterRoleBindingOCPWithOLM(application *applicationsamplev1beta1.Application) *v1.ClusterRoleBinding {
	labels := map[string]string{variables.LabelKey: variables.LabelValue}

	clusterRoleBinding := &v1.ClusterRoleBinding{
		TypeMeta:   metav1.TypeMeta{APIVersion: "v1", Kind: "ClusterRoleBinding"},
		ObjectMeta: metav1.ObjectMeta{Name: variables.ClusterRoleBindingNameOCPWithOLM, Namespace: variables.OCPOperatorWithOLMNamespace, Labels: labels},
		Subjects: []v1.Subject{{
			Kind:      "ServiceAccount",
			Name:      variables.RoleBindingServiceAccountOCP,
			Namespace: variables.OCPOperatorWithOLMNamespace,
		}},
		RoleRef: v1.RoleRef{
			APIGroup: "rbac.authorization.k8s.io",
			Kind:     "ClusterRole",
			Name:     "prometheus-k8s-role",
		},
	}

	ctrl.SetControllerReference(application, clusterRoleBinding, reconciler.Scheme)
	return clusterRoleBinding
}

func (reconciler *ApplicationReconciler) defineClusterRoleBindingOCPWithoutOLM(application *applicationsamplev1beta1.Application) *v1.ClusterRoleBinding {
	labels := map[string]string{variables.LabelKey: variables.LabelValue}

	clusterRoleBinding := &v1.ClusterRoleBinding{
		TypeMeta:   metav1.TypeMeta{APIVersion: "v1", Kind: "ClusterRoleBinding"},
		ObjectMeta: metav1.ObjectMeta{Name: variables.ClusterRoleBindingNameOCPWithoutOLM, Namespace: variables.OCPOperatorWithoutOLMNamespace, Labels: labels},
		Subjects: []v1.Subject{{
			Kind:      "ServiceAccount",
			Name:      variables.RoleBindingServiceAccountOCP,
			Namespace: variables.OCPOperatorWithoutOLMNamespace,
		}},
		RoleRef: v1.RoleRef{
			APIGroup: "rbac.authorization.k8s.io",
			Kind:     "ClusterRole",
			Name:     "prometheus-k8s-role",
		},
	}

	ctrl.SetControllerReference(application, clusterRoleBinding, reconciler.Scheme)
	return clusterRoleBinding
}

func (reconciler *ApplicationReconciler) reconcileClusterRoleBindingOCP(ctx context.Context, application *applicationsamplev1beta1.Application) (ctrl.Result, error) {
	log := log.FromContext(ctx)
	clusterRoleBindingDefinitionWithOLM := reconciler.defineClusterRoleBindingOCPWithOLM(application)
	clusterRoleBindingDefinitionWithoutOLM := reconciler.defineClusterRoleBindingOCPWithoutOLM(application)
	clusterRoleBinding := &v1.ClusterRoleBinding{}

	err := reconciler.Get(ctx, types.NamespacedName{Name: variables.ClusterRoleBindingNameOCPWithOLM, Namespace: variables.OCPOperatorWithOLMNamespace}, clusterRoleBinding)
	if err != nil {
		if errors.IsNotFound(err) {
			log.Info("ClusterRoleBinding resource " + variables.ClusterRoleBindingNameOCPWithOLM + " not found. Creating or re-creating ClusterRoleBinding")
			err = reconciler.Create(ctx, clusterRoleBindingDefinitionWithOLM)
			if err != nil {
				log.Info("Failed to create ClusterRoleBindingWithOLM resource. Re-running reconcile.")
				return ctrl.Result{}, err
			}
		} else {
			log.Info("Failed to get ClusterRoleBinding resource " + variables.ClusterRoleBindingNameOCPWithOLM + ". Re-running reconcile.")
			return ctrl.Result{}, err
		}
	} else {
		// Note: For simplication purposes services are not updated - see deployment section
		log.Info("")
	}

	err = reconciler.Get(ctx, types.NamespacedName{Name: variables.ClusterRoleBindingNameOCPWithoutOLM, Namespace: variables.OCPOperatorWithoutOLMNamespace}, clusterRoleBinding)
	if err != nil {
		if errors.IsNotFound(err) {
			log.Info("ClusterRoleBinding resource " + variables.ClusterRoleBindingNameOCPWithoutOLM + " not found. Creating or re-creating ClusterRoleBinding")
			err = reconciler.Create(ctx, clusterRoleBindingDefinitionWithoutOLM)
			if err != nil {
				log.Info("Failed to create ClusterRoleBindingWithoutOLM resource. Re-running reconcile.")
				return ctrl.Result{}, err
			}
		} else {
			log.Info("Failed to get ClusterRoleBinding resource " + variables.ClusterRoleBindingNameOCPWithoutOLM + ". Re-running reconcile.")
			return ctrl.Result{}, err
		}
	} else {
		// Note: For simplication purposes services are not updated - see deployment section
		log.Info("")
	}

	return ctrl.Result{}, nil
}
