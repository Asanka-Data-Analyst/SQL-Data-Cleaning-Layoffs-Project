# SQL-Data-Cleaning-Layoffs-Project
A full SQL data cleaning walkthrough using layoffs data

# 🧹 SQL Data Cleaning Project – Layoffs Dataset

This project demonstrates how to clean a real-world dataset using SQL. The dataset used contains information about tech company layoffs and includes fields such as company, location, industry, and more.

## 📂 Dataset Overview

- Columns: Company, Location, Industry, Total Laid Off, Percentage Laid Off, Date, Stage, Country, Funds Raised
- Issues addressed: Duplicates, Inconsistent Formatting, Missing Values, Invalid Dates

## 🛠️ Cleaning Steps

1. **Created a staging table** to preserve raw data integrity.
2. **Removed duplicate records** using `ROW_NUMBER()` and CTEs.
3. **Standardized**:
   - Company and Industry names
   - Location (fixed misspellings)
   - Country names
4. **Converted** date column from text to proper `DATE` type.
5. **Handled missing values**:
   - Filled in blanks from other rows where possible
   - Removed fully blank rows
6. **Dropped temporary columns** (e.g., `row_num`) after use.

## 💡 SQL Skills Demonstrated

- Common Table Expressions (CTEs)
- `ROW_NUMBER()` Window Function
- String Functions (`TRIM`, `LIKE`)
- `UPDATE`, `DELETE`, and `ALTER` statements
- Data type conversion

## 📎 File

- `Data_Cleaning_Layoffs.sql`: Full SQL script for cleaning the dataset.

## 👨‍💻 Author

Asanka Dissanayaka  
[LinkedIn Profile](https://www.linkedin.com/in/asanka-dissanayaka-b341712a9) 
