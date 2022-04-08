FROM docker.io/adoptopenjdk/maven-openjdk11 as BUILD
COPY src /usr/src/app/src
COPY pom.xml /usr/src/app
WORKDIR /usr/src/app
RUN mvn clean package

FROM registry.access.redhat.com/ubi8/openjdk-11:1.11
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en'
# for debugging only
USER root
RUN microdnf install curl 
COPY --from=BUILD --chown=185 /usr/src/app/target/quarkus-app/lib/ /deployments/lib/
COPY --from=BUILD --chown=185 /usr/src/app/target/quarkus-app/*.jar /deployments/
COPY --from=BUILD --chown=185 /usr/src/app/target/quarkus-app/app/ /deployments/app/
COPY --from=BUILD --chown=185 /usr/src/app/target/quarkus-app/quarkus/ /deployments/quarkus/
EXPOSE 8081
USER 185
ENV AB_JOLOKIA_OFF=""
ENV JAVA_OPTS="-Dquarkus.http.host=0.0.0.0 -Djava.util.logging.manager=org.jboss.logmanager.LogManager"
ENV JAVA_APP_JAR="/deployments/quarkus-run.jar"