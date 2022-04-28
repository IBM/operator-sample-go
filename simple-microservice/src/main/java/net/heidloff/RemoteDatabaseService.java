package net.heidloff;

import org.eclipse.microprofile.rest.client.inject.RegisterRestClient;
import javax.enterprise.context.ApplicationScoped;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import java.util.Set;

@ApplicationScoped
@Path("/")
@RegisterRestClient
public interface RemoteDatabaseService {

    @GET
    Set<Person> getAll();    
}
