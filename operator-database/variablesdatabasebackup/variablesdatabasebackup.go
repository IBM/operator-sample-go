package variablesdatabasebackup

import (
	"fmt"

	databasesamplev1alpha1 "github.com/ibm/operator-sample-go/operator-database/api/v1alpha1"
)

var CronJobName string
var JobName string

func SetGlobalVariables(applicationName string) {
	CronJobName = applicationName + "-cronjob-databasebackup"
	JobName = applicationName + "-job-databasebackup"
}

func PrintVariables(databaseName string, databaseNamespace string, repos []databasesamplev1alpha1.BackupRepo, manualTrigger databasesamplev1alpha1.ManualTrigger, scheduledTrigger databasesamplev1alpha1.ScheduledTrigger) {
	fmt.Println("Custom Resource Values:")
	fmt.Printf("- Name: %s\n", databaseName)
	fmt.Printf("- Namespace: %s\n", databaseNamespace)

	for i, r := range repos {
		fmt.Printf("- Repo.Name[%d]: %s\n", i, r.Name)
		fmt.Printf("- Repo.Type[%d].ServiceEndpoint: %s\n", i, r.ServiceEndpoint)
		fmt.Printf("- Repo.Type[%d].BucketNamePrefix: %s\n", i, r.BucketNamePrefix)
		fmt.Printf("- Repo.Type[%d].SecretName: %s\n", i, r.SecretName)
	}
	fmt.Printf("- ManualTrigger.Repo: %s\n", manualTrigger.Repo)
	fmt.Printf("- ManualTrigger.Time: %s\n", manualTrigger.Time)
	fmt.Printf("- ManualTrigger.Enabled: %t\n", manualTrigger.Enabled)

	fmt.Printf("- ScheduledTrigger.Repo: %s\n", scheduledTrigger.Repo)
	fmt.Printf("- ScheduledTrigger.Schedule: %s\n", scheduledTrigger.Schedule)
	fmt.Printf("- ScheduledTrigger.Enabled: %t\n", scheduledTrigger.Enabled)

}
