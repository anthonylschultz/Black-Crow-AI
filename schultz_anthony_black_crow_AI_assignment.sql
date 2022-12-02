-- Anthony Schultz
-- Black Crow AI, Data Analyst Assignment
-- December 1, 2022

-- 1a) How many unique page views are there?
=> 38,769 unique page views 

-- Unique Page Views
SELECT
  COUNT(DISTINCT page_view_id) AS count_unique_page_views
FROM
  `expanded-harbor-370301.test.page_views` AS page_views


-- 1b) How many different users generated those page views?
=> 15,184 unique users

-- Users that Generated Page Views

WITH
  unique_views AS (
  SELECT
    DISTINCT page_view_id AS count_unique_page_views,
    visitor_id
  FROM
    `expanded-harbor-370301.test.page_views` AS page_views)
SELECT
  COUNT(DISTINCT(visitor_id)) AS count_unique_users
FROM
  unique_views


-- 2a) How many page views are there by score?
score | count_page_views
null | 551
1 | 3510
2 | 3879
3 | 4096
4 | 3752
5 | 3658
6 | 3816
7 | 3749
8 | 3701
9 | 3950
10| 4107

-- Page Views by Score

SELECT
  score,
  COUNT(page_view_id) AS count_page_views
FROM
  `expanded-harbor-370301.test.page_views`
GROUP BY
  score
ORDER BY
  score ASC


-- 2b) How many users generated those page views for each score?

/*
The question specifies users, not unique users. The following query outputs score, count_page_views, and count_users. 

Seeing as though there's a 1-1 relationship between count_page_views and users, I included an additional query below 
that outputs count_unique_users for each score. 
*/

-- Users for Each Score

score | count_page_views | count_users  
null | 551 | 551
1 | 3510 | 3510 
2 | 3879 | 3879
3 | 4096 | 4096
4 | 3752 | 3752
5 | 3658 | 3658
6 | 3816 | 3816
7 | 3749 | 3749
8 | 3701 | 3701
9 | 3950 | 3950
10| 4107 | 4107

SELECT
  score,
  COUNT(page_view_id) AS count_page_views,
  COUNT(visitor_id) AS count_users
FROM
  `expanded-harbor-370301.test.page_views`
GROUP BY
  score
ORDER BY
  score ASC

-- Unique Users for each Score
score | count_page_views | count_users  
null | 551 | 350
1 | 3510 | 2525
2 | 3879 | 3210
3 | 4096 | 3734
4 | 3752 | 3506
5 | 3658 | 3280
6 | 3816 | 3262
7 | 3749 | 2761
8 | 3701 | 2169
9 | 3950 | 1500
10| 4107 | 725

SELECT
  score,
  COUNT(page_view_id) AS count_page_views,
  COUNT(DISTINCT visitor_id) AS count_unique_users
FROM
  `expanded-harbor-370301.test.page_views`
GROUP BY
  score
ORDER BY
  score ASC


-- 3) How many purchasers and purchases were there, by score? By a purchaser, we mean a unique user who made at least one purchase.

/*
I noticed the results below indicate there are instances where purchases are attributed to more than one page view and hence score. Intuition tells
me that one purchase can be attributed to more than one page view, thus why the results indicate multiple purchases per page view. The question
specifies unique users and does not specify unique purchases, hence why I reported these results. That said, I can envision an argument to report 
unique purchases which I'm happy to discuss. For the purposes of this exercise, however, I reported non-unique purchase IDs throughout the remainder of the exercise.

Also, please note the 168 hour interval chosen as a window to include purchases seven days after a page view (24 hours * 7 days). The decision was
made to use hours instead of days to err on the side of accuracy. Using minutes is also an option, but without more context on the business 
objectives, hours seem sufficient. The DATETIME field in UTC was also used instead of the DATE field in ET in favor of accuracy.
*/

