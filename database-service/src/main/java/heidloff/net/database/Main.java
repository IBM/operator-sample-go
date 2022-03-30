package heidloff.net.database;

import io.quarkus.runtime.annotations.QuarkusMain;

import javax.enterprise.context.ApplicationScoped;
import javax.inject.Inject;

import io.quarkus.runtime.Quarkus;
import io.quarkus.runtime.QuarkusApplication;

@ApplicationScoped
@QuarkusMain  
public class Main {

    public static void main(String... args) {
        Quarkus.run(DatabaseApp.class, args);
    }

    public static class DatabaseApp implements QuarkusApplication {
        
        @Inject
        LeaderUtils leaderUtils;
        
        @Override
        public int run(String... args) throws Exception {            
            leaderUtils.electLeader();
            Quarkus.waitForExit();
            return 0;
        }
    }
}
