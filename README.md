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
## 🛠️ Data Preparation & Implementation

### Excel Pre-Processing (Data Hygiene)

**Challenge:** Raw NHS data files are designed for human readability (PDFs, reports), not machine processing. Manual cleaning in Excel Online was required before importing into SQL.

---

#### 1. Header Flattening & Restructuring

**Problem:**  
NHS files use merged cells and multi-row headers. For example:
- Row 1: "A&E Attendances" (merged across columns)
- Row 2: "Type 1 Department - Major A&E | Type 2 Department - Single Speciality | Type 3 Department - Other A&E/ Minor Injury Unit | Total attendances" (sub-headers)

SQL cannot parse hierarchical headers — it expects a single header row with unique column names.

**Solution:**
- Collapsed multi-row headers into a single row
- Renamed columns to machine-readable format:
  - `total_att_t1`, `total_att_t2`, `total_att_t3`

**Result:** Column names SQL Server could recognise as distinct fields

---
#### 2. Metadata Removal

**Problem:**  
- 14 rows of introductory text at the top (summary, source, etc)
- Creates a non-rectangular dataset with mixed content types
- National (England) summary data at the top of table separted from the individual data

**Solution:**
- Deleted all rows above the actual column headers
- Created a clean rectangular dataset where every row is a data record
- Removed National (England) summary data 

**Result:** Consistent structure — header row followed by data rows only

---
#### 3. Numeric Field Cleaning (MIGHT NEED TO MOVE THIS)

**Problem:**  
- Comma separators in numbers (e.g., `2,300`) → SQL treats as text
- Clinical suppression marks (`-`) → cannot cast to `INT`
- Percentage symbols (e.g., `73.5%`) → cannot cast to `DECIMAL`

**Solution:**
- Changed cell format from Number to General — automatically removed comma thousand separators
- Suppression marks `(-)` left and documented for later `NULLIF()` handling in SQL
- Identified percentage columns and documented for later `REPLACE('%', '')` transformation in SQL

**Result:** Data CSV ready to import into SQL

---
#### 4. File Format Conversion

**Problem:**  
`.xlsx` files contain hidden formatting, styles, and formulas that can cause SSMS Import Wizard to fail to import or misinterpret the data.

**Solution:**
- Exported as **CSV (Comma Separated Values)**
- Plain text format with no embedded formatting


**Result:** Clean, lightweight file optimised so it can be imported into the SQL Server
---

### SQL Transformation (Silver Layer)

>**When importing data converted all data to text `NVARCHAR(MAX)`**
  
**Script:** [`sql/data_cleaning.sql`](sql/data_cleaning.sql)

**Objective:** Transform raw `NVARCHAR` data into strongly-typed, analysis-ready format.

---
#### Key Transformations

**1. Clinical Suppression Handling**

NHS England uses `-` to indicate data suppressed for patient confidentiality (small numbers that could identify individuals).
```sql
-- Convert '-' to NULL before type casting
TRY_CAST(NULLIF(total_att_t1, '-') AS INT) AS total_att_type_1
```

**Why `NULLIF` before `TRY_CAST`?**  
- `NULLIF(column, '-')` returns `NULL` if value is `-`, otherwise returns the value
- `TRY_CAST` then safely converts valid numbers to `INT`, returns `NULL` for invalid values
- No errors, no data loss

---
**2. Percentage Symbol Removal**

Performance metrics stored as strings like `"73.5%"`.
```sql
-- Remove % symbol, then cast to decimal
TRY_CAST(
    REPLACE(NULLIF(pct_all, '-'), '%', '') 
    AS DECIMAL(10,2)
) AS performance_pct_total
```
**Transformation chain:**
1. `NULLIF(pct_all, '-')` → Handle suppression
2. `REPLACE(..., '%', '')` → Remove percentage symbol
3. `TRY_CAST(...AS DECIMAL(10,2))` → Convert to number with 2 decimal places

---

**3. Semantic Column Renaming**

Raw column names were cryptic (`total_att_t1`, `under4_all`). Renamed for clarity:

| Original | Renamed | Meaning |
|----------|---------|---------|
| `total_att_t1` | `total_att_type_1` | Total attendances at Type 1 departments |
| `under4_all` | `seen_under_4hr_total` | Total patients seen within 4 hours |
| `over4_t1` | `waits_over_4hr_type_1` | Type 1 patients waiting over 4 hours |
| `pct_all` | `performance_pct_total` | Overall 4-hour performance percentage |

**Why rename?**  
Self-documenting code. Future analysts can understand the data without referring to external documentation.

---

