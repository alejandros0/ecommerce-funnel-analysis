/*
-- Segmentation Query 4 (The "Why" - Part 4: TimeOnPage)
-- This query compares the AVG time on product pages for users
-- who converted (added to cart) vs. those who did not.
*/

-- STEP 1: Create a temporary table of users and identify
-- if they EVER added to cart.
WITH UserActions AS (
    SELECT
        UserID,
        -- This user's "status": did they ever add to cart? 1=Yes, 0=No
        MAX(CASE WHEN ItemsInCart > 0 THEN 1 ELSE 0 END) AS eventually_added_to_cart
    FROM
        event_log
    GROUP BY
        UserID
)
-- STEP 2: Now, join that status back to the main log
-- to compare the time on page.
SELECT
    -- Create a readable group name
    CASE
        WHEN ua.eventually_added_to_cart = 1 THEN 'Group 1: Added to Cart'
        ELSE 'Group 2: Did NOT Add to Cart'
    END AS user_group,
    
    COUNT(DISTINCT e.UserID) AS total_users,
    AVG(e.TimeOnPage_seconds) AS avg_time_on_page_seconds
FROM
    event_log AS e -- "e" is a nickname for event_log
JOIN
    UserActions AS ua ON e.UserID = ua.UserID -- "ua" is a nickname for UserActions
WHERE
    e.PageType = 'product_page' -- We ONLY care about time spent on product pages
GROUP BY
    user_group; -- Group by our two defined groups