
-- ============================================================
-- WORLD HAPPINESS REPORT — SQLite Cleaning Script
-- ============================================================
-- HOW TO IMPORT (run this in your terminal first):
--   sqlite3 happiness.db
--   .mode csv
--   .headers on
--   .import happiness.csv happiness
--   .quit
-- Then run this entire file:
--   sqlite3 happiness.db < happiness_cleaning.sql
-- ============================================================
--import the happiness.csv file into a table named happiness in the database using terminal command
select * from happiness ;
--couting the number of rows in the happiness table
SELECT count(*) FROM happiness ;
-- Create a backup copy of the happiness table
CREATE TABLE happinesscopy AS SELECT * FROM happiness ;
SELECT * FROM happinesscopy ;
-- Verify the copy was created
SELECT count(*) FROM happinesscopy ;
--Cleaning:-
--First thing — confirm exactly how many rows and columns you have
select 
count(*) as total_rows,
count(distinct country) as unique_countries,
count(distinct year) as unique_years,
min(year) as earliest_year,
max(year) as latest_year
from happinesscopy ;
--checking for missing values as csv files says 2005-2025 but earliest year is 2011 and latest year is 2023
--created temporary table and joined with happinesscopy to find the missing years in the happiness table
CREATE TABLE missing_table (year int);
insert into missing_table (year) values (2005),(2006),(2007),(2008),(2009),(2010),(2011),(2012),(2013),(2014),(2015),(2016),(2017),(2018),(2019),(2020),(2021),(2022),(2023),(2024),(2025);
select DISTINCT(mt.year)
from missing_table as mt
left join happinesscopy as ha on ha.year = mt.year
where ha.year is null;
--- Result: 2005,2006,2007,2008,2009,2010,2013 are missing
-- These years were never collected
-- Next checking null values
SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN country IS NULL OR country = '' THEN 1 ELSE 0 END) AS missing_country,
    COUNT(*) - COUNT(happiness_score) AS missing_happiness_score,
    COUNT(*) - COUNT(lower_whisker) AS missing_lower_whisker,
    COUNT(*) - COUNT(upper_whisker) AS missing_upper_whisker,
    COUNT(*) - COUNT(explained_log_gdp_per_capita) AS missing_gdp,
    COUNT(*) - COUNT(explained_social_support) AS missing_social_support,
    COUNT(*) - COUNT(explained_healthy_life_expectancy) AS missing_health,
    COUNT(*) - COUNT(explained_freedom) AS missing_freedom,
    COUNT(*) - COUNT(explained_generosity) AS missing_generosity,
    COUNT(*) - COUNT(explained_corruption) AS missing_corruption
FROM happinesscopy;
-- Result: 0 missing country, 0 missing happiness_score, 0 missing lower_whisker, 0 missing upper_whisker, 0 missing gdp, 0 missing social_support, 0 missing health, 0 missing freedom, 0 missing generosity, 0 missing corruption

-- Next checking for empty strings in the lower_whisker column(sampling to see why lower_whisker has 0 missing values but there are empty strings in the column)
select count(*) from happinesscopy
where lower_whisker ='';

select count(*) from happinesscopy
where lower_whisker is null;
-- update the lower_whisker column to null where there are empty strings
update happinesscopy
set lower_whisker = null
where lower_whisker ='';
--updating the upper whisker,explained_log_gdp_per_capita, explained_social_support, explained_healthy_life_expectancy, explained_freedom, explained_generosity, explained_corruption columns to null where there are empty strings
update happinesscopy
set
    upper_whisker = case when upper_whisker = '' then null else upper_whisker end,
    explained_log_gdp_per_capita = case when explained_log_gdp_per_capita = '' then null else explained_log_gdp_per_capita end,
    explained_social_support = case when explained_social_support = '' then null else explained_social_support end,
    explained_healthy_life_expectancy = case when explained_healthy_life_expectancy = '' then null else explained_healthy_life_expectancy end,
    explained_freedom = case when explained_freedom = '' then null else explained_freedom end,
    explained_generosity = case when explained_generosity = '' then null else explained_generosity end,
    explained_corruption = case when explained_corruption = '' then null else explained_corruption end;

--checking again for missing values after updating empty strings to null

SELECT
    COUNT(*) AS total_rows,
    (COUNT(*) - COUNT(distinct country)) AS missing_country,
    COUNT(*) - COUNT(happiness_score) AS missing_happiness_score,
    COUNT(*) - COUNT(lower_whisker) AS missing_lower_whisker,
    COUNT(*) - COUNT(upper_whisker) AS missing_upper_whisker,
    COUNT(*) - COUNT(explained_log_gdp_per_capita) AS missing_gdp,
    COUNT(*) - COUNT(explained_social_support) AS missing_social_support,
    COUNT(*) - COUNT(explained_healthy_life_expectancy) AS missing_health,
    COUNT(*) - COUNT(explained_freedom) AS missing_freedom,
    COUNT(*) - COUNT(explained_generosity) AS missing_generosity,
    COUNT(*) - COUNT(explained_corruption) AS missing_corruption

