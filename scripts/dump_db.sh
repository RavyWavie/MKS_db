#!/usr/bin/env bash

# This script was made to run on my specific postgres setup, which uses a compose.yaml file
# Run from the directory containing compose.yaml.
# Change PG_SERVICE, PG_USER and PG_DATABASE to match your own Docker setup.
set -euo pipefail

PG_SERVICE="postgres"
PG_USER="postgres"
PG_DATABASE="MKS_db"

docker compose exec -T "${PG_SERVICE}" pg_dump -U "${PG_USER}" -d ${PG_DATABASE} --format=plain --no-owner --no-privileges > database_dump.sql
