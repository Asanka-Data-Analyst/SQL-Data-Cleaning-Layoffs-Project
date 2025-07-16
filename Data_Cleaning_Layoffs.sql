-- Data Cleaning

SELECT *
FROM layoffs ;

-- 1. Remove duplicates
-- 2. Standardize the Data
-- 3. Null values or Blank values
-- 4. Remove any columns 

-- if you remove columns in your raw dataset, that is a big problem
-- so what we are going to do is create some type of stage datset
-- basically what here doing is copy the raw table data into the staging table

CREATE TABLE layoffs_staging
LIKE layoffs ;


SELECT *
FROM layoffs_staging ;
-- her you will see only the column name.
-- now you have to insert the data

INSERT layoffs_staging
SELECT *
FROM layoffs ;

-- we are about to change the dataset a lot.
-- if we make some type of mistake, we want to have the raw data 
-- available.so that's why we create another dataset(staging dataset) 
-- like raw dataset


SELECT *
FROM layoffs_staging;

-- 1. Remove Duplicates
-- finding duplicates 
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company,location,industry,total_laid_off,
percentage_laid_off,`date`,stage,country,funds_raised_millions) AS row_num
FROM layoffs_staging;


WITH duplicate_cte AS
(
	SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY company,location,industry,total_laid_off,
	percentage_laid_off,`date`,stage,country,funds_raised_millions) AS row_num
	FROM layoffs_staging
) 

 SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- remove duplicates
-- first we have to create a new table layoffs_staging2 that has 
-- the row_num column

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- let see the new table (layoff_staging2) we created
SELECT *
FROM layoffs_staging2;

-- you will see the table is empty.now you have to insert the data

INSERT INTO layoffs_staging2
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY company,location,industry,total_laid_off,
	percentage_laid_off,`date`,stage,country,funds_raised_millions) AS row_num
	FROM layoffs_staging ;

-- let see now the table layoff_staging2
SELECT *
FROM layoffs_staging2 ;

-- now we can see the duplicates
SELECT *
FROM layoffs_staging2 
WHERE row_num > 1;


-- Delete the duplicates
DELETE
FROM layoffs_staging2 
WHERE row_num > 1;

-- if you see error like
-- Error Code: 1175. You are using safe update mode and 
-- you tried to update a table without a WHERE that uses a KEY column
-- what you have to just do temporary turn off the safe update mode
-- then after you delete the rows that hase duplicates ,turn on the safe update mode

SET SQL_SAFE_UPDATES = 0;
DELETE
FROM layoffs_staging2 
WHERE row_num > 1;


SELECT *
FROM layoffs_staging2 
WHERE row_num > 1;

SET SQL_SAFE_UPDATES = 1;


SELECT *
FROM layoffs_staging2 ;

-- 2. Standardizing Data
-- standardizing data is finding issues in your data
-- and fixing it
-- ----------------------------------------------------------
-- 'company' column
SELECT *
FROM layoffs_staging2;

SELECT DISTINCT(company)
FROM layoffs_staging2;

SELECT DISTINCT(TRIM(company))
FROM layoffs_staging2;

SELECT company,TRIM(company)
FROM layoffs_staging2;

-- now we have to add the upadted 'company' column to the dataset
SET SQL_SAFE_UPDATES = 0;

UPDATE layoffs_staging2
SET company = TRIM(company);

-- 'industry' column
SELECT DISTINCT(industry)
FROM layoffs_staging2
ORDER BY 1;

SELECT industry,TRIM(industry)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET industry = TRIM(industry);

-- you can see further about the categorical data in 'industry' column
SELECT DISTINCT(industry)
FROM layoffs_staging2
ORDER BY 1;

-- you will see there are lot of words for 'crypto' like 'crypto currency','cryptocurrency'
SELECT industry
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- 'location' column
SELECT DISTINCT(location)
FROM layoffs_staging2
ORDER BY 1;

SELECT location
FROM layoffs_staging2
WHERE location LIKE '%sseldorf';

UPDATE layoffs_staging2
SET location = 'Dusseldorf'
WHERE location LIKE '%sseldorf';

SELECT location
FROM layoffs_staging2
WHERE location LIKE 'Malm%';

UPDATE layoffs_staging2
SET location = 'Malmo'
WHERE location LIKE 'Malm%';

UPDATE layoffs_staging2
SET location = 'Floriana polis'
WHERE location = 'FlorianÃ³polis';

SELECT location,TRIM(location)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET location = TRIM(location);

SELECT *
FROM layoffs_staging2;

-- 'country' column
SELECT DISTINCT(country)
FROM layoffs_staging2
ORDER BY 1;


UPDATE layoffs_staging2
SET country = 'United States'
WHERE country = 'United States.';

-- OR--------------------------------------------------------------------------
SELECT DISTINCT(country),TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- 'date' column
-- now 'date' column data type is text
-- this is not good for time seires anlyze .so we have to change this

SELECT `date`, STR_TO_DATE(`date`,'%m/%d/%Y')
FROM layoffs_staging2; 

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`,'%m/%d/%Y') ;

-- if you check it still shows as text data type
-- but we already changed it into date type
-- you just need to do is 
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- never do this to a raw table 
-- that is why we create alter table like staging table

-- 3. Null values or Blank values
-- 'total_laid_off' column
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL ;

-- let see the NULL's in 'total_laid_off' & percentage_laid_off columns
-- these rows might be useless
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL ;

-- 'industry' column
-- check all the rows that industry column has nulls and blanks 
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

-- let see the Airbnb company
SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';

-- convert all Blanks in 'industry' column  to NULL's 
UPDATE layoffs_staging2
SET industry = null
WHERE industry = '' ;

SELECT *
FROM layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL ;

-- you will see only the joined industry column
SELECT t1.industry,t2.industry
FROM layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL ;


UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 AS t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL
AND t2.industry IS NOT NULL) ;

SELECT DISTINCT(industry)
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Bally%';

-- -------------------------------------------------------------------
-- can we delete this
-- yes ,actually there is nothing to do with them
SELECT *
FROM layoffs_staging2
WHERE (total_laid_off IS NULL
AND percentage_laid_off IS NULL);

-- delete
DELETE
FROM layoffs_staging2
WHERE (total_laid_off IS NULL
AND percentage_laid_off IS NULL);

-- ---------------------
SELECT *
FROM layoffs_staging2;

-- 4. Remove Column
-- ahh there is another one we have to do
-- delete the unneccesary column 
-- we should do it in alter table like staging table,becuase we it is not a good 
-- to do this in raw table

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- Finalized Clean Data
SELECT *
FROM layoffs_staging2;
