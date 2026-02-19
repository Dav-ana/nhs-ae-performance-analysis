# 🏥 NHS A&E Performance Analysis Pipeline

![Power BI](https://img.shields.io/badge/Power%20BI-F2C811?style=flat&logo=powerbi&logoColor=black)
![SQL Server](https://img.shields.io/badge/SQL%20Server-CC2927?style=flat&logo=microsoftsqlserver&logoColor=white)
![Excel](https://img.shields.io/badge/Excel-217346?style=flat&logo=microsoftexcel&logoColor=white)
![Status](https://img.shields.io/badge/Status-In%20Progress-yellow)

>**End-to-end data pipeline analysing 2.3 million NHS A&E attendance records to evaluate performance against the national 78% 4-hour waiting time standard.**

**Key Finding:** National performance at 73.8% reveals a 7.1 percentage point gap between large hospital performance and small trust averages, indicating major A&E departments face significant capacity pressure.

---
## 📋 Project Overview

This project transforms raw NHS England A&E data into actionable insights through a complete data pipeline:

**What I Did:**
- 🧹 **Data Preparation:** Cleaned messy NHS CSV files in Excel (header flattening, metadata removal, numeric standardisation)
- 🗄️ **Database Layer:** Imported and transformed data using SQL Server and T-SQL scripting
- 📊 **Visualisation Layer:** Built interactive Power BI dashboard with DAX measures
- 📈 **Insight Generation:** Identified critical performance gaps and capacity bottlenecks

**The Challenge:**  
The NHS has an interim target, introduced in June 2025, that **78% of A&E patients should be seen within four hours** by March 2026. December 2025 data shows the NHS is falling short at 73.8%; contributing factors include seasonal winter pressures, bed capacity constraints, staffing challenges, and ambulance handover delays.

Additionally, raw NHS England data files are not optimised for machine processing; they are designed for **human readability**. The initial data contained merged headers, metadata rows, clinical suppression symbols (`-`), comma-separated numbers, and percentage symbols; SQL and Power BI cannot process these directly. Each layer of the pipeline required intentional data engineering to transform the data into a usable state.

**What Was Found:**  
Using volume-weighted analysis, it was observed that the average trust appears to perform at **80.9%**.  As national performance is at **73.8%**; a **7.1 percentage point gap** reveals that the patient experience is significantly worse because **large hospitals treating the majority of patients are underperforming**. 

- **Type 1 Major A&E** departments achieve only **59.6%**; this is the primary bottleneck in the system.
- **~609,000 patients** waited over four hours in December 2025 alone
- **Only 84 out of the 197 trusts and centres (42.6%)** are meeting the 78% interim standard
- **North West (71.5%)** and **Midlands (71.6%)** are the worst performing regions 

**Why Does This Matter:**  
This analysis demonstrates that resource allocation must be **volume-weighted and department-specific**, not evenly distributed across all trusts. Policy interventions should target high-volume Type 1 departments in underperforming regions (North West, Midlands) for maximum patient impact.

---

## 🏗️ Technical Architecture

**Data Pipeline (Bronze → Silver → Gold):**
```
Raw CSV Data ──SQL──> Cleaned Database ──Power BI──> Interactive Dashboard
  (Bronze)             (Silver)                        (Gold)
```

### Layer Descriptions

**🥉 Bronze (Raw Layer)**
- NHS England CSV file imported into SQL Server via SSMS Import Wizard
- Data preserved in original format as `NVARCHAR(MAX)`
- Clinical suppression marks (`-`) and percentage symbols kept as-is
- Purpose: Preserve raw source data without alteration

**🥈 Silver (Cleaned Layer)**
- T-SQL transformations applied to Bronze data
- Handled NULL values, type casting, and semantic renaming
- Output: `nhs_ae_cleaned` table (197 trusts, 25 columns)
- Purpose: Analysis-ready, standardised dataset

**🥇 Gold (Analytics Layer)**
- Power BI connected directly to SQL Server
- DAX measures for business logic and KPI calculations
- Interactive multi-page dashboard for stakeholder use
- Purpose: Executive-ready insights and visualisations

---

### Tech Stack

| Component | Tool | Purpose |
|-----------|------|---------|
| **Pre-Processing** | Microsoft Excel Online | Data hygiene and CSV preparation |
| **Database** | SQL Server (SSMS) | Data storage and querying |
| **Transformation** | T-SQL | Data cleaning and type casting |
| **Visualisation** | Power BI Desktop | Dashboard and reporting |
| **Version Control** | GitHub | Documentation and portfolio |

---
## 📊 Dashboard Pages

### Page 1: Executive Overview
*[Screenshot coming soon]*

**Key Metrics:**
- Total Attendances: **2.3M**
- National Performance: **73.2%** 🔴 (below 78% target)
- Total Breaches: **609K patients**
- Trusts Meeting Target: **84 / 198 (42.4%)**

**Key Insights:**
- 6.3pp gap between average trust (79.5%) and national weighted (73.2%) performance
- Type 1 Major A&E departments at 68.5% - primary bottleneck
- Regional disparity: South West (82.5%) vs London (72.8%)

### Page 2: Regional Deep Dive
*[Coming soon]*

### Page 3: Trust-Level Analysis
*[Coming soon]*

---

## 🔧 Technical Implementation

### 1. Data Ingestion (Bronze Layer)

- **Source:** NHS England CSV (December 2024)
- **Method:** SQL Server Import Wizard
- **Challenge:** All data imported as NVARCHAR due to clinical suppression marks (-)

### 2. Data Transformation (Silver Layer)

**SQL Script:** [`sql/data_cleaning.sql`](sql/data_cleaning.sql)

**Key Transformations:**
```sql
-- Handle suppressed values
TRY_CAST(NULLIF(total_att_t1, '-') AS INT) AS total_att_type_1

-- Remove percentage symbols and convert
TRY_CAST(REPLACE(NULLIF(pct_all, '-'), '%', '') AS DECIMAL(10,2)) AS performance_pct_total

-- Semantic renaming for clarity
```

**Output:** Clean `nhs_ae_cleaned` table with 200+ trusts, 25 columns

### 3. Data Visualization (Gold Layer)

**Power BI Features:**
- DAX measures for weighted vs unweighted metrics
- Conditional formatting (red/green traffic lights)
- Regional performance bar charts with target lines
- Department type comparison analysis
- Performance gauge showing gap to target

**Key DAX Measures:**
```dax
National Performance % = 
DIVIDE(
    SUM(nhs_ae_cleaned[seen_under_4hr_total]),
    SUM(nhs_ae_cleaned[total_att]),
    0
) * 100
```

---

## 💡 Key Insights

### 1. Volume vs. Average Gap (6.3pp)
- **Finding:** Large hospitals underperform vs small trusts
- **Implication:** Resource allocation should target high-volume sites

### 2. Department Type Bottleneck
- Type 1 (Major A&E): 68.5% 🔴
- Type 2 (Single Specialty): 77.2% 🟢
- Type 3 (Minor Injury): 95.8% 🟢

### 3. Regional Disparity
- Best: South West (82.5%), East of England (78.2%)
- Worst: North West (70.5%), London (72.8%)

---

## 📁 Repository Structure
```
nhs-ae-performance-analysis/
│
├── sql/
│   └── data_cleaning.sql          # T-SQL transformation script
│
├── screenshots/
│   ├── executive_overview.png     # Dashboard page 1
│   ├── regional_deepdive.png      # Dashboard page 2 (coming soon)
│   └── trust_analysis.png         # Dashboard page 3 (coming soon)
│
├── powerbi/
│   └── nhs_ae_dashboard.pbix      # Power BI file (to be added)
│
└── README.md                       # This file
```

---

## 🎓 Skills Demonstrated

✅ **SQL:** Data cleaning, type casting, NULL handling, semantic naming  
✅ **Power BI:** DAX measures, conditional formatting, multi-page dashboards  
✅ **Data Architecture:** Bronze-Silver-Gold pipeline design  
✅ **Healthcare Analytics:** NHS performance standards, clinical data handling  
✅ **Business Intelligence:** Weighted vs unweighted metrics, insight generation  

---

## 🚀 Future Enhancements

- [ ] Add time-series analysis (multiple months of data)
- [ ] Incorporate decision-to-admit waiting times
- [ ] Build predictive model for future performance
- [ ] Add Python data validation scripts
- [ ] Regional deep-dive with geographic mapping

---

## 📚 Data Source

**NHS England - A&E Attendances and Emergency Admissions**
- Dataset: December 2024
- License: Open Government Licence

---

## 👤 About Me

**[Your Name]**  
Transitioning from Audiology to Data Analytics

[LinkedIn](your-linkedin-url) | [Email](your-email)

---

*This project is part of my career transition portfolio, demonstrating end-to-end data analysis skills in a real-world healthcare context.*
