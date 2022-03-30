package heidloff.net.database;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.nio.file.Files;
import java.nio.file.Paths;
import org.eclipse.microprofile.config.ConfigProvider;
import javax.annotation.PostConstruct;
import javax.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class LeaderUtils {

    final String IS_LEADER_TRUE = "true";
    final String IS_LEADER_FALSE = "false";

    final String FILENAME_LEADER = "leader.txt";
    String dataDirectory = "";
    String pathAndFileNameLeader;

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
}
