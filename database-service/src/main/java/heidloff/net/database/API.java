package heidloff.net.database;

import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;
import javax.ws.rs.core.Response;
import org.eclipse.microprofile.rest.client.inject.RestClient;
import javax.enterprise.context.ApplicationScoped;
import javax.inject.Inject;
import javax.ws.rs.Consumes;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;

@ApplicationScoped
@Path("/api")
public class API {

    @Inject
    PersonResource personResource;

    @Inject
    LeaderUtils leaderUtils;

    @Inject
    @RestClient
    RemoteDatabaseService remoteDatabaseService;

    @Consumes("text/plain")
    @Produces("text/plain")
    @GET
    @Path("/leader")
    public boolean isLeader() {
        return leaderUtils.isLeader();
    }
    
    // Note: This is for development/debugging only, leader election is done automatically
    @POST
    @Path("/leader")
    public Response setLeader(@QueryParam(value="setAsLeader") String setAsLeader) {
        boolean shouldBeLeader = false;
        if (setAsLeader != null) {
            if (setAsLeader.trim().equalsIgnoreCase("true")) {
                shouldBeLeader = true;
            }
        }
        leaderUtils.setLeader(shouldBeLeader);
        return Response.status(200).build();
    }

    @POST
    @Path("/onLeaderUpdated")
    public Response onLeaderUpdated() {
        return leaderUtils.onLeaderUpdated();
    }

    @GET
    @Path("/executequery")
    public Response executeQuery(@QueryParam(value="query") String query) {
        // Note: This is faked to simulate a JDBC server
        // Invoked via JDBC Connection.createStatement().executeQuery() to run SQL queries
        // See https://www.baeldung.com/java-jdbc#1-resultset-interface
        return Response.status(200).entity(personResource.list()).build();
    }

    @POST
    @Path("/executestatement")
    public Response executeStatement(@QueryParam(value="statement") String statement) {
        // Note: This is faked to simulate a JDBC server
        // Invoked via JDBC Connection.createStatement().execute(), for example to create schemas
        // See https://www.baeldung.com/java-jdbc#1-statement
        return Response.status(200).build();
    }

    @GET
    @Path("/getmetadata")
    public Response getMetadata(@QueryParam(value="metadata") String metadata) {
        // Note: This is faked to simulate a JDBC server
        // Invoked via JDBC Connection.getMetaData(), for example to check whether schema exists
        // See https://www.baeldung.com/java-jdbc#1-databasemetadata
        return Response.status(200).build();
    }
}
