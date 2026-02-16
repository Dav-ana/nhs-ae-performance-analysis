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

**What I Built:**
- 🧹 **Data Preparation:** Cleaned messy NHS CSV files in Excel (header flattening, metadata removal)
- 🗄️ **Database Layer:** Imported and transformed data using SQL Server and T-SQL
- 📊 **Visualisation Layer:** Built interactive Power BI dashboard with DAX measures
- 📈 **Insight Generation:** Identified critical performance gaps and capacity bottlenecks

**The Challenge:**  
The NHS has an interim target that **78% of A&E patients should be seen within four hours** by March 2026. December 2025 data shows the NHS is falling short at 73.8% - but the simple average hides a more complex story.

**The Discovery:**  
Using volume-weighted analysis, I uncovered that whilst the average trust appears to perform at 80.9%, the patient experience is significantly worse because **large hospitals treating the majority of patients are underperforming**. Type 1 Major A&E departments achieve only 59.6% - the primary bottleneck in the system.

**Why This Matters:**  
This analysis demonstrates that resource allocation must be **volume-weighted and department-specific**, not evenly distributed across all trusts. Policy interventions should target high-volume Type 1 departments in underperforming regions (North West, Midlands) for maximum patient impact.

---
## 🎯 Business Problem

The NHS has a recovery target that **78% of A&E patients should be seen within 4 hours**. This project analyzes December 2025 performance to:

- ✅ Identify which regions are failing to meet targets
- ✅ Understand performance differences between department types
- ✅ Quantify the gap between large and small hospitals
- ✅ Provide actionable insights for resource allocation

---

## 🏗️ Technical Architecture

**Data Pipeline (Bronze → Silver → Gold):**
```
Raw CSV Data ──SQL──> Cleaned Database ──Power BI──> Interactive Dashboard
  (Bronze)             (Silver)                        (Gold)
```

**Tech Stack:**
- **Database:** SQL Server (SSMS)
- **Transformation:** T-SQL
- **Visualisation:** Power BI Desktop
- **Source:** NHS England A&E Attendances (December 2024)

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
