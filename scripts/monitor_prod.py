#!/usr/bin/env python3
"""
Production Monitoring Script for E-commerce Data Warehouse
This script monitors data freshness, quality, and sends alerts for issues
"""

import psycopg2
import requests
import os
import sys
import json
import logging
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Tuple

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('logs/monitoring.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

class ProductionMonitor:
    """Production monitoring class for data warehouse health checks"""
    
    def __init__(self):
        self.db_params = {
            'host': os.getenv('DB_HOST'),
            'port': os.getenv('DB_PORT', 5432),
            'database': os.getenv('DB_NAME'),
            'user': os.getenv('DB_USER'),
            'password': os.getenv('DB_PASSWORD')
        }
        self.slack_webhook = os.getenv('SLACK_WEBHOOK_URL')
        self.email_alerts = os.getenv('EMAIL_ALERTS', '').split(',')
        self.schema = os.getenv('DB_SCHEMA', 'analytics')
        
    def get_db_connection(self) -> psycopg2.connection:
        """Establish database connection"""
        try:
            conn = psycopg2.connect(**self.db_params)
            return conn
        except Exception as e:
            logger.error(f"Database connection failed: {e}")
            self.send_alert("🚨 Database Connection Failed", f"Cannot connect to production database: {e}")
            raise
    
    def check_data_freshness(self) -> List[Dict]:
        """Check if data is fresh (updated recently)"""
        logger.info("Checking data freshness...")
        
        freshness_query = f"""
        SELECT 
            'dim_customers' as table_name,
            max(_loaded_at) as last_update,
            extract(epoch from (now() - max(_loaded_at)))/3600 as hours_since_update
        FROM {self.schema}.dim_customers
        
        UNION ALL
        
        SELECT 
            'dim_products' as table_name,
            max(_loaded_at) as last_update,
            extract(epoch from (now() - max(_loaded_at)))/3600 as hours_since_update
        FROM {self.schema}.dim_products
        
        UNION ALL
        
        SELECT 
            'fct_orders' as table_name,
            max(_loaded_at) as last_update,
            extract(epoch from (now() - max(_loaded_at)))/3600 as hours_since_update
        FROM {self.schema}.fct_orders
        
        UNION ALL
        
        SELECT 
            'fct_visits' as table_name,
            max(_loaded_at) as last_update,
            extract(epoch from (now() - max(_loaded_at)))/3600 as hours_since_update
        FROM {self.schema}.fct_visits
        """
        
        stale_tables = []
        
        try:
            conn = self.get_db_connection()
            cursor = conn.cursor()
            cursor.execute(freshness_query)
            results = cursor.fetchall()
            
            for table_name, last_update, hours_since in results:
                if hours_since > 24:  # Data older than 24 hours
                    stale_tables.append({
                        'table': table_name,
                        'last_update': last_update,
                        'hours_since': round(hours_since, 2)
                    })
                    
            conn.close()
            
            if stale_tables:
                message = "⚠️ STALE DATA DETECTED in production:\n"
                for table in stale_tables:
                    message += f"- {table['table']}: {table['hours_since']} hours old\n"
                
                self.send_alert("Data Freshness Alert", message)
                logger.warning(f"Stale data detected: {stale_tables}")
            else:
                logger.info("All data is fresh")
                
        except Exception as e:
            logger.error(f"Data freshness check failed: {e}")
            self.send_alert("Monitoring Error", f"Data freshness check failed: {e}")
            
        return stale_tables
    
    def check_data_quality(self) -> List[Dict]:
        """Run data quality checks"""
        logger.info("Running data quality checks...")
        
        quality_checks = [
            {
                'name': 'Null Customer IDs',
                'query': f"SELECT count(*) FROM {self.schema}.dim_customers WHERE customer_id IS NULL",
                'threshold': 0
            },
            {
                'name': 'Negative Order Amounts',
                'query': f"SELECT count(*) FROM {self.schema}.fct_orders WHERE total_amount < 0",
                'threshold': 0
            },
            {
                'name': 'Future Order Dates',
                'query': f"SELECT count(*) FROM {self.schema}.fct_orders WHERE order_date > CURRENT_DATE",
                'threshold': 0
            },
            {
                'name': 'Orphaned Orders',
                'query': f"""
                    SELECT count(*) 
                    FROM {self.schema}.fct_orders o 
                    LEFT JOIN {self.schema}.dim_customers c ON o.customer_id = c.customer_id 
                    WHERE c.customer_id IS NULL
                """,
                'threshold': 0
            },
            {
                'name': 'Zero Price Products',
                'query': f"SELECT count(*) FROM {self.schema}.dim_products WHERE price <= 0",
                'threshold': 0
            }
        ]
        
        failed_checks = []
        
        try:
            conn = self.get_db_connection()
            cursor = conn.cursor()
            
            for check in quality_checks:
                cursor.execute(check['query'])
                result = cursor.fetchone()[0]
                
                if result > check['threshold']:
                    failed_checks.append({
                        'name': check['name'],
                        'count': result,
                        'threshold': check['threshold']
                    })
                    logger.warning(f"Quality check failed: {check['name']} - {result} issues found")
                else:
                    logger.info(f"Quality check passed: {check['name']}")
            
            conn.close()
            
            if failed_checks:
                message = "❌ DATA QUALITY ISSUES in production:\n"
                for check in failed_checks:
                    message += f"- {check['name']}: {check['count']} issues (threshold: {check['threshold']})\n"
                
                self.send_alert("Data Quality Alert", message)
                
        except Exception as e:
            logger.error(f"Data quality checks failed: {e}")
            self.send_alert("Monitoring Error", f"Data quality checks failed: {e}")
            
        return failed_checks
    
    def check_table_row_counts(self) -> Dict[str, int]:
        """Check row counts for all main tables"""
        logger.info("Checking table row counts...")
        
        tables = ['dim_customers', 'dim_products', 'dim_date', 'fct_orders', 'fct_visits']
        row_counts = {}
        
        try:
            conn = self.get_db_connection()
            cursor = conn.cursor()
            
            for table in tables:
                cursor.execute(f"SELECT count(*) FROM {self.schema}.{table}")
                count = cursor.fetchone()[0]
                row_counts[table] = count
                logger.info(f"{table}: {count:,} rows")
                
                # Alert on suspicious row counts
                if table.startswith('fct_') and count == 0:
                    self.send_alert("Data Volume Alert", f"Fact table {table} is empty!")
                elif table.startswith('dim_') and count == 0:
                    self.send_alert("Data Volume Alert", f"Dimension table {table} is empty!")
            
            conn.close()
            
        except Exception as e:
            logger.error(f"Row count check failed: {e}")
            self.send_alert("Monitoring Error", f"Row count check failed: {e}")
            
        return row_counts
    
    def check_system_performance(self) -> Dict:
        """Check database performance metrics"""
        logger.info("Checking system performance...")
        
        performance_query = f"""
        SELECT 
            schemaname,
            tablename,
            n_tup_ins as inserts,
            n_tup_upd as updates,
            n_tup_del as deletes,
            n_live_tup as live_tuples,
            n_dead_tup as dead_tuples,
            last_vacuum,
            last_autovacuum,
            last_analyze,
            last_autoanalyze
        FROM pg_stat_user_tables 
        WHERE schemaname = '{self.schema}'
        ORDER BY n_live_tup DESC
        """
        
        performance_data = {}
        
        try:
            conn = self.get_db_connection()
            cursor = conn.cursor()
            cursor.execute(performance_query)
            results = cursor.fetchall()
            
            columns = [desc[0] for desc in cursor.description]
            
            for row in results:
                table_data = dict(zip(columns, row))
                table_name = table_data['tablename']
                performance_data[table_name] = table_data
                
                # Check for tables that need maintenance
                dead_ratio = table_data['dead_tuples'] / max(table_data['live_tuples'], 1)
                if dead_ratio > 0.1:  # More than 10% dead tuples
                    logger.warning(f"Table {table_name} has high dead tuple ratio: {dead_ratio:.2%}")
            
            conn.close()
            
        except Exception as e:
            logger.error(f"Performance check failed: {e}")
            
        return performance_data
    
    def send_alert(self, title: str, message: str, severity: str = "warning"):
        """Send alert via Slack and/or email"""
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        
        # Send Slack notification
        if self.slack_webhook:
            try:
                color = {
                    "info": "good",
                    "warning": "warning", 
                    "error": "danger"
                }.get(severity, "warning")
                
                payload = {
                    "text": f"🔔 Production Monitoring Alert",
                    "attachments": [
                        {
                            "color": color,
                            "title": title,
                            "text": message,
                            "fields": [
                                {
                                    "title": "Environment",
                                    "value": "Production",
                                    "short": True
                                },
                                {
                                    "title": "Database",
                                    "value": self.db_params['database'],
                                    "short": True
                                },
                                {
                                    "title": "Timestamp",
                                    "value": timestamp,
                                    "short": False
                                }
                            ]
                        }
                    ]
                }
                
                response = requests.post(
                    self.slack_webhook,
                    json=payload,
                    timeout=10
                )
                
                if response.status_code == 200:
                    logger.info("Slack alert sent successfully")
                else:
                    logger.error(f"Slack alert failed: {response.status_code}")
                    
            except Exception as e:
                logger.error(f"Failed to send Slack alert: {e}")
        
        # Email notifications would be implemented here
        if self.email_alerts and self.email_alerts[0]:
            logger.info(f"Email alerts configured for: {self.email_alerts}")
            # Email implementation would go here
    
    def generate_health_report(self) -> Dict:
        """Generate comprehensive health report"""
        logger.info("Generating production health report...")
        
        report = {
            'timestamp': datetime.now().isoformat(),
            'environment': 'production',
            'database': self.db_params['database'],
            'checks': {}
        }
        
        # Run all checks
        report['checks']['data_freshness'] = self.check_data_freshness()
        report['checks']['data_quality'] = self.check_data_quality()
        report['checks']['row_counts'] = self.check_table_row_counts()
        report['checks']['performance'] = self.check_system_performance()
        
        # Calculate overall health score
        issues = len(report['checks']['data_freshness']) + len(report['checks']['data_quality'])
        health_score = max(0, 100 - (issues * 10))  # Deduct 10 points per issue
        
        report['health_score'] = health_score
        report['status'] = 'healthy' if health_score >= 80 else 'warning' if health_score >= 60 else 'critical'
        
        logger.info(f"Health report generated - Score: {health_score}/100, Status: {report['status']}")
        
        return report
    
    def save_report(self, report: Dict, filename: Optional[str] = None):
        """Save health report to file"""
        if not filename:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            filename = f"reports/health_report_{timestamp}.json"
        
        os.makedirs(os.path.dirname(filename), exist_ok=True)
        
        with open(filename, 'w') as f:
            json.dump(report, f, indent=2, default=str)
        
        logger.info(f"Health report saved to {filename}")

def main():
    """Main monitoring function"""
    logger.info("Starting production monitoring...")
    
    # Load environment variables
    if not os.getenv('DB_HOST'):
        logger.error("Environment variables not loaded. Run with proper environment setup.")
        sys.exit(1)
    
    try:
        monitor = ProductionMonitor()
        
        # Generate health report
        report = monitor.generate_health_report()
        
        # Save report
        monitor.save_report(report)
        
        # Send summary alert if there are issues
        if report['status'] != 'healthy':
            summary = f"Production Health Score: {report['health_score']}/100 ({report['status'].upper()})\n"
            summary += f"Issues found: {len(report['checks']['data_freshness']) + len(report['checks']['data_quality'])}"
            
            monitor.send_alert(
                f"Production Health Report - {report['status'].title()}",
                summary,
                "error" if report['status'] == 'critical' else "warning"
            )
        
        logger.info("Production monitoring completed successfully")
        
    except Exception as e:
        logger.error(f"Production monitoring failed: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main() 