-- Check the number of unique app ids in both tables
SELECT
	COUNT(DISTINCT id) as unique_app_ids
FROM 
	app_store

SELECT
	COUNT(DISTINCT id) as unique_app_ids
FROM 
	app_store_description
/* Result: Both tables contain same number of unqiue apps. So, we can proceed. */


-- Check for any missing values in any of the key fields in both tables
SELECT
	COUNT(*) as missing_values_row_count
FROM 
	app_store
WHERE
	track_name is NULL or 
    size_bytes is NULL or 
    price is NULL or 
    user_rating is NULL OR
    prime_genre is NULL
   
SELECT
	COUNT(*) as missing_values_row_count
FROM
	app_store_description
WHERE   
	app_desc is NULL
/* Result: There are no missing values in any table */


-- Find Number of Apps per genre
SELECT
	prime_genre,
	COUNT(*) as num_apps
FROM
	app_store
GROUP BY
	prime_genre
ORDER BY 
	num_apps DESC
/* Result: A huge number of apps belong to the 'Games' genre, followed by 'Education', 'Entertainment', and others. */


-- Get an overview of average user rating per genre
SELECT
	prime_genre,
    ROUND(AVG(user_rating), 1) as avg_user_rating
FROM
	app_store
GROUP BY
	prime_genre
ORDER BY
	avg_user_rating DESC
/* Result: Productivity and Music genres have the highest average user ratings. */


-- Average user ratings for Free vs Paid apps overall    
SELECT
    CASE
        WHEN price > 0 THEN 'Paid'
        ELSE 'Free'
    END as price_category,
	ROUND(AVG(user_rating), 1) as avg_user_rating_overall
FROM
    app_store
GROUP BY
	price_category
ORDER BY
	avg_user_rating_overall DESC
/* Result: Paid apps have got better user rating on average. */


-- Genres having average user ratings for Paid apps greater than Free apps
WITH 
  app_with_price_category as (
    SELECT
        prime_genre,
        user_rating,
        CASE
            WHEN price > 0 THEN 'Paid'
            ELSE 'Free'
        END as price_category
    FROM
        app_store
  ),
  paid_user_rating as (
    SELECT
        prime_genre,
        count(*) as num_apps,
        ROUND(AVG(user_rating), 1) as avg_user_rating_paid
    FROM
        app_with_price_category
    WHERE
        price_category = 'Paid'
    group BY
        prime_genre
    ORDER by
        COUNT(*) DESC
  ),  
  free_user_rating as (
    SELECT
        prime_genre,
        ROUND(AVG(user_rating), 1) as avg_user_rating_free
    FROM
        app_with_price_category
    WHERE
        price_category = 'Free'
    group BY
        prime_genre
  )

SELECT
	p.prime_genre, 
    p.num_apps, 
    p.avg_user_rating_paid, 
    f.avg_user_rating_free
FROM
	paid_user_rating p
JOIN
	free_user_rating f USING (prime_genre)
WHERE
	p.avg_user_rating_paid > f.avg_user_rating_free
/* Result:  Most of the genres have higher average user rating for paid apps including Games and Entertainment*/


-- Check average size in MB (Megabytes) of apps per genre
SELECT
    prime_genre,
    ROUND(AVG(size_bytes/1e6), 2) avg_size_MB
FROM
	app_store
GROUP BY
	prime_genre
ORDER by
	avg_size_MB DESC
/* Result: Medical apps are leading the chart with average size(376.39MB) followed by Games(284.42MB) and others */ 
  
  
-- Does size of the app (more features) affect user rating
SELECT
	CASE
    	WHEN size_bytes < 5e7 THEN 'Small'
        WHEN size_bytes < 1e8 THEN 'Medium'
        ELSE 'Large'
	END AS size_category,
    ROUND(AVG(user_rating), 1) as avg_rating_over_size
FROM
	app_store
GROUP BY
	size_category
/* Result: Large size apps (>200MB) have an edge in user ratings over others */


-- Check if apps that with more supported languages have higher rating
SELECT
	CASE
    	WHEN lang_num < 10 THEN '<10 languages'
        WHEn lang_num < 30 THEN '10-30 languages'
        ELSE '>30 languages'
    end as lang_num_category,
    ROUND(AVG(user_rating), 1) as avg_user_rating
FROM
	app_store
GROUP BY
	lang_num_category
ORDER BY	
	avg_user_rating DESC
/* Result: Apps having languages in the bucket (10-30) have highest average user ratings followed by apps (>30 languages) */


-- Check if there is a correlation between app description and user rating
SELECT
	CASE
    	WHEN LENGTH(b.app_desc) < 500 THEN 'Short'
        WHEN LENGTH(b.app_desc) < 1000 THEN 'Medium'
        ELSE 'Long'
	END as app_desc_category,
    ROUND(AVG(user_rating), 1) as avg_user_rating
FROM
	app_store a
JOIN
	app_store_description b on a.id = b.id
GROUP BY
	app_desc_category
order by
	avg_user_rating DESC
/* Result: Apps with a longer description have significantly good rating on average */


-- Check the top 3 apps from each genre
SELECT
	prime_genre,
    track_name,
    user_rating,
    app_desc
FROM (
    SELECT
        a.prime_genre,
        a.track_name,
        a.user_rating,
        b.app_desc,
        ROW_NUMBER() OVER(PARTITION BY prime_genre ORDER BY user_rating DESC, rating_count_tot DESC) AS genre_rank
    FROM
        app_store a
    JOIN
        app_store_description b ON a.id = b.id
) top_apps
WHERE
	genre_rank <= 3
/* Result: Get a good idea from the attributes of top rated apps */

