package org.acme;

import java.awt.Font;
import java.awt.GraphicsEnvironment;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;

@Path("/fonts")
@ApplicationScoped
public class FontResource {

    @GET
    @Produces(MediaType.TEXT_PLAIN)
    public String getFonts() {
        StringBuilder sb = new StringBuilder();
        sb.append("=== Font Test for Issue #44435 ===\n\n");

        // Show java.home value
        String javaHome = System.getProperty("java.home");
        sb.append("java.home: ").append(javaHome).append("\n\n");

        // Check if it's the Quarkus workaround directory
        if (javaHome != null && javaHome.contains("quarkus-awt-tmp-fonts")) {
            sb.append("✓ Quarkus AWT workaround ACTIVE\n");
            sb.append("  (Fake java.home created by JDKSubstitutions)\n\n");
        } else {
            sb.append("ℹ Using default java.home\n\n");
        }

        // Initialize fonts - this triggers the java.home access
        try {
            GraphicsEnvironment ge = GraphicsEnvironment.getLocalGraphicsEnvironment();
            Font[] fonts = ge.getAllFonts();

            sb.append("Available fonts: ").append(fonts.length).append("\n");
            sb.append("Sample fonts:\n");
            for (int i = 0; i < Math.min(10, fonts.length); i++) {
                sb.append("  - ").append(fonts[i].getFontName()).append("\n");
            }

            sb.append("\n✓ Font initialization successful\n");
        } catch (Exception e) {
            sb.append("\n✗ Font initialization FAILED: ").append(e.getMessage()).append("\n");
            e.printStackTrace();
        }

        sb.append("\n=== Issue #44435 Context ===\n");
        sb.append("GraalVM PR #10030 detects java.home access.\n");
        sb.append("Quarkus AWT extension substitutes FontConfiguration.\n");
        sb.append("See: https://github.com/quarkusio/quarkus/issues/44435\n");

        return sb.toString();
    }
}
