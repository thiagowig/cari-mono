package dev.thiagofonseca;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;

public class AppHandler implements RequestHandler<String, String> {


    @Override
    public String handleRequest(String request, Context context) {
        context.getLogger().log("Request: " + request);
        return "Response: " + request;
    }

}
