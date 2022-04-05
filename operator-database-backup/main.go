package main

import (
	"fmt"

	"github.com/ibm/operator-sample-go/operator-database-backup/backup"
)

func main() {
	fmt.Println("Main invoked")
	backup.Run()
}
