#!/usr/bin/env python3
"""
Data loading script for E-commerce Data Warehouse
Loads CSV files into PostgreSQL raw schema
"""

import pandas as pd
import psycopg2
import logging
import sys

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# Database connection parameters
DB_PARAMS = {
    'host': 'localhost',
    'port': 5432,
    'database': 'ecommerce_dw',
    'user': 'postgres',
    'password': 'password'
}

def load_csv_to_postgres():
    conn = None
    try:
        # Connect to PostgreSQL
        conn = psycopg2.connect(**DB_PARAMS)
        cur = conn.cursor()
        logging.info("Connected to PostgreSQL")
        
        # Load customers
        df = pd.read_csv('data/customers.csv')
        logging.info(f"Loading {len(df)} customers...")
        cur.execute("TRUNCATE TABLE raw.customers CASCADE")
        for _, row in df.iterrows():
            cur.execute("""
                INSERT INTO raw.customers (customer_id, first_name, last_name, email, registration_date)
                VALUES (%s, %s, %s, %s, %s)
            """, (row['customer_id'], row['first_name'], row['last_name'], row['email'], row['registration_date']))
        
        # Load products
        df = pd.read_csv('data/products.csv')
        logging.info(f"Loading {len(df)} products...")
        cur.execute("TRUNCATE TABLE raw.products CASCADE")
        for _, row in df.iterrows():
            cur.execute("""
                INSERT INTO raw.products (product_id, product_name, category, price)
                VALUES (%s, %s, %s, %s)
            """, (row['product_id'], row['product_name'], row['category'], row['price']))
        
        # Load orders
        df = pd.read_csv('data/orders.csv')
        logging.info(f"Loading {len(df)} orders...")
        cur.execute("TRUNCATE TABLE raw.orders CASCADE")
        for _, row in df.iterrows():
            cur.execute("""
                INSERT INTO raw.orders (order_id, customer_id, order_date, product_id, quantity, total_amount)
                VALUES (%s, %s, %s, %s, %s, %s)
            """, (row['order_id'], row['customer_id'], row['order_date'], row['product_id'], row['quantity'], row['total_amount']))
        
        # Load visits
        df = pd.read_csv('data/visits.csv')
        logging.info(f"Loading {len(df)} visits...")
        cur.execute("TRUNCATE TABLE raw.visits CASCADE")
        for _, row in df.iterrows():
            cur.execute("""
                INSERT INTO raw.visits (visit_id, customer_id, visit_date, duration_minutes, pages_viewed)
                VALUES (%s, %s, %s, %s, %s)
            """, (row['visit_id'], row['customer_id'], row['visit_date'], row['duration_minutes'], row['pages_viewed']))
        
        # Commit all changes
        conn.commit()
        logging.info("✅ All data loaded successfully!")
        
        # Verify data
        cur.execute("SELECT 'customers' as table_name, count(*) FROM raw.customers UNION ALL SELECT 'products', count(*) FROM raw.products UNION ALL SELECT 'orders', count(*) FROM raw.orders UNION ALL SELECT 'visits', count(*) FROM raw.visits")
        results = cur.fetchall()
        for table, count in results:
            logging.info(f"{table}: {count} rows")
            
    except Exception as e:
        logging.error(f"Error: {e}")
        if conn:
            conn.rollback()
        sys.exit(1)
    finally:
        if conn:
            conn.close()

if __name__ == "__main__":
    load_csv_to_postgres() 