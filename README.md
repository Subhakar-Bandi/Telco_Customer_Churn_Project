# Telco Customer Churn Analysis (SQL + Power BI)

An end-to-end analysis of 7,043 telecom customers to find **why customers leave, how much monthly revenue is lost, and which active customers should be targeted for retention.** Data was cleaned and analysed in **PostgreSQL**, and the results are presented in a **2-page Power BI dashboard**.

---

## Business Problem
Customer churn directly reduces recurring revenue. This project answers:
- How many customers churn, and how much revenue is lost?
- Which contract types, payment methods, services and tenure groups drive churn?
- Which active customers are at high risk of leaving next?

## Dataset
- **Source:** Telco Customer Churn dataset (IBM sample data, available on Kaggle)
- **Size:** 7,043 customers, 21 columns (one row per customer)
- **Target column:** `Churn` (Yes / No)
- **Key columns:** `tenure`, `Contract`, `InternetService`, `TechSupport`, `PaymentMethod`, `MonthlyCharges`, `TotalCharges`

## Tools Used
| Tool | Purpose |
|---|---|
| PostgreSQL (pgAdmin) | Data cleaning, analysis, view creation |
| Power BI Desktop | Dashboard, DAX measures, visualisation |

## Project Workflow
1. Imported the CSV into PostgreSQL (`sql/01_create_table.sql`)
2. Cleaned the data (see below)
3. Answered 19 business questions with SQL (`sql/Telco_Customer_Churn_Analysis.sql`)
4. Connected Power BI to PostgreSQL and built DAX measures
5. Designed a 2-page dashboard and documented the insights

## Data Cleaning
- `TotalCharges` was stored as text and had **11 blank values** (all customers with `tenure = 0`). Blanks were converted to `NULL` and the column was cast to `NUMERIC`.
- Verified there are no duplicate `customerID` values and no other missing values.

---

## SQL Business Questions (19)
All queries are in [`sql/Telco_Customer_Churn_Analysis.sql`][Telco Customer Churn Analysis SQL](Telco_Customer_Churn_Analysis.sql)

### Overview
1. How many customers do we have, and how many churned vs stayed?
2. What is the total monthly recurring revenue (MRR), and how much of it comes from churned customers?
3. What is the average tenure and average monthly charge of churned vs retained customers?

### Contract and Billing
4. How many customers churned under each contract type?
5. Which payment method has the highest number of churned customers?
6. Do paperless billing customers churn more? (churned counts and average monthly charges)

### Services
7. How many customers churned under each internet service type?
8. Do customers with tech support churn less than those without it?
9. Do customers with online security churn less than those without it?

### Customer Profile
10. How many senior citizens vs non-senior citizens churned?
11. How does churn differ by partner and dependents status?

### Tenure
12. Group tenure into bands (0-12, 13-24, 25-48, 49-72 months) and count customers and churned customers in each band.
13. In which tenure band is churn the highest?

### Revenue at Risk
14. How much monthly revenue was lost from churned customers, by contract type?
15. What is the average total charges (lifetime value) of churned vs retained customers?
16. Which combination of contract and internet service lost the most monthly revenue?
17. Rank payment methods within each contract type by number of churned customers (window function).

### Win-back (Active but High Risk)
18. How many active customers match the high-risk profile (month-to-month, tenure up to 12 months, fiber optic, electronic check), and how much MRR do they represent?
19. Create a view `vw_churn_analysis` with `tenure_band` and `high_risk_flag` columns for Power BI.

### SQL Skills Demonstrated
- Aggregations, `GROUP BY`, `HAVING`, subqueries
- `CASE WHEN` for tenure bands and risk flags
- `FILTER (WHERE ...)` for conditional counts
- Window function: `RANK() OVER (PARTITION BY ...)`
- Data type conversion with `NULLIF`
- `CREATE VIEW` for the reporting layer

---

## Power BI Measures (DAX)
Percentages are calculated in Power BI.
```
Total Customers = COUNTROWS(Telco_Customer_Churn)

Churned Customers = CALCULATE(COUNTROWS(Telco_Customer_Churn), Telco_Customer_Churn[churn] = "Yes")

Churn Rate % = DIVIDE([Churned Customers], [Total Customers])

Total MRR = SUM(Telco_Customer_Churn[monthlycharges])

Churned MRR = CALCULATE(SUM(Telco_Customer_Churn[monthlycharges]), Telco_Customer_Churn[churn] = "Yes")

MRR Lost % = DIVIDE([Churned MRR], [Total MRR])

High Risk Active Customers = CALCULATE(COUNTROWS(Telco_Customer_Churn),
    Telco_Customer_Churn[contract] = "Month-to-month",
    Telco_Customer_Churn[tenure] <= 12,
    Telco_Customer_Churn[internetservice] = "Fiber optic",
    Telco_Customer_Churn[paymentmethod] = "Electronic check",
    Telco_Customer_Churn[churn] = "No")
```

---

## Key Insights
| Metric | Value |
|---|---|
| Total customers | 7,043 |
| Churned customers | 1,869 (**26.5%**) |
| Total MRR | $456,117 |
| Churned MRR | $139,131 (**30.5%** of MRR) |
| High-risk active customers | 182 ($14,769 MRR) |

- **Contract type is the biggest driver:** Month-to-month customers churn at **42.7%**, versus 11.3% (one year) and 2.8% (two year).
- **Early tenure is critical:** **55%** of all churn (1,037 of 1,869 customers) happens in the first 12 months.
- **Electronic check users churn the most (45.3%)**, compared with 15-19% for other payment methods.
- **No tech support means higher churn:** 41.6% versus 15.2% for customers with tech support.
- **Fiber optic customers churn at 41.9%**, more than double the DSL rate (19.0%).
- **Revenue loss is concentrated:** Month-to-month customers account for about **87%** of lost MRR, and Month-to-month + Fiber optic alone is about **$100K**.
- **182 active high-risk customers** (month-to-month, tenure up to 12 months, fiber optic, electronic check) represent **$14,769 MRR**.

## Dashboard Preview

### Page 1: Churn Overview
![Churn Overview](Churn%20Overview.png)

### Page 2: Revenue at Risk and Win-back
![Revenue at Risk and Win-back](Revenue%20at%20Risk%20and%20Win-back.png)


## Recommendations
1. Offer discounts or incentives to move month-to-month customers to one-year or two-year contracts.
2. Create an onboarding and engagement programme for customers in their first 12 months.
3. Encourage a switch from electronic check to automatic payment methods.
4. Bundle or trial tech support for customers who do not have it.
5. Investigate fiber optic pricing and service quality.
6. Run a win-back campaign for the 182 high-risk active customers.

## Author
**Subhakar**

Data Analyst | SQL | Power BI
