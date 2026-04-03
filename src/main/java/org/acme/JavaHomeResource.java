package org.acme;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;

@Path("/javahome")
@ApplicationScoped
public class JavaHomeResource {

    @GET
    @Produces(MediaType.TEXT_PLAIN)
    public String getJavaHome() {
        StringBuilder sb = new StringBuilder();
        sb.append("=== EXPLICIT java.home Access Test ===\n\n");

        sb.append("Test 1: System.getProperty(\"java.home\")\n");
        String javaHome = System.getProperty("java.home");
        sb.append("Result: ").append(javaHome).append("\n\n");

        sb.append("Test 2: System.getProperty(\"java.home\", \"default\")\n");
        String javaHomeWithDefault = System.getProperty("java.home", "DEFAULT_VALUE");
        sb.append("Result: ").append(javaHomeWithDefault).append("\n\n");

        sb.append("Test 3: Multiple accesses (should trigger warnings)\n");
        for (int i = 0; i < 3; i++) {
            String value = System.getProperty("java.home");
            sb.append("Access ").append(i + 1).append(": ").append(value).append("\n");
        }

        sb.append("\n=== Analysis ===\n");
        if (javaHome == null) {
            sb.append("⚠️ java.home is NULL\n");
            sb.append("This suggests the substitution is NOT setting the property.\n");
        } else if (javaHome.contains("quarkus-awt-tmp-fonts")) {
            sb.append("✅ java.home points to Quarkus workaround directory\n");
        } else {
            sb.append("ℹ️ java.home points to: ").append(javaHome).append("\n");
        }

        sb.append("\n=== Purpose ===\n");
        sb.append("This endpoint EXPLICITLY calls System.getProperty(\"java.home\").\n");
        sb.append("GraalVM PR #10030 should detect these calls and show:\n");
        sb.append("  Warning: System.getProperty(\"java.home\") called at JavaHomeResource.getJavaHome(...)\n");
        sb.append("during the native-image build analysis phase.\n");

        return sb.toString();
    }
}
