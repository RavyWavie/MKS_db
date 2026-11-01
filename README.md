# Mechanical Keyboard Switches

> **Warning:** This is a small, non-comprehensive dataset created for a university assignment. It is not intended to be an authoritative catalog of mechanical keyboard switches, and its coverage is very limited (for now).

## About the dataset

This open dataset catalogs mechanical keyboard switch models, their brands, and selected technical specifications useful for comparing switches. Where available, it also includes links to merchants selling particular models.

The data is maintained in a PostgreSQL database with three tables: `switch_brand`, `switch_model`, and `purchase_link`.

## Dataset metadata

| Metadata | Value |
|---|---|
| Title | Mechanical Keyboard Switches |
| Description | Switch models, associated brands, mechanical specifications, and optional purchase links |
| Author | Patrick Vincek |
| Version | 1.0 |
| Language | English (field names and values) |
| License | Creative Commons Attribution 4.0 International (CC BY 4.0) |
| Dataset formats | CSV and JSON |
| Source database | PostgreSQL |
| Number of switch models | 10 |
| Number of brands | 3 |

## Data files

- `mechanical_switches.csv` — flat representation of the dataset; a switch may appear in multiple rows if it has multiple purchase links.
- `mechanical_switches.json` — one object per switch model, with purchase links represented as an array (which may be empty).
- `database_dump.sql` — PostgreSQL database dump containing the schema and stored records.

Internal database IDs are intentionally excluded from the CSV and JSON exports.

## Attributes

| Attribute | Meaning |
|---|---|
| `brand` | Brand under which the switch is sold |
| `brand_country` | Country associated with the brand |
| `brand_website` | Brand's website |
| `model` | Switch model name |
| `switch_type` | Linear, tactile, or clicky |
| `actuation_force_g` | Nominal actuation force, expressed in gram-force (gf) |
| `bottom_out_force_g` | Nominal force at full key travel, expressed in gram-force (gf) |
| `pre_travel_mm` | Travel distance before actuation, in millimeters |
| `total_travel_mm` | Total key travel, in millimeters |
| `stem_material` | Material of the switch stem |
| `housing_material` | Material of the switch housing |
| `factory_lubed` | Whether the switch is factory-lubricated |
| `purchase_url` (CSV) | Link to a seller, when recorded |
| `purchase_links` (JSON) | Array of seller links for the switch |

A missing purchase link means **no link is recorded**, not necessarily that a switch is unavailable. Some other attributes may also be missing when information is unavailable.

> **Note:** CSV repeats the parent switch data for each purchase link, which is a clunky solution. JSON does not have this issue, as it is hierarchical.
> **Note:** The housing of a switch is made up of multiple parts which don't necessarily use the same material. The 'housing_material' attribute records the most prevalent material.

## Extras

The extra directory contains development files and scripts, if you want to use them.

| File | Usage |
|---|---|
| `compose.yaml` | A Docker Compose setup with PostgreSQL and pgAdmin. Start with `docker compose up` |
| `mechanical_switches_setup.sql` | SQL file used for building the database. Should have a similar effect as running the database dump, but with sane formatting and is more easily reproducible. |
| `dump_db.sh` | Creates a database dump file. Check the script to see if you need to change some variables before running. |
| `export.sh` | Exports the database into CSV and JSON files. Check the script to see if you need to change some variables before running. |

**Note:** JSON will be exported in a concise format. If you wish to have a more readable format, you can run the following command (if you have Python installed):

```bash
python3 -m json.tool mechanical_switches.json > mechanical_switches_pretty.json
```

## License

This dataset is published under the **Creative Commons Attribution 4.0 International (CC BY 4.0)** license. You may share and adapt the data, including commercially, provided appropriate attribution is given. See the repository's `LICENSE` file for the full terms.
