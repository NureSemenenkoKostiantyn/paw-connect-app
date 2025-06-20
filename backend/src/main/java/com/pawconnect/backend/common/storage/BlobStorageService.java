package com.pawconnect.backend.common.storage;

import com.azure.storage.blob.BlobContainerClient;
import com.azure.storage.blob.BlobServiceClient;
import com.azure.storage.blob.BlobServiceClientBuilder;
import com.azure.storage.blob.specialized.BlockBlobClient;
import com.azure.storage.blob.models.BlobHttpHeaders;
import com.azure.storage.blob.sas.BlobSasPermission;
import com.azure.storage.blob.sas.BlobServiceSasSignatureValues;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.annotation.PostConstruct;
import java.io.InputStream;
import java.time.OffsetDateTime;

@Service
public class BlobStorageService {

    private final BlobServiceClient blobServiceClient;
    private final BlobContainerClient containerClient;
    private final int sasExpiryMinutes;

    public BlobStorageService(
            @Value("${azure.storage.connection-string}") String connectionString,
            @Value("${azure.storage.container-name}") String containerName,
            @Value("${azure.storage.sas-expiry-minutes}") int sasExpiryMinutes) {
        this.blobServiceClient = new BlobServiceClientBuilder()
                .connectionString(connectionString)
                .buildClient();
        this.containerClient = blobServiceClient.getBlobContainerClient(containerName);
        this.sasExpiryMinutes = sasExpiryMinutes;
    }

    @PostConstruct
    private void ensureContainerExists() {
        if (!containerClient.exists()) {
            containerClient.create();
        }
    }

    public void upload(String blobName, InputStream data, long length, String contentType, String cacheControl) {
        BlockBlobClient blobClient = containerClient.getBlobClient(blobName).getBlockBlobClient();
        blobClient.upload(data, length, true);
        BlobHttpHeaders headers = new BlobHttpHeaders()
                .setContentType(contentType)
                .setCacheControl(cacheControl);
        blobClient.setHttpHeaders(headers);
    }

    public String generateReadUrl(String blobName) {
        if (blobName == null) return null;
        BlobSasPermission permission = new BlobSasPermission().setReadPermission(true);
        OffsetDateTime expiry = OffsetDateTime.now().plusMinutes(sasExpiryMinutes);
        BlobServiceSasSignatureValues values = new BlobServiceSasSignatureValues(expiry, permission);
        String sas = containerClient.getBlobClient(blobName).generateSas(values);
        return containerClient.getBlobClient(blobName).getBlobUrl() + "?" + sas;
    }

    public void delete(String blobName) {
        if (blobName == null) return;
        containerClient.getBlobClient(blobName).deleteIfExists();
    }
}
