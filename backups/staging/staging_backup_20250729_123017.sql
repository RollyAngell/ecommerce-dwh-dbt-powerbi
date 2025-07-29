--
-- PostgreSQL database dump
--

-- Dumped from database version 14.18 (Homebrew)
-- Dumped by pg_dump version 14.18 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: analytics; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA analytics;


ALTER SCHEMA analytics OWNER TO postgres;

--
-- Name: SCHEMA analytics; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA analytics IS 'Transformed data models created by dbt (production)';


--
-- Name: analytics_dev; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA analytics_dev;


ALTER SCHEMA analytics_dev OWNER TO postgres;

--
-- Name: SCHEMA analytics_dev; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA analytics_dev IS 'Transformed data models created by dbt (development)';


--
-- Name: analytics_staging; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA analytics_staging;


ALTER SCHEMA analytics_staging OWNER TO postgres;

--
-- Name: SCHEMA analytics_staging; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA analytics_staging IS 'Transformed data models created by dbt (staging)';


--
-- Name: raw; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA raw;


ALTER SCHEMA raw OWNER TO postgres;

--
-- Name: SCHEMA raw; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA raw IS 'Raw data loaded from CSV files';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: -- Custom alias naming for modelsdim_customers; Type: TABLE; Schema: analytics_staging; Owner: dbt_staging_user
--

CREATE TABLE analytics_staging."-- Custom alias naming for modelsdim_customers" (
    customer_id integer,
    first_name text,
    last_name text,
    full_name text,
    email text,
    registration_date date,
    customer_segment text,
    total_orders bigint,
    total_spent numeric,
    first_order_date date,
    last_order_date date,
    total_visits bigint,
    total_duration_minutes bigint,
    total_pages_viewed bigint,
    first_visit_date date,
    last_visit_date date,
    conversion_rate_percent numeric,
    avg_order_value numeric,
    _loaded_at timestamp with time zone
);


ALTER TABLE analytics_staging."-- Custom alias naming for modelsdim_customers" OWNER TO dbt_staging_user;

--
-- Name: -- Custom alias naming for modelsdim_date; Type: TABLE; Schema: analytics_staging; Owner: dbt_staging_user
--

CREATE TABLE analytics_staging."-- Custom alias naming for modelsdim_date" (
    date_key timestamp without time zone,
    date_day timestamp without time zone,
    year numeric,
    quarter numeric,
    month numeric,
    week_of_year numeric,
    day_of_month numeric,
    day_of_week numeric,
    day_of_year numeric,
    date_string text,
    year_month text,
    year_quarter text,
    month_name text,
    day_name text,
    is_weekend boolean,
    is_weekday boolean,
    quarter_name text,
    season text,
    _loaded_at timestamp with time zone
);


ALTER TABLE analytics_staging."-- Custom alias naming for modelsdim_date" OWNER TO dbt_staging_user;

--
-- Name: -- Custom alias naming for modelsdim_products; Type: TABLE; Schema: analytics_staging; Owner: dbt_staging_user
--

CREATE TABLE analytics_staging."-- Custom alias naming for modelsdim_products" (
    product_id integer,
    product_name text,
    category text,
    price numeric(10,2),
    price_tier text,
    total_orders bigint,
    total_quantity_sold bigint,
    total_revenue numeric,
    first_sale_date date,
    last_sale_date date,
    performance_tier text,
    avg_quantity_per_order numeric,
    avg_revenue_per_order numeric,
    _loaded_at timestamp with time zone
);


ALTER TABLE analytics_staging."-- Custom alias naming for modelsdim_products" OWNER TO dbt_staging_user;

--
-- Name: -- Custom alias naming for modelsfct_orders; Type: TABLE; Schema: analytics_staging; Owner: dbt_staging_user
--

CREATE TABLE analytics_staging."-- Custom alias naming for modelsfct_orders" (
    order_id integer,
    customer_id integer,
    product_id integer,
    order_date date,
    quantity integer,
    unit_price numeric(10,2),
    total_amount numeric(10,2),
    discount_amount numeric,
    order_year numeric,
    order_month numeric,
    order_quarter numeric,
    order_size text,
    estimated_profit numeric,
    profit_margin_percent numeric,
    _loaded_at timestamp with time zone
);


ALTER TABLE analytics_staging."-- Custom alias naming for modelsfct_orders" OWNER TO dbt_staging_user;

--
-- Name: -- Custom alias naming for modelsfct_visits; Type: TABLE; Schema: analytics_staging; Owner: dbt_staging_user
--

CREATE TABLE analytics_staging."-- Custom alias naming for modelsfct_visits" (
    visit_id character varying(10),
    customer_id integer,
    visit_date date,
    duration_minutes integer,
    pages_viewed integer,
    pages_per_minute numeric,
    engagement_score integer,
    converted_flag integer,
    converted_order_id integer,
    conversion_value numeric,
    session_type text,
    engagement_level text,
    visit_year numeric,
    visit_month numeric,
    traffic_source text,
    _loaded_at timestamp with time zone
);


ALTER TABLE analytics_staging."-- Custom alias naming for modelsfct_visits" OWNER TO dbt_staging_user;

--
-- Name: customers; Type: TABLE; Schema: raw; Owner: postgres
--

CREATE TABLE raw.customers (
    customer_id integer NOT NULL,
    first_name character varying(100),
    last_name character varying(100),
    email character varying(255),
    registration_date date
);


ALTER TABLE raw.customers OWNER TO postgres;

--
-- Name: TABLE customers; Type: COMMENT; Schema: raw; Owner: postgres
--

COMMENT ON TABLE raw.customers IS 'Customer master data';


--
-- Name: -- Custom alias naming for modelsstg_customers; Type: VIEW; Schema: analytics_staging; Owner: dbt_staging_user
--

CREATE VIEW analytics_staging."-- Custom alias naming for modelsstg_customers" AS
 WITH source_data AS (
         SELECT customers.customer_id,
            customers.first_name,
            customers.last_name,
            customers.email,
            customers.registration_date
           FROM raw.customers
        )
 SELECT source_data.customer_id,
    TRIM(BOTH FROM source_data.first_name) AS first_name,
    TRIM(BOTH FROM source_data.last_name) AS last_name,
    lower(TRIM(BOTH FROM source_data.email)) AS email,
    source_data.registration_date,
    concat(TRIM(BOTH FROM source_data.first_name), ' ', TRIM(BOTH FROM source_data.last_name)) AS full_name,
    CURRENT_TIMESTAMP AS _loaded_at
   FROM source_data
  WHERE ((source_data.customer_id IS NOT NULL) AND (source_data.email IS NOT NULL) AND (source_data.registration_date IS NOT NULL));


ALTER TABLE analytics_staging."-- Custom alias naming for modelsstg_customers" OWNER TO dbt_staging_user;

--
-- Name: orders; Type: TABLE; Schema: raw; Owner: postgres
--

CREATE TABLE raw.orders (
    order_id integer NOT NULL,
    customer_id integer,
    order_date date,
    product_id integer,
    quantity integer,
    total_amount numeric(10,2)
);


ALTER TABLE raw.orders OWNER TO postgres;

--
-- Name: TABLE orders; Type: COMMENT; Schema: raw; Owner: postgres
--

COMMENT ON TABLE raw.orders IS 'Order transaction data';


--
-- Name: -- Custom alias naming for modelsstg_orders; Type: VIEW; Schema: analytics_staging; Owner: dbt_staging_user
--

CREATE VIEW analytics_staging."-- Custom alias naming for modelsstg_orders" AS
 WITH source_data AS (
         SELECT orders.order_id,
            orders.customer_id,
            orders.order_date,
            orders.product_id,
            orders.quantity,
            orders.total_amount
           FROM raw.orders
        )
 SELECT source_data.order_id,
    source_data.customer_id,
    source_data.order_date,
    source_data.product_id,
    source_data.quantity,
    source_data.total_amount,
    ((source_data.total_amount / (source_data.quantity)::numeric))::numeric(10,2) AS unit_price,
    EXTRACT(year FROM source_data.order_date) AS order_year,
    EXTRACT(month FROM source_data.order_date) AS order_month,
    EXTRACT(quarter FROM source_data.order_date) AS order_quarter,
    CURRENT_TIMESTAMP AS _loaded_at
   FROM source_data
  WHERE ((source_data.order_id IS NOT NULL) AND (source_data.customer_id IS NOT NULL) AND (source_data.product_id IS NOT NULL) AND (source_data.order_date IS NOT NULL) AND (source_data.quantity > 0) AND (source_data.total_amount > (0)::numeric));


ALTER TABLE analytics_staging."-- Custom alias naming for modelsstg_orders" OWNER TO dbt_staging_user;

--
-- Name: products; Type: TABLE; Schema: raw; Owner: postgres
--

CREATE TABLE raw.products (
    product_id integer NOT NULL,
    product_name character varying(255),
    category character varying(100),
    price numeric(10,2)
);


ALTER TABLE raw.products OWNER TO postgres;

--
-- Name: TABLE products; Type: COMMENT; Schema: raw; Owner: postgres
--

COMMENT ON TABLE raw.products IS 'Product catalog data';


--
-- Name: -- Custom alias naming for modelsstg_products; Type: VIEW; Schema: analytics_staging; Owner: dbt_staging_user
--

CREATE VIEW analytics_staging."-- Custom alias naming for modelsstg_products" AS
 WITH source_data AS (
         SELECT products.product_id,
            products.product_name,
            products.category,
            products.price
           FROM raw.products
        )
 SELECT source_data.product_id,
    TRIM(BOTH FROM source_data.product_name) AS product_name,
    TRIM(BOTH FROM upper((source_data.category)::text)) AS category,
    source_data.price,
        CASE
            WHEN (source_data.price < (50)::numeric) THEN 'Low'::text
            WHEN ((source_data.price >= (50)::numeric) AND (source_data.price <= (200)::numeric)) THEN 'Medium'::text
            WHEN ((source_data.price >= (200)::numeric) AND (source_data.price <= (500)::numeric)) THEN 'High'::text
            ELSE 'Premium'::text
        END AS price_tier,
    CURRENT_TIMESTAMP AS _loaded_at
   FROM source_data
  WHERE ((source_data.product_id IS NOT NULL) AND (source_data.product_name IS NOT NULL) AND (source_data.price IS NOT NULL) AND (source_data.price > (0)::numeric));


ALTER TABLE analytics_staging."-- Custom alias naming for modelsstg_products" OWNER TO dbt_staging_user;

--
-- Name: visits; Type: TABLE; Schema: raw; Owner: postgres
--

CREATE TABLE raw.visits (
    visit_id character varying(10) NOT NULL,
    customer_id integer,
    visit_date date,
    duration_minutes integer,
    pages_viewed integer
);


ALTER TABLE raw.visits OWNER TO postgres;

--
-- Name: TABLE visits; Type: COMMENT; Schema: raw; Owner: postgres
--

COMMENT ON TABLE raw.visits IS 'Website visit tracking data';


--
-- Name: -- Custom alias naming for modelsstg_visits; Type: VIEW; Schema: analytics_staging; Owner: dbt_staging_user
--

CREATE VIEW analytics_staging."-- Custom alias naming for modelsstg_visits" AS
 WITH source_data AS (
         SELECT visits.visit_id,
            visits.customer_id,
            visits.visit_date,
            visits.duration_minutes,
            visits.pages_viewed
           FROM raw.visits
        )
 SELECT source_data.visit_id,
    source_data.customer_id,
    source_data.visit_date,
    source_data.duration_minutes,
    source_data.pages_viewed,
        CASE
            WHEN (source_data.duration_minutes < 5) THEN 'Bounce'::text
            WHEN ((source_data.duration_minutes >= 5) AND (source_data.duration_minutes <= 15)) THEN 'Short'::text
            WHEN ((source_data.duration_minutes >= 15) AND (source_data.duration_minutes <= 30)) THEN 'Medium'::text
            ELSE 'Long'::text
        END AS session_type,
        CASE
            WHEN (source_data.pages_viewed = 1) THEN 'Single Page'::text
            WHEN ((source_data.pages_viewed >= 2) AND (source_data.pages_viewed <= 5)) THEN 'Browse'::text
            WHEN ((source_data.pages_viewed >= 6) AND (source_data.pages_viewed <= 10)) THEN 'Engaged'::text
            ELSE 'Deep Exploration'::text
        END AS engagement_level,
    EXTRACT(year FROM source_data.visit_date) AS visit_year,
    EXTRACT(month FROM source_data.visit_date) AS visit_month,
    CURRENT_TIMESTAMP AS _loaded_at
   FROM source_data
  WHERE ((source_data.visit_id IS NOT NULL) AND (source_data.customer_id IS NOT NULL) AND (source_data.visit_date IS NOT NULL) AND (source_data.duration_minutes >= 0) AND (source_data.pages_viewed > 0));


ALTER TABLE analytics_staging."-- Custom alias naming for modelsstg_visits" OWNER TO dbt_staging_user;

--
-- Data for Name: -- Custom alias naming for modelsdim_customers; Type: TABLE DATA; Schema: analytics_staging; Owner: dbt_staging_user
--

COPY analytics_staging."-- Custom alias naming for modelsdim_customers" (customer_id, first_name, last_name, full_name, email, registration_date, customer_segment, total_orders, total_spent, first_order_date, last_order_date, total_visits, total_duration_minutes, total_pages_viewed, first_visit_date, last_visit_date, conversion_rate_percent, avg_order_value, _loaded_at) FROM stdin;
\.


--
-- Data for Name: -- Custom alias naming for modelsdim_date; Type: TABLE DATA; Schema: analytics_staging; Owner: dbt_staging_user
--

