-- DATA CLEANING
-- . REMOVING DUPLICATES
-- . STANDARDING THE DATA
-- . NULL VALUES AND BLANK VALUES
-- . REMOVING ANY COLUMNS

SELECT *
FROM layoffs;

-- A. CREATING RAW TABLE

CREATE TABLE Layoff_Raw
LIKE layoffs;

SELECT *
FROM layoff_raw;

INSERT layoff_Raw
SELECT *
FROM
layoffs;

-- B. REMOVING DUPLICATE

-- 1. Checking for duplicate
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, industry, total_laid_off, percentage_laid_off,'date') AS Row_Num
FROM layoff_raw;

-- 2. Checking for  more than (1)duplicate 
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions) AS Row_Num
FROM layoff_raw
)
SELECT *
FROM
duplicate_cte
WHERE Row_NUM > 1;

-- 3. Confriming more than 1 duplicates
SELECT *
FROM layoff_raw
WHERE company = 'Casper';

-- 4. Deleting duplicates

CREATE TABLE `layoff_raw_edit` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `ROW_NUM` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoff_raw_edit
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions) AS Row_Num
FROM layoff_raw;

SELECT* 
FROM layoff_raw_edit
WHERE ROW_NUM > 1;

DELETE
FROM layoff_raw_edit
WHERE ROW_NUM > 1;

SELECT* 
FROM layoff_raw_edit;

-- C. STANDAZING DATA

-- 1.Removing spaces from the text
SELECT company, TRIM(company)
FROM layoff_raw_edit;

UPDATE layoff_raw_edit
SET company = TRIM(company);

-- 2.Checking for repeated words or Bad spelling and updating them to a particular word
-- NB: Ensure to inpect all coloums for typographical error

SELECT DISTINCT(industry)
FROM layoff_raw_edit
ORDER BY 1;

SELECT* 
FROM layoff_raw_edit
WHERE industry LIKE 'Crypto%';

UPDATE layoff_raw_edit
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- 3. Removing the puncuation(.) from a word
SELECT DISTINCT(country)
FROM layoff_raw_edit
ORDER BY 1;

SELECT DISTINCT country, TRIM(TRAILING '.' FROM  country)
FROM layoff_raw_edit
ORDER BY 1;

UPDATE layoff_raw_edit
SET country = TRIM(TRAILING '.' FROM  country)
WHERE country LIKE 'United States%';

-- 4. Change date from text  to datetime
SELECT `date`,
STR_TO_DATE (`date`, "%m/%d/%Y" )
FROM
layoff_raw_edit;

UPDATE layoff_raw_edit
SET `date` = STR_TO_DATE (`date`, "%m/%d/%Y" );

ALTER TABLE layoff_raw_edit
MODIFY COLUMN `date` DATE;

SELECT `date`
FROM
layoff_raw_edit;

-- D. CHECKING FOR NULL VALUES OR BLANK VALUE AND REPLACING OR REMOVING THEM

-- 1 Checking for NULL values and BLANK values

SELECT *
FROM layoff_raw_edit
WHERE total_laid_off IS NULL
AND funds_raised_millions IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoff_raw_edit
WHERE industry IS NULL
OR industry = '';

SELECT *
FROM layoff_raw_edit
WHERE company = 'Airbnb';

-- 2. Checking which industry needs to be filled with info 

UPDATE layoff_raw_edit
SET industry = NULL
WHERE industry = '';          

SELECT t1.industry, t2.industry
FROM layoff_raw_edit t1
JOIN layoff_raw_edit t2
		ON t1.company = t2.company
WHERE(t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

UPDATE layoff_raw_edit t1
JOIN layoff_raw_edit t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- 3. Remove columns that has excessive NULL (Colums are useless)
DELETE
FROM layoff_raw_edit
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT*
FROM layoff_raw_edit;

ALTER TABLE layoff_raw_edit
DROP COLUMN ROW_NUM;
        




