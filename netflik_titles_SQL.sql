CREATE DATABASE netflix_title;
use netflix_title;

select * from netflix_titles;

#to rename show_id

ALTER TABLE netflix_titles
RENAME COLUMN ï»¿show_id TO show_id;

SELECT * FROM netflix_titles LIMIT 10;

#to find missing,empty value
select 
SUM(CASE WHEN show_id IS NULL OR show_id='' THEN 1 END)AS missing_show_id,
SUM(CASE WHEN type IS NULL OR type='' THEN 1 END)AS missing_types,
SUM(CASE WHEN title IS NULL OR title=''OR show_id = ' ' THEN 1 END)AS missing_title,
SUM(CASE WHEN director IS NULL OR director='' OR type = ' ' THEN 1 END)AS missing_director,
SUM(CASE WHEN cast IS NULL OR cast='' OR title = ' ' THEN 1 END)AS missing_cast,
SUM(CASE WHEN country IS NULL OR country='' OR country = ' ' THEN 1 END)AS missing_country,
SUM(CASE WHEN date_added IS NULL OR date_added='' OR date_added = ' ' THEN 1 END)AS missing_date_added,
SUM(CASE WHEN release_year IS NULL OR release_year='' THEN 1 END)AS missing_release_year,
SUM(CASE WHEN rating IS NULL OR rating ='' OR rating = ' ' THEN 1 END)AS missing_rating ,
SUM(CASE WHEN duration IS NULL OR duration ='' OR duration = ' ' THEN 1 END)AS missing_duration ,
SUM(CASE WHEN listed_in IS NULL OR listed_in ='' OR listed_in = ' ' THEN 1 END)AS missing_listed_in ,
SUM(CASE WHEN description IS NULL OR description ='' OR description = ' ' THEN 1 END)AS missing_description  
from netflix_titles;

select * from  netflix_titles;

#to fill missing values with null
UPDATE netflix_titles
SET director = 'null'
WHERE director IS NULL OR director = '' OR director = ' ';

SET SQL_SAFE_UPDATES = 0;


UPDATE netflix_titles
SET cast = 'null'
WHERE cast IS NULL OR cast = '' OR cast = ' ';

UPDATE netflix_titles
SET country = 'null'
WHERE country IS NULL OR country = '' OR country = ' ';

select * from  netflix_titles;

#to check
SELECT 
    SUM(director = '' OR director IS NULL OR director = ' ') AS missing_director,
    SUM(cast = '' OR cast IS NULL OR cast = ' ') AS missing_cast,
    SUM(country = '' OR country IS NULL OR country = ' ') AS missing_country
FROM netflix_titles;

select * from  netflix_titles;

#to remove latin1 words
UPDATE netflix_titles
SET 
    title = CONVERT(CAST(CONVERT(title USING latin1) AS BINARY) USING utf8),
    cast = CONVERT(CAST(CONVERT(cast USING latin1) AS BINARY) USING utf8),
    director = CONVERT(CAST(CONVERT(director USING latin1) AS BINARY) USING utf8),
    description = CONVERT(CAST(CONVERT(description USING latin1) AS BINARY) USING utf8),
    country = CONVERT(CAST(CONVERT(country USING latin1) AS BINARY) USING utf8),
    listed_in = CONVERT(CAST(CONVERT(listed_in USING latin1) AS BINARY) USING utf8);
    
    select * from  netflix_titles;
    
    # to fix date format
    UPDATE netflix_titles
SET date_added = STR_TO_DATE(date_added, '%M %d, %Y');

select * from  netflix_titles;

#flitering and cleaning duration column 
ALTER TABLE netflix_titles
ADD COLUMN duration_value INT,
ADD COLUMN duration_unit VARCHAR(20);

UPDATE netflix_titles
SET duration_value = CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED);

UPDATE netflix_titles
SET duration_unit = SUBSTRING_INDEX(duration, ' ', -1);

select * from  netflix_titles;

UPDATE netflix_titles
SET duration_unit = 'Season'
WHERE duration_unit IN ('Seasons', 'season', 'seasons');

UPDATE netflix_titles
SET duration_unit = 'min'
WHERE duration_unit IN ('mins', 'Minutes', 'minute');

