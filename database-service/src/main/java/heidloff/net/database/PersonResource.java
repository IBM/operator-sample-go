package heidloff.net.database;

import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.Set;
import javax.annotation.PostConstruct;
import javax.json.bind.Jsonb;
import javax.json.bind.JsonbBuilder;
import javax.ws.rs.DELETE;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.PUT;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import org.eclipse.microprofile.config.ConfigProvider;

@Path("/persons")
public class PersonResource {

    private Set<Person> persons = Collections.newSetFromMap(Collections.synchronizedMap(new LinkedHashMap<>()));

    public PersonResource() {
    }

    final String DEFAULT_DATA_FILENAME = "data.json";
    String dataFileName;

    @PostConstruct
    void readData() {
        try {
            dataFileName = ConfigProvider.getConfig().getValue("data.filename", String.class);
        } catch (Exception e) {
        }
        if ((dataFileName == null) || (dataFileName.isEmpty())) {
            dataFileName = DEFAULT_DATA_FILENAME;
        }
        try {  
            String content = new String (Files.readAllBytes(Paths.get(dataFileName)));
            Jsonb jsonb = JsonbBuilder.create();
            ArrayList<Person> personsArrayList;
            personsArrayList = jsonb.fromJson(content, new ArrayList<Person>(){}.getClass().getGenericSuperclass());
            personsArrayList.forEach((person) -> {
                persons.add(person);
            });
        } catch (Exception e) {
            System.out.println(e);
            System.out.println("PersonResource.readDate() - file '" + dataFileName + "' couldn't be accessed");
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
    public Set<Person> add(Person person) {
        if (person.id == null) {
            persons.add(new Person(person.firstName, person.lastName));
        } else {
            boolean personExists = false;
            for (Iterator<Person> iterator = persons.iterator(); iterator.hasNext(); ) {
                Person existingPerson = iterator.next();
                if (existingPerson.id.equals(person.id))
                    personExists = true;
            }
            if (personExists == false) {
                persons.add(new Person(person.firstName, person.lastName));
            }
        }
        return persons;
    }

    @PUT
    public Set<Person> update(Person person) {
        if (person.id != null) {
            for (Iterator<Person> iterator = persons.iterator(); iterator.hasNext(); ) {
                Person existingPerson = iterator.next();
                if (existingPerson.id.equals(person.id))
                    existingPerson.firstName = person.firstName;
                    existingPerson.lastName = person.lastName;
            }
        }
        return persons;
    }

    @DELETE
    public Set<Person> delete(Person person) {
        persons.removeIf(existingPerson -> existingPerson.id.contentEquals(person.id));
        return persons;
    }
}