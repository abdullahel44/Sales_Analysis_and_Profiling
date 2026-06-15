# 📊 End-to-End Sales Performance & Customer Segmentation Analysis

## 📌 Project Overview
This project presents an end-to-end data analytics solution, transforming raw, messy sales data into an interactive, business-ready Power BI dashboard. The analysis uncovers key sales trends, regional performance in Bangladesh, and deep customer segmentation using advanced SQL Server profiling and DAX modeling.

---

## 🏗️ Data Architecture & Star Schema
The project follows a robust **Star Schema** architecture to ensure optimal performance and standard data modeling practices:
* **Fact Table:** `fact_table` (Sales revenue, quantities, and transaction keys)
* **Dimension Tables:** * `customer_dim` (Client details and custom segments)
  * `store_dim` (Geographical divisions, districts, and local regions)
  * `item_dim` (Product names, types, and units)
  * `time_dim` (Core temporal breakdown by year, month, and day)
  * `Trans_dim` (Payment methods: Cash, Card, Mobile)

---

## 🛠️ Technical Workflow & Implementation

### 1️⃣ Advanced Data Profiling & Quality Automation (SQL Server)
Before transforming data, an automated database scanner was implemented using an **SQL Cursor and Dynamic SQL**. This scanned every user-defined table and column to detect and rank missing values (`IS NULL`) without hardcoding, ensuring absolute data integrity before the transformation phase.

### 2️⃣ Data Cleaning & Imputation (SQL Server)
* Identified hidden data gaps where the product `unit` was missing (`NULL`) in the fact table.
* Developed a relational script to automatically impute and repair missing values from the `item_dim` table using a clean `UPDATE JOIN` logic.
* Created an optimized **Aggregated View** (`v_Fact_Sales_Aggregated`) to compress granularity, filter dimensions, and boost data retrieval speed for Power BI.

### 3️⃣ Data Modeling & Context Transition Fixes (Power BI & DAX)
* Established relationship flows from Dimension tables (One) to Fact tables (Many).
* Implemented a custom **Customer Segmentation** model dividing clients into **Premium, Mid-Range, and Budget** categories.
* **Critical Technical Fix:** Resolved a major *Context Transition* issue where row-context in a calculated column was merging duplicate customer names (e.g., multiple distinct keys sharing common South-Asian names like "Pooja" or "Nisha"). Handled explicitly using `CALCULATE` and unique `customer_key` filtering to ensure accurate segmentation.

---

## 📈 Key Business Insights & Dashboard Features

### 🏢 1. Executive Sales Overview
* **Total Revenue:** $105.4M with a total volume of 6M quantities sold across the tracked periods.
* **Regional Dominance:** The **Dhaka Division** emerged as the absolute market leader, heavily driving the company's core revenue compared to Chittagong and Rajshahi.

### 👥 2. Customer Segmentation Metrics
* Successfully mapped **9,191 unique customers**.
* Decoupled total sales from generic names to show actual individual purchase power, properly categorizing high-value buyers into the **Premium** tier (> $15,000).

### 💳 3. Transaction & Product Dynamics
* **Preferred Payment:** Cash transactions heavily dominate the payment type landscape (representing over 89% of transactions).
* **Top Products:** High-volume sales are heavily concentrated in specific item units like cans and bottles.

---

## 🚀 How to Explore this Project
1. **Database Scripts:** Check the `/SQL_Scripts` folder to view the automated profiling cursor, cleaning queries, and database view creation.
2. **Power BI Dashboard:** Download the `.pbix` file from the repository to interact with the visual charts, filters, and dynamic DAX metrics.

## Project Dashboards

### 1. Product Sales Dashboard
![Product Sales](Product%20Sales.png)

### 2. General Sales Dashboard
![Sales Dashboard](Sales%20Dashboard.png)

### 3. Clients Dashboard
![Clients Dashboard](Clients%20Dashboard.png)
