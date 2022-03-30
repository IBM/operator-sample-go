package heidloff.net.database;

import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;
import javax.ws.rs.core.Response;
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

    @Consumes("text/plain")
    @Produces("text/plain")
    @GET
    @Path("/leader")
    public boolean isLeader() {
        return leaderUtils.isLeader();
    }
    
    @POST
    @Path("/leader")
    public Response setLeader(@QueryParam(value="setAsLeader") String setAsLeader) {
        boolean shouldBeLeader = false;
        if (setAsLeader != null) {
            if (setAsLeader.trim().equalsIgnoreCase(leaderUtils.IS_LEADER_TRUE)) {
                shouldBeLeader = true;
            }
        }
        leaderUtils.setLeader(shouldBeLeader);
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
