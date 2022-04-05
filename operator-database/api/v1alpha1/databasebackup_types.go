package v1alpha1

import (
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

type DatabaseBackupSpec struct {
	Repos            []BackupRepo     `json:"repos"`
	ManualTrigger    ManualTrigger    `json:"manualTrigger"`
	ScheduledTrigger ScheduledTrigger `json:"scheduledTrigger"`
}

type DatabaseBackupStatus struct {
	Conditions []metav1.Condition `json:"conditions"`
	Jobs       []string           `json:"jobs,omitempty"`
}

//+kubebuilder:object:root=true
//+kubebuilder:subresource:status

type DatabaseBackup struct {
	metav1.TypeMeta   `json:",inline"`
	metav1.ObjectMeta `json:"metadata,omitempty"`

	Spec   DatabaseBackupSpec   `json:"spec,omitempty"`
	Status DatabaseBackupStatus `json:"status,omitempty"`
}

//+kubebuilder:object:root=true

type DatabaseBackupList struct {
	metav1.TypeMeta `json:",inline"`
	metav1.ListMeta `json:"metadata,omitempty"`
	Items           []DatabaseBackup `json:"items"`
}

type ManualTrigger struct {
	Enabled bool   `json:"enabled,omitempty"`
	Time    string `json:"time,omitempty"`
	Repo    string `json:"repo,omitempty"`
}

type ScheduledTrigger struct {
	Enabled  bool   `json:"enabled,omitempty"`
	Schedule string `json:"schedule,omitempty"`
	Repo     string `json:"repo,omitempty"`
}

type BackupRepo struct {
	Name             string `json:"name,omitempty"`
	Type             string `json:"type,omitempty"`
	SecretName       string `json:"secretName,omitempty"`
	ServiceEndpoint  string `json:"serviceEndpoint,omitempty"`
	AuthEndpoint     string `json:"authEndpoint,omitempty"`
	BucketNamePrefix string `json:"bucketNamePrefix,omitempty"`
}

func init() {
	SchemeBuilder.Register(&DatabaseBackup{}, &DatabaseBackupList{})
}
