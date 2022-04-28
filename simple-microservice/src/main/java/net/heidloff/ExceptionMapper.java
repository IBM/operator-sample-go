package net.heidloff;

import javax.ws.rs.core.MultivaluedMap;
import javax.ws.rs.core.Response;
import javax.ws.rs.ext.Provider;

import org.eclipse.microprofile.rest.client.ext.ResponseExceptionMapper;

@Provider
public class ExceptionMapper implements ResponseExceptionMapper<ServiceInvocationException> {

	@Override
	public boolean handles(int status, MultivaluedMap<String, Object> headers) {
		return false;
	}

	@Override
	public ServiceInvocationException toThrowable(Response response) {
		return null;
	}
}