package heidloff.net.database;

import org.eclipse.microprofile.rest.client.inject.RegisterRestClient;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import java.util.Set;

@Path("/api")
@RegisterRestClient
public interface RemoteDatabaseService {

    @GET
    Set<Person> getAll();    
}
