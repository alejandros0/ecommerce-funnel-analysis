---

[Read in English](#english) | [Leer en Español](#espanol)

---

&lt;a name="english"&gt;&lt;/a&gt;

# 📊 E-Commerce Funnel & Segmentation Analysis (SQL + Power BI)

This is a **Funnel Analysis** project that replicates a real-world business scenario.
The analysis follows a detective's journey: from finding a problem (The "What")
to systematically testing and disproving 4 common hypotheses to find
the true root cause (The "Why").

This project demonstrates key Data Analyst skills:
* **Technical Analysis (SQL):** Using `CTEs`, `CASE WHEN`, `JOINs`, and `GROUP BY` to clean, segment, and analyze data at the session level.
* **Data Visualization (Power BI):** Building a dashboard that tells a clear story, using intentional color palettes and conclusive titles.
* **Business Acumen:** Formulating hypotheses, validating them with data, and delivering an actionable business recommendation.

**Tools Used:** MySQL, Power BI, SQL

---

## 1. The Business Problem
The objective was to analyze the user flow to identify the largest drop-off
in the conversion funnel. My job was not just to find *where* users were dropping,
but *why*, by following a process of hypothesis and validation.

---

## 2. About the Data
This project uses a synthetic, publicly available e-commerce dataset (`customer_journey.csv`) that tracks complete user sessions, from the first click to the final conversion. The data was imported into a MySQL database (`funnel_project`) and analyzed from a single table (`event_log`).

### Data Dictionary (Schema)
The `event_log` table has the following structure:

| Column | Description | Data Type |
| :--- | :--- | :--- |
| `SessionID` | The unique identifier for a user session. | `VARCHAR` |
| `UserID` | The unique identifier for a user. | `VARCHAR` |
| `Timestamp` | The date and time of the event. | `TIMESTAMP` |
| `PageType` | The stage of the funnel (`home`, `product_page`, `cart`, `checkout`, `confirmation`). | `VARCHAR` |
| `DeviceType` | The device used (e.g., 'Mobile', 'Desktop', 'Tablet'). | `VARCHAR` |
| `Country` | The user's country of origin. | `VARCHAR` |
| `ReferralSource`| The source of the traffic (e.g., 'Google', 'Social Media'). | `VARCHAR` |
| `TimeOnPage_seconds` | Time spent on the page in seconds. | `INT` |
| `ItemsInCart` | Number of items in the user's cart. | `INT` |
| `Purchased` | (Boolean) 1 if the session ended in a purchase, 0 otherwise. | `INT` |

---

## 3. The Engine (SQL Queries)
Instead of loading raw data into Power BI (which is slow and inefficient), I used MySQL
to perform all the analysis. Power BI connects only to the clean, aggregated results,
which is a best practice. The analysis is performed at the **SessionID** level to accurately track individual user journeys.

**View the complete SQL queries here:** [`sql_queries.sql`](sql_queries.sql)

---

&lt;!-- INICIO SECCIÓN 4 - CERO ESPACIOS ANTES DEL ## --&gt;

## 4. The Investigation (Step-by-Step Analysis)

My analysis followed a process of hypothesis elimination.

**Insight 1 (The "What"): Identifying the Problem**
The first step was to understand the 5-step funnel. The data shows two major drop-offs: one at Product Page -&gt; Cart (the largest) and another at Cart -&gt; Checkout. The investigation focused on the first drop.

![Funnel Chart](images/chart_1_funnel.png)

**Insight 2 (Hypothesis 1: FALSE): Is it a Device Issue?**
My first hypothesis was that it could be a technical issue (e.g., the "Add to Cart" button is broken on mobile). 

**Conclusion: FALSE.** The device segmentation chart shows that the drop-off percentage is identical across Mobile, Desktop, and Tablet. The problem is not technical.

![Device Chart](images/chart_2_device.png)

**Insight 3 (Hypothesis 2: FALSE): Is it a Marketing Issue?**
My second hypothesis was that the marketing team was driving "junk traffic" (e.g., from Social Media) that would browse but never buy.

**Conclusion: FALSE.** The referral source segmentation chart shows that all sources (Social Media, Email, Direct, Google) have the exact same drop-off pattern. The traffic is good quality; the problem is on the page.

![Referral Chart](images/chart_3_referral.png)

**Insight 4 (Hypothesis 3: FALSE): Is it a Logistics Issue?**
My third hypothesis was that it could be a logistics problem (e.g., high shipping costs to certain countries).

**Conclusion: FALSE.** The country segmentation chart shows the drop-off is universal. Users in the USA, UK, India, and France abandon at the same rate. It is not a shipping issue.

![Country Chart](images/chart_4_country.png)

**Insight 5 (Hypothesis 4: FALSE): Is it a Clarity Issue?**
My final hypothesis was that the product page was confusing, and users were leaving quickly because they didn't understand the offer.

**Conclusion: FALSE.** The time-on-page analysis shows that users who do NOT add to cart (Group 2) spend 95 seconds on average, almost the same as the 97 seconds spent by those who DO (Group 1). Users have plenty of time to decide; the problem is not confusion.

![Time on Page Chart](images/chart_5_time.png)

&lt;!-- INICIO SECCIÓN 5 - CERO ESPACIOS ANTES DEL ## --&gt;

## 5. Final Conclusion & Recommendation

I have scientifically proven that the problem is **NOT** technical (mobile), **NOT** marketing (traffic), **NOT** logistics (countries), and **NOT** clarity (time on page).

**The problem is UNIVERSAL and FUNDAMENTAL.**

The drop-off is a "tax" that the Product Page's User Experience (UX) is charging all users equally.

### Business Recommendation
The Product (UX/UI) team must stop looking for external culprits and focus 100% on redesigning the product page. I recommend running A/B Tests on the only elements that all users see:

- **The Price** (Test a discount).
- **The 'Add to Cart' Button** (Test a different color/text).
- **The Offer** (Test adding a 'Free Shipping' banner).

---
