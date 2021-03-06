package heidloff.net.database;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.nio.file.Files;
import java.nio.file.Paths;
import org.eclipse.microprofile.config.ConfigProvider;
import javax.annotation.PostConstruct;
import javax.enterprise.context.ApplicationScoped;
import javax.inject.Inject;
import javax.json.bind.Jsonb;
import javax.json.bind.JsonbBuilder;

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
            if (dataDirectory.endsWith("/")) {
                pathAndFileNamePodState = dataDirectory + FILENAME_POD_STATE;    
            } else {
                pathAndFileNamePodState = dataDirectory + "/" + FILENAME_POD_STATE;
            }            
        }
        initializePodConfig();
    }

    private void initializePodConfig() {
        boolean fileExists = false;
        try {
            Files.readAllBytes(Paths.get(pathAndFileNamePodState));  
            fileExists = true;  
        } catch (Exception e) {            
        }
        if (fileExists == false) {
            try {
                String content = new String (Files.readAllBytes(Paths.get(FILENAME_POD_STATE)));
                java.nio.file.Path path = Paths.get(pathAndFileNamePodState);
                byte[] stringToBytes = content.getBytes();
                Files.write(path, stringToBytes);
            } catch (Exception e) {
            }
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

    public void electLeader() {
        // Note: This is a very simple leader election only for demo purposes
        String podName = System.getenv("POD_NAME");
        if ((podName != null) && (podName.endsWith("-0"))) {
            setLeader(true);
        }
    }
}