FROM happinesscopy;
--result:0 missing country,1094 missing lower_whisker, 1103 missing upper_whisker, 1103 missing gdp, 1103 missing social_support,1103 missing health, 1103 missing freedom, 1103 missing generosity,1103 missing corruption  
-- Next checking the distribution of missing values across years to see if there are any patterns in the missing data
SELECT
    year,
    count(*)                                                        AS total_rows,
    SUM(CASE WHEN lower_whisker IS NULL THEN 1 ELSE 0 END)          AS null_lower_whisker,
    SUM(CASE WHEN upper_whisker IS NULL THEN 1 ELSE 0 END)          AS null_upper_whisker,
    SUM(CASE WHEN explained_log_gdp_per_capita IS NULL THEN 1 ELSE 0 END) AS null_gdp,
    SUM(CASE WHEN explained_social_support IS NULL THEN 1 ELSE 0 END)     AS null_social,
    SUM(CASE WHEN explained_healthy_life_expectancy IS NULL THEN 1 ELSE 0 END) AS null_health,
    SUM(CASE WHEN explained_freedom IS NULL THEN 1 ELSE 0 END)      AS null_freedom,
    SUM(CASE WHEN explained_generosity IS NULL THEN 1 ELSE 0 END)   AS null_generosity,
    SUM(CASE WHEN explained_corruption IS NULL THEN 1 ELSE 0 END)   AS null_corruption,
    SUM(CASE WHEN dystopia_plus_residual IS NULL THEN 1 ELSE 0 END) AS null_dystopia
FROM happinesscopy
GROUP BY year
ORDER BY year;         
-- it shows that till 2019 factor columns gdp,hapiness_score, social_support, health, freedom, generosity, corruption have  missing values but from 2019 to 2025 there are only few missing values in these columns which means hapiness report started collecting data for these factors from 2019 and before that they were not collected which is why there are many missing values in these columns before 2019
--global trends in happiness scores over time
SELECT
    year,
    min(happiness_score) AS min_happiness_score,
    avg(happiness_score) AS avg_happiness_score,
    max(happiness_score) AS max_happiness_score
FROM happinesscopy
GROUP BY year
ORDER BY year ;
-- it shows that the average happiness score has been increasing over time, with a slight dip in 2020, likely due to the COVID-19 pandemic. The minimum is going down and maximum happiness scores have also generally increased over time, indicating that overall happiness levels have been improving globally.
-- which country has the lowest happiness score for each year.
SELECT 
    year,
    country,
    min(happiness_score) AS min_happiness_score
from happinesscopy
GROUP BY year
ORDER BY year DESC, min_happiness_score;
--it shows afghanistan has the lowest happiness score for most of the years(from 2019 to 2025)
-- lets find out the whole journey of afghanistan's happiness score over the years
SELECT
    year,
    country,
    happiness_score
FROM happinesscopy
WHERE country = 'Afghanistan'
ORDER BY year;
--we want to analyze whether the hapiiness index of afghanistand is increasing or decreasing ot by how much--that can be done by analyzing the change in total quantity of the consecutive indexes of afghanistan
--we will use lag function

SELECT
    year,
    country,
    happiness_score,
    happiness_score - LAG(happiness_score, 1) OVER(
        PARTITION BY country 
        ORDER BY year
    ) AS change_in_happiness_score
FROM 
    happinesscopy
WHERE 
    country = 'Afghanistan';
    --2019(Coronavirus) is the biggest drop in happiness score happened and second hit was 2022(Tabliban TAke OVEr)
    --2025 is the highest happiness score for Afghanistan in 13 years but it is still very low compared to other countries

--let's find out the most happiest country in the world for each year

select 
    year,
    country,
    max(happiness_score) AS max_happiness_score
from happinesscopy
group by year
order by year DESC, max_happiness_score DESC;
--Finland has the highest happiness score for most of the years(from 2017 to 2025)

--Afghanistan — started at 4.2, crashed to 1.3, driven by real world events
--Finland — locked between 7.6 and 7.8, consistent, stable, unmoved by global events

--how many years was each country in the top 10?
SELECT
    country,
    COUNT(*) AS years_in_top_10

    FROM HAPPINESSCOPY
WHERE rank_in_year <= 10
GROUP BY country
ORDER BY years_in_top_10 DESC, country;
-- Nordic countries consistently the happiest

--does richer countries have higher happiness scores?
SELECT
    year,
    country,
    happiness_score,
    explained_log_gdp_per_capita    
FROM happinesscopy
WHERE explained_log_gdp_per_capita IS NOT NULL
order by year, explained_log_gdp_per_capita DESC;
--Luxembourg has the highest GDP (1.536) but happiness score is 7.23 — not the highest.
--Finland has lower GDP (1.285) but happiness score is 7.80 — one of the highest!
--no clear correlation between GDP and happiness score, other factors must be at play.

-- ranks countries by how much happier they are beyond what GDP alone predicts
SELECT
    country,
    ROUND(AVG(explained_log_gdp_per_capita), 3) AS avg_gdp_contribution,
    ROUND(AVG(happiness_score), 3) AS avg_happiness,
    ROUND(AVG(happiness_score) - AVG(explained_log_gdp_per_capita), 3) AS happiness_beyond_gdp
FROM happinesscopy
WHERE explained_log_gdp_per_capita IS NOT NULL
GROUP BY country
ORDER BY happiness_beyond_gdp DESC
LIMIT 15;
-- Countries at the top are happier than their GDP alone predicts
-- Countries at the bottom are underperforming relative to their wealth

--  drop the helper table created mid-script for year gap detection
DROP TABLE IF EXISTS missing_table;

--Export your cleaned happinesscopy table from SQLite to CSV:
-- sqlite3 happiness.db
 -- .mode csv
 -- .headers on
--.output happiness_cleaned.csv
 -- SELECT * FROM happinesscopy;
  --.quit