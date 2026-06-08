# 🌍 World Happiness Report — SQL Analysis Project

## Overview

This project cleans and analyzes the **World Happiness Report dataset (2011–2023)** using SQLite. It covers the full data analyst workflow: importing raw CSV data, identifying and fixing data quality issues, and extracting meaningful insights through structured queries.

---

## Dataset

- **Source:** World Happiness Report (Kaggle)
- **Coverage:** 2011–2023 (years 2005–2010 and 2013 were never collected)
- **Rows:** ~2,000+ country-year records
- **Columns:** Country, Year, Happiness Score, Confidence Intervals (whiskers), and six contributing factors — GDP per capita, Social Support, Healthy Life Expectancy, Freedom, Generosity, and Perceptions of Corruption

---

## Tools Used

- **SQLite** — data storage, cleaning, and analysis
- **SQL** — window functions, aggregations, CASE expressions, JOINs

---

## What Was Done

### 1. Data Import & Backup
- Imported `happiness.csv` into SQLite via terminal
- Created a backup table (`happinesscopy`) before any modifications

### 2. Data Cleaning
- Detected missing years by joining against a generated year-range table — found 7 years of data were never collected
- Identified that `COUNT(*)` vs `COUNT(column)` returns 0 for empty strings — caught hidden nulls disguised as empty strings
- Converted all empty string values to proper `NULL` across 7 columns
- Re-validated null counts after cleaning — found 1,094–1,103 true nulls in factor columns
- Identified that factor columns (GDP, social support, etc.) are structurally missing before 2019 — the report only began collecting them consistently from 2019 onwards

### 3. Analysis
| Question | Finding |
|----------|---------|
| Global happiness trend | Average score has risen over time; dipped in 2020 (COVID-19) |
| Lowest happiness by year | Afghanistan ranks last for most years from 2019–2023 |
| Afghanistan deep-dive (LAG function) | Biggest drop in 2019 (COVID); second drop in 2022 (Taliban takeover); 2023 is its highest score in 13 years |
| Highest happiness by year | Finland leads consistently from 2017 onwards |
| Top 10 consistency | Nordic countries dominate — Denmark, Norway, Iceland, Switzerland appear most frequently |
| GDP vs Happiness | Luxembourg has the highest GDP contribution (1.536) but happiness of 7.23; Finland has lower GDP (1.285) but happiness of 7.80 — wealth alone does not predict happiness |

---

## Key SQL Concepts Used

- `LAG()` window function for year-over-year change analysis
- `LEFT JOIN` with a generated table to detect missing years
- `CASE WHEN` for conditional null counting
- `GROUP BY` + `ORDER BY` for ranking and trend analysis
- Empty string vs NULL distinction in SQLite

---

## How to Run

```bash
# Step 1 — Import the CSV
sqlite3 happiness.db
.mode csv
.headers on
.import happiness.csv happiness
.quit

# Step 2 — Run the cleaning and analysis script
sqlite3 happiness.db < happiness_cleaning.sql
```

---

## Insights Summary

- **Afghanistan** went from a score of 4.2 down to 1.3 — directly traceable to real-world geopolitical events
- **Finland** stayed locked between 7.6–7.8 for nearly a decade, showing remarkable stability
- **GDP explains happiness partially but not fully** — social support and freedom are likely stronger predictors for top-ranked countries
- **Structural missingness** (pre-2019 factor data) is not a data quality issue but a collection design choice — important to document rather than impute

---
## Dashboard
[View on Tableau Public]https://public.tableau.com/app/profile/neetu.turan/vizzes
## Files

| File | Description |
|------|-------------|
| `happiness.csv` | Raw dataset |
| `happiness_cleaning.sql` | Full cleaning and analysis script |
| `README.md` | This file |
