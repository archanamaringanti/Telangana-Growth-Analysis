-- Question1
WITH top_districts_cte AS
(
WITH cte1 AS
(
SELECT d.fiscal_year AS fiscal_year,
dd.district AS district,
ROUND(sum(documents_registered_rev)/1000000000,2)  AS Total_doc_Rev_in_bn
FROM fact_stamps fs
JOIN
dim_date d
ON fs.month = d.month
JOIN dim_districts dd
ON fs.dist_code = dd.dist_code
GROUP BY d.fiscal_year, dd.district
)
SELECT DISTINCT *,
dense_rank() OVER (PARTITION BY fiscal_year ORDER BY Total_doc_Rev_in_bn DESC) AS ranking
FROM cte1
)
SELECT *
FROM top_districts_cte
WHERE ranking <= 5;

SELECT COUNT(*) FROM fact_stamps;
SELECT COUNT(*) FROM fact_transport;
SELECT COUNT(*) FROM fact_ts_ipass;

SELECT * FROM fact_stamps;
-- Question2
-- part1
WITH cte2 AS
(
SELECT d.fiscal_year AS fiscal_year,
dd.district AS district,
ROUND(sum(documents_registered_rev)/1000000,3)  AS Total_doc_Rev_in_mln,
ROUND(sum(estamps_challans_rev)/1000000,3)  AS Total_estamps_Rev_in_mln
FROM fact_stamps fs
JOIN
dim_date d
ON fs.month = d.month
JOIN dim_districts dd
ON fs.dist_code = dd.dist_code
GROUP BY d.fiscal_year, dd.district
)
SELECT *,
(Total_estamps_Rev_in_mln - Total_doc_Rev_in_mln)  AS Rev_diff_mln
FROM cte2
ORDER BY Rev_diff_mln DESC;
-- part 2

WITH cte2 AS
(
SELECT d.fiscal_year AS fiscal_year,
dd.district AS district,
ROUND(sum(documents_registered_rev)/1000000,3)  AS Total_doc_Rev_in_mln,
ROUND(sum(estamps_challans_rev)/1000000,3)  AS Total_estamps_Rev_in_mln
FROM fact_stamps fs
JOIN
dim_date d
ON fs.month = d.month
JOIN dim_districts dd
ON fs.dist_code = dd.dist_code
WHERE d.fiscal_year = 2022
GROUP BY d.fiscal_year, dd.district
)
SELECT *,
(Total_estamps_Rev_in_mln - Total_doc_Rev_in_mln)  AS Rev_diff_mln
FROM cte2
ORDER BY Rev_diff_mln DESC
LIMIT 5;

-- Question 3

WITH cte3 AS
(
SELECT d.fiscal_year AS fiscal_year,
sum(documents_registered_cnt)  AS Total_doc_cnt_in_mln,
sum(estamps_challans_cnt)  AS Total_estamps_cnt_in_mln
FROM fact_stamps fs
JOIN
dim_date d
ON fs.month = d.month
JOIN dim_districts dd
ON fs.dist_code = dd.dist_code
GROUP BY d.fiscal_year
)
SELECT *,
(Total_estamps_cnt_in_mln - Total_doc_cnt_in_mln) AS cnt_diff
FROM cte3
ORDER BY cnt_diff DESC;

-- Question 4
WITH segment_cte AS
(
WITH cte4 AS
(
SELECT 
dd.district AS district,
ROUND(sum(documents_registered_rev)/1000000000,2)  AS Total_doc_Rev_in_bn,
ROUND(sum(estamps_challans_rev)/1000000000,2)  AS Total_estamps_Rev_in_bn
FROM fact_stamps fs
JOIN
dim_date d
ON fs.month = d.month
JOIN dim_districts dd
ON fs.dist_code = dd.dist_code
WHERE d.fiscal_year BETWEEN 2021 AND 2022
GROUP BY dd.district
)
SELECT *,
(Total_doc_Rev_in_bn + Total_estamps_Rev_in_bn) AS total_rev
FROM cte4
ORDER BY total_rev DESC
)
SELECT *,
NTILE(3) OVER (ORDER BY total_rev DESC) AS segment
FROM segment_cte;

-- Question 5

