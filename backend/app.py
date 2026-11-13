import os
from pathlib import Path

import psycopg
from psycopg.rows import dict_row
from flask import Flask, jsonify, send_from_directory

frontend_dir = Path(__file__).resolve().parent.parent / "frontend"
app = Flask(__name__, static_folder=str(frontend_dir / "js"), static_url_path="/js")


@app.get("/")
def index():
    return {"message": "Flask is up and running!"}


@app.get("/datatable.html")
def datatable():
    return send_from_directory(frontend_dir, "datatable.html")


@app.get("/api/switches")
def get_switches():
    try:
        with psycopg.connect(os.environ["DATABASE_URL"], row_factory=dict_row) as connection:
            with connection.cursor() as cursor:
                cursor.execute("""
                    SELECT b.name || ' ' || m.name AS model,
                           m.actuation_force_g::double precision AS actuation_force_g
                    FROM switch_model AS m
                    JOIN switch_brand AS b ON b.brand_id = m.brand_id
                    ORDER BY b.name, m.name
                """)
                switches = cursor.fetchall()
    except psycopg.Error:
        app.logger.exception("Failed to load switches from PostgreSQL")
        return jsonify({"error": "Could not load switches from the database."}), 503

    return jsonify(switches)