score | count_purchasers | count_purchases
(null) | 161 | 336
1 | 9  | 58
2 | 16 | 31
3 | 65 | 116
4 | 69 | 138
5 | 99 | 177
6 | 124 | 254
7 | 161 | 369
8 | 192 | 625
9 | 267 | 1413
10 | 280 | 3816


-- Number of Purchasers and Purchases by Score
WITH
  page_views_joined_purchases AS (
  SELECT
    page_views.page_view_id AS page_view_id,
    page_views.site_name AS site_name,
    page_views.requested_at AS page_view_datetime,
    page_views.visitor_id AS page_view_visitor_id,
    page_views.score AS score,
    purchases.purchase_id AS purchase_id,
    purchases.site_name AS purchases_site_name,
    purchases.requested_at AS purchases_datetime,
    purchases.visitor_id AS purchaser_id,
  FROM
    `expanded-harbor-370301.test.page_views` AS page_views
  INNER JOIN
    `expanded-harbor-370301.test.purchases` AS purchases
  ON
    (page_views.site_name = purchases.site_name)
    AND (page_views.visitor_id = purchases.visitor_id)
  WHERE
    (purchases.requested_at > page_views.requested_at)
    AND (purchases.requested_at <= DATETIME_ADD(page_views.requested_at, INTERVAL 168 HOUR)))
SELECT
  score,
  COUNT(DISTINCT purchaser_id) AS count_purchasers,
  COUNT(purchase_id) AS count_purchases
FROM
  page_views_joined_purchases
GROUP BY
  score
ORDER BY 
  score ASC


-- 4) What is the purchase rate by score: that is, the count of purchases divided by the count of users for each score?

score | count_purchasers | count_purchases | purchase_rate
(null) | 161 | 336 | 2.09
1 | 9 | 58 | 6.44
2 | 16 | 31 | 1.94
3 | 65 | 116 | 1.78
4 | 69 | 138 | 2.0
5 | 99 | 177 | 1.79
6 | 124 | 254 | 2.05
7 | 161 | 369 | 2.29
8 | 192 | 625 | 3.26
9 | 267 | 1413 | 5.29
10| 280 | 3816 | 13.63

-- Purchase Rate by Score
WITH
  page_views_joined_purchases AS (
  SELECT
    page_views.page_view_id AS page_view_id,
    page_views.site_name AS site_name,
    page_views.requested_at AS page_view_datetime,
    page_views.visitor_id AS page_view_visitor_id,
    page_views.score AS score,
    purchases.purchase_id AS purchase_id,
    purchases.site_name AS purchases_site_name,
    purchases.requested_at AS purchases_datetime,
    purchases.visitor_id AS purchaser_id,
  FROM
    `expanded-harbor-370301.test.page_views` AS page_views
  INNER JOIN
    `expanded-harbor-370301.test.purchases` AS purchases
  ON
    (page_views.site_name = purchases.site_name)
    AND (page_views.visitor_id = purchases.visitor_id)
  WHERE
    (purchases.requested_at > page_views.requested_at)
    AND (purchases.requested_at <= DATETIME_ADD(page_views.requested_at, INTERVAL 168 HOUR)))
SELECT
  score,
  COUNT(DISTINCT purchaser_id) AS count_purchasers,
  COUNT(purchase_id) AS count_purchases,
  ROUND(CAST(SAFE_DIVIDE(COUNT(purchase_id), COUNT(DISTINCT purchaser_id)) AS float64), 2) AS purchase_rate
FROM
  page_views_joined_purchases
GROUP BY
  score
ORDER BY 
  score ASC

-- 5) What is the average prediction for each score, and how does this compare to the purchase rate for each score? Do our 
-- predictions appear to "work"?

/*
The average prediction seems to correlate closely with the average prediction score. To validate this, I computed the Pearson Correlation 
Coefficient between the average prediction and the average prediction score which resulted in 0.76, a strong positive correlation.
Using this metric, the predictions do appear to "work", though additional analysis on a larger sample would offer more credence to this hypothesis.
*/

