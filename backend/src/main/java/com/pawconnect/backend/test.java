package com.pawconnect.backend;

import org.springframework.boot.SpringApplication;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

public class test {
    public static void main(String[] args) {
        // 1) Instantiate the same encoder you use in your SecurityConfig
        PasswordEncoder encoder = new BCryptPasswordEncoder();

        // 2) Define the raw passwords you need hashes for
        String[] rawPasswords = {
                "password",
                "password",
                // add more as needed
        };

        // 3) Loop and print each hash
        System.out.println("Username | Raw Password | Bcrypt Hash");
        System.out.println("---------|--------------|------------");

        for (String raw : rawPasswords) {
            String hash = encoder.encode(raw);
            System.out.printf("%s | %s | %s%n",
                    "<username?>", // replace or extend this line if you want to tie to a user
                    raw,
                    hash
            );
        }
    }
}
