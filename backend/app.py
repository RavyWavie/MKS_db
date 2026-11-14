import os
from pathlib import Path

import psycopg
from psycopg import sql
from psycopg.rows import dict_row
from flask import Flask, abort, jsonify, redirect, request, send_from_directory, url_for

frontend_dir = Path(__file__).resolve().parent.parent / "frontend"
data_dir = frontend_dir.parent / "data"
app = Flask(__name__, static_folder=str(frontend_dir / "js"), static_url_path="/js")

FILTER_FIELDS = (
    "brand", "brand_country", "brand_website", "model", "switch_type",
    "actuation_force_g", "bottom_out_force_g", "pre_travel_mm",
    "total_travel_mm", "stem_material", "housing_material", "factory_lubed",
    "purchase_links",
)


@app.get("/")
def home():
    return redirect(url_for("index"))


@app.get("/index.html")
def index():
    return send_from_directory(frontend_dir, "index.html")


@app.get("/data/<filename>")
def download_dataset(filename):
    if filename not in {"mechanical_switches.csv", "mechanical_switches.json", "schema.json", "database_dump.sql"}:
        abort(404)
    return send_from_directory(data_dir, filename, as_attachment=True)


@app.get("/LICENSE")
def license_text():
    return send_from_directory(frontend_dir.parent, "LICENSE", mimetype="text/plain")


@app.get("/datatable.html")
def datatable():
    return send_from_directory(frontend_dir, "datatable.html")


@app.get("/css/<path:filename>")
def stylesheet(filename):
    return send_from_directory(frontend_dir / "css", filename)


@app.get("/api/switches")
def get_switches():
    search = request.args.get("search", "").strip()
    attribute = request.args.get("attribute", "all")
    if attribute != "all" and attribute not in FILTER_FIELDS:
        return jsonify({"error": "Unknown search attribute."}), 400

    fields = FILTER_FIELDS if attribute == "all" else (attribute,)
    # Treat %, _ and backslashes as literal search text, not LIKE patterns.
    pattern = "%" + search.replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_") + "%"
    conditions = sql.SQL(" OR ").join(
        sql.SQL("CAST({} AS text) ILIKE %(pattern)s").format(sql.Identifier(field))
        for field in fields
    )
    try:
        with psycopg.connect(os.environ["DATABASE_URL"], row_factory=dict_row) as connection:
            with connection.cursor() as cursor:
                query = sql.SQL("""
                    WITH switches AS (
                    SELECT b.name AS brand,
                           b.country AS brand_country,
                           b.website AS brand_website,
                           m.name AS model,
                           m.switch_type,
                           m.actuation_force_g::double precision AS actuation_force_g,
                           m.bottom_out_force_g::double precision AS bottom_out_force_g,
                           m.pre_travel_mm::double precision AS pre_travel_mm,
                           m.total_travel_mm::double precision AS total_travel_mm,
                           m.stem_material,
                           m.housing_material,
                           m.factory_lubed,
                           COALESCE(
                               (SELECT jsonb_agg(p.url ORDER BY p.url)
                                FROM purchase_link AS p
                                WHERE p.model_id = m.model_id),
                               '[]'::jsonb
                           ) AS purchase_links
                    FROM switch_model AS m
                    JOIN switch_brand AS b ON b.brand_id = m.brand_id
                    )
                    SELECT * FROM switches
                    WHERE {conditions}
                    ORDER BY brand, model
                """).format(conditions=conditions if search else sql.SQL("TRUE"))
                cursor.execute(query, {"pattern": pattern})
                switches = cursor.fetchall()
    except psycopg.Error:
        app.logger.exception("Failed to load switches from PostgreSQL")
        return jsonify({"error": "Could not load switches from the database."}), 503

    return jsonify(switches)