score | purchase_rate | average_prediction
(null) | 2.09 | 0.35
1 | 6.44 | 0.0
2 | 1.94 | 0.01
3 | 1.78 | 0.01
4 | 2.0  | 0.02
5 | 1.79 | 0.02
6 | 2.05 | 0.03
7 | 2.29 | 0.05
8 | 3.26 | 0.09
9 | 5.29 | 0.2
10| 13.63 | 0.6

-- Pearson Correlation Coefficient between Purchase Rate and Average average_prediction 
~ 0.76 

-- Purchase Rate, Average Prediction by Score
WITH
  page_views_joined_purchases AS (
  SELECT
    page_views.page_view_id AS page_view_id,
    page_views.site_name AS site_name,
    page_views.requested_at AS page_view_datetime,
    page_views.visitor_id AS page_view_visitor_id,
    page_views.score AS score,
    page_views.prediction AS prediction,
    purchases.purchase_id AS purchase_id,
    purchases.site_name AS purchases_site_name,
    purchases.requested_at AS purchases_datetime,
    purchases.visitor_id AS purchaser_id,
  FROM
    `expanded-harbor-370301.test.page_views` AS page_views
  INNER JOIN
    `expanded-harbor-370301.test.purchases` AS purchases
  ON
    (page_views.site_name = purchases.site_name)
    AND (page_views.visitor_id = purchases.visitor_id)
  WHERE
    (purchases.requested_at > page_views.requested_at)
    AND (purchases.requested_at <= DATETIME_ADD(page_views.requested_at, INTERVAL 168 HOUR)))
SELECT
  score,
  -- COUNT(DISTINCT purchaser_id) AS count_purchasers,
  -- COUNT(purchase_id) AS count_purchases,
  ROUND(CAST(SAFE_DIVIDE(COUNT(purchase_id), COUNT(DISTINCT purchaser_id)) AS float64), 2) AS purchase_rate,
  ROUND(AVG(page_views_joined_purchases.prediction), 2) AS average_prediction
FROM
  page_views_joined_purchases
GROUP BY
  score
ORDER BY 
  score ASC

-- Pearson Coefficient of Purchase Rate, Average Prediction by Score
WITH
  pearson_corr AS (
  WITH
    page_views_joined_purchases AS (
    SELECT
      page_views.page_view_id AS page_view_id,
      page_views.site_name AS site_name,
      page_views.requested_at AS page_view_datetime,
      page_views.visitor_id AS page_view_visitor_id,
      page_views.score AS score,
      page_views.prediction AS prediction,
      purchases.purchase_id AS purchase_id,
      purchases.site_name AS purchases_site_name,
      purchases.requested_at AS purchases_datetime,
      purchases.visitor_id AS purchaser_id,
    FROM
      `expanded-harbor-370301.test.page_views` AS page_views
    INNER JOIN
      `expanded-harbor-370301.test.purchases` AS purchases
    ON
      (page_views.site_name = purchases.site_name)
      AND (page_views.visitor_id = purchases.visitor_id)
    WHERE
      (purchases.requested_at > page_views.requested_at)
      AND (purchases.requested_at <= DATETIME_ADD(page_views.requested_at, INTERVAL 168 HOUR)))
  SELECT
    score,
    -- COUNT(DISTINCT purchaser_id) AS count_purchasers,
    -- COUNT(purchase_id) AS count_purchases,
    ROUND(CAST(SAFE_DIVIDE(COUNT( purchase_id), COUNT(DISTINCT purchaser_id)) AS float64), 2) AS purchase_rate,
    ROUND(AVG(page_views_joined_purchases.prediction), 2) AS average_prediction
  FROM
    page_views_joined_purchases
  GROUP BY
    score)
SELECT
  CORR(average_prediction, purchase_rate)
FROM
  pearson_corr









