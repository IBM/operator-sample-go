# Test automation

### Kubernetes

| Operator | Verification | Needed configuration | Test sequence | Verification Point |
| --- | --- | --- | --- | --- |
| Database | Database was created | Database operator installed, CR for test defined | Verify prerequisite, Create yaml for test instance CR resource, Apply yaml for test instance CR resoure,Verify the instances, Delete the test instance | If a database was instantiated and two pods of the stateful set are running. | 
| Database | Backup on IBM Cloud Object Storage | Operator installed, Object Storage Configured, Backup Application was instantiated by the Database operator |  | TBD | 
| Application | Application was create | Database Custer Service Version is available, Application was create in version beta | |  TBD | 
| Application | Application scaling| Database Custer Service Version is available, Application was create in version beta, Application scaler was instantiated by application operator | TBD | 

### OpenShift

| Operator | Verification | Needed configuration | |
| --- | --- | --- | --- | 
| Database | Database was created | Operator installed | TBD | 
| Database | Backup on IBM Cloud Object Storage | Operator installed, Object Storage Configured, Backup Application was instantiated by the Database operator | TBD | 
| Application | Application was create | Database Custer Service Version is available, Application was create in version beta | TBD | 
| Application | Application scaling| Database Custer Service Version is available, Application was create in version beta, Application scaler was instantiated by application operator | TBD | 

