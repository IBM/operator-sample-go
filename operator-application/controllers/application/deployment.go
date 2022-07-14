package applicationcontroller

import (
	"context"

	applicationsamplev1beta1 "github.com/ibm/operator-sample-go/operator-application/api/v1beta1"
	"github.com/ibm/operator-sample-go/operator-application/utilities"
	"github.com/ibm/operator-sample-go/operator-application/variables"
	appsv1 "k8s.io/api/apps/v1"
	corev1 "k8s.io/api/core/v1"
	v1 "k8s.io/api/core/v1"
	"k8s.io/apimachinery/pkg/api/errors"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/types"
	"k8s.io/apimachinery/pkg/util/intstr"
	ctrl "sigs.k8s.io/controller-runtime"
	"sigs.k8s.io/controller-runtime/pkg/log"
)

func (reconciler *ApplicationReconciler) defineDeployment(application *applicationsamplev1beta1.Application) *appsv1.Deployment {
	replicas := application.Spec.AmountPods
	labels := map[string]string{variables.LabelKey: variables.ContainerName}

	deployment := &appsv1.Deployment{
		ObjectMeta: metav1.ObjectMeta{
			Name:      variables.DeploymentName,
			Namespace: application.Namespace,
		},
		Spec: appsv1.DeploymentSpec{
			Replicas: &replicas,
			Selector: &metav1.LabelSelector{
				MatchLabels: labels,
			},
			Template: corev1.PodTemplateSpec{
				ObjectMeta: metav1.ObjectMeta{
					Labels: labels,
				},
				Spec: corev1.PodSpec{
					Containers: []corev1.Container{{
						Image: variables.ImageName,
						Name:  variables.ContainerName,
						Ports: []corev1.ContainerPort{{
							ContainerPort: variables.Port,
						}},
						Env: []corev1.EnvVar{{
							Name: variables.SecretGreetingMessageLabel,
							ValueFrom: &v1.EnvVarSource{
								SecretKeyRef: &v1.SecretKeySelector{
									LocalObjectReference: v1.LocalObjectReference{
										Name: variables.SecretName,
									},
									Key: variables.SecretGreetingMessageLabel,
								},
							}},
						},
						ReadinessProbe: &v1.Probe{
							ProbeHandler: v1.ProbeHandler{
								HTTPGet: &v1.HTTPGetAction{Path: "/q/health/live", Port: intstr.IntOrString{
									IntVal: variables.Port,
								}},
							},
							InitialDelaySeconds: 20,
						},
						LivenessProbe: &v1.Probe{
							ProbeHandler: v1.ProbeHandler{
								HTTPGet: &v1.HTTPGetAction{Path: "/q/health/ready", Port: intstr.IntOrString{
									IntVal: variables.Port,
								}},
							},
							InitialDelaySeconds: 40,
						},
					}},
				},
			},
		},
	}

	specHashActual := utilities.GetHashForSpec(&deployment.Spec)
	deployment.Labels = utilities.SetHashToLabels(nil, specHashActual)

	ctrl.SetControllerReference(application, deployment, reconciler.Scheme)
	return deployment
}

func (reconciler *ApplicationReconciler) reconcileDeployment(ctx context.Context, application *applicationsamplev1beta1.Application) (ctrl.Result, error) {
	log := log.FromContext(ctx)
	deployment := &appsv1.Deployment{}
	deploymentDefinition := reconciler.defineDeployment(application)
	err := reconciler.Get(ctx, types.NamespacedName{Name: variables.DeploymentName, Namespace: application.Namespace}, deployment)
	if err != nil {
		if errors.IsNotFound(err) {
			log.Info("Deployment resource " + variables.DeploymentName + " not found. Creating or re-creating deployment")
			err = reconciler.Create(ctx, deploymentDefinition)
			if err != nil {
				log.Info("Failed to create deployment resource. Re-running reconcile.")
				return ctrl.Result{}, err
			}
			reconciler.Recorder.Eventf(application, corev1.EventTypeNormal, "Created", "ADAM Created deployment %s", deploymentDefinition.Name)
		} else {
			log.Info("Failed to get deployment resource " + variables.DeploymentName + ". Re-running reconcile.")
			return ctrl.Result{}, err
		}
	} else {
		// Note: Using the hashes allows more efficient checking of changes
		// Note: Whether or not to use the hashes depends on the scenarios
		// Note: In this scenario, we want to the controller to change back the number of replicas, if changed manually in 'Deployment'
		specHashTarget := utilities.GetHashForSpec(&deploymentDefinition.Spec)
		//specHashActual := utilities.GetHashFromLabels(deployment.Labels)
		//if specHashActual != specHashTarget {
		var current int32 = *deployment.Spec.Replicas
		var expected int32 = *deploymentDefinition.Spec.Replicas
		if current != expected {
			deployment.Spec.Replicas = &expected
			deployment.Labels = utilities.SetHashToLabels(deployment.Labels, specHashTarget)
			err = reconciler.Update(ctx, deployment)
			if err != nil {
				log.Info("Failed to update deployment resource. Re-running reconcile.")
				return ctrl.Result{}, err
			}
		}
		//}
	}
	return ctrl.Result{}, nil
}
