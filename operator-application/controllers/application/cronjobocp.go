package applicationcontroller

import (
	"context"

	applicationsamplev1beta1 "github.com/ibm/operator-sample-go/operator-application/api/v1beta1"
	variables "github.com/ibm/operator-sample-go/operator-application/variables"
	batchv1 "k8s.io/api/batch/v1"
	v1 "k8s.io/api/core/v1"
	"k8s.io/apimachinery/pkg/api/errors"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/types"
	ctrl "sigs.k8s.io/controller-runtime"
	"sigs.k8s.io/controller-runtime/pkg/log"
)

//runsOnOpenShift

func (reconciler *ApplicationReconciler) defineCronJobOCP(application *applicationsamplev1beta1.Application) *batchv1.CronJob {

	cronJob := &batchv1.CronJob{
		TypeMeta: metav1.TypeMeta{},
		ObjectMeta: metav1.ObjectMeta{
			Name:      variables.CronJobName,
			Namespace: application.Namespace,
		},

		Spec: batchv1.CronJobSpec{
			Schedule: variables.CronJobSchedule,
			JobTemplate: batchv1.JobTemplateSpec{
				ObjectMeta: metav1.ObjectMeta{},
				Spec: batchv1.JobSpec{
					Template: v1.PodTemplateSpec{
						ObjectMeta: metav1.ObjectMeta{
							Name:      variables.CronJobName,
							Namespace: application.Namespace,
						},
						Spec: v1.PodSpec{
							RestartPolicy: v1.RestartPolicyNever,
							Containers: []v1.Container{{
								Image: variables.ApplicationScalerImageName,
								Name:  variables.ApplicationScalerContainerName,
								Env: []v1.EnvVar{
									{Name: variables.EnvApplicationResourceName, Value: variables.ValueApplicationResourceName},
									{Name: variables.EnvKeyApplicationResourceNameSpace, Value: variables.ValueApplicationResourceNameSpace},
								},
							}},
							Volumes: []v1.Volume{{
								Name: "certdata",
								VolumeSource: v1.VolumeSource{
									Secret: &v1.SecretVolumeSource{
										SecretName: "prometheus-cert-secret",
									},
								},
							}, {
								Name: "tokendata",
								VolumeSource: v1.VolumeSource{
									Secret: &v1.SecretVolumeSource{
										SecretName: "prometheus-token-secret",
									},
								},
							}},
						},
					},
				},
			},
		},
	}

	ctrl.SetControllerReference(application, cronJob, reconciler.Scheme)
	return cronJob

}

func (reconciler *ApplicationReconciler) reconcileCronJobOCP(ctx context.Context, application *applicationsamplev1beta1.Application) (ctrl.Result, error) {

	log := log.FromContext(ctx)
	var cronJob *batchv1.CronJob
	var cronJobDefinition *batchv1.CronJob

	cronJobDefinition = reconciler.defineCronJob(application)
	cronJob = &batchv1.CronJob{}

	err := reconciler.Get(ctx, types.NamespacedName{Name: variables.CronJobName, Namespace: application.Namespace}, cronJob)
	if err != nil {
		if errors.IsNotFound(err) {
			log.Info("cronjob Resource " + variables.CronJobName + " not found. creating or re-creating cronjob")
			err = reconciler.Create(ctx, cronJobDefinition)
			if err != nil {
				log.Info("failed to create cronjob definition resource. re-running reconcile.")
				return ctrl.Result{}, err
			}
		} else {
			log.Info("failed to get cronjob resource " + variables.CronJobName + ". re-running reconcile.")
			return ctrl.Result{}, err
		}
	} else {
		// Note: For simplication purposes CronJobs are not updated - see deployment section
		log.Info("Else")
	}

	return ctrl.Result{}, nil
}
