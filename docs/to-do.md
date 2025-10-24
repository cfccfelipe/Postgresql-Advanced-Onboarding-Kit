## 🧩 Specific Quest Breakdown
- Dockerizacion
FROM postgres:15

# Install Python, pgcli, and tools
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install Python packages (using --break-system-packages for container isolation)
RUN pip3 install --no-cache-dir --break-system-packages \
    pgcli \
    faker \
    psycopg2-binary

# Copy workshop materials
COPY sql/ /workshop/sql/
COPY scripts/ /workshop/scripts/

# Add helper scripts
COPY reset-db.sh /usr/local/bin/reset-db
COPY benchmark.sh /usr/local/bin/benchmark
RUN chmod +x /usr/local/bin/*

# Configure pgcli
RUN mkdir -p /root/.config/pgcli && \
    echo "[main]" > /root/.config/pgcli/config && \
    echo "multi_line = True" >> /root/.config/pgcli/config && \
    echo "syntax_style = monokai" >> /root/.config/pgcli/config && \
    echo "auto_expand = True" >> /root/.config/pgcli/config

# Set environment variables
ENV POSTGRES_DB=workshop \
    POSTGRES_USER=workshop_user \
    POSTGRES_PASSWORD=workshop_pass \
    PGDATABASE=workshop \
    PGUSER=workshop_user

WORKDIR /workshop

# PostgreSQL runs on port 5432
EXPOSE 5432

-Supervisor
[supervisord]
nodaemon=true
user=root

[program:postgresql]
command=/usr/local/bin/docker-entrypoint.sh postgres
autorestart=true
priority=1

[program:pgadmin]
command=/usr/pgadmin4/bin/pgAdmin4
environment=PGADMIN_DEFAULT_EMAIL=admin@workshop.com,PGADMIN_DEFAULT_PASSWORD=admin
autorestart=true
priority=2
