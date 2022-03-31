package heidloff.net.database;

public class ServiceInvocationException extends RuntimeException {

    private static final long serialVersionUID = 2L;

    public ServiceInvocationException() {
    }

    public ServiceInvocationException(String message) {
        super(message);
    }

    public ServiceInvocationException(Throwable cause) {
        super(cause);
    }
}