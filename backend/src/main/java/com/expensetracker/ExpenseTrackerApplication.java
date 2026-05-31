package com.expensetracker;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

@SpringBootApplication
public class ExpenseTrackerApplication {
    public static void main(String[] args) {
        loadDotEnv();
        SpringApplication.run(ExpenseTrackerApplication.class, args);
    }

    private static void loadDotEnv() {
        Path envPath = Files.exists(Path.of(".env")) ? Path.of(".env") : Path.of("backend", ".env");
        if (!Files.exists(envPath)) {
            return;
        }
        try {
            Files.readAllLines(envPath).stream()
                    .map(String::trim)
                    .filter(line -> !line.isEmpty() && !line.startsWith("#") && line.contains("="))
                    .forEach(line -> {
                        int separator = line.indexOf('=');
                        String key = line.substring(0, separator).trim();
                        String value = line.substring(separator + 1).trim();
                        if (System.getenv(key) == null && System.getProperty(key) == null) {
                            System.setProperty(key, value);
                        }
                    });
        } catch (IOException ex) {
            throw new IllegalStateException("Unable to load .env file", ex);
        }
    }
}
