package net.heidloff;

import java.util.UUID;

public class Person {
    public String firstName;
    public String lastName;
    public String id;

    public Person() {}

    public Person(String firstName, String lastName) {
        this.firstName = firstName;
        this.lastName = lastName;
        this.id = UUID.randomUUID().toString();
    }
}
