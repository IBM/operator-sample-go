/*
Copyright 2022.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package v1alpha1

import (
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

// EDIT THIS FILE!  THIS IS SCAFFOLDING FOR YOU TO OWN!
// NOTE: json tags are required.  Any new fields you add must have json tags for the fields to be serialized.

// DatabaseBackupSpec defines the desired state of DatabaseBackup
type DatabaseBackupSpec struct {
	// INSERT ADDITIONAL SPEC FIELDS - desired state of cluster
	// Important: Run "make" to regenerate code after modifying this file

	Repos            []BackupRepo     `json:"repos"`
	ManualTrigger    ManualTrigger    `json:"manualTrigger"`
	ScheduledTrigger ScheduledTrigger `json:"scheduledTrigger"`
}

// DatabaseBackupStatus defines the observed state of DatabaseBackup
type DatabaseBackupStatus struct {
	// INSERT ADDITIONAL STATUS FIELD - define observed state of cluster
	// Important: Run "make" to regenerate code after modifying this file

	Conditions []DatabaseBackupCondition `json:"conditions,omitempty"`
	Jobs       []string                  `json:"jobs,omitempty"`
}

type DatabaseBackupCondition struct {
	LastTransitionTime string `json:"lastTransitionTime,omitempty"`
	Message            string `json:"message,omitempty"`
	Reason             string `json:"reason,omitempty"`
	Status             string `json:"status,omitempty"`
	Type               string `json:"type,omitempty"`
}

//+kubebuilder:object:root=true
//+kubebuilder:subresource:status

// DatabaseBackup is the Schema for the databasebackups API
type DatabaseBackup struct {
	metav1.TypeMeta   `json:",inline"`
	metav1.ObjectMeta `json:"metadata,omitempty"`

	Spec   DatabaseBackupSpec   `json:"spec,omitempty"`
	Status DatabaseBackupStatus `json:"status,omitempty"`
}

//+kubebuilder:object:root=true

// DatabaseBackupList contains a list of DatabaseBackup
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
	Name string `json:"name,omitempty"`
	//Type BackupRepoType `json:"type,omitempty"`
	Type             string `json:"type,omitempty"`
	SecretName       string `json:"secretName,omitempty"`
	ServiceEndpoint  string `json:"serviceEndpoint,omitempty"`
	AuthEndpoint     string `json:"authEndpoint,omitempty"`
	BucketNamePrefix string `json:"bucketNamePrefix,omitempty"`
}

func init() {
	SchemeBuilder.Register(&DatabaseBackup{}, &DatabaseBackupList{})
}
