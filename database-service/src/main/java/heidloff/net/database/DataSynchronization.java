package heidloff.net.database;

import java.net.URL;
import java.util.Set;

import javax.enterprise.context.ApplicationScoped;
import javax.ws.rs.core.Response;
import org.eclipse.microprofile.rest.client.RestClientBuilder;
import io.fabric8.kubernetes.api.model.PodList;
import io.fabric8.kubernetes.client.DefaultKubernetesClient;
import io.fabric8.kubernetes.client.KubernetesClient;

@ApplicationScoped
public class DataSynchronization {

    public DataSynchronization() {}
      
    public static Response synchronizeDataFromLeader(LeaderUtils leaderUtils, PersonResource personResource) {
        System.out.println("LeaderUtils.synchronizeDataFromLeader()");
        String leaderAddress = "http://database-cluster-0.database-service.database:8089/persons";
        int httpStatus = 200; 
        if (leaderUtils.isLeader() == true) {
            httpStatus = 501; // Not Implemented
        } else {
            Set<Person> persons = null;
            try {
                // Note: This follower should update from the previous follower (or leader)
                // For simplification purposes updates are only read from the leader
                URL apiUrl = new URL(leaderAddress);
                System.out.println("Leader found. URL: " + leaderAddress);
                RemoteDatabaseService customRestClient = RestClientBuilder.newBuilder().baseUrl(apiUrl).
                    register(ExceptionMapper.class).build(RemoteDatabaseService.class);
                persons = customRestClient.getAll();                
            } catch (Exception e) {
                System.out.println("/persons could not be invoked");
                System.out.println(e); 
                httpStatus = 503; // Service Unavailable
            }
            if (persons != null) {
                try {
                    personResource.updateAllPersons(persons);    
                } catch (RuntimeException e) {
                    System.out.println("Data could not be written");
                    System.out.println(e); 
                    httpStatus = 503; // Service Unavailable
                }                
            }
        }
        return Response.status(httpStatus).build();    
    }

    public static void notifyFollowers() {
        KubernetesClient client = new DefaultKubernetesClient();        
        String serviceName = "database-service";
        String namespace = System.getenv("NAMESPACE");     
        PodList podList = client.pods().inNamespace(namespace).list();
        podList.getItems().forEach(pod -> {
            if (pod.getMetadata().getName().endsWith("-0") == false) {
                String followerAddress =  pod.getMetadata().getName() + "." + serviceName + "." + namespace + ":8089";
                System.out.println("Follower found: " + pod.getMetadata().getName() + " - " + followerAddress);
                try {
                    URL apiUrl = new URL("http://" + followerAddress + "/api/onleaderupdated");
                    RemoteDatabaseService customRestClient = RestClientBuilder.newBuilder().
                    register(ExceptionMapper.class).baseUrl(apiUrl).build(RemoteDatabaseService.class);
                    customRestClient.onLeaderUpdated();              
                } catch (Exception e) { 
                    System.out.println("/onleaderupdated could not be invoked");
                    System.out.println(e);           
                }
            }
        });
    }
}
