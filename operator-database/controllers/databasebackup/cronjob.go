package databasebackupcontroller

import (
	"context"

	databasesamplev1alpha1 "github.com/ibm/operator-sample-go/operator-database/api/v1alpha1"

	variables "github.com/ibm/operator-sample-go/operator-database/variablesdatabasebackup"
	batchv1 "k8s.io/api/batch/v1"
	v1 "k8s.io/api/core/v1"
	"k8s.io/apimachinery/pkg/api/errors"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/types"
	ctrl "sigs.k8s.io/controller-runtime"
	"sigs.k8s.io/controller-runtime/pkg/log"
)

func (reconciler *DatabaseBackupReconciler) defineCronJob(databasebackup *databasesamplev1alpha1.DatabaseBackup, repoIndex int) *batchv1.CronJob {
	labels := map[string]string{variables.LabelKey: variables.LabelValue}

	cronJob := &batchv1.CronJob{
		TypeMeta: metav1.TypeMeta{},
		ObjectMeta: metav1.ObjectMeta{
			Name:      variables.CronJobName,
			Namespace: databasebackup.Namespace,
			Labels:    labels,
		},
		Spec: batchv1.CronJobSpec{
			Schedule: databasebackup.Spec.ScheduledTrigger.Schedule,
			JobTemplate: batchv1.JobTemplateSpec{
				ObjectMeta: metav1.ObjectMeta{},
				Spec: batchv1.JobSpec{
					Template: v1.PodTemplateSpec{
						ObjectMeta: metav1.ObjectMeta{
							Name:      variables.CronJobName,
							Namespace: databasebackup.Namespace,
						},
						Spec: v1.PodSpec{
							RestartPolicy: v1.RestartPolicyNever,
							Containers: []v1.Container{{
								Image: variables.ImageName,
								Name:  variables.ContainerName,
								Env: []v1.EnvVar{
									{Name: variables.EnvKeyBackupResourceName, Value: variables.BackupResourceName},
									{Name: variables.EnvKeyNamespace, Value: databasebackup.Namespace},
									{Name: variables.EnvKeyCosRegion, Value: databasebackup.Spec.Repos[repoIndex].CosRegion},
									{Name: variables.EnvKeyCosEndpoint, Value: databasebackup.Spec.Repos[repoIndex].ServiceEndpoint},
									{Name: variables.EnvKeyCosHmacAccessKeyId,
										ValueFrom: &v1.EnvVarSource{
											SecretKeyRef: &v1.SecretKeySelector{
												LocalObjectReference: v1.LocalObjectReference{
													Name: variables.EnvKeyCosSecretName,
												},
												Key: variables.EnvKeyCosSecretDataKeyHmacAccessKeyId,
											},
										}},
									{Name: variables.EnvKeyCosHmacSecretAccessKey,
										ValueFrom: &v1.EnvVarSource{
											SecretKeyRef: &v1.SecretKeySelector{
												LocalObjectReference: v1.LocalObjectReference{
													Name: variables.EnvKeyCosSecretName,
												},
												Key: variables.EnvKeyCosSecretDataKeyHmacSecretAccess,
											},
										}},
								},
							}},
						},
					},
				},
			},
		},
	}

	ctrl.SetControllerReference(databasebackup, cronJob, reconciler.Scheme)
	return cronJob

}

func (reconciler *DatabaseBackupReconciler) reconcileCronJob(ctx context.Context, databasebackup *databasesamplev1alpha1.DatabaseBackup) (ctrl.Result, error) {
	log := log.FromContext(ctx)
	var cronJob *batchv1.CronJob
	var cronJobDefinition *batchv1.CronJob

	for i, _ := range databasebackup.Spec.Repos {

		cronJobDefinition = reconciler.defineCronJob(databasebackup, i)
		cronJob = &batchv1.CronJob{}

		err := reconciler.Get(ctx, types.NamespacedName{Name: variables.CronJobName, Namespace: databasebackup.Namespace}, cronJob)
		if err != nil {
			if errors.IsNotFound(err) {
				log.Info("CronJob resource " + variables.CronJobName + " not found. Creating or re-creating cronjob")
				err = reconciler.Create(ctx, cronJobDefinition)
				if err != nil {
					log.Info("Failed to create CronJob resource. Re-running reconcile.")
					return ctrl.Result{}, err
				}
			} else {
				log.Info("Failed to get CronJob resource " + variables.CronJobName + ". Re-running reconcile.")
				return ctrl.Result{}, err
			}
		} else {
			// Note: For simplication purposes StatefulSets are not updated - see deployment section
		}

	}

	return ctrl.Result{}, nil
}
