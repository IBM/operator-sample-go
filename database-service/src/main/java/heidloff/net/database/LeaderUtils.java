package heidloff.net.database;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.net.URL;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Set;
import org.eclipse.microprofile.config.ConfigProvider;
import org.eclipse.microprofile.rest.client.RestClientBuilder;
import javax.annotation.PostConstruct;
import javax.enterprise.context.ApplicationScoped;
import javax.inject.Inject;
import javax.json.bind.Jsonb;
import javax.json.bind.JsonbBuilder;
import javax.ws.rs.core.Response;

@ApplicationScoped
public class LeaderUtils {

    final String FILENAME_POD_STATE = "podstate.json";
    String dataDirectory = "";
    String pathAndFileNamePodState;

    @Inject
    PersonResource personResource;

    @PostConstruct
    void initialize() {
        try {
            dataDirectory = ConfigProvider.getConfig().getValue("data.directory", String.class);
        } catch (Exception e) {
        }
        if ((dataDirectory == null) || (dataDirectory.isEmpty())) {
            pathAndFileNamePodState = FILENAME_POD_STATE;
        } else {
            pathAndFileNamePodState = dataDirectory + FILENAME_POD_STATE;
        }
    }

    public boolean isLeader() {
        boolean output = false;
        try {
            String content = new String (Files.readAllBytes(Paths.get(pathAndFileNamePodState)));
            Jsonb jsonb = JsonbBuilder.create();            
            PodState podState = jsonb.fromJson(content, PodState.class);            
            if (podState != null) {                
                if (podState.isLeader == true) output = true;
            }
        } catch (Exception e) {
        }
        return output;
    }

    public void setLeader(boolean shouldBeLeader) {
        PodState podState = new PodState(shouldBeLeader);
        try {
            Jsonb jsonb = JsonbBuilder.create();
            String podStateString = jsonb.toJson(podState);
            BufferedWriter writer = new BufferedWriter(new FileWriter(pathAndFileNamePodState));
            writer.write(podStateString);
            writer.close();
        } catch (Exception e) {
            System.out.println(e);
            System.out.println("API.setLeader() - file '" + pathAndFileNamePodState + "' couldn't be accessed");
        }        
    }

    private String getLeaderAddress() {
        return "TODO";
    }

    public Response onLeaderUpdated() {
        int httpStatus = 200; 
        if (isLeader() == true) {
            httpStatus = 501; // Not Implemented
        } else {
            Set<Person> persons = null;
            try {
                // Note: This follower should update from the previous follower (or leader)
                // For simplification purposes updates are only read from the leader
                URL apiUrl = new URL("http://" + getLeaderAddress() + "/persons");
                RemoteDatabaseService customRestClient = RestClientBuilder.newBuilder().baseUrl(apiUrl).build(RemoteDatabaseService.class);
                persons = customRestClient.getAll();                
            } catch (Exception e) {
                httpStatus = 503; // Service Unavailable
            }
            if (persons != null) {
                try {
                    personResource.updateAllPersons(persons);    
                } catch (RuntimeException e) {
                    httpStatus = 503; // Service Unavailable
                }                
            }
        }
        return Response.status(httpStatus).build();    
    }
}
