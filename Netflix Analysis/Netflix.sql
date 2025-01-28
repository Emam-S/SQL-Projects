Create database netflix;
Use netflix;
CREATE TABLE netflix
(
	show_id	VARCHAR(5),
	type VARCHAR(10),
	title VARCHAR(250),
	director VARCHAR(550),
	casts VARCHAR(1050),
	country	VARCHAR(550),
	date_added VARCHAR(55),
	release_year INT,
	rating	VARCHAR(15),
	duration VARCHAR(15),
	listed_in VARCHAR(150),
	description VARCHAR(550)
);
Select * from netflix;
Select distinct type from netflix;

## Count the number of Movies vs TV Shows

SELECT 
	type,
	COUNT(*)
FROM netflix
GROUP BY 1;

## The most common rating for movies and TV shows

WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank_1
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rank_1 = 1;


## All movies released in a specific year (e.g., 2020)

SELECT * 
FROM netflix
WHERE release_year = 2020;


## Find the top 5 countries with the most content on Netflix

SELECT country, COUNT(*) AS content_count
FROM netflix
GROUP BY country
ORDER BY content_count DESC
LIMIT 5;

## Identify the longest movie

SELECT title, duration
FROM netflix
WHERE type = 'Movie'
ORDER BY duration DESC
LIMIT 1;

## Find content added in the last 5 years

SELECT title, date_added
FROM netflix
WHERE date_added >= DATE_SUB(CURDATE(), INTERVAL 5 YEAR);

## Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT title, type, director
FROM netflix
WHERE director = 'Rajiv Chilaka';

## List all TV shows with more than 5 seasons

SELECT show_id, title, type, duration
FROM netflix
WHERE type = 'TV Show' 
AND CAST(SUBSTR(duration, 1, INSTR(duration, ' ') - 1) AS INTEGER) > 5;


## Count the number of content items in each genre

SELECT genre, COUNT(*) AS genre_count
FROM (
    SELECT DISTINCT show_id, listed_in AS genre
    FROM netflix
) AS distinct_genres
GROUP BY genre
ORDER BY genre_count DESC;


## Find each year and the average numbers of content release by India on netflix. 
-- return top 5 year with highest avg content release !

SELECT 
    release_year, 
    AVG(content_count) AS avg_content_release
FROM (
    SELECT 
        release_year, 
        COUNT(*) AS content_count
    FROM netflix
    WHERE country LIKE '%India%' -- Filter for content released by India
    GROUP BY release_year
) AS yearly_content
GROUP BY release_year
ORDER BY avg_content_release DESC
LIMIT 5;


## List all movies that are documentaries

SELECT * FROM netflix
WHERE listed_in LIKE '%Documentaries';


## Find all content without a director
SELECT * FROM netflix
WHERE director IS NULL;


## Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT * FROM netflix
WHERE 
	cast LIKE '%Salman Khan%'
	AND 
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;

## Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT 
    actor,
    COUNT(*) AS movie_count
FROM (
    SELECT 
        TRIM(SPLIT_VALUE) AS actor, 
        show_id
    FROM (
        SELECT 
            show_id, 
            country, 
            SPLIT_PART(cast, ',', n) AS SPLIT_VALUE
        FROM netflix, 
        GENERATE_SERIES(1, SPLIT_PARTS(cast)) AS n
        WHERE country LIKE '%India%'
          AND type = 'Movie'
    ) AS actor_list
) AS movies_by_actor
GROUP BY actor
ORDER BY movie_count DESC
LIMIT 10;


/*
## Categorize the content based on the presence of the keywords 'kill' and 'violence' 
## in the description field. Label content containing these keywords as 'Bad' and all other content as 'Good'. 
## Count how many items fall into each category.
*/


SELECT 
    category,
	TYPE,
    COUNT(*) AS content_count
FROM (
    SELECT 
		*,
        CASE 
            WHEN description LIKE '%kill%' OR description LIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY 1,2
ORDER BY 2;







