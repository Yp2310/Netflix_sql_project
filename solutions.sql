-- Netflix Project
Drop table if exists netflix;
create table netflix(
	show_id varchar(6),
	type varchar(10),
	title varchar(150), 
	director varchar(208),
	casts varchar(1000),
	country varchar(150),
	date_added varchar(50),
	release_year INT,
	rating varchar(10),
	duration varchar(15),
	listed_in varchar(100),	
	description varchar(250)
);

select * from netflix;

select 
	distinct type
from netflix;

-- 15 Bussiness Problems

-- 1. Count the number of Movies vs TV Shows

Select type,
	count(*) as total_count
from netflix
group by type;

-- 2. Find the most common rating for movies and TV shows

select
	type,
	rating
from
(
	Select 
		type,
		rating,
		count(*),
		Rank() over(Partition by type order by count(*) desc) as ranking
	from netflix
	group by 1, 2
) as t1
where
	ranking = 1


-- 3. List all movies released in a specific year (e.g., 2020)

Select * from netflix
where 
	type = 'Movie'
	and
	release_year = 2020

-- 4. Find the top 5 countries with the most content on Netflix

SELECT 
	unnest(string_to_array(country, ',')) as new_country,
	COUNT(show_id) AS total_content
FROM 
	netflix
GROUP BY 1
order by 2 desc
limit 5;

--5. Identify the longest movie

Select * from netflix
where 
	type = 'Movie'
	and 
	duration = (select max(duration) from netflix)

-- 6. Find content added in the last 5 years

SELECT 
	*
FROM 
	netflix
WHERE 
	TO_DATE(TRIM(date_added), 'FMMonth DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';


-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

select * from netflix
where director ILIKE '%Rajiv Chilaka%'


--8. List all TV shows with more than 5 seasons

Select 
	*
from netflix
where 
	type = 'TV Show'
	AND
	SPLIT_PART(duration, ' ', 1)::numeric > 5 


--9. Count the number of content items in each genre

SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
	COUNT(show_id) AS total_content
FROM 
	netflix
GROUP BY genre;


-- 10.Find each year and the average numbers of content release in India on netflix. 
-- return top 5 year with highest avg content release!

Select
	Extract(Year from TO_DATE(date_added, 'Month DD, YYYY'))as year,
	count(*) as yearly_content, 
	ROUND(
	count(*)::numeric/ (Select count(*) from netflix where country = 'India')::numeric * 100 
	,2) as avg_content_per_year
from netflix
where country = 'India'
group by 1


-- 11. List all movies that are documentaries

select * from netflix
where
	listed_in ILIKE '%documentaries%'

-- 12. Find all content without a director

select * from netflix 
where
	director is null


-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

select * from netflix 
where
	casts ILIKE '%Salman Khan%'
	AND
	release_year > EXTRACT(Year from Current_date) - 10


-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

select
--show_id,
--casts,
UNNEST(String_to_array(casts, ',')) as actors,
count(*) as total_content
from netflix
where country ILIKE '%india'
group by 1
order by 2 desc
limit 10

-- 15.
-- Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
-- the description field. Label content containing these keywords as 'Bad' and all other 
-- content as 'Good'. Count how many items fall into each category.

WITH new_table
AS
(
select
*,
	case
	when
		description ILIKE '%kill%' OR
		description ILIKE '%violence%' THEN 'Bad_content'
		Else 'Good Content'
	END category
from netflix
)
Select 
	category,
	count(*) as total_content
from new_table
group by 1


