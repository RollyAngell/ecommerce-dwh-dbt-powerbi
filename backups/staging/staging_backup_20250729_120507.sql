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


--
-- Name: SCHEMA analytics_dev; Type: ACL; Schema: -; Owner: postgres
--

GRANT ALL ON SCHEMA analytics_dev TO dbt_dev_user;


--
-- Name: SCHEMA analytics_staging; Type: ACL; Schema: -; Owner: postgres
--

GRANT ALL ON SCHEMA analytics_staging TO dbt_staging_user;


--
-- Name: SCHEMA raw; Type: ACL; Schema: -; Owner: postgres
--

GRANT ALL ON SCHEMA raw TO dbt_dev_user;
GRANT ALL ON SCHEMA raw TO dbt_staging_user;
GRANT ALL ON SCHEMA raw TO dbt_prod_user;
GRANT ALL ON SCHEMA raw TO dbt_user;


--
-- Name: TABLE customers; Type: ACL; Schema: raw; Owner: postgres
--

GRANT ALL ON TABLE raw.customers TO dbt_user;
GRANT ALL ON TABLE raw.customers TO dbt_dev_user;
GRANT ALL ON TABLE raw.customers TO dbt_staging_user;
GRANT ALL ON TABLE raw.customers TO dbt_prod_user;


--
-- Name: TABLE orders; Type: ACL; Schema: raw; Owner: postgres
--

GRANT ALL ON TABLE raw.orders TO dbt_user;
GRANT ALL ON TABLE raw.orders TO dbt_dev_user;
GRANT ALL ON TABLE raw.orders TO dbt_staging_user;
GRANT ALL ON TABLE raw.orders TO dbt_prod_user;


--
-- Name: TABLE products; Type: ACL; Schema: raw; Owner: postgres
--

GRANT ALL ON TABLE raw.products TO dbt_user;
GRANT ALL ON TABLE raw.products TO dbt_dev_user;
GRANT ALL ON TABLE raw.products TO dbt_staging_user;
GRANT ALL ON TABLE raw.products TO dbt_prod_user;


--
-- Name: TABLE visits; Type: ACL; Schema: raw; Owner: postgres
--

GRANT ALL ON TABLE raw.visits TO dbt_user;
GRANT ALL ON TABLE raw.visits TO dbt_dev_user;
GRANT ALL ON TABLE raw.visits TO dbt_staging_user;
GRANT ALL ON TABLE raw.visits TO dbt_prod_user;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: analytics; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA analytics GRANT ALL ON TABLES  TO dbt_user;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA analytics GRANT ALL ON TABLES  TO dbt_prod_user;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: analytics_dev; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA analytics_dev GRANT ALL ON TABLES  TO dbt_dev_user;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: analytics_staging; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA analytics_staging GRANT ALL ON TABLES  TO dbt_staging_user;


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

