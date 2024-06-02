-- EDA (Explortary Data Anaysis)

use world_layoffs;

SELECT *
FROM layoff_raw_edit;

-- 1. Max total laid-off and Percentage laid_off
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoff_raw_edit;

-- 2. Company that has 1 for Percentage laid_off
SELECT *
FROM layoff_raw_edit
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

-- 3. Which company has the  most Funding in Millions
SELECT *
FROM layoff_raw_edit
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- 4. Whcih Company has the most laid_off
SELECT company, SUM(total_laid_off)
FROM layoff_raw_edit
GROUP BY company
ORDER BY 2 DESC;

-- 5. Minimum and Maxium Date
SELECT MIN(`date`), MAX(`date`)
FROM layoff_raw_edit;

-- 6. Which industry has the most laid-off
SELECT industry, SUM(total_laid_off)
FROM layoff_raw_edit
GROUP BY industry
ORDER BY 2 DESC; 

-- 7. Which Country has the most laid_off
SELECT country, SUM(total_laid_off)
FROM layoff_raw_edit
GROUP BY country
ORDER BY 2 DESC; 

-- 8. Which date has the most laid_off
SELECT `date`, SUM(total_laid_off)
FROM layoff_raw_edit
GROUP BY `date`
ORDER BY 1 DESC; 

-- 9. Which Year has the most laid_off
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoff_raw_edit
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

-- 10. Progression of layoff (Rolling-Sum)
-- Months of laid-off
SELECT SUBSTRING(`date`,1,7) AS Months , SUM(total_laid_off)
FROM layoff_raw_edit
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY Months
ORDER BY 1 ASC;

-- Rolling Total using CTE
WITH Rollig_Total AS
(
SELECT SUBSTRING(`date`,1,7) AS Months , SUM(total_laid_off) AS Total_laid_off
FROM layoff_raw_edit
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY Months
ORDER BY 1 ASC
)
SELECT  Months, Total_laid_off,
SUM(Total_laid_off) OVER(ORDER BY Months ) AS Rolling_Total
FROM Rollig_Total;

-- 11. Which company has the most laid-off per year
SELECT company,YEAR(`date`) ,SUM(total_laid_off)
FROM layoff_raw_edit
GROUP BY company,YEAR(`date`)
ORDER BY 3 DESC;

WITH Company_year (company, years, total_laid_off)AS
(
SELECT company,YEAR(`date`) ,SUM(total_laid_off)
FROM layoff_raw_edit
GROUP BY company,YEAR(`date`)
ORDER BY 3 DESC  
),Company_Year_Rank AS
(SELECT* , 
DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS RANKING
FROM Company_year
WHERE years IS NOT NULL
ORDER BY RANKING ASC
)
SELECT *
FROM Company_Year_Rank
WHERE RANKING <=5;