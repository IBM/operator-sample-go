package main

import (
	"fmt"

	"github.com/ibm/operator-sample-go/operator-application-scaler/scaler"
)

func main() {
	fmt.Println("Main invoked")
	scaler.Run()
}
