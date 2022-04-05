package backup

func getBackupResource() error {
	/*
		_, err := client.New(config.GetConfigOrDie(), client.Options{})
		if err != nil {
			fmt.Println("failed to create client")
			os.Exit(1)
		}
	*/

	//c, err = controller.NewUnmanaged(meta.GetName(), mgr, controller.Options{Reconciler: r})
	/*
		databaseBackupResource := &databaseoperatorv1alpha1.DatabaseBackup{}
		fmt.Println("n1")
		if kubernetesClient == nil {
			fmt.Println("n2")
		}
		err = kubernetesClient.Get(applicationContext, types.NamespacedName{Name: backupResourceName, Namespace: namespace}, databaseBackupResource)
		return err
	*/
	return nil
}
