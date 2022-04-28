package net.heidloff;

import java.net.URL;
import java.util.Set;

import javax.enterprise.context.ApplicationScoped;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import javax.ws.rs.ext.ExceptionMapper;

import org.eclipse.microprofile.config.inject.ConfigProperty;
import org.eclipse.microprofile.metrics.annotation.Counted;
import org.eclipse.microprofile.rest.client.RestClientBuilder;

@Path("/hello")
@ApplicationScoped
public class GreetingResource {

    public GreetingResource() {}
      
    @ConfigProperty(name = "greeting.message")
    String message;

    @GET
    @Produces(MediaType.TEXT_PLAIN)
    @Counted(name = "countHelloEndpointInvoked", description = "How often /hello has been invoked")
    public String hello() {
        String name = this.readFromDatabase();
        return "Hello " + message + ". Name from database: " + name;
    }

    public String readFromDatabase() {
        System.out.println("GreetingResource.readFromDatabase()");
        String output = "Could not access database";
        String databaseAddress = "http://database-cluster-0.database-service.database:8089/persons";
        Set<Person> persons = null;
        try {
            URL apiUrl = new URL(databaseAddress);
            RemoteDatabaseService customRestClient = RestClientBuilder.newBuilder().baseUrl(apiUrl)
                .register(ExceptionMapper.class).build(RemoteDatabaseService.class);
            persons = customRestClient.getAll();
            if (persons != null) {
                if (persons.size() > 0) {
                    output = persons.iterator().next().firstName;
                }
            }
        } catch (Exception e) {
            System.out.println("/persons could not be invoked");
            System.out.println(e);            
        }
        return output;
    }
}