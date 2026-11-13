#!/usr/bin/env bash

# This script was made to run on my specific postgres setup, which uses a compose.yaml file
# Run from the directory containing compose.yaml.
# Change PG_SERVICE, PG_USER and PG_DATABASE to match your own Docker setup.
set -euo pipefail

PG_SERVICE="postgres"
PG_USER="postgres"
PG_DATABASE="MKS_db"
OUTPUT_DIR="${OUTPUT_DIR:-.}"
mkdir -p "$OUTPUT_DIR"

CSV_TEMP="$(mktemp "$OUTPUT_DIR/.mechanical_switches.csv.XXXXXX")"
JSON_TEMP="$(mktemp "$OUTPUT_DIR/.mechanical_switches.json.XXXXXX")"
trap 'rm -f "$CSV_TEMP" "$JSON_TEMP"' EXIT

# The CSV repeats switch details for each purchase link; models with zero links remain present.
# Internal primary/foreign keys are intentionally omitted.
docker compose exec -T "$PG_SERVICE" \
  psql -X -v ON_ERROR_STOP=1 -U "$PG_USER" -d "$PG_DATABASE" \
  -c "COPY (
    SELECT
      b.name AS brand,
      b.country AS brand_country,
      b.website AS brand_website,
      m.name AS model,
      m.switch_type,
      m.actuation_force_g,
      m.bottom_out_force_g,
      m.pre_travel_mm,
      m.total_travel_mm,
      m.stem_material,
      m.housing_material,
      m.factory_lubed,
      p.url AS purchase_url
    FROM public.switch_model AS m
    JOIN public.switch_brand AS b ON b.brand_id = m.brand_id
    LEFT JOIN public.purchase_link AS p ON p.model_id = m.model_id
    ORDER BY b.name, m.name, p.url
  ) TO STDOUT WITH (FORMAT csv, HEADER true)" > "$CSV_TEMP"

# The JSON has one object per switch. Purchase links are an array (possibly empty).
docker compose exec -T "$PG_SERVICE" \
  psql -X -q -t -A -v ON_ERROR_STOP=1 -U "$PG_USER" -d "$PG_DATABASE" \
  -c "
    SELECT COALESCE(jsonb_agg(to_jsonb(x) ORDER BY x.brand, x.model), '[]'::jsonb)
    FROM (
      SELECT
        b.name AS brand,
        b.country AS brand_country,
        b.website AS brand_website,
        m.name AS model,
        m.switch_type,
        m.actuation_force_g,
        m.bottom_out_force_g,
        m.pre_travel_mm,
        m.total_travel_mm,
        m.stem_material,
        m.housing_material,
        m.factory_lubed,
        COALESCE(
          (SELECT jsonb_agg(p.url ORDER BY p.url)
           FROM public.purchase_link p
           WHERE p.model_id = m.model_id),
          '[]'::jsonb
        ) AS purchase_links
      FROM public.switch_model m
      JOIN public.switch_brand b ON b.brand_id = m.brand_id
    ) x;
  " > "$JSON_TEMP"

mv "$CSV_TEMP" "$OUTPUT_DIR/mechanical_switches.csv"
mv "$JSON_TEMP" "$OUTPUT_DIR/mechanical_switches.json"
echo "Created $OUTPUT_DIR/mechanical_switches.csv and $OUTPUT_DIR/mechanical_switches.json"
