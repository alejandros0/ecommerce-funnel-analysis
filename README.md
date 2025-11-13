````markdown
[Read in English](#english-version) | [Leer en Español](#versión-en-español)

---

<a name="english-version"></a>

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

## 3. The Dashboard (Final Result)
This is the final dashboard that summarizes the entire investigation. The step-by-step analysis follows below.

![Full Investigation Dashboard](./images/dashboard_full.png)

---

## 4. The Engine (SQL Queries)
Instead of loading raw data into Power BI, I used MySQL to pre-aggregate and segment the data. The analysis is performed at the **SessionID** level to accurately track individual user journeys.

<details>
<summary>Click to see all 5 (New) SQL Queries</summary>

**Query 1: General 5-Step Funnel (The "What")**
*This query counts the unique sessions that reached each stage of the 5-step funnel.*
```sql
/*
-- General 5-Step Funnel Query (The "What")
-- Counts unique SessionIDs that reached each page.
*/

-- 1. Count sessions that saw Homepage
SELECT
    '1. Homepage' AS stage,
    COUNT(DISTINCT SessionID) AS total_sessions,
    1 AS step_order
FROM event_log
WHERE PageType = 'home'

UNION

-- 2. Count sessions that saw Product Page
SELECT
    '2. Product Page' AS stage,
    COUNT(DISTINCT SessionID) AS total_sessions,
    2 AS step_order
FROM event_log
WHERE PageType = 'product_page'

UNION

-- 3. Count sessions that saw Cart
SELECT
    '3. Cart' AS stage,
    COUNT(DISTINCT SessionID) AS total_sessions,
    3 AS step_order
FROM event_log
WHERE PageType = 'cart'

UNION

-- 4. Count sessions that saw Checkout
SELECT
    '4. Checkout' AS stage,
    COUNT(DISTINCT SessionID) AS total_sessions,
    4 AS step_order
FROM event_log
WHERE PageType = 'checkout'

UNION

-- 5. Count sessions that saw Confirmation (Purchased)
SELECT
    '5. Confirmation' AS stage,
    COUNT(DISTINCT SessionID) AS total_sessions,
    5 AS step_order
FROM event_log
WHERE PageType = 'confirmation'

ORDER BY
    step_order;
````

**Query 2: Hypothesis 1 (Device)**
*This query segments the 5-step funnel by device.*

```sql
/*
-- Segmentation Query 1 (The "Why" - Part 1: Device)
-- Segments the 5-step funnel by DeviceType.
*/

-- STEP 1: Create a temporary summary table of actions per session
WITH SessionActions AS (
    SELECT
        SessionID,
        DeviceType, -- The column we segment by
        MAX(CASE WHEN PageType = 'home' THEN 1 ELSE 0 END) AS saw_homepage,
        MAX(CASE WHEN PageType = 'product_page' THEN 1 ELSE 0 END) AS saw_product_page,
        MAX(CASE WHEN PageType = 'cart' THEN 1 ELSE 0 END) AS saw_cart,
        MAX(CASE WHEN PageType = 'checkout' THEN 1 ELSE 0 END) AS saw_checkout,
        MAX(CASE WHEN PageType = 'confirmation' THEN 1 ELSE 0 END) AS saw_confirmation
    FROM
        event_log
    GROUP BY
        SessionID, DeviceType
)
-- STEP 2: Count the results from that temporary table
SELECT
    DeviceType,
    SUM(saw_homepage) AS homepage_sessions,
    SUM(saw_product_page) AS product_page_sessions,
    SUM(saw_cart) AS cart_sessions,
    SUM(saw_checkout) AS checkout_sessions,
    SUM(saw_confirmation) AS confirmation_sessions
FROM
    SessionActions
GROUP BY
    DeviceType;
```

**Query 3: Hypothesis 2 (Referral Source)**
*This query segments the 5-step funnel by referral source.*

```sql
/*
-- Segmentation Query 2 (The "Why" - Part 2: Referral)
-- Segments the 5-step funnel by ReferralSource.
*/

-- STEP 1: Create a temporary summary table of actions per session
WITH SessionActions AS (
    SELECT
        SessionID,
        ReferralSource, -- <--- The only change is here
        MAX(CASE WHEN PageType = 'home' THEN 1 ELSE 0 END) AS saw_homepage,
        MAX(CASE WHEN PageType = 'product_page' THEN 1 ELSE 0 END) AS saw_product_page,
        MAX(CASE WHEN PageType = 'cart' THEN 1 ELSE 0 END) AS saw_cart,
        MAX(CASE WHEN PageType = 'checkout' THEN 1 ELSE 0 END) AS saw_checkout,
        MAX(CASE WHEN PageType = 'confirmation' THEN 1 ELSE 0 END) AS saw_confirmation
    FROM
        event_log
    GROUP BY
        SessionID, ReferralSource -- <--- And here
)
-- STEP 2: Count the results from that temporary table
SELECT
    ReferralSource, -- <--- And here
    SUM(saw_homepage) AS homepage_sessions,
    SUM(saw_product_page) AS product_page_sessions,
    SUM(saw_cart) AS cart_sessions,
    SUM(saw_checkout) AS checkout_sessions,
    SUM(saw_confirmation) AS confirmation_sessions
FROM
    SessionActions
GROUP BY
    ReferralSource; -- <--- And here
```

**Query 4: Hypothesis 3 (Country)**
*This query segments the 5-step funnel by country.*

```sql
/*
-- Segmentation Query 3 (The "Why" - Part 3: Country)
-- Segments the 5-step funnel by Country.
*/

-- STEP 1: Create a temporary summary table of actions per session
WITH SessionActions AS (
    SELECT
        SessionID,
        Country, -- <--- The only change is here
        MAX(CASE WHEN PageType = 'home' THEN 1 ELSE 0 END) AS saw_homepage,
        MAX(CASE WHEN PageType = 'product_page' THEN 1 ELSE 0 END) AS saw_product_page,
        MAX(CASE WHEN PageType = 'cart' THEN 1 ELSE 0 END) AS saw_cart,
        MAX(CASE WHEN PageType = 'checkout' THEN 1 ELSE 0 END) AS saw_checkout,
        MAX(CASE WHEN PageType = 'confirmation' THEN 1 ELSE 0 END) AS saw_confirmation
    FROM
        event_log
    GROUP BY
        SessionID, Country -- <--- And here
)
-- STEP 2: Count the results from that temporary table
SELECT
    Country, -- <--- And here
    SUM(saw_homepage) AS homepage_sessions,
    SUM(saw_product_page) AS product_page_sessions,
    SUM(saw_cart) AS cart_sessions,
    SUM(saw_checkout) AS checkout_sessions,
    SUM(saw_confirmation) AS confirmation_sessions
FROM
    SessionActions
GROUP BY
    Country; -- <--- And here
```

**Query 5: Hypothesis 4 (Time on Page)**
*This query tests if users who add to cart spend more time on product pages than users who don't.*

```sql
/*
-- Segmentation Query 4 (The "Why" - Part 4: TimeOnPage)
-- Compares AVG time on product pages for sessions that
-- converted (added to cart) vs. those that did not.
*/

-- STEP 1: Create a temporary table to tag each session
-- with its "conversion status" (did they ever reach the cart?)
WITH SessionStatus AS (
    SELECT
        SessionID,
        MAX(CASE WHEN PageType = 'cart' THEN 1 ELSE 0 END) AS eventually_added_to_cart
    FROM
        event_log
    GROUP BY
        SessionID
)
-- STEP 2: Join that status back to the main log
-- to compare the time spent ONLY on product pages.
SELECT
    CASE
        WHEN ss.eventually_added_to_cart = 1 THEN 'Group 1: Added to Cart'
        ELSE 'Group 2: Did NOT Add to Cart'
    END AS user_group,
    
    COUNT(DISTINCT e.SessionID) AS total_sessions,
    AVG(e.TimeOnPage_seconds) AS avg_time_on_page
FROM
    event_log AS e
JOIN
    SessionStatus AS ss ON e.SessionID = ss.SessionID
WHERE
    e.PageType = 'product_page' -- We ONLY care about time spent on product pages
GROUP BY
    user_group;
```

\</details\>

-----

## 5\. The Investigation (Step-by-Step Analysis)

My analysis followed a process of hypothesis elimination.

### Insight 1 (The "What"): Identifying the Problem

The first step was to understand the new 5-step funnel. The data shows two major drop-offs:

1.  **Product Page -\> Cart:** A large number of users view products but never add them to the cart.
2.  **Cart -\> Checkout:** A significant number of users add items to their cart but abandon before starting the checkout process.

The drop from **Product Page to Cart** is the largest, so that will be the focus of the investigation.

### Insight 2 (Hypothesis 1: FALSE): Is it a Device Issue?

My first hypothesis was that it could be a technical issue (e.g., the "Add to Cart" button is broken on mobile).
**Conclusion: FALSE.** The device segmentation chart shows that the drop-off pattern (the salmon-colored bar) is *identical* across Mobile, Desktop, and Tablet. The problem is not technical.

### Insight 3 (Hypothesis 2: FALSE): Is it a Marketing Issue?

My second hypothesis was that the marketing team was driving "junk traffic" (e.g., from Social Media) that would browse but never buy.
**Conclusion: FALSE.** The referral source segmentation chart shows that *all* sources (Social Media, Email, Direct, Google) have the exact same drop-off pattern. The traffic is good quality; the problem is on the page.

### Insight 4 (Hypothesis 3: FALSE): Is it a Logistics Issue?

My third hypothesis was that it could be a logistics problem (e.g., high shipping costs to certain countries).
**Conclusion: FALSE.** The country segmentation chart shows the drop-off is universal. Users in the USA, UK, India, and France abandon at the same rate. It is not a shipping issue.

### Insight 5 (Hypothesis 4: FALSE): Is it a Clarity Issue?

My final hypothesis was that the product page was confusing, and users were leaving quickly because they didn't understand the offer.
**Conclusion: FALSE.** The time-on-page analysis shows that users who do NOT add to cart (Group 2) spend 95 seconds on average, almost the same as the 97 seconds spent by those who DO (Group 1).
Users *have* plenty of time to decide; the problem is not confusion.

-----

## 6\. Final Conclusion & Recommendation

I have scientifically proven that the problem is **NOT technical** (mobile), **NOT marketing** (traffic), **NOT logistics** (countries), and **NOT clarity** (time on page).

The problem is **UNIVERSAL and FUNDAMENTAL**.

The drop-off is a "tax" that the Product Page's User Experience (UX) is charging *all* users equally.

### Business Recommendation

The Product (UX/UI) team must stop looking for external culprits and focus 100% on redesigning the product page. I recommend running **A/B Tests** on the only elements that all users see:

  * **The Price** (Test a discount).
  * **The 'Add to Cart' Button** (Test a different color/text).
  * **The Offer** (Test adding a 'Free Shipping' banner).

-----

-----

\<a name="versión-en-español"\>\</a\>

# 📊 Análisis de Funnel y Segmentación de E-Commerce (SQL + Power BI)

Este es un proyecto de **Análisis de Funnel (Funnel Analysis)** que replica un escenario de negocio real.
El análisis sigue el viaje de un detective: desde encontrar un problema ("El Qué")
hasta probar y refutar sistemáticamente 4 hipótesis comunes para encontrar
la verdadera causa raíz ("El Por Qué").

Este proyecto demuestra habilidades clave de un Analista de Datos:

  * **Análisis Técnico (SQL):** Uso de `CTEs`, `CASE WHEN`, `JOINs` y `GROUP BY` para limpiar, segmentar y analizar datos a nivel de sesión.
  * **Visualización (Power BI):** Creación de un dashboard que cuenta una historia clara, usando paletas de color con intención y títulos conclusivos.
  * **Visión de Negocio:** Formulación de hipótesis, validación de las mismas con datos y entrega de una recomendación de negocio accionable.

**Herramientas Usadas:** MySQL, Power BI, SQL

-----

## 1\. El Problema de Negocio

El objetivo era analizar el flujo de usuarios para identificar la mayor caída
en el embudo de conversión. Mi trabajo no era solo encontrar *dónde* caían,
sino *por qué* lo hacían, siguiendo un proceso de hipótesis y validación.

-----

## 2\. Sobre los Datos

Este proyecto utiliza un dataset sintético de e-commerce (`customer_journey.csv`), disponible públicamente, que rastrea sesiones de usuario completas, desde el primer clic hasta la conversión final. Los datos fueron importados a una base de datos MySQL (`funnel_project`) y analizados desde una única tabla (`event_log`).

### Diccionario de Datos (Schema)

La tabla `event_log` tiene la siguiente estructura:

| Columna | Descripción | Tipo de Dato |
| :--- | :--- | :--- |
| `SessionID` | El identificador único para una sesión de usuario. | `VARCHAR` |
| `UserID` | El identificador único para un usuario. | `VARCHAR` |
| `Timestamp` | La fecha y hora del evento. | `TIMESTAMP` |
| `PageType` | La etapa del embudo (`home`, `product_page`, `cart`, `checkout`, `confirmation`). | `VARCHAR` |
| `DeviceType` | El dispositivo utilizado (ej. 'Mobile', 'Desktop', 'Tablet'). | `VARCHAR` |
| `Country` | El país de origen del usuario. | `VARCHAR` |
| `ReferralSource`| La fuente del tráfico (ej. 'Google', 'Social Media'). | `VARCHAR` |
| `TimeOnPage_seconds` | Tiempo en la página en segundos. | `INT` |
| `ItemsInCart` | Número de artículos en el carrito del usuario. | `INT` |
| `Purchased` | (Booleano) 1 si la sesión terminó en compra, 0 si no. | `INT` |

-----

## 3\. El Dashboard (Resultado Final)

Este es el dashboard completo que resume toda la investigación. A continuación, se detalla el análisis paso a paso.

-----

## 4\. El Motor (Consultas SQL)

En lugar de cargar datos crudos en Power BI, usé MySQL para pre-agregar y segmentar los datos. El análisis se realiza a nivel de **SessionID** (ID de Sesión) para rastrear con precisión los viajes individuales de los usuarios.

\<details\>
\<summary\>Haz clic para ver las 5 (Nuevas) Consultas SQL\</summary\>

**Consulta 1: Funnel General de 5 Pasos (El "Qué")**
*Esta consulta cuenta las sesiones únicas que alcanzaron cada etapa del embudo de 5 pasos.*

```sql
/*
-- General 5-Step Funnel Query (The "What")
-- Counts unique SessionIDs that reached each page.
*/

-- 1. Contar sesiones que vieron Homepage
SELECT
    '1. Homepage' AS stage,
    COUNT(DISTINCT SessionID) AS total_sessions,
    1 AS step_order
FROM event_log
WHERE PageType = 'home'

UNION

-- 2. Contar sesiones que vieron Product Page
SELECT
    '2. Product Page' AS stage,
    COUNT(DISTINCT SessionID) AS total_sessions,
    2 AS step_order
FROM event_log
WHERE PageType = 'product_page'

UNION

-- 3. Contar sesiones que vieron Cart
SELECT
    '3. Cart' AS stage,
    COUNT(DISTINCT SessionID) AS total_sessions,
    3 AS step_order
FROM event_log
WHERE PageType = 'cart'

UNION

-- 4. Contar sesiones que vieron Checkout
SELECT
    '4. Checkout' AS stage,
    COUNT(DISTINCT SessionID) AS total_sessions,
    4 AS step_order
FROM event_log
WHERE PageType = 'checkout'

UNION

-- 5. Contar sesiones que vieron Confirmation (Purchased)
SELECT
    '5. Confirmation' AS stage,
    COUNT(DISTINCT SessionID) AS total_sessions,
    5 AS step_order
FROM event_log
WHERE PageType = 'confirmation'

ORDER BY
    step_order;
```

**Consulta 2: Hipótesis 1 (Dispositivo)**
*Esta consulta segmenta el embudo de 5 pasos por dispositivo.*

```sql
/*
-- Segmentation Query 1 (The "Why" - Part 1: Device)
-- Segments the 5-step funnel by DeviceType.
*/

-- PASO 1: Crear una tabla temporal de resumen de acciones por sesión
WITH SessionActions AS (
    SELECT
        SessionID,
        DeviceType, -- La columna por la que segmentamos
        MAX(CASE WHEN PageType = 'home' THEN 1 ELSE 0 END) AS saw_homepage,
        MAX(CASE WHEN PageType = 'product_page' THEN 1 ELSE 0 END) AS saw_product_page,
        MAX(CASE WHEN PageType = 'cart' THEN 1 ELSE 0 END) AS saw_cart,
        MAX(CASE WHEN PageType = 'checkout' THEN 1 ELSE 0 END) AS saw_checkout,
        MAX(CASE WHEN PageType = 'confirmation' THEN 1 ELSE 0 END) AS saw_confirmation
    FROM
        event_log
    GROUP BY
        SessionID, DeviceType
)
-- PASO 2: Contar los resultados de esa tabla temporal
SELECT
    DeviceType,
    SUM(saw_homepage) AS homepage_sessions,
    SUM(saw_product_page) AS product_page_sessions,
    SUM(saw_cart) AS cart_sessions,
    SUM(saw_checkout) AS checkout_sessions,
    SUM(saw_confirmation) AS confirmation_sessions
FROM
    SessionActions
GROUP BY
    DeviceType;
```

**Consulta 3: Hipótesis 2 (Fuente de Tráfico)**
*Esta consulta segmenta el embudo de 5 pasos por fuente de tráfico.*

```sql
/*
-- Segmentation Query 2 (The "Why" - Part 2: Referral)
-- Segments the 5-step funnel by ReferralSource.
*/

-- PASO 1: Crear una tabla temporal de resumen de acciones por sesión
WITH SessionActions AS (
    SELECT
        SessionID,
        ReferralSource, -- <--- El único cambio está aquí
        MAX(CASE WHEN PageType = 'home' THEN 1 ELSE 0 END) AS saw_homepage,
        MAX(CASE WHEN PageType = 'product_page' THEN 1 ELSE 0 END) AS saw_product_page,
        MAX(CASE WHEN PageType = 'cart' THEN 1 ELSE 0 END) AS saw_cart,
        MAX(CASE WHEN PageType = 'checkout' THEN 1 ELSE 0 END) AS saw_checkout,
        MAX(CASE WHEN PageType = 'confirmation' THEN 1 ELSE 0 END) AS saw_confirmation
    FROM
        event_log
    GROUP BY
        SessionID, ReferralSource -- <--- Y aquí
)
-- PASO 2: Contar los resultados de esa tabla temporal
SELECT
    ReferralSource, -- <--- Y aquí
    SUM(saw_homepage) AS homepage_sessions,
    SUM(saw_product_page) AS product_page_sessions,
    SUM(saw_cart) AS cart_sessions,
    SUM(saw_checkout) AS checkout_sessions,
    SUM(saw_confirmation) AS confirmation_sessions
FROM
    SessionActions
GROUP BY
    ReferralSource; -- <--- Y aquí
```

**Consulta 4: Hipótesis 3 (País)**
*Esta consulta segmenta el embudo de 5 pasos por país.*

```sql
/*
-- Segmentation Query 3 (The "Why" - Part 3: Country)
-- Segments the 5-step funnel by Country.
*/

-- PASO 1: Crear una tabla temporal de resumen de acciones por sesión
WITH SessionActions AS (
    SELECT
        SessionID,
        Country, -- <--- El único cambio está aquí
        MAX(CASE WHEN PageType = 'home' THEN 1 ELSE 0 END) AS saw_homepage,
        MAX(CASE WHEN PageType = 'product_page' THEN 1 ELSE 0 END) AS saw_product_page,
        MAX(CASE WHEN PageType = 'cart' THEN 1 ELSE 0 END) AS saw_cart,
        MAX(CASE WHEN PageType = 'checkout' THEN 1 ELSE 0 END) AS saw_checkout,
        MAX(CASE WHEN PageType = 'confirmation' THEN 1 ELSE 0 END) AS saw_confirmation
    FROM
        event_log
    GROUP BY
        SessionID, Country -- <--- Y aquí
)
-- PASO 2: Contar los resultados de esa tabla temporal
SELECT
    Country, -- <--- Y aquí
    SUM(saw_homepage) AS homepage_sessions,
    SUM(saw_product_page) AS product_page_sessions,
    SUM(saw_cart) AS cart_sessions,
    SUM(saw_checkout) AS checkout_sessions,
    SUM(saw_confirmation) AS confirmation_sessions
FROM
    SessionActions
GROUP BY
    Country; -- <--- Y aquí
```

**Consulta 5: Hipótesis 4 (Tiempo en Página)**
*Esta consulta prueba si los usuarios que añaden al carrito pasan más tiempo en las páginas de producto que los que no.*

```sql
/*
-- Segmentation Query 4 (The "Why" - Part 4: TimeOnPage)
-- Compara el tiempo AVG en páginas de producto para sesiones que
-- convirtieron (añadieron al carrito) vs. las que no.
*/

-- PASO 1: Crear una tabla temporal para etiquetar cada sesión
-- con su "estado de conversión" (¿llegó al carrito?)
WITH SessionStatus AS (
    SELECT
        SessionID,
        MAX(CASE WHEN PageType = 'cart' THEN 1 ELSE 0 END) AS eventually_added_to_cart
    FROM
        event_log
    GROUP BY
        SessionID
)
-- PASO 2: Unir ese estado a la tabla principal
-- para comparar el tiempo gastado SOLAMENTE en páginas de producto.
SELECT
    CASE
        WHEN ss.eventually_added_to_cart = 1 THEN 'Group 1: Added to Cart'
        ELSE 'Group 2: Did NOT Add to Cart'
    END AS user_group,
    
    COUNT(DISTINCT e.SessionID) AS total_sessions,
    AVG(e.TimeOnPage_seconds) AS avg_time_on_page
FROM
    event_log AS e
JOIN
    SessionStatus AS ss ON e.SessionID = ss.SessionID
WHERE
    e.PageType = 'product_page' -- SOLO nos importa el tiempo en páginas de producto
GROUP BY
    user_group;
```

\</details\>

-----

## 5\. La Investigación (Análisis Paso a Paso)

Mi análisis siguió un proceso de eliminación de hipótesis.

### Insight 1 (El "Qué"): Identificando el Problema

El primer paso fue entender el nuevo embudo de 5 pasos. Los datos muestran dos caídas (drop-offs) principales:

1.  **Product Page -\> Cart:** Un gran número de usuarios ve productos pero nunca los añade al carrito.
2.  **Cart -\> Checkout:** Un número significativo de usuarios añade artículos al carrito pero lo abandona antes de iniciar el pago.

La caída de **Product Page a Cart** es la más grande, así que será el foco de la investigación.

### Insight 2 (Hipótesis 1: FALSO): ¿Es un problema de Dispositivo?

Mi primera hipótesis fue que podría ser un problema técnico (ej. el botón "Añadir al Carrito" está roto en móviles).
**Conclusión: FALSO.** El gráfico de segmentación por dispositivo muestra que el porcentaje de caída (la barra color salmón) es *idéntico* en Mobile, Desktop y Tablet. El problema no es técnico.

### Insight 3 (Hipótesis 2: FALSO): ¿Es un problema de Marketing?

Mi segunda hipótesis fue que el equipo de marketing estaba atrayendo "tráfico basura" (ej. de Social Media) que solo miraba pero nunca compraba.
**ConVclusión: FALSO.** El gráfico de segmentación por fuente de tráfico muestra que *todas* las fuentes (Social Media, Email, Directo, Google) tienen exactamente el mismo patrón de caída. El tráfico es de buena calidad; el problema está en la página.

### Insight 4 (Hipótesis 3: FALSO): ¿Es un problema de Logística?

Mi tercera hipótesis fue que podría ser un problema de logística (ej. costos de envío muy altos para ciertos países).
**Conclusión: FALSO.** El gráfico de segmentación por país muestra que la caída es universal. Usuarios en USA, UK, India y Francia abandonan en la misma proporción. No es un problema de envíos.

### Insight 5 (Hipótesis 4: FALSO): ¿Es un problema de Claridad?

Mi hipótesis final fue que la página de producto era confusa, y los usuarios abandonaban rápido porque no entendían la oferta.
**Conclusión: FALSO.** El análisis de tiempo en página muestra que los usuarios que NO añaden al carrito (Grupo 2) pasan 95 segundos en promedio, casi lo mismo que los 97 segundos de los que SÍ añaden (Grupo 1).
Los usuarios *tienen* tiempo de sobra para decidir; el problema no es de confusión.

-----

## 6\. Conclusión Final y Recomendación

He probado científicamente que el problema **NO es técnico** (móvil), **NO es de marketing** (tráfico), **NO es de logística** (países) y **NO es de claridad** (tiempo en página).

El problema es **UNIVERSAL Y FUNDAMENTAL**.

La caída es un "impuesto" que la Experiencia de Usuario (UX) de la página de producto está cobrando a *todos* los usuarios por igual.

### Recomendación de Negocio

El equipo de Producto (UX/UI) debe centrarse 100% en rediseñar la página de producto. Recomiendo hacer **Pruebas A/B (A/B Testing)** en los únicos elementos que ven todos los usuarios:

  * **El Precio** (Probar un descuento).
  * **El Botón de 'Añadir al Carrito'** (Probar un color/texto diferente).
  * **La Oferta** (Probar añadir un banner de 'Envío Gratis').

<!-- end list -->

```
```
