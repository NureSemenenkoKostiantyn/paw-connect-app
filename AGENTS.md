# AGENTS.md  ── repo root
## Environment
shell: |
# 1  Start the built-in Postgres cluster
service postgresql start

# 2  (idempotent) ensure DB + PostGIS exist
sudo -u postgres psql -v ON_ERROR_STOP=1 <<'SQL'
DO $$ BEGIN
IF NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = 'pawconnect')
THEN CREATE DATABASE pawconnect OWNER postgres;  END IF;
END$$;
\c pawconnect
CREATE EXTENSION IF NOT EXISTS postgis;
SQL

# 3  Wire Spring-Boot tests to it
export SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/pawconnect
export SPRING_DATASOURCE_USERNAME=postgres
export SPRING_DATASOURCE_PASSWORD=postgres

## Tests
run: ./mvnw -B -ntp test