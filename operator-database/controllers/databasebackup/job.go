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

func (reconciler *DatabaseBackupReconciler) defineJob(databasebackup *databasesamplev1alpha1.DatabaseBackup, repoIndex int) *batchv1.Job {
	labels := map[string]string{variables.LabelKey: variables.LabelValue}

	job := &batchv1.Job{
		TypeMeta: metav1.TypeMeta{},
		ObjectMeta: metav1.ObjectMeta{
			Name:      variables.JobName,
			Namespace: databasebackup.Namespace,
			Labels:    labels,
		}, Spec: batchv1.JobSpec{
			Template: v1.PodTemplateSpec{
				ObjectMeta: metav1.ObjectMeta{
					Name:      variables.CronJobName,
					Namespace: databasebackup.Namespace,
				},
				Spec: v1.PodSpec{
					RestartPolicy: v1.RestartPolicyNever,
					Containers: []v1.Container{{
						Image: variables.Image,
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
	}

	ctrl.SetControllerReference(databasebackup, job, reconciler.Scheme)
	return job

}

func (reconciler *DatabaseBackupReconciler) reconcileJob(ctx context.Context, databasebackup *databasesamplev1alpha1.DatabaseBackup) (ctrl.Result, error) {
	log := log.FromContext(ctx)
	var job *batchv1.Job
	var jobDefinition *batchv1.Job

	for i, _ := range databasebackup.Spec.Repos {

		jobDefinition = reconciler.defineJob(databasebackup, i)
		job = &batchv1.Job{}
		err := reconciler.Get(ctx, types.NamespacedName{Name: variables.JobName, Namespace: databasebackup.Namespace}, job)
		if err != nil {
			if errors.IsNotFound(err) {
				log.Info("Job resource " + variables.JobName + " not found. Creating or re-creating job")
				err = reconciler.Create(ctx, jobDefinition)
				if err != nil {
					log.Info("Failed to create Job resource. Re-running reconcile.")
					return ctrl.Result{}, err
				}
			} else {
				log.Info("Failed to get Job resource " + variables.JobName + ". Re-running reconcile.")
				return ctrl.Result{}, err
			}
		} else {
			// Note: For simplication purposes StatefulSets are not updated - see deployment section
		}

	}

	return ctrl.Result{}, nil
}