COPY analytics_staging."-- Custom alias naming for modelsdim_date" (date_key, date_day, year, quarter, month, week_of_year, day_of_month, day_of_week, day_of_year, date_string, year_month, year_quarter, month_name, day_name, is_weekend, is_weekday, quarter_name, season, _loaded_at) FROM stdin;
2023-01-01 00:00:00	2023-01-01 00:00:00	2023	1	1	52	1	0	1	2023-01-01	2023-01	2023-1	January  	Sunday   	t	f	Q1	Winter	2025-07-29 12:25:04.696528-05
2023-01-02 00:00:00	2023-01-02 00:00:00	2023	1	1	1	2	1	2	2023-01-02	2023-01	2023-1	January  	Monday   	f	t	Q1	Winter	2025-07-29 12:25:04.696528-05
2023-01-03 00:00:00	2023-01-03 00:00:00	2023	1	1	1	3	2	3	2023-01-03	2023-01	2023-1	January  	Tuesday  	f	t	Q1	Winter	2025-07-29 12:25:04.696528-05
2023-01-04 00:00:00	2023-01-04 00:00:00	2023	1	1	1	4	3	4	2023-01-04	2023-01	2023-1	January  	Wednesday	f	t	Q1	Winter	2025-07-29 12:25:04.696528-05
2023-01-05 00:00:00	2023-01-05 00:00:00	2023	1	1	1	5	4	5	2023-01-05	2023-01	2023-1	January  	Thursday 	f	t	Q1	Winter	2025-07-29 12:25:04.696528-05
2023-01-06 00:00:00	2023-01-06 00:00:00	2023	1	1	1	6	5	6	2023-01-06	2023-01	2023-1	January  	Friday   	f	t	Q1	Winter	2025-07-29 12:25:04.696528-05
2023-01-07 00:00:00	2023-01-07 00:00:00	2023	1	1	1	7	6	7	2023-01-07	2023-01	2023-1	January  	Saturday 	t	f	Q1	Winter	2025-07-29 12:25:04.696528-05
2023-01-08 00:00:00	2023-01-08 00:00:00	2023	1	1	1	8	0	8	2023-01-08	2023-01	2023-1	January  	Sunday   	t	f	Q1	Winter	2025-07-29 12:25:04.696528-05
2023-01-09 00:00:00	2023-01-09 00:00:00	2023	1	1	2	9	1	9	2023-01-09	2023-01	2023-1	January  	Monday   	f	t	Q1	Winter	2025-07-29 12:25:04.696528-05
2023-01-10 00:00:00	2023-01-10 00:00:00	2023	1	1	2	10	2	10	2023-01-10	2023-01	2023-1	January  	Tuesday  	f	t	Q1	Winter	2025-07-29 12:25:04.696528-05
2023-01-11 00:00:00	2023-01-11 00:00:00	2023	1	1	2	11	3	11	2023-01-11	2023-01	2023-1	January  	Wednesday	f	t	Q1	Winter	2025-07-29 12:25:04.696528-05
2023-01-12 00:00:00	2023-01-12 00:00:00	2023	1	1	2	12	4	12	2023-01-12	2023-01	2023-1	January  	Thursday 	f	t	Q1	Winter	2025-07-29 12:25:04.696528-05
2023-01-13 00:00:00	2023-01-13 00:00:00	2023	1	1	2	13	5	13	2023-01-13	2023-01	2023-1	January  	Friday   	f	t	Q1	Winter	2025-07-29 12:25:04.696528-05
2023-01-14 00:00:00	2023-01-14 00:00:00	2023	1	1	2	14	6	14	2023-01-14	2023-01	2023-1	January  	Saturday 	t	f	Q1	Winter	2025-07-29 12:25:04.696528-05
2023-01-15 00:00:00	2023-01-15 00:00:00	2023	1	1	2	15	0	15	2023-01-15	2023-01	2023-1	January  	Sunday   	t	f	Q1	Winter	2025-07-29 12:25:04.696528-05
2023-01-16 00:00:00	2023-01-16 00:00:00	2023	1	1	3	16	1	16	2023-01-16	2023-01	2023-1	January  	Monday   	f	t	Q1	Winter	2025-07-29 12:25:04.696528-05
2023-01-17 00:00:00	2023-01-17 00:00:00	2023	1	1	3	17	2	17	2023-01-17	2023-01	2023-1	January  	Tuesday  	f	t	Q1	Winter	2025-07-29 12:25:04.696528-05
2023-01-18 00:00:00	2023-01-18 00:00:00	2023	1	1	3	18	3	18	2023-01-18	2023-01	2023-1	January  	Wednesday	f	t	Q1	Winter	2025-07-29 12:25:04.696528-05
2023-01-19 00:00:00	2023-01-19 00:00:00	2023	1	1	3	19	4	19	2023-01-19	2023-01	2023-1	January  	Thursday 	f	t	Q1	Winter	2025-07-29 12:25:04.696528-05
2023-01-20 00:00:00	2023-01-20 00:00:00	2023	1	1	3	20	5	20	2023-01-20	2023-01	2023-1	January  	Friday   	f	t	Q1	Winter	2025-07-29 12:25:04.696528-05
2023-01-21 00:00:00	2023-01-21 00:00:00	2023	1	1	3	21	6	21	2023-01-21	2023-01	2023-1	January  	Saturday 	t	f	Q1	Winter	2025-07-29 12:25:04.696528-05
2023-01-22 00:00:00	2023-01-22 00:00:00	2023	1	1	3	22	0	22	2023-01-22	2023-01	2023-1	January  	Sunday   	t	f	Q1	Winter	2025-07-29 12:25:04.696528-05
2023-01-23 00:00:00	2023-01-23 00:00:00	2023	1	1	4	23	1	23	2023-01-23	2023-01	2023-1	January  	Monday   	f	t	Q1	Winter	2025-07-29 12:25:04.696528-05
2023-01-24 00:00:00	2023-01-24 00:00:00	2023	1	1	4	24	2	24	2023-01-24	2023-01	2023-1	January  	Tuesday  	f	t	Q1	Winter	2025-07-29 12:25:04.696528-05
2023-01-25 00:00:00	2023-01-25 00:00:00	2023	1	1	4	25	3	25	2023-01-25	2023-01	2023-1	January  	Wednesday	f	t	Q1	Winter	2025-07-29 12:25:04.696528-05
2023-01-26 00:00:00	2023-01-26 00:00:00	2023	1	1	4	26	4	26	2023-01-26	2023-01	2023-1	January  	Thursday 	f	t	Q1	Winter	2025-07-29 12:25:04.696528-05
2023-01-27 00:00:00	2023-01-27 00:00:00	2023	1	1	4	27	5	27	2023-01-27	2023-01	2023-1	January  	Friday   	f	t	Q1	Winter	2025-07-29 12:25:04.696528-05
2023-01-28 00:00:00	2023-01-28 00:00:00	2023	1	1	4	28	6	28	2023-01-28	2023-01	2023-1	January  	Saturday 	t	f	Q1	Winter	2025-07-29 12:25:04.696528-05
2023-01-29 00:00:00	2023-01-29 00:00:00	2023	1	1	4	29	0	29	2023-01-29	2023-01	2023-1	January  	Sunday   	t	f	Q1	Winter	2025-07-29 12:25:04.696528-05
2023-01-30 00:00:00	2023-01-30 00:00:00	2023	1	1	5	30	1	30	2023-01-30	2023-01	2023-1	January  	Monday   	f	t	Q1	Winter	2025-07-29 12:25:04.696528-05
2023-01-31 00:00:00	2023-01-31 00:00:00	2023	1	1	5	31	2	31	2023-01-31	2023-01	2023-1	January  	Tuesday  	f	t	Q1	Winter	2025-07-29 12:25:04.696528-05
2023-02-01 00:00:00	2023-02-01 00:00:00	2023	1	2	5	1	3	32	2023-02-01	2023-02	2023-1	February 	Wednesday	f	t	Q1	Winter	2025-07-29 12:25:04.696528-05
2023-02-02 00:00:00	2023-02-02 00:00:00	2023	1	2	5	2	4	33	2023-02-02	2023-02	2023-1	February 	Thursday 	f	t	Q1	Winter	2025-07-29 12:25:04.696528-05
2023-02-03 00:00:00	2023-02-03 00:00:00	2023	1	2	5	3	5	34	2023-02-03	2023-02	2023-1	February 	Friday   	f	t	Q1	Winter	2025-07-29 12:25:04.696528-05
2023-02-04 00:00:00	2023-02-04 00:00:00	2023	1	2	5	4	6	35	2023-02-04	2023-02	2023-1	February 	Saturday 	t	f	Q1	Winter	2025-07-29 12:25:04.696528-05
2023-02-05 00:00:00	2023-02-05 00:00:00	2023	1	2	5	5	0	36	2023-02-05	2023-02	2023-1	February 	Sunday   	t	f	Q1	Winter	2025-07-29 12:25:04.696528-05
2023-02-06 00:00:00	2023-02-06 00:00:00	2023	1	2	6	6	1	37	2023-02-06	2023-02	2023-1	February 	Monday   	f	t	Q1	Winter	2025-07-29 12:25:04.696528-05
2023-02-07 00:00:00	2023-02-07 00:00:00	2023	1	2	6	7	2	38	2023-02-07	2023-02	2023-1	February 	Tuesday  	f	t	Q1	Winter	2025-07-29 12:25:04.696528-05
2023-02-08 00:00:00	2023-02-08 00:00:00	2023	1	2	6	8	3	39	2023-02-08	2023-02	2023-1	February 	Wednesday	f	t	Q1	Winter	2025-07-29 12:25:04.696528-05
2023-02-09 00:00:00	2023-02-09 00:00:00	2023	1	2	6	9	4	40	2023-02-09	2023-02	2023-1	February 	Thursday 	f	t	Q1	Winter	2025-07-29 12:25:04.696528-05
2023-02-10 00:00:00	2023-02-10 00:00:00	2023	1	2	6	10	5	41	2023-02-10	2023-02	2023-1	February 	Friday   	f	t	Q1	Winter	2025-07-29 12:25:04.696528-05
2023-02-11 00:00:00	2023-02-11 00:00:00	2023	1	2	6	11	6	42	2023-02-11	2023-02	2023-1	February 	Saturday 	t	f	Q1	Winter	2025-07-29 12:25:04.696528-05
2023-02-12 00:00:00	2023-02-12 00:00:00	2023	1	2	6	12	0	43	2023-02-12	2023-02	2023-1	February 	Sunday   	t	f	Q1	Winter	2025-07-29 12:25:04.696528-05
2023-02-13 00:00:00	2023-02-13 00:00:00	2023	1	2	7	13	1	44	2023-02-13	2023-02	2023-1	February 	Monday   	f	t	Q1	Winter	2025-07-29 12:25:04.696528-05
2023-02-14 00:00:00	2023-02-14 00:00:00	2023	1	2	7	14	2	45	2023-02-14	2023-02	2023-1	February 	Tuesday  	f	t	Q1	Winter	2025-07-29 12:25:04.696528-05
2023-02-15 00:00:00	2023-02-15 00:00:00	2023	1	2	7	15	3	46	2023-02-15	2023-02	2023-1	February 	Wednesday	f	t	Q1	Winter	2025-07-29 12:25:04.696528-05
2023-02-16 00:00:00	2023-02-16 00:00:00	2023	1	2	7	16	4	47	2023-02-16	2023-02	2023-1	February 	Thursday 	f	t	Q1	Winter	2025-07-29 12:25:04.696528-05
2023-02-17 00:00:00	2023-02-17 00:00:00	2023	1	2	7	17	5	48	2023-02-17	2023-02	2023-1	February 	Friday   	f	t	Q1	Winter	2025-07-29 12:25:04.696528-05
2023-02-18 00:00:00	2023-02-18 00:00:00	2023	1	2	7	18	6	49	2023-02-18	2023-02	2023-1	February 	Saturday 	t	f	Q1	Winter	2025-07-29 12:25:04.696528-05
2023-02-19 00:00:00	2023-02-19 00:00:00	2023	1	2	7	19	0	50	2023-02-19	2023-02	2023-1	February 	Sunday   	t	f	Q1	Winter	2025-07-29 12:25:04.696528-05
2023-02-20 00:00:00	2023-02-20 00:00:00	2023	1	2	8	20	1	51	2023-02-20	2023-02	2023-1	February 	Monday   	f	t	Q1	Winter	2025-07-29 12:25:04.696528-05
2023-02-21 00:00:00	2023-02-21 00:00:00	2023	1	2	8	21	2	52	2023-02-21	2023-02	2023-1	February 	Tuesday  	f	t	Q1	Winter	2025-07-29 12:25:04.696528-05
2023-02-22 00:00:00	2023-02-22 00:00:00	2023	1	2	8	22	3	53	2023-02-22	2023-02	2023-1	February 	Wednesday	f	t	Q1	Winter	2025-07-29 12:25:04.696528-05
2023-02-23 00:00:00	2023-02-23 00:00:00	2023	1	2	8	23	4	54	2023-02-23	2023-02	2023-1	February 	Thursday 	f	t	Q1	Winter	2025-07-29 12:25:04.696528-05
2023-02-24 00:00:00	2023-02-24 00:00:00	2023	1	2	8	24	5	55	2023-02-24	2023-02	2023-1	February 	Friday   	f	t	Q1	Winter	2025-07-29 12:25:04.696528-05
2023-02-25 00:00:00	2023-02-25 00:00:00	2023	1	2	8	25	6	56	2023-02-25	2023-02	2023-1	February 	Saturday 	t	f	Q1	Winter	2025-07-29 12:25:04.696528-05
2023-02-26 00:00:00	2023-02-26 00:00:00	2023	1	2	8	26	0	57	2023-02-26	2023-02	2023-1	February 	Sunday   	t	f	Q1	Winter	2025-07-29 12:25:04.696528-05
2023-02-27 00:00:00	2023-02-27 00:00:00	2023	1	2	9	27	1	58	2023-02-27	2023-02	2023-1	February 	Monday   	f	t	Q1	Winter	2025-07-29 12:25:04.696528-05
2023-02-28 00:00:00	2023-02-28 00:00:00	2023	1	2	9	28	2	59	2023-02-28	2023-02	2023-1	February 	Tuesday  	f	t	Q1	Winter	2025-07-29 12:25:04.696528-05
2023-03-01 00:00:00	2023-03-01 00:00:00	2023	1	3	9	1	3	60	2023-03-01	2023-03	2023-1	March    	Wednesday	f	t	Q1	Spring	2025-07-29 12:25:04.696528-05
2023-03-02 00:00:00	2023-03-02 00:00:00	2023	1	3	9	2	4	61	2023-03-02	2023-03	2023-1	March    	Thursday 	f	t	Q1	Spring	2025-07-29 12:25:04.696528-05
2023-03-03 00:00:00	2023-03-03 00:00:00	2023	1	3	9	3	5	62	2023-03-03	2023-03	2023-1	March    	Friday   	f	t	Q1	Spring	2025-07-29 12:25:04.696528-05
2023-03-04 00:00:00	2023-03-04 00:00:00	2023	1	3	9	4	6	63	2023-03-04	2023-03	2023-1	March    	Saturday 	t	f	Q1	Spring	2025-07-29 12:25:04.696528-05
2023-03-05 00:00:00	2023-03-05 00:00:00	2023	1	3	9	5	0	64	2023-03-05	2023-03	2023-1	March    	Sunday   	t	f	Q1	Spring	2025-07-29 12:25:04.696528-05
2023-03-06 00:00:00	2023-03-06 00:00:00	2023	1	3	10	6	1	65	2023-03-06	2023-03	2023-1	March    	Monday   	f	t	Q1	Spring	2025-07-29 12:25:04.696528-05
2023-03-07 00:00:00	2023-03-07 00:00:00	2023	1	3	10	7	2	66	2023-03-07	2023-03	2023-1	March    	Tuesday  	f	t	Q1	Spring	2025-07-29 12:25:04.696528-05
2023-03-08 00:00:00	2023-03-08 00:00:00	2023	1	3	10	8	3	67	2023-03-08	2023-03	2023-1	March    	Wednesday	f	t	Q1	Spring	2025-07-29 12:25:04.696528-05
2023-03-09 00:00:00	2023-03-09 00:00:00	2023	1	3	10	9	4	68	2023-03-09	2023-03	2023-1	March    	Thursday 	f	t	Q1	Spring	2025-07-29 12:25:04.696528-05
2023-03-10 00:00:00	2023-03-10 00:00:00	2023	1	3	10	10	5	69	2023-03-10	2023-03	2023-1	March    	Friday   	f	t	Q1	Spring	2025-07-29 12:25:04.696528-05
2023-03-11 00:00:00	2023-03-11 00:00:00	2023	1	3	10	11	6	70	2023-03-11	2023-03	2023-1	March    	Saturday 	t	f	Q1	Spring	2025-07-29 12:25:04.696528-05
2023-03-12 00:00:00	2023-03-12 00:00:00	2023	1	3	10	12	0	71	2023-03-12	2023-03	2023-1	March    	Sunday   	t	f	Q1	Spring	2025-07-29 12:25:04.696528-05
2023-03-13 00:00:00	2023-03-13 00:00:00	2023	1	3	11	13	1	72	2023-03-13	2023-03	2023-1	March    	Monday   	f	t	Q1	Spring	2025-07-29 12:25:04.696528-05
2023-03-14 00:00:00	2023-03-14 00:00:00	2023	1	3	11	14	2	73	2023-03-14	2023-03	2023-1	March    	Tuesday  	f	t	Q1	Spring	2025-07-29 12:25:04.696528-05
2023-03-15 00:00:00	2023-03-15 00:00:00	2023	1	3	11	15	3	74	2023-03-15	2023-03	2023-1	March    	Wednesday	f	t	Q1	Spring	2025-07-29 12:25:04.696528-05
2023-03-16 00:00:00	2023-03-16 00:00:00	2023	1	3	11	16	4	75	2023-03-16	2023-03	2023-1	March    	Thursday 	f	t	Q1	Spring	2025-07-29 12:25:04.696528-05
2023-03-17 00:00:00	2023-03-17 00:00:00	2023	1	3	11	17	5	76	2023-03-17	2023-03	2023-1	March    	Friday   	f	t	Q1	Spring	2025-07-29 12:25:04.696528-05
2023-03-18 00:00:00	2023-03-18 00:00:00	2023	1	3	11	18	6	77	2023-03-18	2023-03	2023-1	March    	Saturday 	t	f	Q1	Spring	2025-07-29 12:25:04.696528-05
2023-03-19 00:00:00	2023-03-19 00:00:00	2023	1	3	11	19	0	78	2023-03-19	2023-03	2023-1	March    	Sunday   	t	f	Q1	Spring	2025-07-29 12:25:04.696528-05
2023-03-20 00:00:00	2023-03-20 00:00:00	2023	1	3	12	20	1	79	2023-03-20	2023-03	2023-1	March    	Monday   	f	t	Q1	Spring	2025-07-29 12:25:04.696528-05
2023-03-21 00:00:00	2023-03-21 00:00:00	2023	1	3	12	21	2	80	2023-03-21	2023-03	2023-1	March    	Tuesday  	f	t	Q1	Spring	2025-07-29 12:25:04.696528-05
2023-03-22 00:00:00	2023-03-22 00:00:00	2023	1	3	12	22	3	81	2023-03-22	2023-03	2023-1	March    	Wednesday	f	t	Q1	Spring	2025-07-29 12:25:04.696528-05
2023-03-23 00:00:00	2023-03-23 00:00:00	2023	1	3	12	23	4	82	2023-03-23	2023-03	2023-1	March    	Thursday 	f	t	Q1	Spring	2025-07-29 12:25:04.696528-05
2023-03-24 00:00:00	2023-03-24 00:00:00	2023	1	3	12	24	5	83	2023-03-24	2023-03	2023-1	March    	Friday   	f	t	Q1	Spring	2025-07-29 12:25:04.696528-05
2023-03-25 00:00:00	2023-03-25 00:00:00	2023	1	3	12	25	6	84	2023-03-25	2023-03	2023-1	March    	Saturday 	t	f	Q1	Spring	2025-07-29 12:25:04.696528-05
2023-03-26 00:00:00	2023-03-26 00:00:00	2023	1	3	12	26	0	85	2023-03-26	2023-03	2023-1	March    	Sunday   	t	f	Q1	Spring	2025-07-29 12:25:04.696528-05
2023-03-27 00:00:00	2023-03-27 00:00:00	2023	1	3	13	27	1	86	2023-03-27	2023-03	2023-1	March    	Monday   	f	t	Q1	Spring	2025-07-29 12:25:04.696528-05
2023-03-28 00:00:00	2023-03-28 00:00:00	2023	1	3	13	28	2	87	2023-03-28	2023-03	2023-1	March    	Tuesday  	f	t	Q1	Spring	2025-07-29 12:25:04.696528-05
2023-03-29 00:00:00	2023-03-29 00:00:00	2023	1	3	13	29	3	88	2023-03-29	2023-03	2023-1	March    	Wednesday	f	t	Q1	Spring	2025-07-29 12:25:04.696528-05
2023-03-30 00:00:00	2023-03-30 00:00:00	2023	1	3	13	30	4	89	2023-03-30	2023-03	2023-1	March    	Thursday 	f	t	Q1	Spring	2025-07-29 12:25:04.696528-05
2023-03-31 00:00:00	2023-03-31 00:00:00	2023	1	3	13	31	5	90	2023-03-31	2023-03	2023-1	March    	Friday   	f	t	Q1	Spring	2025-07-29 12:25:04.696528-05
2023-04-01 00:00:00	2023-04-01 00:00:00	2023	2	4	13	1	6	91	2023-04-01	2023-04	2023-2	April    	Saturday 	t	f	Q2	Spring	2025-07-29 12:25:04.696528-05
2023-04-02 00:00:00	2023-04-02 00:00:00	2023	2	4	13	2	0	92	2023-04-02	2023-04	2023-2	April    	Sunday   	t	f	Q2	Spring	2025-07-29 12:25:04.696528-05
2023-04-03 00:00:00	2023-04-03 00:00:00	2023	2	4	14	3	1	93	2023-04-03	2023-04	2023-2	April    	Monday   	f	t	Q2	Spring	2025-07-29 12:25:04.696528-05
2023-04-04 00:00:00	2023-04-04 00:00:00	2023	2	4	14	4	2	94	2023-04-04	2023-04	2023-2	April    	Tuesday  	f	t	Q2	Spring	2025-07-29 12:25:04.696528-05
2023-04-05 00:00:00	2023-04-05 00:00:00	2023	2	4	14	5	3	95	2023-04-05	2023-04	2023-2	April    	Wednesday	f	t	Q2	Spring	2025-07-29 12:25:04.696528-05
2023-04-06 00:00:00	2023-04-06 00:00:00	2023	2	4	14	6	4	96	2023-04-06	2023-04	2023-2	April    	Thursday 	f	t	Q2	Spring	2025-07-29 12:25:04.696528-05
2023-04-07 00:00:00	2023-04-07 00:00:00	2023	2	4	14	7	5	97	2023-04-07	2023-04	2023-2	April    	Friday   	f	t	Q2	Spring	2025-07-29 12:25:04.696528-05
2023-04-08 00:00:00	2023-04-08 00:00:00	2023	2	4	14	8	6	98	2023-04-08	2023-04	2023-2	April    	Saturday 	t	f	Q2	Spring	2025-07-29 12:25:04.696528-05
2023-04-09 00:00:00	2023-04-09 00:00:00	2023	2	4	14	9	0	99	2023-04-09	2023-04	2023-2	April    	Sunday   	t	f	Q2	Spring	2025-07-29 12:25:04.696528-05
2023-04-10 00:00:00	2023-04-10 00:00:00	2023	2	4	15	10	1	100	2023-04-10	2023-04	2023-2	April    	Monday   	f	t	Q2	Spring	2025-07-29 12:25:04.696528-05
2023-04-11 00:00:00	2023-04-11 00:00:00	2023	2	4	15	11	2	101	2023-04-11	2023-04	2023-2	April    	Tuesday  	f	t	Q2	Spring	2025-07-29 12:25:04.696528-05
2023-04-12 00:00:00	2023-04-12 00:00:00	2023	2	4	15	12	3	102	2023-04-12	2023-04	2023-2	April    	Wednesday	f	t	Q2	Spring	2025-07-29 12:25:04.696528-05
2023-04-13 00:00:00	2023-04-13 00:00:00	2023	2	4	15	13	4	103	2023-04-13	2023-04	2023-2	April    	Thursday 	f	t	Q2	Spring	2025-07-29 12:25:04.696528-05
2023-04-14 00:00:00	2023-04-14 00:00:00	2023	2	4	15	14	5	104	2023-04-14	2023-04	2023-2	April    	Friday   	f	t	Q2	Spring	2025-07-29 12:25:04.696528-05
2023-04-15 00:00:00	2023-04-15 00:00:00	2023	2	4	15	15	6	105	2023-04-15	2023-04	2023-2	April    	Saturday 	t	f	Q2	Spring	2025-07-29 12:25:04.696528-05
2023-04-16 00:00:00	2023-04-16 00:00:00	2023	2	4	15	16	0	106	2023-04-16	2023-04	2023-2	April    	Sunday   	t	f	Q2	Spring	2025-07-29 12:25:04.696528-05
2023-04-17 00:00:00	2023-04-17 00:00:00	2023	2	4	16	17	1	107	2023-04-17	2023-04	2023-2	April    	Monday   	f	t	Q2	Spring	2025-07-29 12:25:04.696528-05
2023-04-18 00:00:00	2023-04-18 00:00:00	2023	2	4	16	18	2	108	2023-04-18	2023-04	2023-2	April    	Tuesday  	f	t	Q2	Spring	2025-07-29 12:25:04.696528-05
2023-04-19 00:00:00	2023-04-19 00:00:00	2023	2	4	16	19	3	109	2023-04-19	2023-04	2023-2	April    	Wednesday	f	t	Q2	Spring	2025-07-29 12:25:04.696528-05
2023-04-20 00:00:00	2023-04-20 00:00:00	2023	2	4	16	20	4	110	2023-04-20	2023-04	2023-2	April    	Thursday 	f	t	Q2	Spring	2025-07-29 12:25:04.696528-05
2023-04-21 00:00:00	2023-04-21 00:00:00	2023	2	4	16	21	5	111	2023-04-21	2023-04	2023-2	April    	Friday   	f	t	Q2	Spring	2025-07-29 12:25:04.696528-05
2023-04-22 00:00:00	2023-04-22 00:00:00	2023	2	4	16	22	6	112	2023-04-22	2023-04	2023-2	April    	Saturday 	t	f	Q2	Spring	2025-07-29 12:25:04.696528-05
2023-04-23 00:00:00	2023-04-23 00:00:00	2023	2	4	16	23	0	113	2023-04-23	2023-04	2023-2	April    	Sunday   	t	f	Q2	Spring	2025-07-29 12:25:04.696528-05
2023-04-24 00:00:00	2023-04-24 00:00:00	2023	2	4	17	24	1	114	2023-04-24	2023-04	2023-2	April    	Monday   	f	t	Q2	Spring	2025-07-29 12:25:04.696528-05
2023-04-25 00:00:00	2023-04-25 00:00:00	2023	2	4	17	25	2	115	2023-04-25	2023-04	2023-2	April    	Tuesday  	f	t	Q2	Spring	2025-07-29 12:25:04.696528-05
2023-04-26 00:00:00	2023-04-26 00:00:00	2023	2	4	17	26	3	116	2023-04-26	2023-04	2023-2	April    	Wednesday	f	t	Q2	Spring	2025-07-29 12:25:04.696528-05
2023-04-27 00:00:00	2023-04-27 00:00:00	2023	2	4	17	27	4	117	2023-04-27	2023-04	2023-2	April    	Thursday 	f	t	Q2	Spring	2025-07-29 12:25:04.696528-05
2023-04-28 00:00:00	2023-04-28 00:00:00	2023	2	4	17	28	5	118	2023-04-28	2023-04	2023-2	April    	Friday   	f	t	Q2	Spring	2025-07-29 12:25:04.696528-05
2023-04-29 00:00:00	2023-04-29 00:00:00	2023	2	4	17	29	6	119	2023-04-29	2023-04	2023-2	April    	Saturday 	t	f	Q2	Spring	2025-07-29 12:25:04.696528-05
2023-04-30 00:00:00	2023-04-30 00:00:00	2023	2	4	17	30	0	120	2023-04-30	2023-04	2023-2	April    	Sunday   	t	f	Q2	Spring	2025-07-29 12:25:04.696528-05
2023-05-01 00:00:00	2023-05-01 00:00:00	2023	2	5	18	1	1	121	2023-05-01	2023-05	2023-2	May      	Monday   	f	t	Q2	Spring	2025-07-29 12:25:04.696528-05
2023-05-02 00:00:00	2023-05-02 00:00:00	2023	2	5	18	2	2	122	2023-05-02	2023-05	2023-2	May      	Tuesday  	f	t	Q2	Spring	2025-07-29 12:25:04.696528-05
2023-05-03 00:00:00	2023-05-03 00:00:00	2023	2	5	18	3	3	123	2023-05-03	2023-05	2023-2	May      	Wednesday	f	t	Q2	Spring	2025-07-29 12:25:04.696528-05
2023-05-04 00:00:00	2023-05-04 00:00:00	2023	2	5	18	4	4	124	2023-05-04	2023-05	2023-2	May      	Thursday 	f	t	Q2	Spring	2025-07-29 12:25:04.696528-05
2023-05-05 00:00:00	2023-05-05 00:00:00	2023	2	5	18	5	5	125	2023-05-05	2023-05	2023-2	May      	Friday   	f	t	Q2	Spring	2025-07-29 12:25:04.696528-05
2023-05-06 00:00:00	2023-05-06 00:00:00	2023	2	5	18	6	6	126	2023-05-06	2023-05	2023-2	May      	Saturday 	t	f	Q2	Spring	2025-07-29 12:25:04.696528-05
2023-05-07 00:00:00	2023-05-07 00:00:00	2023	2	5	18	7	0	127	2023-05-07	2023-05	2023-2	May      	Sunday   	t	f	Q2	Spring	2025-07-29 12:25:04.696528-05
2023-05-08 00:00:00	2023-05-08 00:00:00	2023	2	5	19	8	1	128	2023-05-08	2023-05	2023-2	May      	Monday   	f	t	Q2	Spring	2025-07-29 12:25:04.696528-05
2023-05-09 00:00:00	2023-05-09 00:00:00	2023	2	5	19	9	2	129	2023-05-09	2023-05	2023-2	May      	Tuesday  	f	t	Q2	Spring	2025-07-29 12:25:04.696528-05
2023-05-10 00:00:00	2023-05-10 00:00:00	2023	2	5	19	10	3	130	2023-05-10	2023-05	2023-2	May      	Wednesday	f	t	Q2	Spring	2025-07-29 12:25:04.696528-05
2023-05-11 00:00:00	2023-05-11 00:00:00	2023	2	5	19	11	4	131	2023-05-11	2023-05	2023-2	May      	Thursday 	f	t	Q2	Spring	2025-07-29 12:25:04.696528-05
2023-05-12 00:00:00	2023-05-12 00:00:00	2023	2	5	19	12	5	132	2023-05-12	2023-05	2023-2	May      	Friday   	f	t	Q2	Spring	2025-07-29 12:25:04.696528-05
2023-05-13 00:00:00	2023-05-13 00:00:00	2023	2	5	19	13	6	133	2023-05-13	2023-05	2023-2	May      	Saturday 	t	f	Q2	Spring	2025-07-29 12:25:04.696528-05
2023-05-14 00:00:00	2023-05-14 00:00:00	2023	2	5	19	14	0	134	2023-05-14	2023-05	2023-2	May      	Sunday   	t	f	Q2	Spring	2025-07-29 12:25:04.696528-05
2023-05-15 00:00:00	2023-05-15 00:00:00	2023	2	5	20	15	1	135	2023-05-15	2023-05	2023-2	May      	Monday   	f	t	Q2	Spring	2025-07-29 12:25:04.696528-05
2023-05-16 00:00:00	2023-05-16 00:00:00	2023	2	5	20	16	2	136	2023-05-16	2023-05	2023-2	May      	Tuesday  	f	t	Q2	Spring	2025-07-29 12:25:04.696528-05
2023-05-17 00:00:00	2023-05-17 00:00:00	2023	2	5	20	17	3	137	2023-05-17	2023-05	2023-2	May      	Wednesday	f	t	Q2	Spring	2025-07-29 12:25:04.696528-05
2023-05-18 00:00:00	2023-05-18 00:00:00	2023	2	5	20	18	4	138	2023-05-18	2023-05	2023-2	May      	Thursday 	f	t	Q2	Spring	2025-07-29 12:25:04.696528-05
2023-05-19 00:00:00	2023-05-19 00:00:00	2023	2	5	20	19	5	139	2023-05-19	2023-05	2023-2	May      	Friday   	f	t	Q2	Spring	2025-07-29 12:25:04.696528-05
2023-05-20 00:00:00	2023-05-20 00:00:00	2023	2	5	20	20	6	140	2023-05-20	2023-05	2023-2	May      	Saturday 	t	f	Q2	Spring	2025-07-29 12:25:04.696528-05
2023-05-21 00:00:00	2023-05-21 00:00:00	2023	2	5	20	21	0	141	2023-05-21	2023-05	2023-2	May      	Sunday   	t	f	Q2	Spring	2025-07-29 12:25:04.696528-05
2023-05-22 00:00:00	2023-05-22 00:00:00	2023	2	5	21	22	1	142	2023-05-22	2023-05	2023-2	May      	Monday   	f	t	Q2	Spring	2025-07-29 12:25:04.696528-05
2023-05-23 00:00:00	2023-05-23 00:00:00	2023	2	5	21	23	2	143	2023-05-23	2023-05	2023-2	May      	Tuesday  	f	t	Q2	Spring	2025-07-29 12:25:04.696528-05
2023-05-24 00:00:00	2023-05-24 00:00:00	2023	2	5	21	24	3	144	2023-05-24	2023-05	2023-2	May      	Wednesday	f	t	Q2	Spring	2025-07-29 12:25:04.696528-05
2023-05-25 00:00:00	2023-05-25 00:00:00	2023	2	5	21	25	4	145	2023-05-25	2023-05	2023-2	May      	Thursday 	f	t	Q2	Spring	2025-07-29 12:25:04.696528-05
2023-05-26 00:00:00	2023-05-26 00:00:00	2023	2	5	21	26	5	146	2023-05-26	2023-05	2023-2	May      	Friday   	f	t	Q2	Spring	2025-07-29 12:25:04.696528-05
2023-05-27 00:00:00	2023-05-27 00:00:00	2023	2	5	21	27	6	147	2023-05-27	2023-05	2023-2	May      	Saturday 	t	f	Q2	Spring	2025-07-29 12:25:04.696528-05
2023-05-28 00:00:00	2023-05-28 00:00:00	2023	2	5	21	28	0	148	2023-05-28	2023-05	2023-2	May      	Sunday   	t	f	Q2	Spring	2025-07-29 12:25:04.696528-05
2023-05-29 00:00:00	2023-05-29 00:00:00	2023	2	5	22	29	1	149	2023-05-29	2023-05	2023-2	May      	Monday   	f	t	Q2	Spring	2025-07-29 12:25:04.696528-05
2023-05-30 00:00:00	2023-05-30 00:00:00	2023	2	5	22	30	2	150	2023-05-30	2023-05	2023-2	May      	Tuesday  	f	t	Q2	Spring	2025-07-29 12:25:04.696528-05
2023-05-31 00:00:00	2023-05-31 00:00:00	2023	2	5	22	31	3	151	2023-05-31	2023-05	2023-2	May      	Wednesday	f	t	Q2	Spring	2025-07-29 12:25:04.696528-05
2023-06-01 00:00:00	2023-06-01 00:00:00	2023	2	6	22	1	4	152	2023-06-01	2023-06	2023-2	June     	Thursday 	f	t	Q2	Summer	2025-07-29 12:25:04.696528-05
2023-06-02 00:00:00	2023-06-02 00:00:00	2023	2	6	22	2	5	153	2023-06-02	2023-06	2023-2	June     	Friday   	f	t	Q2	Summer	2025-07-29 12:25:04.696528-05
2023-06-03 00:00:00	2023-06-03 00:00:00	2023	2	6	22	3	6	154	2023-06-03	2023-06	2023-2	June     	Saturday 	t	f	Q2	Summer	2025-07-29 12:25:04.696528-05
2023-06-04 00:00:00	2023-06-04 00:00:00	2023	2	6	22	4	0	155	2023-06-04	2023-06	2023-2	June     	Sunday   	t	f	Q2	Summer	2025-07-29 12:25:04.696528-05
2023-06-05 00:00:00	2023-06-05 00:00:00	2023	2	6	23	5	1	156	2023-06-05	2023-06	2023-2	June     	Monday   	f	t	Q2	Summer	2025-07-29 12:25:04.696528-05
2023-06-06 00:00:00	2023-06-06 00:00:00	2023	2	6	23	6	2	157	2023-06-06	2023-06	2023-2	June     	Tuesday  	f	t	Q2	Summer	2025-07-29 12:25:04.696528-05
2023-06-07 00:00:00	2023-06-07 00:00:00	2023	2	6	23	7	3	158	2023-06-07	2023-06	2023-2	June     	Wednesday	f	t	Q2	Summer	2025-07-29 12:25:04.696528-05
2023-06-08 00:00:00	2023-06-08 00:00:00	2023	2	6	23	8	4	159	2023-06-08	2023-06	2023-2	June     	Thursday 	f	t	Q2	Summer	2025-07-29 12:25:04.696528-05
2023-06-09 00:00:00	2023-06-09 00:00:00	2023	2	6	23	9	5	160	2023-06-09	2023-06	2023-2	June     	Friday   	f	t	Q2	Summer	2025-07-29 12:25:04.696528-05
2023-06-10 00:00:00	2023-06-10 00:00:00	2023	2	6	23	10	6	161	2023-06-10	2023-06	2023-2	June     	Saturday 	t	f	Q2	Summer	2025-07-29 12:25:04.696528-05
2023-06-11 00:00:00	2023-06-11 00:00:00	2023	2	6	23	11	0	162	2023-06-11	2023-06	2023-2	June     	Sunday   	t	f	Q2	Summer	2025-07-29 12:25:04.696528-05
2023-06-12 00:00:00	2023-06-12 00:00:00	2023	2	6	24	12	1	163	2023-06-12	2023-06	2023-2	June     	Monday   	f	t	Q2	Summer	2025-07-29 12:25:04.696528-05
2023-06-13 00:00:00	2023-06-13 00:00:00	2023	2	6	24	13	2	164	2023-06-13	2023-06	2023-2	June     	Tuesday  	f	t	Q2	Summer	2025-07-29 12:25:04.696528-05
2023-06-14 00:00:00	2023-06-14 00:00:00	2023	2	6	24	14	3	165	2023-06-14	2023-06	2023-2	June     	Wednesday	f	t	Q2	Summer	2025-07-29 12:25:04.696528-05
2023-06-15 00:00:00	2023-06-15 00:00:00	2023	2	6	24	15	4	166	2023-06-15	2023-06	2023-2	June     	Thursday 	f	t	Q2	Summer	2025-07-29 12:25:04.696528-05
2023-06-16 00:00:00	2023-06-16 00:00:00	2023	2	6	24	16	5	167	2023-06-16	2023-06	2023-2	June     	Friday   	f	t	Q2	Summer	2025-07-29 12:25:04.696528-05
2023-06-17 00:00:00	2023-06-17 00:00:00	2023	2	6	24	17	6	168	2023-06-17	2023-06	2023-2	June     	Saturday 	t	f	Q2	Summer	2025-07-29 12:25:04.696528-05
2023-06-18 00:00:00	2023-06-18 00:00:00	2023	2	6	24	18	0	169	2023-06-18	2023-06	2023-2	June     	Sunday   	t	f	Q2	Summer	2025-07-29 12:25:04.696528-05
2023-06-19 00:00:00	2023-06-19 00:00:00	2023	2	6	25	19	1	170	2023-06-19	2023-06	2023-2	June     	Monday   	f	t	Q2	Summer	2025-07-29 12:25:04.696528-05
2023-06-20 00:00:00	2023-06-20 00:00:00	2023	2	6	25	20	2	171	2023-06-20	2023-06	2023-2	June     	Tuesday  	f	t	Q2	Summer	2025-07-29 12:25:04.696528-05
2023-06-21 00:00:00	2023-06-21 00:00:00	2023	2	6	25	21	3	172	2023-06-21	2023-06	2023-2	June     	Wednesday	f	t	Q2	Summer	2025-07-29 12:25:04.696528-05
2023-06-22 00:00:00	2023-06-22 00:00:00	2023	2	6	25	22	4	173	2023-06-22	2023-06	2023-2	June     	Thursday 	f	t	Q2	Summer	2025-07-29 12:25:04.696528-05
2023-06-23 00:00:00	2023-06-23 00:00:00	2023	2	6	25	23	5	174	2023-06-23	2023-06	2023-2	June     	Friday   	f	t	Q2	Summer	2025-07-29 12:25:04.696528-05
2023-06-24 00:00:00	2023-06-24 00:00:00	2023	2	6	25	24	6	175	2023-06-24	2023-06	2023-2	June     	Saturday 	t	f	Q2	Summer	2025-07-29 12:25:04.696528-05
2023-06-25 00:00:00	2023-06-25 00:00:00	2023	2	6	25	25	0	176	2023-06-25	2023-06	2023-2	June     	Sunday   	t	f	Q2	Summer	2025-07-29 12:25:04.696528-05
2023-06-26 00:00:00	2023-06-26 00:00:00	2023	2	6	26	26	1	177	2023-06-26	2023-06	2023-2	June     	Monday   	f	t	Q2	Summer	2025-07-29 12:25:04.696528-05
2023-06-27 00:00:00	2023-06-27 00:00:00	2023	2	6	26	27	2	178	2023-06-27	2023-06	2023-2	June     	Tuesday  	f	t	Q2	Summer	2025-07-29 12:25:04.696528-05
2023-06-28 00:00:00	2023-06-28 00:00:00	2023	2	6	26	28	3	179	2023-06-28	2023-06	2023-2	June     	Wednesday	f	t	Q2	Summer	2025-07-29 12:25:04.696528-05
2023-06-29 00:00:00	2023-06-29 00:00:00	2023	2	6	26	29	4	180	2023-06-29	2023-06	2023-2	June     	Thursday 	f	t	Q2	Summer	2025-07-29 12:25:04.696528-05
2023-06-30 00:00:00	2023-06-30 00:00:00	2023	2	6	26	30	5	181	2023-06-30	2023-06	2023-2	June     	Friday   	f	t	Q2	Summer	2025-07-29 12:25:04.696528-05
2023-07-01 00:00:00	2023-07-01 00:00:00	2023	3	7	26	1	6	182	2023-07-01	2023-07	2023-3	July     	Saturday 	t	f	Q3	Summer	2025-07-29 12:25:04.696528-05
2023-07-02 00:00:00	2023-07-02 00:00:00	2023	3	7	26	2	0	183	2023-07-02	2023-07	2023-3	July     	Sunday   	t	f	Q3	Summer	2025-07-29 12:25:04.696528-05
2023-07-03 00:00:00	2023-07-03 00:00:00	2023	3	7	27	3	1	184	2023-07-03	2023-07	2023-3	July     	Monday   	f	t	Q3	Summer	2025-07-29 12:25:04.696528-05
2023-07-04 00:00:00	2023-07-04 00:00:00	2023	3	7	27	4	2	185	2023-07-04	2023-07	2023-3	July     	Tuesday  	f	t	Q3	Summer	2025-07-29 12:25:04.696528-05
2023-07-05 00:00:00	2023-07-05 00:00:00	2023	3	7	27	5	3	186	2023-07-05	2023-07	2023-3	July     	Wednesday	f	t	Q3	Summer	2025-07-29 12:25:04.696528-05
2023-07-06 00:00:00	2023-07-06 00:00:00	2023	3	7	27	6	4	187	2023-07-06	2023-07	2023-3	July     	Thursday 	f	t	Q3	Summer	2025-07-29 12:25:04.696528-05
2023-07-07 00:00:00	2023-07-07 00:00:00	2023	3	7	27	7	5	188	2023-07-07	2023-07	2023-3	July     	Friday   	f	t	Q3	Summer	2025-07-29 12:25:04.696528-05
2023-07-08 00:00:00	2023-07-08 00:00:00	2023	3	7	27	8	6	189	2023-07-08	2023-07	2023-3	July     	Saturday 	t	f	Q3	Summer	2025-07-29 12:25:04.696528-05
2023-07-09 00:00:00	2023-07-09 00:00:00	2023	3	7	27	9	0	190	2023-07-09	2023-07	2023-3	July     	Sunday   	t	f	Q3	Summer	2025-07-29 12:25:04.696528-05
2023-07-10 00:00:00	2023-07-10 00:00:00	2023	3	7	28	10	1	191	2023-07-10	2023-07	2023-3	July     	Monday   	f	t	Q3	Summer	2025-07-29 12:25:04.696528-05
2023-07-11 00:00:00	2023-07-11 00:00:00	2023	3	7	28	11	2	192	2023-07-11	2023-07	2023-3	July     	Tuesday  	f	t	Q3	Summer	2025-07-29 12:25:04.696528-05
2023-07-12 00:00:00	2023-07-12 00:00:00	2023	3	7	28	12	3	193	2023-07-12	2023-07	2023-3	July     	Wednesday	f	t	Q3	Summer	2025-07-29 12:25:04.696528-05
2023-07-13 00:00:00	2023-07-13 00:00:00	2023	3	7	28	13	4	194	2023-07-13	2023-07	2023-3	July     	Thursday 	f	t	Q3	Summer	2025-07-29 12:25:04.696528-05
2023-07-14 00:00:00	2023-07-14 00:00:00	2023	3	7	28	14	5	195	2023-07-14	2023-07	2023-3	July     	Friday   	f	t	Q3	Summer	2025-07-29 12:25:04.696528-05
2023-07-15 00:00:00	2023-07-15 00:00:00	2023	3	7	28	15	6	196	2023-07-15	2023-07	2023-3	July     	Saturday 	t	f	Q3	Summer	2025-07-29 12:25:04.696528-05
2023-07-16 00:00:00	2023-07-16 00:00:00	2023	3	7	28	16	0	197	2023-07-16	2023-07	2023-3	July     	Sunday   	t	f	Q3	Summer	2025-07-29 12:25:04.696528-05
2023-07-17 00:00:00	2023-07-17 00:00:00	2023	3	7	29	17	1	198	2023-07-17	2023-07	2023-3	July     	Monday   	f	t	Q3	Summer	2025-07-29 12:25:04.696528-05
2023-07-18 00:00:00	2023-07-18 00:00:00	2023	3	7	29	18	2	199	2023-07-18	2023-07	2023-3	July     	Tuesday  	f	t	Q3	Summer	2025-07-29 12:25:04.696528-05
2023-07-19 00:00:00	2023-07-19 00:00:00	2023	3	7	29	19	3	200	2023-07-19	2023-07	2023-3	July     	Wednesday	f	t	Q3	Summer	2025-07-29 12:25:04.696528-05
2023-07-20 00:00:00	2023-07-20 00:00:00	2023	3	7	29	20	4	201	2023-07-20	2023-07	2023-3	July     	Thursday 	f	t	Q3	Summer	2025-07-29 12:25:04.696528-05
2023-07-21 00:00:00	2023-07-21 00:00:00	2023	3	7	29	21	5	202	2023-07-21	2023-07	2023-3	July     	Friday   	f	t	Q3	Summer	2025-07-29 12:25:04.696528-05
2023-07-22 00:00:00	2023-07-22 00:00:00	2023	3	7	29	22	6	203	2023-07-22	2023-07	2023-3	July     	Saturday 	t	f	Q3	Summer	2025-07-29 12:25:04.696528-05
2023-07-23 00:00:00	2023-07-23 00:00:00	2023	3	7	29	23	0	204	2023-07-23	2023-07	2023-3	July     	Sunday   	t	f	Q3	Summer	2025-07-29 12:25:04.696528-05
2023-07-24 00:00:00	2023-07-24 00:00:00	2023	3	7	30	24	1	205	2023-07-24	2023-07	2023-3	July     	Monday   	f	t	Q3	Summer	2025-07-29 12:25:04.696528-05
2023-07-25 00:00:00	2023-07-25 00:00:00	2023	3	7	30	25	2	206	2023-07-25	2023-07	2023-3	July     	Tuesday  	f	t	Q3	Summer	2025-07-29 12:25:04.696528-05
2023-07-26 00:00:00	2023-07-26 00:00:00	2023	3	7	30	26	3	207	2023-07-26	2023-07	2023-3	July     	Wednesday	f	t	Q3	Summer	2025-07-29 12:25:04.696528-05
2023-07-27 00:00:00	2023-07-27 00:00:00	2023	3	7	30	27	4	208	2023-07-27	2023-07	2023-3	July     	Thursday 	f	t	Q3	Summer	2025-07-29 12:25:04.696528-05
2023-07-28 00:00:00	2023-07-28 00:00:00	2023	3	7	30	28	5	209	2023-07-28	2023-07	2023-3	July     	Friday   	f	t	Q3	Summer	2025-07-29 12:25:04.696528-05
2023-07-29 00:00:00	2023-07-29 00:00:00	2023	3	7	30	29	6	210	2023-07-29	2023-07	2023-3	July     	Saturday 	t	f	Q3	Summer	2025-07-29 12:25:04.696528-05
2023-07-30 00:00:00	2023-07-30 00:00:00	2023	3	7	30	30	0	211	2023-07-30	2023-07	2023-3	July     	Sunday   	t	f	Q3	Summer	2025-07-29 12:25:04.696528-05
2023-07-31 00:00:00	2023-07-31 00:00:00	2023	3	7	31	31	1	212	2023-07-31	2023-07	2023-3	July     	Monday   	f	t	Q3	Summer	2025-07-29 12:25:04.696528-05
2023-08-01 00:00:00	2023-08-01 00:00:00	2023	3	8	31	1	2	213	2023-08-01	2023-08	2023-3	August   	Tuesday  	f	t	Q3	Summer	2025-07-29 12:25:04.696528-05
2023-08-02 00:00:00	2023-08-02 00:00:00	2023	3	8	31	2	3	214	2023-08-02	2023-08	2023-3	August   	Wednesday	f	t	Q3	Summer	2025-07-29 12:25:04.696528-05
2023-08-03 00:00:00	2023-08-03 00:00:00	2023	3	8	31	3	4	215	2023-08-03	2023-08	2023-3	August   	Thursday 	f	t	Q3	Summer	2025-07-29 12:25:04.696528-05
2023-08-04 00:00:00	2023-08-04 00:00:00	2023	3	8	31	4	5	216	2023-08-04	2023-08	2023-3	August   	Friday   	f	t	Q3	Summer	2025-07-29 12:25:04.696528-05
2023-08-05 00:00:00	2023-08-05 00:00:00	2023	3	8	31	5	6	217	2023-08-05	2023-08	2023-3	August   	Saturday 	t	f	Q3	Summer	2025-07-29 12:25:04.696528-05
2023-08-06 00:00:00	2023-08-06 00:00:00	2023	3	8	31	6	0	218	2023-08-06	2023-08	2023-3	August   	Sunday   	t	f	Q3	Summer	2025-07-29 12:25:04.696528-05
2023-08-07 00:00:00	2023-08-07 00:00:00	2023	3	8	32	7	1	219	2023-08-07	2023-08	2023-3	August   	Monday   	f	t	Q3	Summer	2025-07-29 12:25:04.696528-05
2023-08-08 00:00:00	2023-08-08 00:00:00	2023	3	8	32	8	2	220	2023-08-08	2023-08	2023-3	August   	Tuesday  	f	t	Q3	Summer	2025-07-29 12:25:04.696528-05
2023-08-09 00:00:00	2023-08-09 00:00:00	2023	3	8	32	9	3	221	2023-08-09	2023-08	2023-3	August   	Wednesday	f	t	Q3	Summer	2025-07-29 12:25:04.696528-05
2023-08-10 00:00:00	2023-08-10 00:00:00	2023	3	8	32	10	4	222	2023-08-10	2023-08	2023-3	August   	Thursday 	f	t	Q3	Summer	2025-07-29 12:25:04.696528-05
2023-08-11 00:00:00	2023-08-11 00:00:00	2023	3	8	32	11	5	223	2023-08-11	2023-08	2023-3	August   	Friday   	f	t	Q3	Summer	2025-07-29 12:25:04.696528-05
2023-08-12 00:00:00	2023-08-12 00:00:00	2023	3	8	32	12	6	224	2023-08-12	2023-08	2023-3	August   	Saturday 	t	f	Q3	Summer	2025-07-29 12:25:04.696528-05
2023-08-13 00:00:00	2023-08-13 00:00:00	2023	3	8	32	13	0	225	2023-08-13	2023-08	2023-3	August   	Sunday   	t	f	Q3	Summer	2025-07-29 12:25:04.696528-05
2023-08-14 00:00:00	2023-08-14 00:00:00	2023	3	8	33	14	1	226	2023-08-14	2023-08	2023-3	August   	Monday   	f	t	Q3	Summer	2025-07-29 12:25:04.696528-05
2023-08-15 00:00:00	2023-08-15 00:00:00	2023	3	8	33	15	2	227	2023-08-15	2023-08	2023-3	August   	Tuesday  	f	t	Q3	Summer	2025-07-29 12:25:04.696528-05
2023-08-16 00:00:00	2023-08-16 00:00:00	2023	3	8	33	16	3	228	2023-08-16	2023-08	2023-3	August   	Wednesday	f	t	Q3	Summer	2025-07-29 12:25:04.696528-05
2023-08-17 00:00:00	2023-08-17 00:00:00	2023	3	8	33	17	4	229	2023-08-17	2023-08	2023-3	August   	Thursday 	f	t	Q3	Summer	2025-07-29 12:25:04.696528-05
2023-08-18 00:00:00	2023-08-18 00:00:00	2023	3	8	33	18	5	230	2023-08-18	2023-08	2023-3	August   	Friday   	f	t	Q3	Summer	2025-07-29 12:25:04.696528-05
2023-08-19 00:00:00	2023-08-19 00:00:00	2023	3	8	33	19	6	231	2023-08-19	2023-08	2023-3	August   	Saturday 	t	f	Q3	Summer	2025-07-29 12:25:04.696528-05
2023-08-20 00:00:00	2023-08-20 00:00:00	2023	3	8	33	20	0	232	2023-08-20	2023-08	2023-3	August   	Sunday   	t	f	Q3	Summer	2025-07-29 12:25:04.696528-05
2023-08-21 00:00:00	2023-08-21 00:00:00	2023	3	8	34	21	1	233	2023-08-21	2023-08	2023-3	August   	Monday   	f	t	Q3	Summer	2025-07-29 12:25:04.696528-05
2023-08-22 00:00:00	2023-08-22 00:00:00	2023	3	8	34	22	2	234	2023-08-22	2023-08	2023-3	August   	Tuesday  	f	t	Q3	Summer	2025-07-29 12:25:04.696528-05
2023-08-23 00:00:00	2023-08-23 00:00:00	2023	3	8	34	23	3	235	2023-08-23	2023-08	2023-3	August   	Wednesday	f	t	Q3	Summer	2025-07-29 12:25:04.696528-05
2023-08-24 00:00:00	2023-08-24 00:00:00	2023	3	8	34	24	4	236	2023-08-24	2023-08	2023-3	August   	Thursday 	f	t	Q3	Summer	2025-07-29 12:25:04.696528-05
2023-08-25 00:00:00	2023-08-25 00:00:00	2023	3	8	34	25	5	237	2023-08-25	2023-08	2023-3	August   	Friday   	f	t	Q3	Summer	2025-07-29 12:25:04.696528-05
2023-08-26 00:00:00	2023-08-26 00:00:00	2023	3	8	34	26	6	238	2023-08-26	2023-08	2023-3	August   	Saturday 	t	f	Q3	Summer	2025-07-29 12:25:04.696528-05
2023-08-27 00:00:00	2023-08-27 00:00:00	2023	3	8	34	27	0	239	2023-08-27	2023-08	2023-3	August   	Sunday   	t	f	Q3	Summer	2025-07-29 12:25:04.696528-05
2023-08-28 00:00:00	2023-08-28 00:00:00	2023	3	8	35	28	1	240	2023-08-28	2023-08	2023-3	August   	Monday   	f	t	Q3	Summer	2025-07-29 12:25:04.696528-05
2023-08-29 00:00:00	2023-08-29 00:00:00	2023	3	8	35	29	2	241	2023-08-29	2023-08	2023-3	August   	Tuesday  	f	t	Q3	Summer	2025-07-29 12:25:04.696528-05
2023-08-30 00:00:00	2023-08-30 00:00:00	2023	3	8	35	30	3	242	2023-08-30	2023-08	2023-3	August   	Wednesday	f	t	Q3	Summer	2025-07-29 12:25:04.696528-05
2023-08-31 00:00:00	2023-08-31 00:00:00	2023	3	8	35	31	4	243	2023-08-31	2023-08	2023-3	August   	Thursday 	f	t	Q3	Summer	2025-07-29 12:25:04.696528-05
2023-09-01 00:00:00	2023-09-01 00:00:00	2023	3	9	35	1	5	244	2023-09-01	2023-09	2023-3	September	Friday   	f	t	Q3	Fall	2025-07-29 12:25:04.696528-05
2023-09-02 00:00:00	2023-09-02 00:00:00	2023	3	9	35	2	6	245	2023-09-02	2023-09	2023-3	September	Saturday 	t	f	Q3	Fall	2025-07-29 12:25:04.696528-05
2023-09-03 00:00:00	2023-09-03 00:00:00	2023	3	9	35	3	0	246	2023-09-03	2023-09	2023-3	September	Sunday   	t	f	Q3	Fall	2025-07-29 12:25:04.696528-05
2023-09-04 00:00:00	2023-09-04 00:00:00	2023	3	9	36	4	1	247	2023-09-04	2023-09	2023-3	September	Monday   	f	t	Q3	Fall	2025-07-29 12:25:04.696528-05
2023-09-05 00:00:00	2023-09-05 00:00:00	2023	3	9	36	5	2	248	2023-09-05	2023-09	2023-3	September	Tuesday  	f	t	Q3	Fall	2025-07-29 12:25:04.696528-05
2023-09-06 00:00:00	2023-09-06 00:00:00	2023	3	9	36	6	3	249	2023-09-06	2023-09	2023-3	September	Wednesday	f	t	Q3	Fall	2025-07-29 12:25:04.696528-05
2023-09-07 00:00:00	2023-09-07 00:00:00	2023	3	9	36	7	4	250	2023-09-07	2023-09	2023-3	September	Thursday 	f	t	Q3	Fall	2025-07-29 12:25:04.696528-05
2023-09-08 00:00:00	2023-09-08 00:00:00	2023	3	9	36	8	5	251	2023-09-08	2023-09	2023-3	September	Friday   	f	t	Q3	Fall	2025-07-29 12:25:04.696528-05
2023-09-09 00:00:00	2023-09-09 00:00:00	2023	3	9	36	9	6	252	2023-09-09	2023-09	2023-3	September	Saturday 	t	f	Q3	Fall	2025-07-29 12:25:04.696528-05
2023-09-10 00:00:00	2023-09-10 00:00:00	2023	3	9	36	10	0	253	2023-09-10	2023-09	2023-3	September	Sunday   	t	f	Q3	Fall	2025-07-29 12:25:04.696528-05
2023-09-11 00:00:00	2023-09-11 00:00:00	2023	3	9	37	11	1	254	2023-09-11	2023-09	2023-3	September	Monday   	f	t	Q3	Fall	2025-07-29 12:25:04.696528-05
2023-09-12 00:00:00	2023-09-12 00:00:00	2023	3	9	37	12	2	255	2023-09-12	2023-09	2023-3	September	Tuesday  	f	t	Q3	Fall	2025-07-29 12:25:04.696528-05
2023-09-13 00:00:00	2023-09-13 00:00:00	2023	3	9	37	13	3	256	2023-09-13	2023-09	2023-3	September	Wednesday	f	t	Q3	Fall	2025-07-29 12:25:04.696528-05
2023-09-14 00:00:00	2023-09-14 00:00:00	2023	3	9	37	14	4	257	2023-09-14	2023-09	2023-3	September	Thursday 	f	t	Q3	Fall	2025-07-29 12:25:04.696528-05
2023-09-15 00:00:00	2023-09-15 00:00:00	2023	3	9	37	15	5	258	2023-09-15	2023-09	2023-3	September	Friday   	f	t	Q3	Fall	2025-07-29 12:25:04.696528-05
2023-09-16 00:00:00	2023-09-16 00:00:00	2023	3	9	37	16	6	259	2023-09-16	2023-09	2023-3	September	Saturday 	t	f	Q3	Fall	2025-07-29 12:25:04.696528-05
2023-09-17 00:00:00	2023-09-17 00:00:00	2023	3	9	37	17	0	260	2023-09-17	2023-09	2023-3	September	Sunday   	t	f	Q3	Fall	2025-07-29 12:25:04.696528-05
2023-09-18 00:00:00	2023-09-18 00:00:00	2023	3	9	38	18	1	261	2023-09-18	2023-09	2023-3	September	Monday   	f	t	Q3	Fall	2025-07-29 12:25:04.696528-05
2023-09-19 00:00:00	2023-09-19 00:00:00	2023	3	9	38	19	2	262	2023-09-19	2023-09	2023-3	September	Tuesday  	f	t	Q3	Fall	2025-07-29 12:25:04.696528-05
2023-09-20 00:00:00	2023-09-20 00:00:00	2023	3	9	38	20	3	263	2023-09-20	2023-09	2023-3	September	Wednesday	f	t	Q3	Fall	2025-07-29 12:25:04.696528-05
2023-09-21 00:00:00	2023-09-21 00:00:00	2023	3	9	38	21	4	264	2023-09-21	2023-09	2023-3	September	Thursday 	f	t	Q3	Fall	2025-07-29 12:25:04.696528-05
2023-09-22 00:00:00	2023-09-22 00:00:00	2023	3	9	38	22	5	265	2023-09-22	2023-09	2023-3	September	Friday   	f	t	Q3	Fall	2025-07-29 12:25:04.696528-05
2023-09-23 00:00:00	2023-09-23 00:00:00	2023	3	9	38	23	6	266	2023-09-23	2023-09	2023-3	September	Saturday 	t	f	Q3	Fall	2025-07-29 12:25:04.696528-05
2023-09-24 00:00:00	2023-09-24 00:00:00	2023	3	9	38	24	0	267	2023-09-24	2023-09	2023-3	September	Sunday   	t	f	Q3	Fall	2025-07-29 12:25:04.696528-05
2023-09-25 00:00:00	2023-09-25 00:00:00	2023	3	9	39	25	1	268	2023-09-25	2023-09	2023-3	September	Monday   	f	t	Q3	Fall	2025-07-29 12:25:04.696528-05
2023-09-26 00:00:00	2023-09-26 00:00:00	2023	3	9	39	26	2	269	2023-09-26	2023-09	2023-3	September	Tuesday  	f	t	Q3	Fall	2025-07-29 12:25:04.696528-05
2023-09-27 00:00:00	2023-09-27 00:00:00	2023	3	9	39	27	3	270	2023-09-27	2023-09	2023-3	September	Wednesday	f	t	Q3	Fall	2025-07-29 12:25:04.696528-05
2023-09-28 00:00:00	2023-09-28 00:00:00	2023	3	9	39	28	4	271	2023-09-28	2023-09	2023-3	September	Thursday 	f	t	Q3	Fall	2025-07-29 12:25:04.696528-05
2023-09-29 00:00:00	2023-09-29 00:00:00	2023	3	9	39	29	5	272	2023-09-29	2023-09	2023-3	September	Friday   	f	t	Q3	Fall	2025-07-29 12:25:04.696528-05
2023-09-30 00:00:00	2023-09-30 00:00:00	2023	3	9	39	30	6	273	2023-09-30	2023-09	2023-3	September	Saturday 	t	f	Q3	Fall	2025-07-29 12:25:04.696528-05
2023-10-01 00:00:00	2023-10-01 00:00:00	2023	4	10	39	1	0	274	2023-10-01	2023-10	2023-4	October  	Sunday   	t	f	Q4	Fall	2025-07-29 12:25:04.696528-05
2023-10-02 00:00:00	2023-10-02 00:00:00	2023	4	10	40	2	1	275	2023-10-02	2023-10	2023-4	October  	Monday   	f	t	Q4	Fall	2025-07-29 12:25:04.696528-05
2023-10-03 00:00:00	2023-10-03 00:00:00	2023	4	10	40	3	2	276	2023-10-03	2023-10	2023-4	October  	Tuesday  	f	t	Q4	Fall	2025-07-29 12:25:04.696528-05
2023-10-04 00:00:00	2023-10-04 00:00:00	2023	4	10	40	4	3	277	2023-10-04	2023-10	2023-4	October  	Wednesday	f	t	Q4	Fall	2025-07-29 12:25:04.696528-05
2023-10-05 00:00:00	2023-10-05 00:00:00	2023	4	10	40	5	4	278	2023-10-05	2023-10	2023-4	October  	Thursday 	f	t	Q4	Fall	2025-07-29 12:25:04.696528-05
2023-10-06 00:00:00	2023-10-06 00:00:00	2023	4	10	40	6	5	279	2023-10-06	2023-10	2023-4	October  	Friday   	f	t	Q4	Fall	2025-07-29 12:25:04.696528-05
2023-10-07 00:00:00	2023-10-07 00:00:00	2023	4	10	40	7	6	280	2023-10-07	2023-10	2023-4	October  	Saturday 	t	f	Q4	Fall	2025-07-29 12:25:04.696528-05
2023-10-08 00:00:00	2023-10-08 00:00:00	2023	4	10	40	8	0	281	2023-10-08	2023-10	2023-4	October  	Sunday   	t	f	Q4	Fall	2025-07-29 12:25:04.696528-05
2023-10-09 00:00:00	2023-10-09 00:00:00	2023	4	10	41	9	1	282	2023-10-09	2023-10	2023-4	October  	Monday   	f	t	Q4	Fall	2025-07-29 12:25:04.696528-05
2023-10-10 00:00:00	2023-10-10 00:00:00	2023	4	10	41	10	2	283	2023-10-10	2023-10	2023-4	October  	Tuesday  	f	t	Q4	Fall	2025-07-29 12:25:04.696528-05
2023-10-11 00:00:00	2023-10-11 00:00:00	2023	4	10	41	11	3	284	2023-10-11	2023-10	2023-4	October  	Wednesday	f	t	Q4	Fall	2025-07-29 12:25:04.696528-05
2023-10-12 00:00:00	2023-10-12 00:00:00	2023	4	10	41	12	4	285	2023-10-12	2023-10	2023-4	October  	Thursday 	f	t	Q4	Fall	2025-07-29 12:25:04.696528-05
2023-10-13 00:00:00	2023-10-13 00:00:00	2023	4	10	41	13	5	286	2023-10-13	2023-10	2023-4	October  	Friday   	f	t	Q4	Fall	2025-07-29 12:25:04.696528-05
2023-10-14 00:00:00	2023-10-14 00:00:00	2023	4	10	41	14	6	287	2023-10-14	2023-10	2023-4	October  	Saturday 	t	f	Q4	Fall	2025-07-29 12:25:04.696528-05
2023-10-15 00:00:00	2023-10-15 00:00:00	2023	4	10	41	15	0	288	2023-10-15	2023-10	2023-4	October  	Sunday   	t	f	Q4	Fall	2025-07-29 12:25:04.696528-05
2023-10-16 00:00:00	2023-10-16 00:00:00	2023	4	10	42	16	1	289	2023-10-16	2023-10	2023-4	October  	Monday   	f	t	Q4	Fall	2025-07-29 12:25:04.696528-05
2023-10-17 00:00:00	2023-10-17 00:00:00	2023	4	10	42	17	2	290	2023-10-17	2023-10	2023-4	October  	Tuesday  	f	t	Q4	Fall	2025-07-29 12:25:04.696528-05
2023-10-18 00:00:00	2023-10-18 00:00:00	2023	4	10	42	18	3	291	2023-10-18	2023-10	2023-4	October  	Wednesday	f	t	Q4	Fall	2025-07-29 12:25:04.696528-05
2023-10-19 00:00:00	2023-10-19 00:00:00	2023	4	10	42	19	4	292	2023-10-19	2023-10	2023-4	October  	Thursday 	f	t	Q4	Fall	2025-07-29 12:25:04.696528-05
2023-10-20 00:00:00	2023-10-20 00:00:00	2023	4	10	42	20	5	293	2023-10-20	2023-10	2023-4	October  	Friday   	f	t	Q4	Fall	2025-07-29 12:25:04.696528-05
2023-10-21 00:00:00	2023-10-21 00:00:00	2023	4	10	42	21	6	294	2023-10-21	2023-10	2023-4	October  	Saturday 	t	f	Q4	Fall	2025-07-29 12:25:04.696528-05
2023-10-22 00:00:00	2023-10-22 00:00:00	2023	4	10	42	22	0	295	2023-10-22	2023-10	2023-4	October  	Sunday   	t	f	Q4	Fall	2025-07-29 12:25:04.696528-05
2023-10-23 00:00:00	2023-10-23 00:00:00	2023	4	10	43	23	1	296	2023-10-23	2023-10	2023-4	October  	Monday   	f	t	Q4	Fall	2025-07-29 12:25:04.696528-05
2023-10-24 00:00:00	2023-10-24 00:00:00	2023	4	10	43	24	2	297	2023-10-24	2023-10	2023-4	October  	Tuesday  	f	t	Q4	Fall	2025-07-29 12:25:04.696528-05
2023-10-25 00:00:00	2023-10-25 00:00:00	2023	4	10	43	25	3	298	2023-10-25	2023-10	2023-4	October  	Wednesday	f	t	Q4	Fall	2025-07-29 12:25:04.696528-05
2023-10-26 00:00:00	2023-10-26 00:00:00	2023	4	10	43	26	4	299	2023-10-26	2023-10	2023-4	October  	Thursday 	f	t	Q4	Fall	2025-07-29 12:25:04.696528-05
2023-10-27 00:00:00	2023-10-27 00:00:00	2023	4	10	43	27	5	300	2023-10-27	2023-10	2023-4	October  	Friday   	f	t	Q4	Fall	2025-07-29 12:25:04.696528-05
2023-10-28 00:00:00	2023-10-28 00:00:00	2023	4	10	43	28	6	301	2023-10-28	2023-10	2023-4	October  	Saturday 	t	f	Q4	Fall	2025-07-29 12:25:04.696528-05
2023-10-29 00:00:00	2023-10-29 00:00:00	2023	4	10	43	29	0	302	2023-10-29	2023-10	2023-4	October  	Sunday   	t	f	Q4	Fall	2025-07-29 12:25:04.696528-05
2023-10-30 00:00:00	2023-10-30 00:00:00	2023	4	10	44	30	1	303	2023-10-30	2023-10	2023-4	October  	Monday   	f	t	Q4	Fall	2025-07-29 12:25:04.696528-05
2023-10-31 00:00:00	2023-10-31 00:00:00	2023	4	10	44	31	2	304	2023-10-31	2023-10	2023-4	October  	Tuesday  	f	t	Q4	Fall	2025-07-29 12:25:04.696528-05
2023-11-01 00:00:00	2023-11-01 00:00:00	2023	4	11	44	1	3	305	2023-11-01	2023-11	2023-4	November 	Wednesday	f	t	Q4	Fall	2025-07-29 12:25:04.696528-05
2023-11-02 00:00:00	2023-11-02 00:00:00	2023	4	11	44	2	4	306	2023-11-02	2023-11	2023-4	November 	Thursday 	f	t	Q4	Fall	2025-07-29 12:25:04.696528-05
2023-11-03 00:00:00	2023-11-03 00:00:00	2023	4	11	44	3	5	307	2023-11-03	2023-11	2023-4	November 	Friday   	f	t	Q4	Fall	2025-07-29 12:25:04.696528-05
2023-11-04 00:00:00	2023-11-04 00:00:00	2023	4	11	44	4	6	308	2023-11-04	2023-11	2023-4	November 	Saturday 	t	f	Q4	Fall	2025-07-29 12:25:04.696528-05
2023-11-05 00:00:00	2023-11-05 00:00:00	2023	4	11	44	5	0	309	2023-11-05	2023-11	2023-4	November 	Sunday   	t	f	Q4	Fall	2025-07-29 12:25:04.696528-05
2023-11-06 00:00:00	2023-11-06 00:00:00	2023	4	11	45	6	1	310	2023-11-06	2023-11	2023-4	November 	Monday   	f	t	Q4	Fall	2025-07-29 12:25:04.696528-05
2023-11-07 00:00:00	2023-11-07 00:00:00	2023	4	11	45	7	2	311	2023-11-07	2023-11	2023-4	November 	Tuesday  	f	t	Q4	Fall	2025-07-29 12:25:04.696528-05
2023-11-08 00:00:00	2023-11-08 00:00:00	2023	4	11	45	8	3	312	2023-11-08	2023-11	2023-4	November 	Wednesday	f	t	Q4	Fall	2025-07-29 12:25:04.696528-05
2023-11-09 00:00:00	2023-11-09 00:00:00	2023	4	11	45	9	4	313	2023-11-09	2023-11	2023-4	November 	Thursday 	f	t	Q4	Fall	2025-07-29 12:25:04.696528-05
2023-11-10 00:00:00	2023-11-10 00:00:00	2023	4	11	45	10	5	314	2023-11-10	2023-11	2023-4	November 	Friday   	f	t	Q4	Fall	2025-07-29 12:25:04.696528-05
2023-11-11 00:00:00	2023-11-11 00:00:00	2023	4	11	45	11	6	315	2023-11-11	2023-11	2023-4	November 	Saturday 	t	f	Q4	Fall	2025-07-29 12:25:04.696528-05
2023-11-12 00:00:00	2023-11-12 00:00:00	2023	4	11	45	12	0	316	2023-11-12	2023-11	2023-4	November 	Sunday   	t	f	Q4	Fall	2025-07-29 12:25:04.696528-05
2023-11-13 00:00:00	2023-11-13 00:00:00	2023	4	11	46	13	1	317	2023-11-13	2023-11	2023-4	November 	Monday   	f	t	Q4	Fall	2025-07-29 12:25:04.696528-05
2023-11-14 00:00:00	2023-11-14 00:00:00	2023	4	11	46	14	2	318	2023-11-14	2023-11	2023-4	November 	Tuesday  	f	t	Q4	Fall	2025-07-29 12:25:04.696528-05
2023-11-15 00:00:00	2023-11-15 00:00:00	2023	4	11	46	15	3	319	2023-11-15	2023-11	2023-4	November 	Wednesday	f	t	Q4	Fall	2025-07-29 12:25:04.696528-05
2023-11-16 00:00:00	2023-11-16 00:00:00	2023	4	11	46	16	4	320	2023-11-16	2023-11	2023-4	November 	Thursday 	f	t	Q4	Fall	2025-07-29 12:25:04.696528-05
2023-11-17 00:00:00	2023-11-17 00:00:00	2023	4	11	46	17	5	321	2023-11-17	2023-11	2023-4	November 	Friday   	f	t	Q4	Fall	2025-07-29 12:25:04.696528-05
2023-11-18 00:00:00	2023-11-18 00:00:00	2023	4	11	46	18	6	322	2023-11-18	2023-11	2023-4	November 	Saturday 	t	f	Q4	Fall	2025-07-29 12:25:04.696528-05
2023-11-19 00:00:00	2023-11-19 00:00:00	2023	4	11	46	19	0	323	2023-11-19	2023-11	2023-4	November 	Sunday   	t	f	Q4	Fall	2025-07-29 12:25:04.696528-05
2023-11-20 00:00:00	2023-11-20 00:00:00	2023	4	11	47	20	1	324	2023-11-20	2023-11	2023-4	November 	Monday   	f	t	Q4	Fall	2025-07-29 12:25:04.696528-05
2023-11-21 00:00:00	2023-11-21 00:00:00	2023	4	11	47	21	2	325	2023-11-21	2023-11	2023-4	November 	Tuesday  	f	t	Q4	Fall	2025-07-29 12:25:04.696528-05
2023-11-22 00:00:00	2023-11-22 00:00:00	2023	4	11	47	22	3	326	2023-11-22	2023-11	2023-4	November 	Wednesday	f	t	Q4	Fall	2025-07-29 12:25:04.696528-05
2023-11-23 00:00:00	2023-11-23 00:00:00	2023	4	11	47	23	4	327	2023-11-23	2023-11	2023-4	November 	Thursday 	f	t	Q4	Fall	2025-07-29 12:25:04.696528-05
2023-11-24 00:00:00	2023-11-24 00:00:00	2023	4	11	47	24	5	328	2023-11-24	2023-11	2023-4	November 	Friday   	f	t	Q4	Fall	2025-07-29 12:25:04.696528-05
2023-11-25 00:00:00	2023-11-25 00:00:00	2023	4	11	47	25	6	329	2023-11-25	2023-11	2023-4	November 	Saturday 	t	f	Q4	Fall	2025-07-29 12:25:04.696528-05
2023-11-26 00:00:00	2023-11-26 00:00:00	2023	4	11	47	26	0	330	2023-11-26	2023-11	2023-4	November 	Sunday   	t	f	Q4	Fall	2025-07-29 12:25:04.696528-05
2023-11-27 00:00:00	2023-11-27 00:00:00	2023	4	11	48	27	1	331	2023-11-27	2023-11	2023-4	November 	Monday   	f	t	Q4	Fall	2025-07-29 12:25:04.696528-05
2023-11-28 00:00:00	2023-11-28 00:00:00	2023	4	11	48	28	2	332	2023-11-28	2023-11	2023-4	November 	Tuesday  	f	t	Q4	Fall	2025-07-29 12:25:04.696528-05
2023-11-29 00:00:00	2023-11-29 00:00:00	2023	4	11	48	29	3	333	2023-11-29	2023-11	2023-4	November 	Wednesday	f	t	Q4	Fall	2025-07-29 12:25:04.696528-05
2023-11-30 00:00:00	2023-11-30 00:00:00	2023	4	11	48	30	4	334	2023-11-30	2023-11	2023-4	November 	Thursday 	f	t	Q4	Fall	2025-07-29 12:25:04.696528-05
2023-12-01 00:00:00	2023-12-01 00:00:00	2023	4	12	48	1	5	335	2023-12-01	2023-12	2023-4	December 	Friday   	f	t	Q4	Winter	2025-07-29 12:25:04.696528-05
2023-12-02 00:00:00	2023-12-02 00:00:00	2023	4	12	48	2	6	336	2023-12-02	2023-12	2023-4	December 	Saturday 	t	f	Q4	Winter	2025-07-29 12:25:04.696528-05
2023-12-03 00:00:00	2023-12-03 00:00:00	2023	4	12	48	3	0	337	2023-12-03	2023-12	2023-4	December 	Sunday   	t	f	Q4	Winter	2025-07-29 12:25:04.696528-05
2023-12-04 00:00:00	2023-12-04 00:00:00	2023	4	12	49	4	1	338	2023-12-04	2023-12	2023-4	December 	Monday   	f	t	Q4	Winter	2025-07-29 12:25:04.696528-05
2023-12-05 00:00:00	2023-12-05 00:00:00	2023	4	12	49	5	2	339	2023-12-05	2023-12	2023-4	December 	Tuesday  	f	t	Q4	Winter	2025-07-29 12:25:04.696528-05
2023-12-06 00:00:00	2023-12-06 00:00:00	2023	4	12	49	6	3	340	2023-12-06	2023-12	2023-4	December 	Wednesday	f	t	Q4	Winter	2025-07-29 12:25:04.696528-05
2023-12-07 00:00:00	2023-12-07 00:00:00	2023	4	12	49	7	4	341	2023-12-07	2023-12	2023-4	December 	Thursday 	f	t	Q4	Winter	2025-07-29 12:25:04.696528-05
2023-12-08 00:00:00	2023-12-08 00:00:00	2023	4	12	49	8	5	342	2023-12-08	2023-12	2023-4	December 	Friday   	f	t	Q4	Winter	2025-07-29 12:25:04.696528-05
2023-12-09 00:00:00	2023-12-09 00:00:00	2023	4	12	49	9	6	343	2023-12-09	2023-12	2023-4	December 	Saturday 	t	f	Q4	Winter	2025-07-29 12:25:04.696528-05
2023-12-10 00:00:00	2023-12-10 00:00:00	2023	4	12	49	10	0	344	2023-12-10	2023-12	2023-4	December 	Sunday   	t	f	Q4	Winter	2025-07-29 12:25:04.696528-05
2023-12-11 00:00:00	2023-12-11 00:00:00	2023	4	12	50	11	1	345	2023-12-11	2023-12	2023-4	December 	Monday   	f	t	Q4	Winter	2025-07-29 12:25:04.696528-05
2023-12-12 00:00:00	2023-12-12 00:00:00	2023	4	12	50	12	2	346	2023-12-12	2023-12	2023-4	December 	Tuesday  	f	t	Q4	Winter	2025-07-29 12:25:04.696528-05
2023-12-13 00:00:00	2023-12-13 00:00:00	2023	4	12	50	13	3	347	2023-12-13	2023-12	2023-4	December 	Wednesday	f	t	Q4	Winter	2025-07-29 12:25:04.696528-05
2023-12-14 00:00:00	2023-12-14 00:00:00	2023	4	12	50	14	4	348	2023-12-14	2023-12	2023-4	December 	Thursday 	f	t	Q4	Winter	2025-07-29 12:25:04.696528-05
2023-12-15 00:00:00	2023-12-15 00:00:00	2023	4	12	50	15	5	349	2023-12-15	2023-12	2023-4	December 	Friday   	f	t	Q4	Winter	2025-07-29 12:25:04.696528-05
2023-12-16 00:00:00	2023-12-16 00:00:00	2023	4	12	50	16	6	350	2023-12-16	2023-12	2023-4	December 	Saturday 	t	f	Q4	Winter	2025-07-29 12:25:04.696528-05
2023-12-17 00:00:00	2023-12-17 00:00:00	2023	4	12	50	17	0	351	2023-12-17	2023-12	2023-4	December 	Sunday   	t	f	Q4	Winter	2025-07-29 12:25:04.696528-05
2023-12-18 00:00:00	2023-12-18 00:00:00	2023	4	12	51	18	1	352	2023-12-18	2023-12	2023-4	December 	Monday   	f	t	Q4	Winter	2025-07-29 12:25:04.696528-05
2023-12-19 00:00:00	2023-12-19 00:00:00	2023	4	12	51	19	2	353	2023-12-19	2023-12	2023-4	December 	Tuesday  	f	t	Q4	Winter	2025-07-29 12:25:04.696528-05
2023-12-20 00:00:00	2023-12-20 00:00:00	2023	4	12	51	20	3	354	2023-12-20	2023-12	2023-4	December 	Wednesday	f	t	Q4	Winter	2025-07-29 12:25:04.696528-05
2023-12-21 00:00:00	2023-12-21 00:00:00	2023	4	12	51	21	4	355	2023-12-21	2023-12	2023-4	December 	Thursday 	f	t	Q4	Winter	2025-07-29 12:25:04.696528-05
2023-12-22 00:00:00	2023-12-22 00:00:00	2023	4	12	51	22	5	356	2023-12-22	2023-12	2023-4	December 	Friday   	f	t	Q4	Winter	2025-07-29 12:25:04.696528-05
2023-12-23 00:00:00	2023-12-23 00:00:00	2023	4	12	51	23	6	357	2023-12-23	2023-12	2023-4	December 	Saturday 	t	f	Q4	Winter	2025-07-29 12:25:04.696528-05
2023-12-24 00:00:00	2023-12-24 00:00:00	2023	4	12	51	24	0	358	2023-12-24	2023-12	2023-4	December 	Sunday   	t	f	Q4	Winter	2025-07-29 12:25:04.696528-05
2023-12-25 00:00:00	2023-12-25 00:00:00	2023	4	12	52	25	1	359	2023-12-25	2023-12	2023-4	December 	Monday   	f	t	Q4	Winter	2025-07-29 12:25:04.696528-05
2023-12-26 00:00:00	2023-12-26 00:00:00	2023	4	12	52	26	2	360	2023-12-26	2023-12	2023-4	December 	Tuesday  	f	t	Q4	Winter	2025-07-29 12:25:04.696528-05
2023-12-27 00:00:00	2023-12-27 00:00:00	2023	4	12	52	27	3	361	2023-12-27	2023-12	2023-4	December 	Wednesday	f	t	Q4	Winter	2025-07-29 12:25:04.696528-05
2023-12-28 00:00:00	2023-12-28 00:00:00	2023	4	12	52	28	4	362	2023-12-28	2023-12	2023-4	December 	Thursday 	f	t	Q4	Winter	2025-07-29 12:25:04.696528-05
2023-12-29 00:00:00	2023-12-29 00:00:00	2023	4	12	52	29	5	363	2023-12-29	2023-12	2023-4	December 	Friday   	f	t	Q4	Winter	2025-07-29 12:25:04.696528-05
2023-12-30 00:00:00	2023-12-30 00:00:00	2023	4	12	52	30	6	364	2023-12-30	2023-12	2023-4	December 	Saturday 	t	f	Q4	Winter	2025-07-29 12:25:04.696528-05
\.


