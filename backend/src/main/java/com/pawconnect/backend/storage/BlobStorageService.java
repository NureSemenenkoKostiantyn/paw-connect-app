package com.pawconnect.backend.storage;

import org.springframework.stereotype.Service;

@Service
public class BlobStorageService {
    public String generateSasLink(String blobName) {
        // Placeholder for actual SAS generation logic using Azure SDK
        return "https://storage.example.com/" + blobName + "?sig=dummy";
    }
}