**4. Complete Transformation Script**
```sql
-- Create cleaned table from raw data
SELECT 
    org_code,
    region,
    org_name,
    
    -- Type 1 (Major A&E) metrics
    TRY_CAST(NULLIF(total_att_t1, '-') AS INT) AS total_att_type_1,
    TRY_CAST(NULLIF(under4_t1, '-') AS INT) AS seen_under_4hr_type_1,
    TRY_CAST(NULLIF(over4_t1, '-') AS INT) AS waits_over_4hr_type_1,
    
    -- Type 2 (Single Specialty) metrics
    TRY_CAST(NULLIF(total_att_t2, '-') AS INT) AS total_att_type_2,
    TRY_CAST(NULLIF(under4_t2, '-') AS INT) AS seen_under_4hr_type_2,
    TRY_CAST(NULLIF(over4_t2, '-') AS INT) AS waits_over_4hr_type_2,
    
    -- Type 3 (Minor Injury) metrics
    TRY_CAST(NULLIF(total_att_t3, '-') AS INT) AS total_att_type_3,
    TRY_CAST(NULLIF(under4_t3, '-') AS INT) AS seen_under_4hr_type_3,
    TRY_CAST(NULLIF(over4_t3, '-') AS INT) AS waits_over_4hr_type_3,
    
    -- Overall metrics
    TRY_CAST(NULLIF(total_att_all, '-') AS INT) AS total_att,
    TRY_CAST(NULLIF(under4_all, '-') AS INT) AS seen_under_4hr_total,
    TRY_CAST(NULLIF(over4_all, '-') AS INT) AS waits_over_4hr_total,
    
    -- Performance percentages
    TRY_CAST(REPLACE(NULLIF(pct_all, '-'), '%', '') AS DECIMAL(10,2)) AS performance_pct_total,
    TRY_CAST(REPLACE(NULLIF(pct_t1, '-'), '%', '') AS DECIMAL(10,2)) AS performance_pct_type_1,
    TRY_CAST(REPLACE(NULLIF(pct_t2, '-'), '%', '') AS DECIMAL(10,2)) AS performance_pct_type_2,
    TRY_CAST(REPLACE(NULLIF(pct_t3, '-'), '%', '') AS DECIMAL(10,2)) AS performance_pct_type_3,
    
    -- Emergency admissions
    TRY_CAST(NULLIF(adm_t1, '-') AS INT) AS emergency_adm_type_1,
    TRY_CAST(NULLIF(adm_t2, '-') AS INT) AS emergency_adm_type_2,
    TRY_CAST(NULLIF(adm_t3_4, '-') AS INT) AS emergency_adm_type_3_4,
    TRY_CAST(NULLIF(adm_total_ae, '-') AS INT) AS emergency_adm_total_ae,
    TRY_CAST(NULLIF(adm_non_ae, '-') AS INT) AS other_emergency_adm,
    TRY_CAST(NULLIF(adm_total, '-') AS INT) AS emergency_adm_total,
    
    -- Decision-to-admit waiting times
    TRY_CAST(NULLIF(dta_over4, '-') AS INT) AS over_4hr_waits,
    TRY_CAST(NULLIF(dta_over12, '-') AS INT) AS over_12hr_waits

INTO nhs_ae_cleaned
FROM nhs_ae_dec25;

**Output:** `nhs_ae_cleaned` table
- 197 rows (trusts)
- 25 columns (all strongly typed)
- Ready for analysis
```

### Power BI Visualisation (Gold Layer)

**Connection Method:** Import Mode (Direct Query to SQL Server)

---

#### 1. Data Connection

**Steps:**
1. Power BI Desktop → Get Data → SQL Server
2. Server: `localhost` 
3. Import mode selected
4. Table: `nhs_ae_cleaned`

**Result:** 197 trusts × 25 columns successfully imported

---

#### 2. DAX Measures Created

##### Page 1

**Total A&E Attendances**
```dax
Total A&E Attendances =
SUM(nhs_ae_cleaned[total_att])
```
**Purpose** 
Overall total of people seen in the NHS Nationally.  

---
**National Performance Percentage (Volume-Weighted)**
```dax
National Performance = 
DIVIDE(
    SUM(nhs_ae_cleaned[seen_under_4hr_total]),
    SUM(nhs_ae_cleaned[total_att]),
    0
)
```
*Format changed to percentage
**Purpose**
This reflects actual patient experience. Patient centric performance calculation so the proportion of people seen within 4 hours in the NHS as a whole nationally. 

**Why volume-weighted?**  
 A bigger trust with 10,000 patients for example should have more influence on the national average than a smaller trust with around 100 patients.

---

**Average Performance Percentage (Unweighted)**
```dax
Average Performance =
AVERAGE(nhs_ae_cleaned[performance_pct_total])/100
```
*Format changed to percentage
**Purpose**
This shows how the typical trust is performing on average, regardless of size. This is useful for comparing trust management effectiveness. A comparison of  weighted vs unweighted percentages reveals whether large or small hospitals are driving performance.

---
**Breaches**
```dax
Breaches =
SUM(nhs_ae_cleaned[waits_over_4hr_total])
```
**Purpose** 
Observation of how many people who waited over 4 hours to be seen in the NHS overall nationally

---

