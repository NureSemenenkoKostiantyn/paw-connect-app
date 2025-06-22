package com.pawconnect.backend.storage;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import java.time.Duration;

@Service
public class CachedSasService {
    private final RedisTemplate<String, String> redisTemplate;
    private final BlobStorageService blobStorageService;
    private final Duration ttl;

    public CachedSasService(RedisTemplate<String, String> redisTemplate,
                            BlobStorageService blobStorageService,
                            @Value("${storage.sas.ttl:600}") long ttlSeconds) {
        this.redisTemplate = redisTemplate;
        this.blobStorageService = blobStorageService;
        this.ttl = Duration.ofSeconds(ttlSeconds);
    }

    public String getSasLink(String blobName) {
        String key = "sas:" + blobName;
        String link = redisTemplate.opsForValue().get(key);
        if (link != null) {
            return link;
        }
        link = blobStorageService.generateSasLink(blobName);
        redisTemplate.opsForValue().set(key, link, ttl);
        return link;
    }
}
