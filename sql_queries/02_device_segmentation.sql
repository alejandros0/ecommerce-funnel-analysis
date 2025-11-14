/*
-- Segmentation Query 1 (The "Why" - Part 1: Device)
-- Uses a CTE (WITH...) to analyze behavior by device.
*/

-- STEP 1: Create a temporary summary table called "UserActions"
WITH UserActions AS (
    SELECT
        UserID,
        DeviceType, -- The column we segment by
        MAX(CASE WHEN PageType = 'home' THEN 1 ELSE 0 END) AS saw_homepage,
        MAX(CASE WHEN PageType = 'product_page' THEN 1 ELSE 0 END) AS saw_product_page,
        MAX(CASE WHEN ItemsInCart > 0 THEN 1 ELSE 0 END) AS added_to_cart,
        MAX(CASE WHEN Purchased = 1 THEN 1 ELSE 0 END) AS purchased
    FROM
        event_log
    GROUP BY
        UserID, DeviceType
)
-- STEP 2: Now, count the results from that temporary table
SELECT
    DeviceType,
    SUM(saw_homepage) AS homepage_users,
    SUM(saw_product_page) AS product_page_users,
    SUM(added_to_cart) AS cart_users,
    SUM(purchased) AS purchased_users
FROM
    UserActions
GROUP BY
    DeviceType;