**Trust Compliance Metrics**
```dax
Number of Trusts = 
DISTINCTCOUNT(nhs_ae_cleaned[org_code])

Trusts Meeting Target = 
CALCULATE(
    DISTINCTCOUNT(nhs_ae_cleaned[org_code]),
    nhs_ae_cleaned[performance_pct_total] >= 78
)

Trusts Meeting Target = 
[Trusts Meeting Target] & " / " & [Number of Trusts]
```
---

**Department Type Performance**
```dax
Type 1 Performance % = 
DIVIDE(
    SUM(nhs_ae_cleaned[seen_under_4hr_type_1]),
    SUM(nhs_ae_cleaned[total_att_type_1]),
    0
)
```
```
Type 2 Performance % = 
DIVIDE(
    SUM(nhs_ae_cleaned[seen_under_4hr_type_2]),
    SUM(nhs_ae_cleaned[total_att_type_2]),
    0
)
```
```
Type 3 Performance % = 
DIVIDE(
    SUM(nhs_ae_cleaned[seen_under_4hr_type_3]),
    SUM(nhs_ae_cleaned[total_att_type_3]),
    0
) 
```
*Format changed to percentage for each department calculation
**This is also used on page 3**

---

##### Page 2

**Regional-Level Measures**
```dax
Regional Total Attendances =
SUM(nhs_ae_cleaned[total_att])
```

```dax
Regional Performance % = 
DIVIDE(
    SUM(nhs_ae_cleaned[seen_under_4hr_total]),
    SUM(nhs_ae_cleaned[total_att]),
    0
)
*Format changed to percentage
```
```dax
Regional Breaches =
SUM(nhs_ae_cleaned[waits_over_4hr_total])
```
```dax
Regional Trusts Count = 
DISTINCTCOUNT(nhs_ae_cleaned[org_code])

Regional Trusts Meeting Target = 
CALCULATE(
    DISTINCTCOUNT(nhs_ae_cleaned[org_code]),
    nhs_ae_cleaned[performance_pct_total] >= 78
)
Regional Trusts Meeting Target =
[Regional Trusts Meeting Tartget Calc] & "/" & [Regional Trust Count]
```
**Purpose:** Enable interactive regional analysis via slicer on Page 2.

---
##### Page 3

**Trust-Level Measures**
```dax
Trust Total Attendances =
SUM(nhs_ae_cleaned[total_att])
```

```dax
Trust Performance % = 
DIVIDE(
    SUM(nhs_ae_cleaned[seen_under_4hr_total]),
    SUM(nhs_ae_cleaned[total_att]),
    0
)
*Format changed to percentage
```
```dax
Trust Breaches =
SUM(nhs_ae_cleaned[waits_over_4hr_total])
```
```dax
Trust Region = 
SELECTEDVALUE(nhs_ae_cleaned[region], "No Trust Selected")
```
---
**Capacity Pressure Indicators**
```dax
Patients Waiting >4hrs (DTA) = 
SUM(nhs_ae_cleaned[over_4hr_waits])

Patients Waiting >12hrs (DTA) = 
SUM(nhs_ae_cleaned[over_12hr_waits])

% Waiting >12hrs (DTA) = 
DIVIDE(
    [Patients Waiting >12hrs (DTA)],
    [Patients Waiting >4hrs (DTA)],
    0
)
*Format changed to percentage
```
**Clinical significance:** Decision-to-admit (DTA) waits indicate bed capacity problems, not A&E efficiency. >12hr waits represent severe capacity crisis.

**Purpose:** Slicer used for page 3's iteractive individual trust deep-dive analysis.

---
#### 3. Dashboard Design & Visualisation Techniques

##### Page Architecture 
Three Pages 
- **Page 1:** Executive Overview (national summary)
- **Page 2:** Regional Deep Dive (interactive regional filter)
- **Page 3:** Trust-Level Analysis (individual trust deep-dive)

**Canvas:** 16:9 ratio (1280×720)

---

##### Visual Design

**Conditional Formatting**
Implemented traffic light system across all visuals:
- **Green** (≥78%): Meeting target — Green
- **Orange** (70-78%): At risk — Orange
- **Red** (<70%): Critical — Red 

Applied to:
- KPI card font colours
- KPI card backgrounds (light tints)
- Bar chart colours
- Table cell backgrounds

---

**Analytics Lines**
- 78% target line on all performance charts
- Reference lines for comparison across visuals

---

**Interactive Features**
- Region slicer for filtering
- Department type drill-down
- Trust slicer: Dropdown of 197 trusts 

---
## 📊 Dashboard Pages

### Page 1: Executive Overview
<img width="979" height="555" alt="image" src="https://github.com/user-attachments/assets/64a8f867-7d25-4ee0-b20a-d6d36c01a1c0" />


**Key Metrics:**
- Total Attendances: **2.3M**
- National Performance: **73.8%** (below 78% target)
- Total Breaches: **609K patients**
- Trusts Meeting Target: **84 / 197 (42.6%)**

**Key Insights:**
- 7pp gap between average trust (80.9.%) and national weighted (73.8%) performance
- Type 1 Major A&E departments at 58.6% - primary bottleneck
- Regional disparity: London (76.3%) vs North West (71.5)

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
