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
import javax.ws.rs.core.Response;

@ApplicationScoped
public class LeaderUtils {

    final String IS_LEADER_TRUE = "true";
    final String IS_LEADER_FALSE = "false";

    final String FILENAME_LEADER = "leader.txt";
    String dataDirectory = "";
    String pathAndFileNameLeader;

    @Inject
    PersonResource personResource;

    @PostConstruct
    void initialize() {
        try {
            dataDirectory = ConfigProvider.getConfig().getValue("data.directory", String.class);
        } catch (Exception e) {
        }
        if ((dataDirectory == null) || (dataDirectory.isEmpty())) {
            pathAndFileNameLeader = FILENAME_LEADER;
        } else {
            pathAndFileNameLeader = dataDirectory + FILENAME_LEADER;
        }
    }

    public boolean isLeader() {
        boolean output = false;
        try {
            String content = new String (Files.readAllBytes(Paths.get(pathAndFileNameLeader)));
            if (content != null) {
                content = content.trim();
                if (content.equalsIgnoreCase(IS_LEADER_TRUE)) output = true;
            }
        } catch (Exception e) {
        }
        return output;
    }

    public void setLeader(boolean shouldBeLeader) {
        String toBeWritten = IS_LEADER_FALSE;
        if (shouldBeLeader == true) {
            toBeWritten = IS_LEADER_TRUE;
        }
        try {
            BufferedWriter writer = new BufferedWriter(new FileWriter(pathAndFileNameLeader));
            writer.write(toBeWritten);
            writer.close();
        } catch (Exception e) {
            System.out.println(e);
            System.out.println("API.setLeader() - file '" + pathAndFileNameLeader + "' couldn't be accessed");
        }        
    }

    public Response replicateWithLeader(String dnsLeader) {
        int httpStatus = 200; 
        if (isLeader() == true) {
            httpStatus = 501; // Not Implemented
        } else {
            Set<Person> persons = null;
            try {
                URL apiUrl = new URL("http://" + dnsLeader + "/persons");
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
