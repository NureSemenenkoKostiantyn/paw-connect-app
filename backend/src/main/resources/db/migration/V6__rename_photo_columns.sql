ALTER TABLE users RENAME COLUMN profile_photo_url TO profile_photo_blob_name;
ALTER TABLE dog_photo_urls RENAME TO dog_photo_blob_names;
ALTER TABLE dog_photo_blob_names RENAME COLUMN photo_urls TO photo_blob_names;
