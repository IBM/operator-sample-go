package scaler

import (
	"context"
	"fmt"
	"os"
	"time"

	"github.com/prometheus/client_golang/api"
	v1 "github.com/prometheus/client_golang/api/prometheus/v1"
	"github.com/prometheus/common/model"
)

func Run() {
	prometheusAddress := "http://prometheus-operated.monitoring:9090"
	queryAmountHelloEndpointInvocations := "application_net_heidloff_GreetingResource_countHelloEndpointInvoked_total"

	// Run locally: docker run -p 9090:9090 prom/prometheus
	//prometheusAddress := "http://localhost:9090"
	//queryAmountHelloEndpointInvocations := "go_info"

	client, err := api.NewClient(api.Config{
		Address: prometheusAddress,
	})
	if err != nil {
		fmt.Printf("Error creating Prometheus client: %v\n", err)
		os.Exit(1)
	}

	v1api := v1.NewAPI(client)
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	result, warnings, err := v1api.Query(ctx, queryAmountHelloEndpointInvocations, time.Now())
	if err != nil {
		fmt.Printf("Error querying Prometheus: %v\n", err)
		os.Exit(1)
	}
	if len(warnings) > 0 {
		fmt.Printf("Query Result Warnings: %v\n", warnings)
	}
	fmt.Printf("Query Result:\n%v\n", result)

	resultVector, conversionSuccessful := (result).(model.Vector)
	if conversionSuccessful == true {
		if resultVector.Len() > 0 {
			firstElement := resultVector[0]
			if firstElement.Value > 5 {
				// TODO: Needs to be scaled up
				fmt.Println("Needs to be scaled up")
			} else {
				fmt.Println("Does not need to be scaled up")
			}
		}
	}
}
