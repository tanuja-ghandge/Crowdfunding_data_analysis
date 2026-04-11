create database Crowdfundingproject_db;
use Crowdfundingproject_db;

-- Total Projects by Outcome---
SELECT state AS outcome,
COUNT(ProjectID) AS total_projects
FROM projects
GROUP BY state;

-- Total Projects by Location--
SELECT country,
COUNT(ProjectID) AS total_projects
FROM projects
GROUP BY country
ORDER BY total_projects DESC;

-- Total Projects by Category--
SELECT category_id,
COUNT(ProjectID) AS total_projects
FROM projects
GROUP BY category_id
ORDER BY total_projects DESC;

-- Total Projects by Year / Quarter / Month--
-- Projects by Year--
SELECT YEAR(FROM_UNIXTIME(created_at)) AS year,
COUNT(ProjectID) AS total_projects
FROM projects
GROUP BY year
ORDER BY year;

-- Projects by Quarter--
SELECT YEAR(FROM_UNIXTIME(created_at)) AS year,
QUARTER(FROM_UNIXTIME(created_at)) AS quarter,
COUNT(ProjectID) AS total_projects
FROM projects
GROUP BY year, quarter;

-- Projects by Month--
SELECT YEAR(FROM_UNIXTIME(created_at)) AS year,
MONTH(FROM_UNIXTIME(created_at)) AS month,
COUNT(ProjectID) AS total_projects
FROM projects
GROUP BY year, month;

-- Successful Projects KPIs--
-- Total Amount Raised--
SELECT SUM(goal) AS total_amount_raised
FROM projects
WHERE state = 'successful';

-- Number of Backers--
SELECT SUM(backers_count) AS total_backers
FROM projects
WHERE state = 'successful';

-- Average Days for Successful Projects--
SELECT AVG(DATEDIFF(FROM_UNIXTIME(deadline),
FROM_UNIXTIME(created_at))) AS avg_days
FROM projects
WHERE state = 'successful';

-- Top Successful Projects--
-- Top Projects by Backers--
SELECT 
ProjectID,
backers_count,
RANK() OVER (ORDER BY backers_count DESC) AS rank_by_backers
FROM projects
WHERE state = 'successful'
LIMIT 10;

-- Top Projects by Amount Raised--
SELECT 
ProjectID,
goal,
RANK() OVER (ORDER BY goal DESC) AS rank_by_amount
FROM projects
WHERE state = 'successful'
LIMIT 10;

-- Percentage of Successful Projects--
-- Overall Success Rate--
SELECT 
ROUND(
SUM(CASE WHEN state='successful' THEN 1 ELSE 0 END) 
/ COUNT(ProjectID) * 100,2
) AS success_percentage
FROM projects;

-- Success Rate by Category--
ALTER TABLE crowdfunding_category
CHANGE COLUMN `ï»¿id` id INT;

SELECT 
c.name AS category_name,
ROUND(
SUM(CASE WHEN p.state = 'successful' THEN 1 ELSE 0 END)
/ COUNT(p.ProjectID) * 100,2
) AS success_rate
FROM projects p
JOIN crowdfunding_category c
ON p.category_id = c.id
GROUP BY c.name
ORDER BY success_rate DESC;

-- Success Rate by Year--
SELECT 
YEAR(FROM_UNIXTIME(created_at)) AS year,
ROUND(
SUM(CASE WHEN state='successful' THEN 1 ELSE 0 END)
/ COUNT(ProjectID) * 100,2
) AS success_rate
FROM projects
GROUP BY year
ORDER BY year;

-- Success Rate by Goal Range--
SELECT 
CASE
WHEN goal < 1000 THEN 'Below 1K'
WHEN goal BETWEEN 1000 AND 10000 THEN '1K-10K'
WHEN goal BETWEEN 10000 AND 50000 THEN '10K-50K'
WHEN goal BETWEEN 50000 AND 100000 THEN '50K-100K'
ELSE 'Above 100K'
END AS goal_range,

ROUND(
SUM(CASE WHEN state='successful' THEN 1 ELSE 0 END)
/ COUNT(ProjectID) * 100,2
) AS success_rate

FROM projects
GROUP BY goal_range
ORDER BY success_rate DESC;