--
-- Data for Name: -- Custom alias naming for modelsdim_products; Type: TABLE DATA; Schema: analytics_staging; Owner: dbt_staging_user
--

COPY analytics_staging."-- Custom alias naming for modelsdim_products" (product_id, product_name, category, price, price_tier, total_orders, total_quantity_sold, total_revenue, first_sale_date, last_sale_date, performance_tier, avg_quantity_per_order, avg_revenue_per_order, _loaded_at) FROM stdin;
\.


--
-- Data for Name: -- Custom alias naming for modelsfct_orders; Type: TABLE DATA; Schema: analytics_staging; Owner: dbt_staging_user
--

COPY analytics_staging."-- Custom alias naming for modelsfct_orders" (order_id, customer_id, product_id, order_date, quantity, unit_price, total_amount, discount_amount, order_year, order_month, order_quarter, order_size, estimated_profit, profit_margin_percent, _loaded_at) FROM stdin;
\.


--
-- Data for Name: -- Custom alias naming for modelsfct_visits; Type: TABLE DATA; Schema: analytics_staging; Owner: dbt_staging_user
--

COPY analytics_staging."-- Custom alias naming for modelsfct_visits" (visit_id, customer_id, visit_date, duration_minutes, pages_viewed, pages_per_minute, engagement_score, converted_flag, converted_order_id, conversion_value, session_type, engagement_level, visit_year, visit_month, traffic_source, _loaded_at) FROM stdin;
\.


