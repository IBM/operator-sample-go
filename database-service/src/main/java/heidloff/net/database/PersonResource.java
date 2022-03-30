package heidloff.net.database;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.Set;
import javax.annotation.PostConstruct;
import javax.inject.Inject;
import javax.json.bind.Jsonb;
import javax.json.bind.JsonbBuilder;
import javax.ws.rs.DELETE;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.PUT;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.core.Response;
import org.eclipse.microprofile.config.ConfigProvider;

@Path("/persons")
public class PersonResource {

    private Set<Person> persons = Collections.newSetFromMap(Collections.synchronizedMap(new LinkedHashMap<>()));

    @Inject
    LeaderUtils leaderUtils;

    public PersonResource() {
    }

    final String FILENAME_DATA = "data.json";
    String dataDirectory = "";
    String pathAndFileName;

    @PostConstruct
    void initialize() {
        try {
            dataDirectory = ConfigProvider.getConfig().getValue("data.directory", String.class);
        } catch (Exception e) {
        }
        if ((dataDirectory == null) || (dataDirectory.isEmpty())) {
            pathAndFileName = FILENAME_DATA;
        } else {
            pathAndFileName = dataDirectory + FILENAME_DATA;
        }
        readData();
    }

    void readData() {
        try {  
            String content = new String (Files.readAllBytes(Paths.get(pathAndFileName)));
            Jsonb jsonb = JsonbBuilder.create();
            ArrayList<Person> personsArrayList;
            personsArrayList = jsonb.fromJson(content, new ArrayList<Person>(){}.getClass().getGenericSuperclass());
            personsArrayList.forEach((person) -> {
                persons.add(person);
            });
        } catch (Exception e) {
            System.out.println(e);
            System.out.println("PersonResource.readData() - file '" + pathAndFileName + "' couldn't be accessed");
        }
    }

    private void writeData() throws RuntimeException {
        try {
            Jsonb jsonb = JsonbBuilder.create();
            String personsString = jsonb.toJson(persons);
            BufferedWriter writer = new BufferedWriter(new FileWriter(pathAndFileName));
            writer.write(personsString);
            writer.close();
        } catch (Exception e) {
            System.out.println(e);
            String exceptionMessage = "PersonResource.writeData() - file '" + pathAndFileName + "' couldn't be accessed";
            System.out.println(exceptionMessage);
            throw new RuntimeException(exceptionMessage);
        }
    }

    private Response writeDataIfLeader(Object outputObject) {
        int httpStatus = 200; 
        if (leaderUtils.isLeader() == false) {
            httpStatus = 501; // Not Implemented
        } else {
            try {
                writeData();
            } catch (RuntimeException e) {
                httpStatus = 503; // Service Unavailable
            }    
        }
        if (outputObject != null) {
            return Response.status(httpStatus).entity(outputObject).build();    
        } else {
            return Response.status(httpStatus).build();    
        }
    }

    @GET
    public Set<Person> list() {
        return persons;
    }

    @GET
    @Path("{id}")
    public Person get(@PathParam(value="id") String id) {
        for (Iterator<Person> iterator = persons.iterator(); iterator.hasNext(); ) {
            Person person = iterator.next();
            if (person.id.equals(id))
                return person;
        }
        return null;
    }

    @POST
    public Response add(Person person) {
        Person newPerson = null;
        if (leaderUtils.isLeader()) {
            if (person.id == null) {
                newPerson = new Person(person.firstName, person.lastName);
                persons.add(newPerson);
            } else {
                boolean personExists = false;
                for (Iterator<Person> iterator = persons.iterator(); iterator.hasNext(); ) {
                    Person existingPerson = iterator.next();
                    if (existingPerson.id.equals(person.id))
                        personExists = true;
                }
                if (personExists == false) {
                    newPerson = new Person(person.firstName, person.lastName);
                    persons.add(newPerson);
                }
            }
        }
        return writeDataIfLeader(newPerson);
    }

    @PUT
    public Response update(Person person) {
        Person updatedPerson = null;
        if (leaderUtils.isLeader()) {
            if (person.id != null) {
                for (Iterator<Person> iterator = persons.iterator(); iterator.hasNext(); ) {
                    Person existingPerson = iterator.next();
                    if (existingPerson.id.equals(person.id))
                        existingPerson.firstName = person.firstName;
                        existingPerson.lastName = person.lastName;
                        updatedPerson = existingPerson;
                }
            }
        }
        return writeDataIfLeader(updatedPerson);
    }

    @DELETE
    public Response delete(Person person) {
        if (leaderUtils.isLeader()) {
            persons.removeIf(existingPerson -> existingPerson.id.contentEquals(person.id));
        }
        return writeDataIfLeader(null);
    }
}