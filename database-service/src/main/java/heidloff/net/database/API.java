package heidloff.net.database;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Set;

import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;
import javax.ws.rs.core.Response;

import org.eclipse.microprofile.config.ConfigProvider;
import javax.annotation.PostConstruct;
import javax.enterprise.context.ApplicationScoped;
import javax.inject.Inject;
import javax.ws.rs.Consumes;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;

@ApplicationScoped
@Path("/api")
public class API {

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

    @Consumes("text/plain")
    @Produces("text/plain")
    @GET
    @Path("/leader")
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
    
    @POST
    @Path("/leader")
    public Response setLeader(@QueryParam(value="setAsLeader") String setAsLeader) {
        String toBeWritten = IS_LEADER_FALSE;
        if (setAsLeader != null) {
            if (setAsLeader.trim().equalsIgnoreCase(IS_LEADER_TRUE)) {
                toBeWritten = IS_LEADER_TRUE;
            }
        }
        try {
            BufferedWriter writer = new BufferedWriter(new FileWriter(pathAndFileNameLeader));
            writer.write(toBeWritten);
            writer.close();
        } catch (Exception e) {
            System.out.println(e);
            System.out.println("API.setLeader() - file '" + pathAndFileNameLeader + "' couldn't be accessed");
        }
        return Response.status(200).build();
    }

    @GET
    @Path("/query")
    public Response executeQuery(@QueryParam(value="query") String query) {
        // Note: This is only faked
        // Note: Invoked via JDBC Connection.createStatement().executeQuery() to run SQL queries
        return Response.status(200).entity(personResource.list()).build();
    }

    @POST
    @Path("/statement")
    public Response executeStatement(@QueryParam(value="statement") String statement) {
        // Note: This is only faked
        // Note: Invoked via JDBC Connection.createStatement().execute(), for example to create schemas
        return Response.status(200).build();
    }

    @GET
    @Path("/metadata")
    public Response getMetadata(@QueryParam(value="metadata") String metadata) {
        // Note: This is only faked
        // Note: Invoked via JDBC Connection.getMetaData(), for example to check whether schema exists
        return Response.status(200).build();
    }
}
