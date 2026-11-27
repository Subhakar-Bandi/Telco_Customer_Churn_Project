-- =====================================================
-- Telco Customer Churn: Business Questions
-- Table: telco_customer_churn
-- (Counts, sums and averages only. Percentages are built in Power BI.)
-- =====================================================

-- ============ OVERVIEW ============

-- Q1. How many customers do we have, and how many churned vs stayed?

select count(churn) as total_customer from telco_customer_churn;

select 
	count(customerid) as customer,
	churn
	from telco_customer_churn
	group by churn;


-- Q2. What is the total monthly recurring revenue (MRR), and how much of it comes from churned customers?

select * from telco_customer_churn;

select 
	sum(monthlycharges) as monthly_revenue,
	sum(case when churn = 'Yes' then 1 else 0 end) as churm_customer
	from telco_customer_churn;

-- Q3. What is the average tenure and average monthly charge of churned vs retained customers?

select
	churn,
	Round(avg(tenure),2) as avg_tenure,
	Round(avg(monthlycharges),2) as avg_month_charged
	from telco_customer_churn
	where churn = 'Yes'
	group by churn;
	


-- ============ CONTRACT AND BILLING ============

-- Q4. How many customers churned under each contract type?

select * from telco_customer_churn;

select 
	contract,
	count(churn) as churn_customer
	from telco_customer_churn
	where churn = 'Yes'
	group by contract
	order by count(churn) desc;


-- Q5. Which payment method has the highest number of churned customers?

select
	paymentmethod,
	count(churn) as total_customer
	from telco_customer_churn
	where churn = 'Yes'
	group by paymentmethod;


-- Q6. Do paperless billing customers churn more? (compare churned counts and average monthly charges)

select
	paperlessbilling,
	count(churn) as total_cust,
	round(avg(monthlycharges),2) as avg_monthlycharges
	from telco_customer_churn
	group by paperlessbilling;


-- ============ SERVICES ============

-- Q7. How many customers churned under each internet service type?

select 
	internetservice,
	count(churn) as total_cust
	from telco_customer_churn
	where churn = 'Yes'
	group by internetservice
	order by count(churn) desc;


-- Q8. Do customers with tech support churn less than those without it?

select
	techsupport,
	count(case when churn = 'Yes' then 1 end) as customers,
	count(*) as total_customers,
	round(count(case when churn = 'Yes' then 1 end) * 100.0 / count(*),2) as pct_churn
	from telco_customer_churn
	group by techsupport
	order by pct_churn desc;


-- Q9. Do customers with online security churn less than those without it?

select
	onlinesecurity,
	count(case when churn = 'Yes' then 1 end) as customers,
	count(*) as total_customers,
	round(count(case when churn = 'Yes' then 1 end) * 100.0 / count(*),2) as pct_churn
	from telco_customer_churn
	group by onlinesecurity
	order by pct_churn desc;

-- ============ CUSTOMER PROFILE ============

-- Q10. How many senior citizens vs non-senior citizens churned?

select * from telco_customer_churn;

select
	case when seniorcitizen = 1 then 'Senior Citizen' else 'Non - Senior- Citizen' end as Customer_type,
	count(churn) as customers
	from telco_customer_churn
	where churn = 'Yes'
	group by case when seniorcitizen = 1 then 'Senior Citizen' else 'Non - Senior- Citizen' end;


-- Q11. How does churn differ by partner and dependents status?

select * from telco_customer_churn;

select 
	dependents,
	count(churn) as count_custmore
	from telco_customer_churn
	where churn = 'Yes'
	group by dependents;

-- ============ TENURE ============

-- Q12. Group tenure into bands (0-12, 13-24, 25-48, 49-72 months) and count customers and churned customers in each band.

select 
	tenur_bands,
	count(churn) as total_customer,
	sum(case when churn = 'Yes' then 1 else 0 end) as churned_customer
	from telco_customer_churn
	group by tenur_bands
	order by count(churn) desc;
	
-- Q13. In which tenure band is churn the highest?

select 
	tenur_bands,
	count(churn) as total_customer
	from telco_customer_churn
	where churn = 'Yes'
	group by tenur_bands
	order by count(churn)desc;


-- ============ REVENUE AT RISK ============

-- Q14. How much monthly revenue was lost from churned customers, by contract type?

select 
	contract,
	sum(monthlycharges) as monthly_revenue
	from telco_customer_churn
	where churn = 'Yes'
	group by contract;


-- Q15. What is the average total charges (lifetime value) of churned vs retained customers?
select 
	case
		when churn = 'Yes' then 'churned'
		else 'retained'end as type,
		Round(avg(totalcharges),2) as avg_totalcharges
		from telco_customer_churn
		group by type;

-- Q16. Which combination of contract and internet service lost the most monthly revenue?

select 
	contract,
	internetservice,
	sum(monthlycharges) as monthly_revenue
	from telco_customer_churn
	where churn = 'Yes'
	group by contract, internetservice
	order by sum(monthlycharges) desc;


-- Q17. Rank payment methods within each contract type by number of churned customers (window function).

select * from telco_customer_churn;

select 
	contract,
	paymentmethod,
	count(case when churn = 'Yes' then 1 end) as churne_cust,
	rank() over(partition by contract order by count(case when churn = 'Yes' then 1 end) desc) as rnk
	from telco_customer_churn
	group by contract,paymentmethod;
	
	

-- ============ WIN-BACK (ACTIVE BUT HIGH RISK) ============
-- High-risk profile: Month-to-month contract, tenure <= 12, Fiber optic, Electronic check

-- Q18. How many active customers match the high-risk profile, and how much MRR do they represent?

select 
	count(*) as active_cust,
	sum(monthlycharges) as high_risk
	from telco_customer_churn
	where contract = 'Month-to-month'
	and paymentmethod = 'Electronic check'
	and tenure <= 12
	and internetservice = 'Fiber optic'
	and churn = 'No';
	
-- Q19. Create a view vw_churn_analysis with tenure_band and high_risk_flag columns for Power BI.
WITH churn_cte AS (
    SELECT
        *,
        CASE
            WHEN Contract = 'Month-to-month'
             AND tenure <= 12
             AND InternetService = 'Fiber optic'
             AND PaymentMethod = 'Electronic check'
            THEN 'High Risk'
            ELSE 'Not High Risk'
        END AS high_risk_flag
    FROM telco_customer_churn
)
SELECT *
FROM churn_cte;