package scaler

import (
	"context"
	"fmt"
	"os"
	"path/filepath"
	"time"

	"crypto/tls"
	"crypto/x509"

	"io/ioutil"
	"net/http"
	"strings"

	applicationoperatorv1beta1 "github.com/ibm/operator-sample-go/operator-application/api/v1beta1"
	"github.com/prometheus/client_golang/api"
	v1 "github.com/prometheus/client_golang/api/prometheus/v1"
	"github.com/prometheus/common/model"
	"k8s.io/client-go/discovery"
	"k8s.io/client-go/rest"
	"k8s.io/client-go/tools/clientcmd"
	"k8s.io/utils/env"
	"sigs.k8s.io/controller-runtime/pkg/client"
	//"sigs.k8s.io/controller-runtime/pkg/client"
)

var (
	// mandatory enviornment variables
	applicationName      = env.GetString("APPLICATION_RESOURCE_NAME", "")
	applicationNamespace = env.GetString("APPLICATION_RESOURCE_NAMESPACE", "")

	// internal variables
	applicationContext  context.Context
	kubernetesClient    client.Client
	applicationResource *applicationoperatorv1beta1.Application
	prometheusClient    api.Client
)

func Run() {
	applicationContext = context.Background()

	var prometheusAddress string
	openShift, err := checkOpenShift()
	if err != nil {
		fmt.Printf("Error querying OpenShift vs Kubernetes: %v\n", err)
		os.Exit(1)
	}
	if openShift {
		prometheusAddress = "https://prometheus-k8s.openshift-monitoring:9091"
	} else {
		prometheusAddress = "http://prometheus-operated.monitoring:9090"
	}
	fmt.Printf("prometheusAddress=%s\n", prometheusAddress)
	queryAmountHelloEndpointInvocations := "application_net_heidloff_GreetingResource_countHelloEndpointInvoked_total"

	// Run locally: docker run -p 9090:9090 prom/prometheus
	//prometheusAddress = "http://localhost:9090"
	//queryAmountHelloEndpointInvocations = "go_info"

	if openShift {
		var caFile = "/etc/prometheus-k8s-cert/tls.crt"
		var bearerToken = "/etc/prometheus-k8s-token/token.txt"
		roundTripper, _ := createRoundTripper(caFile, true)
		bearerTokenRoundTripper := addBearerAuthToRoundTripper(bearerToken, roundTripper)
		prometheusClient, err = api.NewClient(api.Config{
			Address:      prometheusAddress,
			RoundTripper: bearerTokenRoundTripper,
		})
		if err != nil {
			fmt.Printf("Error creating Prometheus client for OpenShift: %v\n", err)
			os.Exit(1)
		}

	} else {
		prometheusClient, err = api.NewClient(api.Config{
			Address: prometheusAddress,
		})
		if err != nil {
			fmt.Printf("Error creating Prometheus client for IKS: %v\n", err)
			os.Exit(1)
		}
	}

	v1api := v1.NewAPI(prometheusClient)
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
				// Note: '5' is only used for demo purposes
				scaleUp()
				fmt.Println("Application " + applicationNamespace + "." + applicationName + " needs to be scaled up")
			} else {
				fmt.Println("Application " + applicationNamespace + "." + applicationName + " does not need to be scaled up")
			}
		}
	}

}

func scaleUp() {
	err := getApplicationResource()
	if err != nil {
		fmt.Println("Application " + applicationNamespace + "." + applicationName + " could not be found")
		fmt.Printf("err= %v\n", err)
	} else {
		applicationResource.Spec.AmountPods = 3
		err = kubernetesClient.Update(applicationContext, applicationResource)
		if err != nil {
			fmt.Println("Failed to update application resource")
			fmt.Printf("err= %v\n", err)
		} else {
			fmt.Println("Success. Application has been scaled up to three pods.")
		}
	}
}

func checkOpenShift() (bool, error) {
	var runsOnOpenShift bool

	config, err := rest.InClusterConfig()
	if err != nil {
		kubeconfig := filepath.Join(
			os.Getenv("HOME"), ".kube", "config",
		)
		fmt.Println("Using kubeconfig file: ", kubeconfig)
		config, err = clientcmd.BuildConfigFromFlags("", kubeconfig)
		if err != nil {
			return runsOnOpenShift, err
		}
	}

	discoveryClient, err := discovery.NewDiscoveryClientForConfig(config)
	if err == nil {
		_, err := discoveryClient.ServerVersion()
		if err == nil {
			apiGroup, _, err := discoveryClient.ServerGroupsAndResources()
			if err == nil {
				for i := 0; i < len(apiGroup); i++ {
					if apiGroup[i].Name == "route.openshift.io" {
						runsOnOpenShift = true
					}
				}
			}
		}
	}
	return runsOnOpenShift, nil
}

// creates a TLSConfig using provided CA cert
func createNewTLSConfig(CAFile string, InsecureSkipVerify bool) (*tls.Config, error) {
	fmt.Println("Creating new TLS Config")
	tlsConfig := &tls.Config{InsecureSkipVerify: InsecureSkipVerify}

	if len(CAFile) > 0 {
		certPool := x509.NewCertPool()
		caCert, err := ioutil.ReadFile(CAFile)
		if err != nil {
			return nil, fmt.Errorf("error using CA cert %s: %s", CAFile, err)
		}
		certPool.AppendCertsFromPEM(caCert)
		tlsConfig.RootCAs = certPool
	}
	return tlsConfig, nil
}

// create HTTP roudtripper, inserting tlsConfig
func createRoundTripper(CaFile string, InsecureSkipVerify bool) (http.RoundTripper, error) {
	fmt.Println("Creating new Round Tripper")
	tlsConfig, err := createNewTLSConfig(CaFile, InsecureSkipVerify)
	if err != nil {
		return nil, err
	}
	return createDefaultRoundTripper(tlsConfig), nil
}

func createDefaultRoundTripper(tlsConfig *tls.Config) http.RoundTripper {
	var rt http.RoundTripper = &http.Transport{
		TLSClientConfig: tlsConfig,
	}
	return rt
}

// add bearer token function to RoundTripper
func addBearerAuthToRoundTripper(bearerFile string, rt http.RoundTripper) http.RoundTripper {
	return &bearerAuthFileRoundTripper{bearerFile, rt}
}

type bearerAuthFileRoundTripper struct {
	bearerFile string
	rt         http.RoundTripper
}

// Implements RoundTrip
func (rt *bearerAuthFileRoundTripper) RoundTrip(req *http.Request) (*http.Response, error) {
	fmt.Println("Executing Roundtrip")
	if len(req.Header.Get("Authorization")) == 0 {
		bearerTokenBytes, err := ioutil.ReadFile(rt.bearerFile)
		if err != nil {
			return nil, fmt.Errorf("unable to read bearer token file %s: %s", rt.bearerFile, err)
		}
		bearerToken := strings.TrimSpace(string(bearerTokenBytes))
		req = cloneHttpRequest(req)
		req.Header.Set("Authorization", "Bearer "+bearerToken)
	}

	return rt.rt.RoundTrip(req)
}

// clone provided http.Request.  Shallow copy for the struct, deep copy for the header
func cloneHttpRequest(req *http.Request) *http.Request {

	req2 := new(http.Request)
	*req2 = *req

	req2.Header = make(http.Header)
	for i, val := range req.Header {
		req2.Header[i] = val
	}
	return req2
}
