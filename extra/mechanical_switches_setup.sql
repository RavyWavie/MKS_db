-- Mechanical keyboard switches: development database setup
BEGIN;

DROP TABLE IF EXISTS purchase_link;
DROP TABLE IF EXISTS switch_model;
DROP TABLE IF EXISTS switch_brand;

CREATE TABLE switch_brand (
    brand_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    country VARCHAR(100),
    website VARCHAR(255)
);

CREATE TABLE switch_model (
    model_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    brand_id INTEGER NOT NULL REFERENCES switch_brand(brand_id),
    name VARCHAR(100) NOT NULL,
    switch_type VARCHAR(10) NOT NULL
        CHECK (switch_type IN ('Linear', 'Tactile', 'Clicky')),
    actuation_force_g NUMERIC(5,1) CHECK (actuation_force_g > 0),
    bottom_out_force_g NUMERIC(5,1) CHECK (bottom_out_force_g > 0),
    pre_travel_mm NUMERIC(3,1) CHECK (pre_travel_mm >= 0),
    total_travel_mm NUMERIC(3,1) CHECK (total_travel_mm > 0),
    stem_material VARCHAR(50),
    housing_material VARCHAR(50),
    factory_lubed BOOLEAN,
    CONSTRAINT unique_model_per_brand UNIQUE (brand_id, name),
    CONSTRAINT travel_order CHECK (
        pre_travel_mm IS NULL OR total_travel_mm IS NULL
        OR pre_travel_mm <= total_travel_mm
    ),
    CONSTRAINT actuation_force_sanity_check CHECK (actuation_force_g <= bottom_out_force_g)
);

CREATE TABLE purchase_link (
    link_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    model_id INTEGER NOT NULL REFERENCES switch_model(model_id) ON DELETE CASCADE,
    url VARCHAR(1024) NOT NULL,
    CONSTRAINT unique_purchase_link UNIQUE (model_id, url)
);

INSERT INTO switch_brand (name, country, website) VALUES
    ('Cherry', 'Germany', 'www.cherry.de'),
    ('Gateron', 'China', 'www.gateron.com'),
    ('Keygeek', 'China', 'www.keygeek.cn');

INSERT INTO switch_model (
    brand_id, name, switch_type, actuation_force_g, bottom_out_force_g,
    pre_travel_mm, total_travel_mm, stem_material, housing_material, factory_lubed
) VALUES
    (1, 'MX2A Silent Red',  'Linear',   45, 65, 1.9, 3.7, 'POM',    'Nylon',    TRUE),
    (1, 'MX2A Black',       'Linear',   60, 90, 2.0, 4.0, 'POM',    'Nylon',    TRUE),
    (1, 'MX2A Brown',       'Tactile',  48, 60, 2.0, 4.0, 'POM',    'Nylon',    TRUE),

    (2, 'Oil King',         'Linear',   55, 65, 2.0, 4.0, 'POM',    'Nylon',    TRUE),
    (2, 'Milky Yellow Pro', 'Linear',   50, 62, 2.0, 4.0, 'POM',    'Nylon',    TRUE),
    (2, 'Jupiter Banana',   'Tactile',  59, 60, 2.0, 3.4, 'POM',    'PC',       TRUE),
    (2, 'G Pro 3.0 Blue',   'Clicky',   50, 60, 2.0, 4.0, 'POM',    'PC',       TRUE),

    (3, 'Y2',               'Linear',   32, 37, 2.0, 3.6, 'U5/UPE', 'PA12',     TRUE),
    (3, 'Xiaoba V2',        'Linear',   40, 48, 2.0, 3.6, 'U4',     'Nylon',    FALSE),
    (3, 'Crepe',            'Linear',   37, 45, 2.0, 3.6, 'PBT',    'PC',       TRUE);


INSERT INTO purchase_link (model_id, url) VALUES
    (2, 'https://omnitype.com/products/cherry-mx2a-black-linear-switches'),
    (2, 'https://divinikey.com/products/cherry-mx2a-black-linear-switches'),
    (8, 'https://monacokeys.de/en/products/keygeek-y2-linear-switches');

COMMIT;

-- Quick sanity check:
SELECT m.model_id, b.name AS brand, m.name AS model, m.switch_type,
       m.actuation_force_g, m.total_travel_mm
FROM switch_model AS m
JOIN switch_brand AS b ON b.brand_id = m.brand_id
ORDER BY m.model_id;
