package com.pawconnect.backend.common;

import com.azure.storage.blob.BlobClient;
import com.azure.storage.blob.BlobContainerClient;
import com.azure.storage.blob.BlobServiceClient;
import com.azure.storage.blob.BlobServiceClientBuilder;
import com.azure.storage.blob.sas.BlobSasPermission;
import com.azure.storage.blob.sas.BlobServiceSasSignatureValues;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.time.Duration;
import java.time.OffsetDateTime;
import java.util.UUID;

@Service
public class BlobStorageService {
    private final BlobContainerClient containerClient;
    private final Duration sasExpiry;

    public BlobStorageService(
            @Value("${azure.storage.connection-string}") String connectionString,
            @Value("${azure.storage.container-name}") String containerName,
            @Value("${azure.storage.sas-expiry-minutes}") long expiryMinutes) {
        BlobServiceClient serviceClient = new BlobServiceClientBuilder()
                .connectionString(connectionString)
                .buildClient();
        this.containerClient = serviceClient.getBlobContainerClient(containerName);
        this.sasExpiry = Duration.ofMinutes(expiryMinutes);
        if (!containerClient.exists()) {
            containerClient.create();
        }
    }

    public String upload(MultipartFile file, String folder) throws IOException {
        String blobName = folder + '/' + UUID.randomUUID() + '-' + file.getOriginalFilename();
        BlobClient blob = containerClient.getBlobClient(blobName);
        blob.upload(file.getInputStream(), file.getSize(), true);
        return blobName;
    }

    /** Generate a read-only SAS URL valid for a limited time. */
    public String generateReadSasUrl(String blobName) {
        OffsetDateTime expiry = OffsetDateTime.now().plus(sasExpiry);
        BlobSasPermission perms = new BlobSasPermission().setReadPermission(true);
        BlobServiceSasSignatureValues values =
                new BlobServiceSasSignatureValues(expiry, perms)
                        .setStartTime(OffsetDateTime.now());
        String sasToken = containerClient.getBlobClient(blobName)
                .generateSas(values);
        return containerClient.getBlobClient(blobName).getBlobUrl() + "?" + sasToken;
    }

    public void delete(String blobName) {
        BlobClient blob = containerClient.getBlobClient(blobName);
        if (blob.exists()) {
            blob.delete();
        }
    }
}