select * from netflix_titles;
ALTER TABLE netflix_titles
DROP COLUMN duration;

#to check duplicate
SELECT show_id, COUNT(*) 
FROM netflix_titles
GROUP BY show_id
HAVING COUNT(*) > 1;

select * from  netflix_titles;

#to remove unwanted spaces or specified characters
UPDATE netflix_titles
SET title = TRIM(title),
    director = TRIM(director),
    cast = TRIM(cast),
    country = TRIM(country);
    
    select * from  netflix_titles;
    
ALTER TABLE netflix_titles 
MODIFY COLUMN date_added DATE;

#filter rating col
ALTER TABLE netflix_titles
ADD COLUMN duration_minutes INT null ,
ADD COLUMN seasons INT null ;

UPDATE netflix_titles
SET duration_minutes = duration_value,
    seasons = NULL
WHERE type = 'Movie' AND duration_unit = 'min';

UPDATE netflix_titles
SET seasons = duration_value,
    duration_minutes = NULL
WHERE type = 'TV Show' AND duration_unit LIKE 'Season%';

select * from netflix_titles;

#to check wrong rating   
   SELECT DISTINCT rating
FROM netflix_titles
ORDER BY rating;

#rating modification

UPDATE netflix_titles
SET rating = 'TV-MA'
WHERE rating IN ('TV MA', 'TVMA');

UPDATE netflix_titles
SET rating = 'PG-13'
WHERE rating IN ('PG 13', 'PG13');

UPDATE netflix_titles
SET rating = 'TV-14'
WHERE rating IN ('TV 14', 'TV14');

#converting ratings in categories

ALTER TABLE netflix_titles ADD COLUMN rating_category VARCHAR(20);
UPDATE netflix_titles
SET rating_category = 'Kids'
WHERE rating IN ('TV-Y', 'TV-Y7', 'TV-G', 'G');

UPDATE netflix_titles
SET rating_category = 'Teens'
WHERE rating IN ('PG', 'PG-13', 'TV-PG', 'TV-14');

UPDATE netflix_titles
SET rating_category = 'Adult'
WHERE rating IN ('R', 'TV-MA');

select * from netflix_titles;

#count of total shows
SELECT COUNT(*) AS total_shows
FROM netflix_titles;

#Count of shows by type
SELECT type, COUNT(*) AS count
FROM netflix_titles
GROUP BY type;

#top 10 countries produc
SELECT country, COUNT(*) AS show_count
FROM netflix_total
GROUP BY country
ORDER BY show_count DESC
LIMIT 10;

#top 10 directoes
SELECT director, COUNT(*) AS titles_count
FROM netflix_titles
WHERE director IS NOT NULL
GROUP BY director
ORDER BY titles_count DESC
LIMIT 10;

#top 10 cast
SELECT cast, COUNT(*) AS total_work
FROM netflix_titles
WHERE cast IS NOT NULL
GROUP BY cast
ORDER BY total_work DESC
LIMIT 10;

#rating count
SELECT rating, COUNT(*) AS count
FROM netflix_titles
GROUP BY rating
ORDER BY count DESC;

# top 10 common categories
SELECT listed_in, COUNT(*) AS count
FROM netflix_titles
GROUP BY listed_in
ORDER BY count DESC
LIMIT 10;

#total movies & tv shows
SELECT type,COUNT(*) AS total_count
FROM netflix_titles 
GROUP BY type;

#distribution of movie and tv shows
SELECT country, type, COUNT(*) AS count
FROM netflix_titles
GROUP BY country, type
ORDER BY country, type;

#Top 5 directors per country
SELECT country, director, COUNT(*) AS titles_count
FROM netflix_titles
WHERE director IS NOT NULL
GROUP BY country, director
ORDER BY country, titles_count DESC;

#Top countries producing Movies vs TV Shows
SELECT country, type, COUNT(*) AS count
FROM netflix_titles
GROUP BY country, type
ORDER BY type, count DESC;

#ratings by type
SELECT type, rating, COUNT(*) AS count
FROM netflix_titles
GROUP BY type, rating
ORDER BY type, count DESC;










































    