WITH high_sales_month_cte AS
(
WITH cte5 AS
(
SELECT 
d.quarter,
d.fiscal_year,
SUM(fuel_type_diesel + fuel_type_electric + fuel_type_petrol + fuel_type_others) AS fuel_type
FROM
fact_transport ft
JOIN dim_date d
ON d.month = ft.month
GROUP BY d.quarter, d.fiscal_year
)
SELECT *,
dense_rank() OVER (PARTITION BY fiscal_year ORDER BY fuel_type DESC) AS ranking
FROM cte5
)
SELECT * 
FROM 
high_sales_month_cte
WHERE ranking = 1
;

-- Question 6

SELECT 
dd.district AS district,
SUM(vehicleClass_MotorCycle) AS motorcycle,
SUM(vehicleClass_MotorCar) AS car,
SUM(vehicleClass_AutoRickshaw) AS auto,
SUM(vehicleClass_Agriculture) AS agriculture,
SUM(vehicleClass_MotorCycle + vehicleClass_MotorCar + vehicleClass_AutoRickshaw + vehicleClass_Agriculture) AS total_vehicles
FROM
fact_transport ft
JOIN dim_date d
ON d.month = ft.month
JOIN dim_districts dd 
ON ft.dist_code = dd.dist_code
WHERE d.fiscal_year = 2022
GROUP BY dd.district
ORDER BY total_vehicles DESC;

-- Question 7

CREATE VIEW petrol_diesel_electric_2022 AS
(
SELECT 
dd.district,
SUM(fuel_type_petrol) AS petrol,
SUM(fuel_type_diesel) AS diesel,
SUM(fuel_type_electric) AS electric
FROM
fact_transport ft
JOIN dim_date d
ON d.month = ft.month
JOIN 
dim_districts dd 
ON ft.dist_code = dd.dist_code
WHERE d.fiscal_year = 2022
GROUP BY dd.district
);

CREATE VIEW petrol_diesel_electric_2021 AS
(
SELECT 
dd.district,
SUM(fuel_type_petrol) AS petrol,
SUM(fuel_type_diesel) AS diesel,
SUM(fuel_type_electric) AS electric
FROM
fact_transport ft
JOIN dim_date d
ON d.month = ft.month
JOIN 
dim_districts dd 
ON ft.dist_code = dd.dist_code
WHERE d.fiscal_year = 2021
GROUP BY dd.district
);

SELECT a.district,
ROUND((a.petrol/b.petrol - 1) * 100, 2) AS petrol_growth_pct
FROM petrol_diesel_electric_2022 a
JOIN
petrol_diesel_electric_2021 b
ON a.district = b.district
ORDER BY petrol_growth_pct DESC
LIMIT 3;

SELECT a.district,
ROUND((a.petrol/b.petrol - 1) * 100, 2) AS petrol_growth_pct
FROM petrol_diesel_electric_2022 a
JOIN
petrol_diesel_electric_2021 b
ON a.district = b.district
ORDER BY petrol_growth_pct
LIMIT 3;

SELECT a.district,
ROUND((a.diesel/b.diesel - 1) * 100, 2) AS diesel_growth_pct
FROM petrol_diesel_electric_2022 a
JOIN
petrol_diesel_electric_2021 b
ON a.district = b.district
ORDER BY diesel_growth_pct DESC
LIMIT 3;

SELECT a.district,
ROUND((a.diesel/b.diesel - 1) * 100, 2) AS diesel_growth_pct
FROM petrol_diesel_electric_2022 a
JOIN
petrol_diesel_electric_2021 b
ON a.district = b.district
ORDER BY diesel_growth_pct
LIMIT 3;

SELECT a.district,
ROUND((a.electric/b.electric - 1) * 100, 2) AS electric_growth_pct
FROM petrol_diesel_electric_2022 a
JOIN
petrol_diesel_electric_2021 b
ON a.district = b.district
ORDER BY electric_growth_pct DESC
LIMIT 3;

SELECT a.district,
ROUND((a.electric/b.electric - 1) * 100, 2) AS electric_growth_pct
FROM petrol_diesel_electric_2022 a
JOIN
petrol_diesel_electric_2021 b
ON a.district = b.district
ORDER BY electric_growth_pct
LIMIT 3;

