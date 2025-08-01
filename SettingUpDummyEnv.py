#!/usr/bin/env python3
"""
Banking Employee Behavior Simulator for macOS
Simulates realistic banking sector employee activities without requiring credentials
Perfect for security training, monitoring system testing, and CTF scenarios
"""

import os
import time
import random
import json
import subprocess
import threading
from datetime import datetime, timedelta
from pathlib import Path
import logging

class BankingEmployeeSimulator:
    def __init__(self, employee_name="Sarah Chen", department="Finance"):
        self.employee_name = employee_name
        self.department = department
        self.home_dir = Path.home()
        self.work_dir = self.home_dir / "Documents" / "BankWork"
        self.temp_dir = self.home_dir / "Downloads" / "temp_banking"
        self.is_running = False
        
        # Set up logging
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler(self.home_dir / 'banking_simulation.log'),
                logging.StreamHandler()
            ]
        )
        self.logger = logging.getLogger(__name__)
        
        # Employee behavior patterns
        self.applications = [
            "Microsoft Excel", "Microsoft Word", "Microsoft Outlook",
            "Safari", "Chrome", "Calculator", "Preview", "Numbers",
            "Terminal", "Activity Monitor", "Keychain Access"
        ]
        
        self.banking_websites = [
            "https://internal-banking-portal.testbank.com",
            "https://core-banking.testbank.com",
            "https://regulatory-reporting.testbank.com",
            "https://risk-management.testbank.com",
            "https://customer-portal.testbank.com"
        ]
        
        self.file_types = {
            'financial_reports': ['.xlsx', '.csv', '.pdf'],
            'presentations': ['.pptx', '.key'],
            'documents': ['.docx', '.pages', '.txt'],
            'data_files': ['.json', '.xml', '.sql']
        }
        
        self.setup_workspace()

    def setup_workspace(self):
        """Create realistic banking workspace structure"""
        directories = [
            self.work_dir / "Financial_Reports",
            self.work_dir / "Client_Data",
            self.work_dir / "Regulatory_Docs",
            self.work_dir / "Internal_Memos",
            self.work_dir / "Risk_Analysis",
            self.work_dir / "Compliance",
            self.temp_dir
        ]
        
        for directory in directories:
            directory.mkdir(parents=True, exist_ok=True)
        
        self.logger.info(f"Workspace setup complete for {self.employee_name}")

    def simulate_file_operations(self):
        """Simulate typical banking file operations"""
        operations = [
            self.create_financial_report,
            self.update_client_data,
            self.create_compliance_document,
            self.generate_risk_analysis,
            self.backup_files,
            self.access_regulatory_docs
        ]
        
        operation = random.choice(operations)
        operation()

    def create_financial_report(self):
        """Simulate creating financial reports"""
        report_types = ["Monthly_P&L", "Cash_Flow_Analysis", "Budget_Variance", 
                       "Credit_Risk_Report", "Investment_Summary"]
        report_type = random.choice(report_types)
        
        filename = f"{report_type}_{datetime.now().strftime('%Y%m%d')}.xlsx"
        filepath = self.work_dir / "Financial_Reports" / filename
        
        # Create fake Excel-like data
        fake_data = {
            "report_type": report_type,
            "generated_by": self.employee_name,
            "timestamp": datetime.now().isoformat(),
            "department": self.department,
            "data": {
                "total_assets": random.randint(1000000, 10000000),
                "total_liabilities": random.randint(500000, 8000000),
                "net_income": random.randint(50000, 500000),
                "risk_score": round(random.uniform(1.0, 10.0), 2)
            }
        }
        
        with open(filepath, 'w') as f:
            json.dump(fake_data, f, indent=2)
        
        self.logger.info(f"Created financial report: {filename}")
        
        # Simulate Excel opening time
        time.sleep(random.uniform(2, 5))

    def update_client_data(self):
        """Simulate updating client information"""
        client_files = ["High_Net_Worth_Clients.csv", "Corporate_Accounts.xlsx", 
                       "Loan_Portfolio.json", "Investment_Clients.csv"]
        filename = random.choice(client_files)
        filepath = self.work_dir / "Client_Data" / filename
        
        client_data = {
            "last_updated": datetime.now().isoformat(),
            "updated_by": self.employee_name,
            "clients_processed": random.randint(10, 50),
            "accounts_reviewed": random.randint(25, 100),
            "flags_raised": random.randint(0, 5)
        }
        
        with open(filepath, 'w') as f:
            json.dump(client_data, f, indent=2)
        
        self.logger.info(f"Updated client data file: {filename}")
        time.sleep(random.uniform(1, 3))

    def create_compliance_document(self):
        """Simulate creating compliance documentation"""
        compliance_docs = ["AML_Review", "KYC_Updates", "Regulatory_Filing", 
                          "Audit_Response", "Policy_Update"]
        doc_type = random.choice(compliance_docs)
        
        filename = f"{doc_type}_{datetime.now().strftime('%Y%m%d')}.docx"
        filepath = self.work_dir / "Compliance" / filename
        
        compliance_content = f"""
CONFIDENTIAL - INTERNAL USE ONLY

{doc_type} Document
Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
Author: {self.employee_name}
Department: {self.department}

Summary:
- Compliance review completed
- No significant issues identified
- Recommendations for improvement documented
- Next review scheduled for {(datetime.now() + timedelta(days=30)).strftime('%Y-%m-%d')}

Classification: Internal
Distribution: Compliance Team Only
"""
        
        with open(filepath, 'w') as f:
            f.write(compliance_content)
        
        self.logger.info(f"Created compliance document: {filename}")
        time.sleep(random.uniform(3, 7))

    def generate_risk_analysis(self):
        """Simulate risk analysis activities"""
        risk_types = ["Credit_Risk", "Market_Risk", "Operational_Risk", 
                     "Liquidity_Risk", "Regulatory_Risk"]
        risk_type = random.choice(risk_types)
        
        filename = f"{risk_type}_Analysis_{datetime.now().strftime('%Y%m%d')}.json"
        filepath = self.work_dir / "Risk_Analysis" / filename
        
        risk_data = {
            "analysis_type": risk_type,
            "analyst": self.employee_name,
            "date": datetime.now().isoformat(),
            "risk_level": random.choice(["Low", "Medium", "High", "Critical"]),
            "probability": round(random.uniform(0.1, 0.9), 2),
            "impact_score": random.randint(1, 10),
            "mitigation_strategies": [
                "Implement additional controls",
                "Increase monitoring frequency",
                "Review policy limits",
                "Escalate to management"
            ]
        }
        
        with open(filepath, 'w') as f:
            json.dump(risk_data, f, indent=2)
        
        self.logger.info(f"Generated risk analysis: {filename}")
        time.sleep(random.uniform(2, 4))

    def backup_files(self):
        """Simulate file backup operations"""
        backup_dir = self.work_dir / "Backups" / datetime.now().strftime('%Y%m%d')
        backup_dir.mkdir(parents=True, exist_ok=True)
        
        # Simulate copying important files
        source_dirs = [self.work_dir / "Financial_Reports", self.work_dir / "Client_Data"]
        
        for source_dir in source_dirs:
            if source_dir.exists():
                for file_path in source_dir.iterdir():
                    if file_path.is_file():
                        backup_path = backup_dir / file_path.name
                        # Simulate file copy without actually copying
                        time.sleep(0.1)
        
        self.logger.info(f"Backup operation completed to {backup_dir}")
        time.sleep(random.uniform(5, 10))

    def access_regulatory_docs(self):
        """Simulate accessing regulatory documentation"""
        reg_docs = ["Basel_III_Guidelines.pdf", "FDIC_Regulations.pdf", 
                   "SOX_Compliance.docx", "GDPR_Banking.pdf", "AML_Guidelines.txt"]
        doc_name = random.choice(reg_docs)
        filepath = self.work_dir / "Regulatory_Docs" / doc_name
        
        # Create regulatory document
        reg_content = f"""
REGULATORY DOCUMENT - {doc_name}
Last Accessed: {datetime.now().isoformat()}
Accessed By: {self.employee_name}

This document contains regulatory guidelines and compliance requirements.
Classification: Restricted Access
Review Required: Yes
"""
        
        with open(filepath, 'w') as f:
            f.write(reg_content)
        
        self.logger.info(f"Accessed regulatory document: {doc_name}")
        time.sleep(random.uniform(10, 20))  # Longer read time

    def simulate_application_usage(self):
        """Simulate opening and using banking applications"""
        app = random.choice(self.applications)
        
        try:
            # On macOS, simulate opening applications
            if app in ["Microsoft Excel", "Microsoft Word", "Microsoft Outlook"]:
                # Simulate Office applications
                self.logger.info(f"Opening {app} for banking work")
                time.sleep(random.uniform(3, 8))  # App launch time
                
            elif app in ["Safari", "Chrome"]:
                # Simulate web browser usage
                website = random.choice(self.banking_websites)
                self.logger.info(f"Accessing {website} via {app}")
                time.sleep(random.uniform(5, 15))  # Web browsing time
                
            elif app == "Terminal":
                # Simulate terminal commands
                commands = [
                    "ls -la ~/Documents/BankWork",
                    "du -sh ~/Documents/BankWork/*",
                    "find . -name '*.xlsx' -mtime -1",
                    "grep -r 'CONFIDENTIAL' ~/Documents/BankWork/"
                ]
                cmd = random.choice(commands)
                self.logger.info(f"Executing terminal command: {cmd}")
                time.sleep(random.uniform(1, 3))
                
            else:
                self.logger.info(f"Using {app} for banking operations")
                time.sleep(random.uniform(2, 5))
                
        except Exception as e:
            self.logger.error(f"Error simulating {app}: {e}")

    def simulate_network_activity(self):
        """Simulate network-related activities"""
        activities = [
            "VPN connection check",
            "Internal banking portal access",
            "Email server synchronization",
            "Database query execution",
            "File server backup",
            "Regulatory reporting upload"
        ]
        
        activity = random.choice(activities)
        self.logger.info(f"Network activity: {activity}")
        
        # Simulate network delay
        time.sleep(random.uniform(1, 5))

    def simulate_security_actions(self):
        """Simulate security-related actions"""
        security_actions = [
            "Password policy compliance check",
            "Two-factor authentication verification",
            "Security certificate validation",
            "Encrypted file access",
            "Audit log review",
            "Security policy acknowledgment"
        ]
        
        action = random.choice(security_actions)
        self.logger.info(f"Security action: {action}")
        
        # Log security event
        security_log = {
            "timestamp": datetime.now().isoformat(),
            "employee": self.employee_name,
            "action": action,
            "result": "Success",
            "ip_address": f"192.168.1.{random.randint(100, 200)}",
            "department": self.department
        }
        
        security_log_path = self.home_dir / "security_events.log"
        with open(security_log_path, 'a') as f:
            f.write(json.dumps(security_log) + '\n')
        
        time.sleep(random.uniform(2, 4))

    def simulate_work_day(self):
        """Simulate a typical banking work day"""
        work_activities = [
            (self.simulate_file_operations, 0.4),      # 40% of time
            (self.simulate_application_usage, 0.3),    # 30% of time
            (self.simulate_network_activity, 0.2),     # 20% of time
            (self.simulate_security_actions, 0.1)      # 10% of time
        ]
        
        # Weight-based selection
        activities = []
        weights = []
        for activity, weight in work_activities:
            activities.append(activity)
            weights.append(weight)
        
        while self.is_running:
            try:
                # Simulate work hours (9 AM - 5 PM)
                current_hour = datetime.now().hour
                if 9 <= current_hour <= 17:
                    # Higher activity during work hours
                    activity = random.choices(activities, weights=weights)[0]
                    activity()
                    
                    # Random pause between activities
                    pause_time = random.uniform(30, 300)  # 30 seconds to 5 minutes
                    time.sleep(pause_time)
                else:
                    # Minimal activity outside work hours
                    if random.random() < 0.1:  # 10% chance of after-hours activity
                        self.simulate_security_actions()
                    time.sleep(random.uniform(300, 1800))  # 5-30 minutes pause
                    
            except KeyboardInterrupt:
                self.logger.info("Simulation interrupted by user")
                break
            except Exception as e:
                self.logger.error(f"Error in work simulation: {e}")
                time.sleep(60)  # Wait a minute before retrying

    def start_simulation(self):
        """Start the banking employee simulation"""
        self.is_running = True
        self.logger.info(f"Starting banking employee simulation for {self.employee_name}")
        
        try:
            self.simulate_work_day()
        except KeyboardInterrupt:
            self.stop_simulation()

    def stop_simulation(self):
        """Stop the simulation"""
        self.is_running = False
        self.logger.info("Banking employee simulation stopped")

    def generate_daily_report(self):
        """Generate a daily activity report"""
        report = {
            "date": datetime.now().strftime('%Y-%m-%d'),
            "employee": self.employee_name,
            "department": self.department,
            "files_created": random.randint(5, 15),
            "applications_used": random.randint(3, 8),
            "network_activities": random.randint(10, 25),
            "security_events": random.randint(2, 8),
            "work_hours": round(random.uniform(7.5, 9.0), 1),
            "suspicious_activities": random.randint(0, 2)
        }
        
        report_path = self.work_dir / f"daily_report_{datetime.now().strftime('%Y%m%d')}.json"
        with open(report_path, 'w') as f:
            json.dump(report, f, indent=2)
        
        self.logger.info(f"Daily report generated: {report_path}")
        return report

def main():
    """Main function to run the banking employee simulator"""
    print("Banking Employee Behavior Simulator for macOS")
    print("=" * 50)
    
    # You can customize the employee details here
    employees = [
        ("Sarah Chen", "Finance"),
        ("Michael Rodriguez", "Risk Management"),
        ("Jennifer Miller", "Compliance"),
        ("David Wilson", "IT"),
        ("Lisa Thompson", "Operations")
    ]
    
    employee_name, department = random.choice(employees)
    simulator = BankingEmployeeSimulator(employee_name, department)
    
    print(f"Simulating behavior for: {employee_name} ({department})")
    print("Press Ctrl+C to stop the simulation")
    print("-" * 50)
    
    try:
        # Run simulation
        simulator.start_simulation()
    except KeyboardInterrupt:
        print("\nStopping simulation...")
        simulator.stop_simulation()
        
        # Generate final report
        print("Generating daily report...")
        report = simulator.generate_daily_report()
        print(f"Final Report: {json.dumps(report, indent=2)}")

if __name__ == "__main__":
    main()