--
-- Data for Name: customers; Type: TABLE DATA; Schema: raw; Owner: postgres
--

COPY raw.customers (customer_id, first_name, last_name, email, registration_date) FROM stdin;
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: raw; Owner: postgres
--

COPY raw.orders (order_id, customer_id, order_date, product_id, quantity, total_amount) FROM stdin;
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: raw; Owner: postgres
--

COPY raw.products (product_id, product_name, category, price) FROM stdin;
\.


--
-- Data for Name: visits; Type: TABLE DATA; Schema: raw; Owner: postgres
--

COPY raw.visits (visit_id, customer_id, visit_date, duration_minutes, pages_viewed) FROM stdin;
\.


--
-- Name: customers customers_email_key; Type: CONSTRAINT; Schema: raw; Owner: postgres
--

ALTER TABLE ONLY raw.customers
    ADD CONSTRAINT customers_email_key UNIQUE (email);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: raw; Owner: postgres
--

ALTER TABLE ONLY raw.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (customer_id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: raw; Owner: postgres
--

ALTER TABLE ONLY raw.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (order_id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: raw; Owner: postgres
--

ALTER TABLE ONLY raw.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (product_id);


--
-- Name: visits visits_pkey; Type: CONSTRAINT; Schema: raw; Owner: postgres
--

ALTER TABLE ONLY raw.visits
    ADD CONSTRAINT visits_pkey PRIMARY KEY (visit_id);


--
-- Name: idx_orders_customer_id; Type: INDEX; Schema: raw; Owner: postgres
--

CREATE INDEX idx_orders_customer_id ON raw.orders USING btree (customer_id);


--
-- Name: idx_orders_date; Type: INDEX; Schema: raw; Owner: postgres
--

CREATE INDEX idx_orders_date ON raw.orders USING btree (order_date);


--
-- Name: idx_orders_product_id; Type: INDEX; Schema: raw; Owner: postgres
--

CREATE INDEX idx_orders_product_id ON raw.orders USING btree (product_id);


--
-- Name: idx_visits_customer_id; Type: INDEX; Schema: raw; Owner: postgres
--

CREATE INDEX idx_visits_customer_id ON raw.visits USING btree (customer_id);


--
-- Name: idx_visits_date; Type: INDEX; Schema: raw; Owner: postgres
--

CREATE INDEX idx_visits_date ON raw.visits USING btree (visit_date);


--
-- Name: orders orders_customer_id_fkey; Type: FK CONSTRAINT; Schema: raw; Owner: postgres
--

ALTER TABLE ONLY raw.orders
    ADD CONSTRAINT orders_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES raw.customers(customer_id);


--
-- Name: orders orders_product_id_fkey; Type: FK CONSTRAINT; Schema: raw; Owner: postgres
--

ALTER TABLE ONLY raw.orders
    ADD CONSTRAINT orders_product_id_fkey FOREIGN KEY (product_id) REFERENCES raw.products(product_id);


--
-- Name: visits visits_customer_id_fkey; Type: FK CONSTRAINT; Schema: raw; Owner: postgres
--

ALTER TABLE ONLY raw.visits
    ADD CONSTRAINT visits_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES raw.customers(customer_id);


--
-- Name: SCHEMA analytics; Type: ACL; Schema: -; Owner: postgres
--

GRANT ALL ON SCHEMA analytics TO dbt_prod_user;
GRANT ALL ON SCHEMA analytics TO dbt_user;
GRANT ALL ON SCHEMA analytics TO dbt_dev_user;
GRANT ALL ON SCHEMA analytics TO dbt_staging_user;


--
-- Name: SCHEMA analytics_dev; Type: ACL; Schema: -; Owner: postgres
--

GRANT ALL ON SCHEMA analytics_dev TO dbt_dev_user;
GRANT ALL ON SCHEMA analytics_dev TO dbt_staging_user;
GRANT ALL ON SCHEMA analytics_dev TO dbt_prod_user;


--
-- Name: SCHEMA analytics_staging; Type: ACL; Schema: -; Owner: postgres
--

GRANT ALL ON SCHEMA analytics_staging TO dbt_staging_user;
GRANT ALL ON SCHEMA analytics_staging TO dbt_dev_user;
GRANT ALL ON SCHEMA analytics_staging TO dbt_prod_user;


--
-- Name: SCHEMA pg_catalog; Type: ACL; Schema: -; Owner: rollyangell
--

GRANT USAGE ON SCHEMA pg_catalog TO dbt_dev_user;
GRANT USAGE ON SCHEMA pg_catalog TO dbt_staging_user;
GRANT USAGE ON SCHEMA pg_catalog TO dbt_prod_user;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: rollyangell
--

GRANT ALL ON SCHEMA public TO dbt_dev_user;
GRANT ALL ON SCHEMA public TO dbt_staging_user;
GRANT ALL ON SCHEMA public TO dbt_prod_user;


--
-- Name: SCHEMA raw; Type: ACL; Schema: -; Owner: postgres
--

GRANT ALL ON SCHEMA raw TO dbt_dev_user;
GRANT ALL ON SCHEMA raw TO dbt_staging_user;
GRANT ALL ON SCHEMA raw TO dbt_prod_user;
GRANT ALL ON SCHEMA raw TO dbt_user;


--
-- Name: TABLE "-- Custom alias naming for modelsdim_customers"; Type: ACL; Schema: analytics_staging; Owner: dbt_staging_user
--

GRANT ALL ON TABLE analytics_staging."-- Custom alias naming for modelsdim_customers" TO dbt_dev_user;
GRANT ALL ON TABLE analytics_staging."-- Custom alias naming for modelsdim_customers" TO dbt_prod_user;


--
-- Name: TABLE "-- Custom alias naming for modelsdim_date"; Type: ACL; Schema: analytics_staging; Owner: dbt_staging_user
--

GRANT ALL ON TABLE analytics_staging."-- Custom alias naming for modelsdim_date" TO dbt_dev_user;
GRANT ALL ON TABLE analytics_staging."-- Custom alias naming for modelsdim_date" TO dbt_prod_user;


--
-- Name: TABLE "-- Custom alias naming for modelsdim_products"; Type: ACL; Schema: analytics_staging; Owner: dbt_staging_user
--

GRANT ALL ON TABLE analytics_staging."-- Custom alias naming for modelsdim_products" TO dbt_dev_user;
GRANT ALL ON TABLE analytics_staging."-- Custom alias naming for modelsdim_products" TO dbt_prod_user;


--
-- Name: TABLE "-- Custom alias naming for modelsfct_orders"; Type: ACL; Schema: analytics_staging; Owner: dbt_staging_user
--

GRANT ALL ON TABLE analytics_staging."-- Custom alias naming for modelsfct_orders" TO dbt_dev_user;
GRANT ALL ON TABLE analytics_staging."-- Custom alias naming for modelsfct_orders" TO dbt_prod_user;


--
-- Name: TABLE "-- Custom alias naming for modelsfct_visits"; Type: ACL; Schema: analytics_staging; Owner: dbt_staging_user
--

GRANT ALL ON TABLE analytics_staging."-- Custom alias naming for modelsfct_visits" TO dbt_dev_user;
GRANT ALL ON TABLE analytics_staging."-- Custom alias naming for modelsfct_visits" TO dbt_prod_user;


--
-- Name: TABLE customers; Type: ACL; Schema: raw; Owner: postgres
--

GRANT ALL ON TABLE raw.customers TO dbt_user;
GRANT ALL ON TABLE raw.customers TO dbt_dev_user;
GRANT ALL ON TABLE raw.customers TO dbt_staging_user;
GRANT ALL ON TABLE raw.customers TO dbt_prod_user;


--
-- Name: TABLE "-- Custom alias naming for modelsstg_customers"; Type: ACL; Schema: analytics_staging; Owner: dbt_staging_user
--

GRANT ALL ON TABLE analytics_staging."-- Custom alias naming for modelsstg_customers" TO dbt_dev_user;
GRANT ALL ON TABLE analytics_staging."-- Custom alias naming for modelsstg_customers" TO dbt_prod_user;


--
-- Name: TABLE orders; Type: ACL; Schema: raw; Owner: postgres
--

GRANT ALL ON TABLE raw.orders TO dbt_user;
GRANT ALL ON TABLE raw.orders TO dbt_dev_user;
GRANT ALL ON TABLE raw.orders TO dbt_staging_user;
GRANT ALL ON TABLE raw.orders TO dbt_prod_user;


--
-- Name: TABLE "-- Custom alias naming for modelsstg_orders"; Type: ACL; Schema: analytics_staging; Owner: dbt_staging_user
--

GRANT ALL ON TABLE analytics_staging."-- Custom alias naming for modelsstg_orders" TO dbt_dev_user;
GRANT ALL ON TABLE analytics_staging."-- Custom alias naming for modelsstg_orders" TO dbt_prod_user;


--
-- Name: TABLE products; Type: ACL; Schema: raw; Owner: postgres
--

GRANT ALL ON TABLE raw.products TO dbt_user;
GRANT ALL ON TABLE raw.products TO dbt_dev_user;
GRANT ALL ON TABLE raw.products TO dbt_staging_user;
GRANT ALL ON TABLE raw.products TO dbt_prod_user;


--
-- Name: TABLE "-- Custom alias naming for modelsstg_products"; Type: ACL; Schema: analytics_staging; Owner: dbt_staging_user
--

GRANT ALL ON TABLE analytics_staging."-- Custom alias naming for modelsstg_products" TO dbt_dev_user;
GRANT ALL ON TABLE analytics_staging."-- Custom alias naming for modelsstg_products" TO dbt_prod_user;


--
-- Name: TABLE visits; Type: ACL; Schema: raw; Owner: postgres
--

GRANT ALL ON TABLE raw.visits TO dbt_user;
GRANT ALL ON TABLE raw.visits TO dbt_dev_user;
GRANT ALL ON TABLE raw.visits TO dbt_staging_user;
GRANT ALL ON TABLE raw.visits TO dbt_prod_user;


--
-- Name: TABLE "-- Custom alias naming for modelsstg_visits"; Type: ACL; Schema: analytics_staging; Owner: dbt_staging_user
--

GRANT ALL ON TABLE analytics_staging."-- Custom alias naming for modelsstg_visits" TO dbt_dev_user;
GRANT ALL ON TABLE analytics_staging."-- Custom alias naming for modelsstg_visits" TO dbt_prod_user;


--
-- Name: TABLE pg_aggregate; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_aggregate TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_aggregate TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_aggregate TO dbt_prod_user;


--
-- Name: TABLE pg_am; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_am TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_am TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_am TO dbt_prod_user;


--
-- Name: TABLE pg_amop; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_amop TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_amop TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_amop TO dbt_prod_user;


--
-- Name: TABLE pg_amproc; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_amproc TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_amproc TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_amproc TO dbt_prod_user;


--
-- Name: TABLE pg_attrdef; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_attrdef TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_attrdef TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_attrdef TO dbt_prod_user;


--
-- Name: TABLE pg_attribute; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_attribute TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_attribute TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_attribute TO dbt_prod_user;


--
-- Name: TABLE pg_auth_members; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_auth_members TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_auth_members TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_auth_members TO dbt_prod_user;


--
-- Name: TABLE pg_authid; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_authid TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_authid TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_authid TO dbt_prod_user;


--
-- Name: TABLE pg_available_extension_versions; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_available_extension_versions TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_available_extension_versions TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_available_extension_versions TO dbt_prod_user;


--
-- Name: TABLE pg_available_extensions; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_available_extensions TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_available_extensions TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_available_extensions TO dbt_prod_user;


--
-- Name: TABLE pg_backend_memory_contexts; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_backend_memory_contexts TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_backend_memory_contexts TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_backend_memory_contexts TO dbt_prod_user;


--
-- Name: TABLE pg_cast; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_cast TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_cast TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_cast TO dbt_prod_user;


--
-- Name: TABLE pg_class; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_class TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_class TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_class TO dbt_prod_user;


--
-- Name: TABLE pg_collation; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_collation TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_collation TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_collation TO dbt_prod_user;


--
-- Name: TABLE pg_config; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_config TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_config TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_config TO dbt_prod_user;


--
-- Name: TABLE pg_constraint; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_constraint TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_constraint TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_constraint TO dbt_prod_user;


--
-- Name: TABLE pg_conversion; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_conversion TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_conversion TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_conversion TO dbt_prod_user;


--
-- Name: TABLE pg_cursors; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_cursors TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_cursors TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_cursors TO dbt_prod_user;


--
-- Name: TABLE pg_database; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_database TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_database TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_database TO dbt_prod_user;


--
-- Name: TABLE pg_db_role_setting; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_db_role_setting TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_db_role_setting TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_db_role_setting TO dbt_prod_user;


--
-- Name: TABLE pg_default_acl; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_default_acl TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_default_acl TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_default_acl TO dbt_prod_user;


--
-- Name: TABLE pg_depend; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_depend TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_depend TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_depend TO dbt_prod_user;


--
-- Name: TABLE pg_description; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_description TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_description TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_description TO dbt_prod_user;


--
-- Name: TABLE pg_enum; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_enum TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_enum TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_enum TO dbt_prod_user;


--
-- Name: TABLE pg_event_trigger; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_event_trigger TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_event_trigger TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_event_trigger TO dbt_prod_user;


--
-- Name: TABLE pg_extension; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_extension TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_extension TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_extension TO dbt_prod_user;


--
-- Name: TABLE pg_file_settings; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_file_settings TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_file_settings TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_file_settings TO dbt_prod_user;


--
-- Name: TABLE pg_foreign_data_wrapper; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_foreign_data_wrapper TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_foreign_data_wrapper TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_foreign_data_wrapper TO dbt_prod_user;


--
-- Name: TABLE pg_foreign_server; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_foreign_server TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_foreign_server TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_foreign_server TO dbt_prod_user;


--
-- Name: TABLE pg_foreign_table; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_foreign_table TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_foreign_table TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_foreign_table TO dbt_prod_user;


--
-- Name: TABLE pg_group; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_group TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_group TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_group TO dbt_prod_user;


--
-- Name: TABLE pg_hba_file_rules; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_hba_file_rules TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_hba_file_rules TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_hba_file_rules TO dbt_prod_user;


--
-- Name: TABLE pg_index; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_index TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_index TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_index TO dbt_prod_user;


--
-- Name: TABLE pg_indexes; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_indexes TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_indexes TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_indexes TO dbt_prod_user;


--
-- Name: TABLE pg_inherits; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_inherits TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_inherits TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_inherits TO dbt_prod_user;


--
-- Name: TABLE pg_init_privs; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_init_privs TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_init_privs TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_init_privs TO dbt_prod_user;


--
-- Name: TABLE pg_language; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_language TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_language TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_language TO dbt_prod_user;


--
-- Name: TABLE pg_largeobject; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_largeobject TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_largeobject TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_largeobject TO dbt_prod_user;


--
-- Name: TABLE pg_largeobject_metadata; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_largeobject_metadata TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_largeobject_metadata TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_largeobject_metadata TO dbt_prod_user;


--
-- Name: TABLE pg_locks; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_locks TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_locks TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_locks TO dbt_prod_user;


--
-- Name: TABLE pg_matviews; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_matviews TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_matviews TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_matviews TO dbt_prod_user;


--
-- Name: TABLE pg_namespace; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_namespace TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_namespace TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_namespace TO dbt_prod_user;


--
-- Name: TABLE pg_opclass; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_opclass TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_opclass TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_opclass TO dbt_prod_user;


--
-- Name: TABLE pg_operator; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_operator TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_operator TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_operator TO dbt_prod_user;


--
-- Name: TABLE pg_opfamily; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_opfamily TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_opfamily TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_opfamily TO dbt_prod_user;


--
-- Name: TABLE pg_partitioned_table; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_partitioned_table TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_partitioned_table TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_partitioned_table TO dbt_prod_user;


--
-- Name: TABLE pg_policies; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_policies TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_policies TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_policies TO dbt_prod_user;


--
-- Name: TABLE pg_policy; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_policy TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_policy TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_policy TO dbt_prod_user;


--
-- Name: TABLE pg_prepared_statements; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_prepared_statements TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_prepared_statements TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_prepared_statements TO dbt_prod_user;


--
-- Name: TABLE pg_prepared_xacts; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_prepared_xacts TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_prepared_xacts TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_prepared_xacts TO dbt_prod_user;


--
-- Name: TABLE pg_proc; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_proc TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_proc TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_proc TO dbt_prod_user;


--
-- Name: TABLE pg_publication; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_publication TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_publication TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_publication TO dbt_prod_user;


--
-- Name: TABLE pg_publication_rel; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_publication_rel TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_publication_rel TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_publication_rel TO dbt_prod_user;


--
-- Name: TABLE pg_publication_tables; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_publication_tables TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_publication_tables TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_publication_tables TO dbt_prod_user;


--
-- Name: TABLE pg_range; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_range TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_range TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_range TO dbt_prod_user;


--
-- Name: TABLE pg_replication_origin; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_replication_origin TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_replication_origin TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_replication_origin TO dbt_prod_user;


--
-- Name: TABLE pg_replication_origin_status; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_replication_origin_status TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_replication_origin_status TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_replication_origin_status TO dbt_prod_user;


--
-- Name: TABLE pg_replication_slots; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_replication_slots TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_replication_slots TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_replication_slots TO dbt_prod_user;


--
-- Name: TABLE pg_rewrite; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_rewrite TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_rewrite TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_rewrite TO dbt_prod_user;


--
-- Name: TABLE pg_roles; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_roles TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_roles TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_roles TO dbt_prod_user;


--
-- Name: TABLE pg_rules; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_rules TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_rules TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_rules TO dbt_prod_user;


--
-- Name: TABLE pg_seclabel; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_seclabel TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_seclabel TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_seclabel TO dbt_prod_user;


--
-- Name: TABLE pg_seclabels; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_seclabels TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_seclabels TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_seclabels TO dbt_prod_user;


--
-- Name: TABLE pg_sequence; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_sequence TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_sequence TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_sequence TO dbt_prod_user;


--
-- Name: TABLE pg_sequences; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_sequences TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_sequences TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_sequences TO dbt_prod_user;


--
-- Name: TABLE pg_settings; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_settings TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_settings TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_settings TO dbt_prod_user;


--
-- Name: TABLE pg_shadow; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_shadow TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_shadow TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_shadow TO dbt_prod_user;


--
-- Name: TABLE pg_shdepend; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_shdepend TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_shdepend TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_shdepend TO dbt_prod_user;


--
-- Name: TABLE pg_shdescription; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_shdescription TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_shdescription TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_shdescription TO dbt_prod_user;


--
-- Name: TABLE pg_shmem_allocations; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_shmem_allocations TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_shmem_allocations TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_shmem_allocations TO dbt_prod_user;


--
-- Name: TABLE pg_shseclabel; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_shseclabel TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_shseclabel TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_shseclabel TO dbt_prod_user;


--
-- Name: TABLE pg_stat_activity; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_stat_activity TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_stat_activity TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_stat_activity TO dbt_prod_user;


--
-- Name: TABLE pg_stat_all_indexes; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_stat_all_indexes TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_stat_all_indexes TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_stat_all_indexes TO dbt_prod_user;


--
-- Name: TABLE pg_stat_all_tables; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_stat_all_tables TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_stat_all_tables TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_stat_all_tables TO dbt_prod_user;


--
-- Name: TABLE pg_stat_archiver; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_stat_archiver TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_stat_archiver TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_stat_archiver TO dbt_prod_user;


--
-- Name: TABLE pg_stat_bgwriter; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_stat_bgwriter TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_stat_bgwriter TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_stat_bgwriter TO dbt_prod_user;


--
-- Name: TABLE pg_stat_database; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_stat_database TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_stat_database TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_stat_database TO dbt_prod_user;


--
-- Name: TABLE pg_stat_database_conflicts; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_stat_database_conflicts TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_stat_database_conflicts TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_stat_database_conflicts TO dbt_prod_user;


--
-- Name: TABLE pg_stat_gssapi; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_stat_gssapi TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_stat_gssapi TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_stat_gssapi TO dbt_prod_user;


--
-- Name: TABLE pg_stat_progress_analyze; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_stat_progress_analyze TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_stat_progress_analyze TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_stat_progress_analyze TO dbt_prod_user;


--
-- Name: TABLE pg_stat_progress_basebackup; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_stat_progress_basebackup TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_stat_progress_basebackup TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_stat_progress_basebackup TO dbt_prod_user;


--
-- Name: TABLE pg_stat_progress_cluster; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_stat_progress_cluster TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_stat_progress_cluster TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_stat_progress_cluster TO dbt_prod_user;


--
-- Name: TABLE pg_stat_progress_copy; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_stat_progress_copy TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_stat_progress_copy TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_stat_progress_copy TO dbt_prod_user;


--
-- Name: TABLE pg_stat_progress_create_index; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_stat_progress_create_index TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_stat_progress_create_index TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_stat_progress_create_index TO dbt_prod_user;


--
-- Name: TABLE pg_stat_progress_vacuum; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_stat_progress_vacuum TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_stat_progress_vacuum TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_stat_progress_vacuum TO dbt_prod_user;


--
-- Name: TABLE pg_stat_replication; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_stat_replication TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_stat_replication TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_stat_replication TO dbt_prod_user;


--
-- Name: TABLE pg_stat_replication_slots; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_stat_replication_slots TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_stat_replication_slots TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_stat_replication_slots TO dbt_prod_user;


--
-- Name: TABLE pg_stat_slru; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_stat_slru TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_stat_slru TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_stat_slru TO dbt_prod_user;


--
-- Name: TABLE pg_stat_ssl; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_stat_ssl TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_stat_ssl TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_stat_ssl TO dbt_prod_user;


--
-- Name: TABLE pg_stat_subscription; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_stat_subscription TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_stat_subscription TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_stat_subscription TO dbt_prod_user;


--
-- Name: TABLE pg_stat_sys_indexes; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_stat_sys_indexes TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_stat_sys_indexes TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_stat_sys_indexes TO dbt_prod_user;


--
-- Name: TABLE pg_stat_sys_tables; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_stat_sys_tables TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_stat_sys_tables TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_stat_sys_tables TO dbt_prod_user;


--
-- Name: TABLE pg_stat_user_functions; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_stat_user_functions TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_stat_user_functions TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_stat_user_functions TO dbt_prod_user;


--
-- Name: TABLE pg_stat_user_indexes; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_stat_user_indexes TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_stat_user_indexes TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_stat_user_indexes TO dbt_prod_user;


--
-- Name: TABLE pg_stat_user_tables; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_stat_user_tables TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_stat_user_tables TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_stat_user_tables TO dbt_prod_user;


--
-- Name: TABLE pg_stat_wal; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_stat_wal TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_stat_wal TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_stat_wal TO dbt_prod_user;


--
-- Name: TABLE pg_stat_wal_receiver; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_stat_wal_receiver TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_stat_wal_receiver TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_stat_wal_receiver TO dbt_prod_user;


--
-- Name: TABLE pg_stat_xact_all_tables; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_stat_xact_all_tables TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_stat_xact_all_tables TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_stat_xact_all_tables TO dbt_prod_user;


--
-- Name: TABLE pg_stat_xact_sys_tables; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_stat_xact_sys_tables TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_stat_xact_sys_tables TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_stat_xact_sys_tables TO dbt_prod_user;


--
-- Name: TABLE pg_stat_xact_user_functions; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_stat_xact_user_functions TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_stat_xact_user_functions TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_stat_xact_user_functions TO dbt_prod_user;


--
-- Name: TABLE pg_stat_xact_user_tables; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_stat_xact_user_tables TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_stat_xact_user_tables TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_stat_xact_user_tables TO dbt_prod_user;


--
-- Name: TABLE pg_statio_all_indexes; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_statio_all_indexes TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_statio_all_indexes TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_statio_all_indexes TO dbt_prod_user;


--
-- Name: TABLE pg_statio_all_sequences; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_statio_all_sequences TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_statio_all_sequences TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_statio_all_sequences TO dbt_prod_user;


--
-- Name: TABLE pg_statio_all_tables; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_statio_all_tables TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_statio_all_tables TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_statio_all_tables TO dbt_prod_user;


--
-- Name: TABLE pg_statio_sys_indexes; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_statio_sys_indexes TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_statio_sys_indexes TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_statio_sys_indexes TO dbt_prod_user;


--
-- Name: TABLE pg_statio_sys_sequences; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_statio_sys_sequences TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_statio_sys_sequences TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_statio_sys_sequences TO dbt_prod_user;


--
-- Name: TABLE pg_statio_sys_tables; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_statio_sys_tables TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_statio_sys_tables TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_statio_sys_tables TO dbt_prod_user;


--
-- Name: TABLE pg_statio_user_indexes; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_statio_user_indexes TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_statio_user_indexes TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_statio_user_indexes TO dbt_prod_user;


--
-- Name: TABLE pg_statio_user_sequences; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_statio_user_sequences TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_statio_user_sequences TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_statio_user_sequences TO dbt_prod_user;


--
-- Name: TABLE pg_statio_user_tables; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_statio_user_tables TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_statio_user_tables TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_statio_user_tables TO dbt_prod_user;


--
-- Name: TABLE pg_statistic; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_statistic TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_statistic TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_statistic TO dbt_prod_user;


--
-- Name: TABLE pg_statistic_ext; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_statistic_ext TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_statistic_ext TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_statistic_ext TO dbt_prod_user;


--
-- Name: TABLE pg_statistic_ext_data; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_statistic_ext_data TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_statistic_ext_data TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_statistic_ext_data TO dbt_prod_user;


--
-- Name: TABLE pg_stats; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_stats TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_stats TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_stats TO dbt_prod_user;


--
-- Name: TABLE pg_stats_ext; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_stats_ext TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_stats_ext TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_stats_ext TO dbt_prod_user;


--
-- Name: TABLE pg_stats_ext_exprs; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_stats_ext_exprs TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_stats_ext_exprs TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_stats_ext_exprs TO dbt_prod_user;


--
-- Name: TABLE pg_subscription; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_subscription TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_subscription TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_subscription TO dbt_prod_user;


--
-- Name: TABLE pg_subscription_rel; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_subscription_rel TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_subscription_rel TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_subscription_rel TO dbt_prod_user;


--
-- Name: TABLE pg_tables; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_tables TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_tables TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_tables TO dbt_prod_user;


--
-- Name: TABLE pg_tablespace; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_tablespace TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_tablespace TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_tablespace TO dbt_prod_user;


--
-- Name: TABLE pg_timezone_abbrevs; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_timezone_abbrevs TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_timezone_abbrevs TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_timezone_abbrevs TO dbt_prod_user;


--
-- Name: TABLE pg_timezone_names; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_timezone_names TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_timezone_names TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_timezone_names TO dbt_prod_user;


--
-- Name: TABLE pg_transform; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_transform TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_transform TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_transform TO dbt_prod_user;


--
-- Name: TABLE pg_trigger; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_trigger TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_trigger TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_trigger TO dbt_prod_user;


--
-- Name: TABLE pg_ts_config; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_ts_config TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_ts_config TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_ts_config TO dbt_prod_user;


--
-- Name: TABLE pg_ts_config_map; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_ts_config_map TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_ts_config_map TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_ts_config_map TO dbt_prod_user;


--
-- Name: TABLE pg_ts_dict; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_ts_dict TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_ts_dict TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_ts_dict TO dbt_prod_user;


--
-- Name: TABLE pg_ts_parser; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_ts_parser TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_ts_parser TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_ts_parser TO dbt_prod_user;


--
-- Name: TABLE pg_ts_template; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_ts_template TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_ts_template TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_ts_template TO dbt_prod_user;


--
-- Name: TABLE pg_type; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_type TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_type TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_type TO dbt_prod_user;


--
-- Name: TABLE pg_user; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_user TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_user TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_user TO dbt_prod_user;


--
-- Name: TABLE pg_user_mapping; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_user_mapping TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_user_mapping TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_user_mapping TO dbt_prod_user;


--
-- Name: TABLE pg_user_mappings; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_user_mappings TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_user_mappings TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_user_mappings TO dbt_prod_user;


--
-- Name: TABLE pg_views; Type: ACL; Schema: pg_catalog; Owner: rollyangell
--

GRANT SELECT ON TABLE pg_catalog.pg_views TO dbt_dev_user;
GRANT SELECT ON TABLE pg_catalog.pg_views TO dbt_staging_user;
GRANT SELECT ON TABLE pg_catalog.pg_views TO dbt_prod_user;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: analytics; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA analytics GRANT ALL ON SEQUENCES  TO dbt_dev_user;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA analytics GRANT ALL ON SEQUENCES  TO dbt_staging_user;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA analytics GRANT ALL ON SEQUENCES  TO dbt_prod_user;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: analytics; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA analytics GRANT ALL ON FUNCTIONS  TO dbt_dev_user;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA analytics GRANT ALL ON FUNCTIONS  TO dbt_staging_user;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA analytics GRANT ALL ON FUNCTIONS  TO dbt_prod_user;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: analytics; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA analytics GRANT ALL ON TABLES  TO dbt_user;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA analytics GRANT ALL ON TABLES  TO dbt_dev_user;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA analytics GRANT ALL ON TABLES  TO dbt_staging_user;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA analytics GRANT ALL ON TABLES  TO dbt_prod_user;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: analytics_dev; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA analytics_dev GRANT ALL ON SEQUENCES  TO dbt_dev_user;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA analytics_dev GRANT ALL ON SEQUENCES  TO dbt_staging_user;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA analytics_dev GRANT ALL ON SEQUENCES  TO dbt_prod_user;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: analytics_dev; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA analytics_dev GRANT ALL ON FUNCTIONS  TO dbt_dev_user;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA analytics_dev GRANT ALL ON FUNCTIONS  TO dbt_staging_user;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA analytics_dev GRANT ALL ON FUNCTIONS  TO dbt_prod_user;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: analytics_dev; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA analytics_dev GRANT ALL ON TABLES  TO dbt_dev_user;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA analytics_dev GRANT ALL ON TABLES  TO dbt_staging_user;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA analytics_dev GRANT ALL ON TABLES  TO dbt_prod_user;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: analytics_staging; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA analytics_staging GRANT ALL ON SEQUENCES  TO dbt_dev_user;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA analytics_staging GRANT ALL ON SEQUENCES  TO dbt_staging_user;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA analytics_staging GRANT ALL ON SEQUENCES  TO dbt_prod_user;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: analytics_staging; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA analytics_staging GRANT ALL ON FUNCTIONS  TO dbt_dev_user;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA analytics_staging GRANT ALL ON FUNCTIONS  TO dbt_staging_user;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA analytics_staging GRANT ALL ON FUNCTIONS  TO dbt_prod_user;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: analytics_staging; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA analytics_staging GRANT ALL ON TABLES  TO dbt_dev_user;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA analytics_staging GRANT ALL ON TABLES  TO dbt_staging_user;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA analytics_staging GRANT ALL ON TABLES  TO dbt_prod_user;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES  TO dbt_dev_user;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES  TO dbt_staging_user;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES  TO dbt_prod_user;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS  TO dbt_dev_user;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS  TO dbt_staging_user;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS  TO dbt_prod_user;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES  TO dbt_dev_user;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES  TO dbt_staging_user;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES  TO dbt_prod_user;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: raw; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA raw GRANT ALL ON SEQUENCES  TO dbt_dev_user;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA raw GRANT ALL ON SEQUENCES  TO dbt_staging_user;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA raw GRANT ALL ON SEQUENCES  TO dbt_prod_user;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: raw; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA raw GRANT ALL ON FUNCTIONS  TO dbt_dev_user;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA raw GRANT ALL ON FUNCTIONS  TO dbt_staging_user;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA raw GRANT ALL ON FUNCTIONS  TO dbt_prod_user;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: raw; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA raw GRANT ALL ON TABLES  TO dbt_user;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA raw GRANT ALL ON TABLES  TO dbt_dev_user;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA raw GRANT ALL ON TABLES  TO dbt_staging_user;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA raw GRANT ALL ON TABLES  TO dbt_prod_user;


--
-- PostgreSQL database dump complete
--