--   
CREATE VIEW fuel_vehicles_2022 AS
(
SELECT 
dd.district,
SUM(fuel_type_petrol + fuel_type_diesel + fuel_type_electric) AS fuel_vehicles
FROM
fact_transport ft
JOIN dim_date d
ON d.month = ft.month
JOIN 
dim_districts dd 
ON ft.dist_code = dd.dist_code
WHERE d.fiscal_year = 2022
GROUP BY dd.district
);

CREATE VIEW fuel_vehicles_2021 AS
(
SELECT 
dd.district,
SUM(fuel_type_petrol + fuel_type_diesel + fuel_type_electric) AS fuel_vehicles
FROM
fact_transport ft
JOIN dim_date d
ON d.month = ft.month
JOIN 
dim_districts dd 
ON ft.dist_code = dd.dist_code
WHERE d.fiscal_year = 2021
GROUP BY dd.district
);

SELECT a.district,
a.fuel_vehicles,
b.fuel_vehicles,
(a.fuel_vehicles/b.fuel_vehicles - 1) * 100 AS growth_pct
FROM fuel_vehicles_2022 a
JOIN fuel_vehicles_2021 b 
ON a.district = b.district
ORDER BY growth_pct DESC
limit 3;

SELECT a.district,
a.fuel_vehicles,
b.fuel_vehicles,
(a.fuel_vehicles/b.fuel_vehicles - 1) * 100 AS growth_pct
FROM fuel_vehicles_2022 a
JOIN fuel_vehicles_2021 b 
ON a.district = b.district
ORDER BY growth_pct
limit 3;

-- Question 8

SELECT sector,
ROUND(SUM(investment_in_cr), 2)  AS total_inv
FROM
fact_ts_ipass ts
JOIN dim_date d
ON ts.month = d.month
WHERE d.fiscal_year = 2022
GROUP BY sector
ORDER BY total_inv DESC
LIMIT 5;

-- Question 9

SELECT dd.district,
ROUND(SUM(investment_in_cr), 2)  AS total_inv
FROM
fact_ts_ipass ts
JOIN dim_districts dd
ON ts.dist_code = dd.dist_code
GROUP BY dd.district
ORDER BY total_inv DESC
LIMIT 5;

-- Question 10
WITH ctea AS
(
SELECT dd.district,
ROUND(SUM(investment_in_cr), 2) AS total_inv_in_cr
FROM fact_ts_ipass ts
JOIN dim_date d 
ON ts.month = d.month
JOIN dim_districts dd 
ON ts.dist_code = dd.dist_code
WHERE d.fiscal_year BETWEEN 2021 AND 2022
GROUP BY dd.district
),
cteb AS
(
SELECT dd.district,
ROUND(SUM( documents_registered_rev + estamps_challans_rev)/10000000, 2) AS total_rev_stamps_in_cr
FROM fact_stamps fs
JOIN dim_date d 
ON fs.month = d.month
JOIN dim_districts dd 
ON fs.dist_code = dd.dist_code
WHERE d.fiscal_year BETWEEN 2021 AND 2022
GROUP BY dd.district 
),
ctec AS
(
SELECT dd.district,
SUM(category_Non_Transport + category_Transport)/10000000 AS total_vehicle_sales_in_cr
FROM fact_transport ft
JOIN dim_date d 
ON ft.month = d.month
JOIN dim_districts dd 
ON ft.dist_code = dd.dist_code
WHERE d.fiscal_year BETWEEN 2021 AND 2022
GROUP BY dd.district
)
SELECT ctea.district,
total_inv_in_cr, 
total_rev_stamps_in_cr,
total_vehicle_sales_in_cr
FROM ctea
JOIN cteb
ON ctea.district = cteb.district
JOIN ctec 
ON cteb.district = ctec.district;

-- Question 11

SELECT sector,
ROUND(SUM(investment_in_cr), 2)  AS total_inv,
COUNT(DISTINCT ts.dist_code) AS no_of_districts
FROM
fact_ts_ipass ts
JOIN dim_date d
ON ts.month = d.month
WHERE d.fiscal_year BETWEEN 2021 AND 2022
GROUP BY sector
ORDER BY total_inv DESC
;

-- Question 12

SELECT fiscal_year,
quarter,
sector,
ROUND(SUM(investment_in_cr), 2)  AS total_inv
FROM
fact_ts_ipass ts
JOIN dim_date d
ON ts.month = d.month
GROUP BY fiscal_year, sector, quarter
ORDER BY fiscal_year, quarter, total_inv DESC;



