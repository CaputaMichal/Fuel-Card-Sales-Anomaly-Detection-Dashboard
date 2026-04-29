![SQL](https://img.shields.io/badge/Language-SQL-blue)
![Python](https://img.shields.io/badge/Language-Python-yellow)
![PowerBI](https://img.shields.io/badge/Tool-PowerBI-orange)

# Fuel Card Sales & Anomaly Detection Dashboard

## 📊 Project Overview
This project focuses on analyzing fuel transaction data across 25 European markets. The goal was to monitor sales performance and identify potential fraud using a combination of SQL, Power BI, and Python.

The project covers the entire data lifecycle: from designing the database schema and generating synthetic data, through advanced modeling in Power BI, to exploratory data analysis (EDA) in Python.

---

## 🔒 Data Privacy & Authenticity
**Important:** To ensure data privacy and comply with security standards, all datasets used in this project are **synthetic and randomly generated**. No real customer or corporate data was used. This project is a demonstration of data modeling, SQL logic, and visualization skills.

---

## 🛠 Tech Stack & Workflow

### 1. SQL: Foundation & Data Engineering
* **Schema Design:** Building the database structure from scratch, including tables for countries, customers, fuel cards, and transactions with enforced referential integrity (1:N relationships).
* **Master Data Seeding:** Using dynamic scripts (`generate_series`, `md5`, `random`) to generate unique customers and cards.
* **Transaction Generation:** Generating 10,000 transaction records with intentional anomalies (e.g., inconsistent text casing, error codes) for stress-testing.
* **Data Cleaning:** Implementing SQL scripts to handle simulated errors and ensure data consistency.
* **Advanced Analytics:** Custom anomaly detection logic to flag suspicious transactions.

### 2. Power BI: Business Intelligence & Modeling
* **Data Modeling:** Building a robust Star Schema and managing relationships between tables.
* **DAX Calculations:** Creating advanced measures (using `CALCULATE`, `KEEPFILTERS`, etc.) to track KPIs like Total Revenue, Volume, and Transaction counts.
* **Interactive Dashboard:** Designing a user-friendly UI to visualize executive insights and "Revenue at Risk" due to anomalies.

### 3. Python: Exploratory Data Analysis (EDA)
* **Data Integration:** Merging exported datasets using Pandas to recreate the full transaction context.
* **Data Validation:** Cleaning and converting data types (dates, numeric values) to ensure analytical accuracy.
* **Custom Visualization:** Generating professional business charts (Pie Charts for product mix, Bar Charts for revenue/volume by country) using Matplotlib and Seaborn to validate findings.

---

## 🚀 Key Features
* **Full Data Pipeline:** End-to-end process from raw SQL data generation to final business insights.
* **Executive KPI Tracking:** Real-time monitoring of financial and operational performance.
* **Dynamic Anomaly Detection:** Automated flagging of high-volume or suspicious behaviors.
* **Cross-Tool Validation:** Using Python to audit and visualize data exported from the SQL database.

---

## 📈 Dashboard Preview
![Dashboard Preview](preview.png)

---

## 📁 Files in Repository

* **`Fuel_Analytics_Report.pbix`**: The full interactive Power BI report.
* **`fuel_analytics_visualization.py`**: Python script for data merging, cleaning, and EDA visualizations.
* **`sql_scripts/`**: 
    * `01_Schema_Setup.sql`: Creating the database structure.
    * `02_Data_Generation.sql`: Scripts for synthetic data and error simulation.
    * `03_Data_Cleaning.sql`: Data transformation and consistency checks.
    * `04_Anomaly_Detection.sql`: Advanced analytics and fraud detection logic.
* **`data/`**: Synthetic datasets (countries.csv, cards.csv, customers.csv, transactions.csv).
* **`README.md`**: Project documentation and business summary.
