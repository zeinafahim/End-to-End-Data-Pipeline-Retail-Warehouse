# End-to-End-Data-Pipeline-Retail-Warehouse

An end-to-end data engineering and business intelligence project implementing a **Medallion Architecture** (Bronze, Silver, and Gold layers) to process raw data, apply transformations, and deliver analytics-ready data visualized through an interactive Power BI dashboard.

## Project Overview
This project demonstrates a scalable data pipeline that ingests raw, unstructured/semi-structured datasets and refines them through a three-tier architecture. The final structured data is optimized for analytical queries, reporting, and tracking key business performance metrics.

---

## System Architecture

The data flows sequentially through three distinct layers to ensure high data quality and schema enforcement:

### 1. Bronze Layer (Raw Ingestion)
* **Purpose:** Acts as the landing zone for the raw ingestion.
* **Process:** Inserted all raw datasets, maintaining the full history of rows and columns without modifications. 
* **State:** Immutable, raw historical data.

### 2. Silver Layer (Enrichment & Transformation)
* **Purpose:** The cleansing and optimization zone.
* **Process:** Performed ETL (Extract, Transform, Load) processes. This involved handling missing values, standardizing data types, removing duplicates, and structuring tables for relationship mapping.
* **State:** Cleaned, conformed, and enriched data.

### 3. Gold Layer (Business Analytics Ready)
* **Purpose:** The consumption zone optimized for analytics.
* **Process:** Formatted the data into business-level aggregates, dimensional models (Star/Snowflake schema), and analytical views ready for reporting.
* **State:** High-performance, analytics-ready datasets.

---

## Business Intelligence (Power BI)

Once the data reached the Gold layer, it was connected to **Power BI** to build an interactive dashboard. 

* **Data Modeling:** Established a clean star schema model using the analytics-ready Gold datasets.
* **Features:** Implemented advanced DAX measures for key business metrics, interactive filtering, and intuitive visual hierarchies to drive data-driven decision-making.

---

