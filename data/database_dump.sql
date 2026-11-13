--
-- PostgreSQL database dump
--

\restrict JEJn2LV96aKBvIsX0W8kqbAblOMh44pruwX41OiryiX6821yfSWpPIwC8f7sknU

-- Dumped from database version 18.6 (Debian 18.6-1.pgdg13+2)
-- Dumped by pg_dump version 18.6 (Debian 18.6-1.pgdg13+2)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: purchase_link; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.purchase_link (
    link_id integer NOT NULL,
    model_id integer NOT NULL,
    url character varying(1024) NOT NULL
);


--
-- Name: purchase_link_link_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.purchase_link ALTER COLUMN link_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.purchase_link_link_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: switch_brand; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.switch_brand (
    brand_id integer NOT NULL,
    name character varying(100) NOT NULL,
    country character varying(100),
    website character varying(255)
);


--
-- Name: switch_brand_brand_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.switch_brand ALTER COLUMN brand_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.switch_brand_brand_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: switch_model; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.switch_model (
    model_id integer NOT NULL,
    brand_id integer NOT NULL,
    name character varying(100) NOT NULL,
    switch_type character varying(10) NOT NULL,
    actuation_force_g numeric(5,1),
    bottom_out_force_g numeric(5,1),
    pre_travel_mm numeric(3,1),
    total_travel_mm numeric(3,1),
    stem_material character varying(50),
    housing_material character varying(50),
    factory_lubed boolean,
    CONSTRAINT actuation_force_sanity_check CHECK ((actuation_force_g <= bottom_out_force_g)),
    CONSTRAINT switch_model_actuation_force_g_check CHECK ((actuation_force_g > (0)::numeric)),
    CONSTRAINT switch_model_bottom_out_force_g_check CHECK ((bottom_out_force_g > (0)::numeric)),
    CONSTRAINT switch_model_pre_travel_mm_check CHECK ((pre_travel_mm >= (0)::numeric)),
    CONSTRAINT switch_model_switch_type_check CHECK (((switch_type)::text = ANY ((ARRAY['Linear'::character varying, 'Tactile'::character varying, 'Clicky'::character varying])::text[]))),
    CONSTRAINT switch_model_total_travel_mm_check CHECK ((total_travel_mm > (0)::numeric)),
    CONSTRAINT travel_order CHECK (((pre_travel_mm IS NULL) OR (total_travel_mm IS NULL) OR (pre_travel_mm <= total_travel_mm)))
);


--
-- Name: switch_model_model_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.switch_model ALTER COLUMN model_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.switch_model_model_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Data for Name: purchase_link; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.purchase_link (link_id, model_id, url) FROM stdin;
1	2	https://omnitype.com/products/cherry-mx2a-black-linear-switches
2	2	https://divinikey.com/products/cherry-mx2a-black-linear-switches
3	8	https://monacokeys.de/en/products/keygeek-y2-linear-switches
\.


--
-- Data for Name: switch_brand; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.switch_brand (brand_id, name, country, website) FROM stdin;
1	Cherry	Germany	www.cherry.de
2	Gateron	China	www.gateron.com
3	Keygeek	China	www.keygeek.cn
\.


--
-- Data for Name: switch_model; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.switch_model (model_id, brand_id, name, switch_type, actuation_force_g, bottom_out_force_g, pre_travel_mm, total_travel_mm, stem_material, housing_material, factory_lubed) FROM stdin;
1	1	MX2A Silent Red	Linear	45.0	65.0	1.9	3.7	POM	Nylon	t
2	1	MX2A Black	Linear	60.0	90.0	2.0	4.0	POM	Nylon	t
3	1	MX2A Brown	Tactile	48.0	60.0	2.0	4.0	POM	Nylon	t
4	2	Oil King	Linear	55.0	65.0	2.0	4.0	POM	Nylon	t
5	2	Milky Yellow Pro	Linear	50.0	62.0	2.0	4.0	POM	Nylon	t
6	2	Jupiter Banana	Tactile	59.0	60.0	2.0	3.4	POM	PC	t
7	2	G Pro 3.0 Blue	Clicky	50.0	60.0	2.0	4.0	POM	PC	t
8	3	Y2	Linear	32.0	37.0	2.0	3.6	U5/UPE	PA12	t
9	3	Xiaoba V2	Linear	40.0	48.0	2.0	3.6	U4	Nylon	f
10	3	Crepe	Linear	37.0	45.0	2.0	3.6	PBT	PC	t
\.


--
-- Name: purchase_link_link_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.purchase_link_link_id_seq', 3, true);


--
-- Name: switch_brand_brand_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.switch_brand_brand_id_seq', 3, true);


--
-- Name: switch_model_model_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.switch_model_model_id_seq', 10, true);


--
-- Name: purchase_link purchase_link_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purchase_link
    ADD CONSTRAINT purchase_link_pkey PRIMARY KEY (link_id);


--
-- Name: switch_brand switch_brand_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.switch_brand
    ADD CONSTRAINT switch_brand_name_key UNIQUE (name);


--
-- Name: switch_brand switch_brand_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.switch_brand
    ADD CONSTRAINT switch_brand_pkey PRIMARY KEY (brand_id);


--
-- Name: switch_model switch_model_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.switch_model
    ADD CONSTRAINT switch_model_pkey PRIMARY KEY (model_id);


--
-- Name: switch_model unique_model_per_brand; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.switch_model
    ADD CONSTRAINT unique_model_per_brand UNIQUE (brand_id, name);


--
-- Name: purchase_link unique_purchase_link; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purchase_link
    ADD CONSTRAINT unique_purchase_link UNIQUE (model_id, url);


--
-- Name: purchase_link purchase_link_model_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purchase_link
    ADD CONSTRAINT purchase_link_model_id_fkey FOREIGN KEY (model_id) REFERENCES public.switch_model(model_id) ON DELETE CASCADE;


--
-- Name: switch_model switch_model_brand_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.switch_model
    ADD CONSTRAINT switch_model_brand_id_fkey FOREIGN KEY (brand_id) REFERENCES public.switch_brand(brand_id);


--
-- PostgreSQL database dump complete
--

\unrestrict JEJn2LV96aKBvIsX0W8kqbAblOMh44pruwX41OiryiX6821yfSWpPIwC8f7sknU

