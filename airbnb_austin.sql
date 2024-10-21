-- --------------------------Top 20 earnerners in the airbnb business------------------------
USE airbnb;
SELECT id, listing_url, name, 30 - availability_30 AS booked_out_30,
CAST(replace(Price, '$','') AS UNSIGNED) AS PRICE_CLEAN,
CAST(replace(PRICE, '$','') AS UNSIGNED) * (30 - AVAILABILITY_30) AS PROJ_REV_30
FROM listings ORDER BY PROJ_REV_30 DESC LIMIT 20;

-- -- -------------------------Top 10 neighbourhoods in Austin--------------------------------
SELECT 
    neighbourhood,
    avg_avail_365,
    total_listings,
    final_score,
    -- Generate continuous ranks for the final combined score
    ROW_NUMBER() OVER (ORDER BY final_score ASC) AS combined_rank
FROM (
    SELECT 
        neighbourhood, 
        AVG(availability_365) AS avg_avail_365, 
        COUNT(*) AS total_listings,
        -- Compute the combined weighted score
        (0.7 * (RANK() OVER (ORDER BY AVG(availability_365) ASC)) +
         0.3 * (RANK() OVER (ORDER BY COUNT(*) ASC))) AS final_score
    FROM listings
    GROUP BY neighbourhood
    HAVING COUNT(*) > 5  -- Filter out neighborhoods with fewer than 5 listings
) AS NeighborhoodStats
ORDER BY combined_rank ASC
LIMIT 10;

-- --------------------Top 10 property types in the top 10 neighbourhoods----------------------------
WITH PropertyStats AS (
    SELECT 
        property_type,
        neighbourhood,  -- Include neighbourhood for filtering
        ROUND(AVG(CAST(REPLACE(price, '$', '') AS UNSIGNED))) AS avg_price,  -- Cleaned average price rounded
        ROUND(AVG(accommodates)) AS avg_accommodates,  -- Rounded average accommodates
        ROUND(AVG(availability_30)) AS avg_avail_30,  -- Average availability over 30 days
        ROUND(AVG(availability_365)) AS avg_avail_365,  -- Average availability over 365 days
        COUNT(*) AS total_listings  -- Total listings for each property type
    FROM listings
    WHERE 
        price IS NOT NULL AND price != ''  -- Filter out null/empty prices
        AND neighbourhood IN (  -- Filter by the desired neighborhoods
            'Sunrise Beach Village, Texas, United States',
            'Smithville, Texas, United States',
            'West Lake Hills, Texas, United States',
            'Fischer, Texas, United States',
            'Liberty Hill, Texas, United States',
            'Round Mountain, Texas, United States',
            'Volente, Texas, United States',
            'Del Valle, Texas, United States',
            'Lakeway, Texas, United States',
            'Sunset Valley, Texas, United States'
        )
    GROUP BY property_type, neighbourhood
    HAVING COUNT(*) >= 5  -- Exclude property types with fewer than 5 listings
),

NeighborhoodStats AS (
    SELECT 
        neighbourhood,
        AVG(avg_avail_365) AS avg_neighborhood_avail_365,  -- Aggregating availability over neighborhoods
        SUM(total_listings) AS total_neighborhood_listings  -- Total listings for each neighborhood
    FROM PropertyStats
    GROUP BY neighbourhood
    HAVING total_neighborhood_listings >= 5  -- Exclude neighborhoods with fewer than 5 listings
),

PerformanceRank AS (
    SELECT 
        p.property_type,
        p.neighbourhood,
        p.avg_price,
        p.avg_accommodates,
        p.avg_avail_30,
        p.avg_avail_365,
        p.total_listings,
        -- Price value per person
        (p.avg_price / NULLIF(p.avg_accommodates, 0)) AS price_per_person,
        -- Combined score: lower price per person + lower availability is better
        (p.avg_price / NULLIF(p.avg_accommodates, 0) + p.avg_avail_365) AS combined_score
    FROM PropertyStats p
    JOIN NeighborhoodStats n ON p.neighbourhood = n.neighbourhood  -- Link filtered neighborhoods
)

SELECT 
    property_type,
    neighbourhood,
    avg_price,
    avg_accommodates,
    avg_avail_30,
    avg_avail_365,
    total_listings,
    ROW_NUMBER() OVER (ORDER BY combined_score ASC) AS value_rank  -- Rank by combined score
FROM PerformanceRank
ORDER BY value_rank  -- Order by combined rank
LIMIT 10;

-- ---------------Host behaviour patters ----------------------
ALTER TABLE reviews 
ADD COLUMN sentiment VARCHAR(10);  -- New column for sentiment classification

UPDATE reviews
SET sentiment = 
    CASE
        WHEN comments LIKE '%good%' OR 
             comments LIKE '%excellent%' OR 
             comments LIKE '%happy%' OR 
             comments LIKE '%satisfied%' OR
             comments LIKE '%great%' THEN 'positive'
        WHEN comments LIKE '%bad%' OR 
             comments LIKE '%poor%' OR 
             comments LIKE '%unhappy%' OR 
             comments LIKE '%disappointed%' THEN 'negative'
        ELSE 'neutral'
    END;

SELECT sentiment, COUNT(*) 
FROM reviews 
GROUP BY sentiment;

-- ---------------Host response time and communication ratings with sentiment-------------------
SELECT 
    l.host_response_time, 
    CASE 
        WHEN l.host_acceptance_rate >= 90 AND l.host_acceptance_rate < 95 THEN '90-95%'
        WHEN l.host_acceptance_rate >= 95 AND l.host_acceptance_rate <= 100 THEN '95-100%'
        ELSE 'Out of Range'  -- This line handles unexpected values, can be modified as needed
    END AS acceptance_rate_range,
    COUNT(r.id) AS total_reviews, 
    SUM(CASE WHEN r.sentiment = 'positive' THEN 1 ELSE 0 END) AS positive_reviews, 
    ROUND(SUM(CASE WHEN r.sentiment = 'positive' THEN 1 ELSE 0 END) / COUNT(r.id) * 100, 2) AS positive_review_percentage
FROM listings l
JOIN reviews r ON l.id = r.listing_id  -- Join listings with reviews
WHERE 
    l.host_response_time IS NOT NULL AND  -- Remove null entries for response time
    l.host_acceptance_rate >= 90  -- Filter for acceptance rate
GROUP BY 
    l.host_response_time, 
    acceptance_rate_range
ORDER BY positive_review_percentage DESC;

-- ----------------------- Returning customers ------------------------
SELECT 
    r.reviewer_id, 
    l.host_is_superhost, 
    COUNT(r.id) AS review_count, 
    SUM(CASE WHEN r.sentiment = 'positive' THEN 1 ELSE 0 END) AS positive_reviews
FROM reviews r
JOIN listings l ON r.listing_id = l.id
GROUP BY r.reviewer_id, l.host_is_superhost
HAVING review_count > 1  -- Filter only returning customers
ORDER BY positive_reviews DESC;

-- -------------------------cleaning business customers------------------------
SELECT host_id, host_url, host_name, COUNT(*) AS num_dirty_reviews FROM reviews
INNER JOIN listings ON reviews.listing_id = listings.id
WHERE comments LIKE "%dirty%"
GROUP BY host_id, host_url, host_name ORDER BY num_dirty_reviews DESC;


