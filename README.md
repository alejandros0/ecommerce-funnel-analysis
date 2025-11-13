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
This dashboard summarizes the entire investigation. The 5 charts tell the story from identifying the problem to the final root cause.

![Full Investigation Dashboard](./images/dashboard_full.png)

---

## 4. The Engine (SQL Queries)
Instead of loading raw data into Power BI, I used MySQL to pre-aggregate and segment the data. The analysis is performed at the **SessionID** level to accurately track individual user journeys.

<details>
<summary>Click to see all 5 SQL Queries</summary>

**Query 1: General 5-Step Funnel (The "What")**
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

```sql
/*
-- Segmentation Query 1 (The "Why" - Part 1: Device)
*/
WITH SessionActions AS (
    SELECT
        SessionID,
        DeviceType, 
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

```sql
/*
-- Segmentation Query 2 (The "Why" - Part 2: Referral)
*/
WITH SessionActions AS (
    SELECT
        SessionID,
        ReferralSource, 
        MAX(CASE WHEN PageType = 'home' THEN 1 ELSE 0 END) AS saw_homepage,
        MAX(CASE WHEN PageType = 'product_page' THEN 1 ELSE 0 END) AS saw_product_page,
        MAX(CASE WHEN PageType = 'cart' THEN 1 ELSE 0 END) AS saw_cart,
        MAX(CASE WHEN PageType = 'checkout' THEN 1 ELSE 0 END) AS saw_checkout,
        MAX(CASE WHEN PageType = 'confirmation' THEN 1 ELSE 0 END) AS saw_confirmation
    FROM
        event_log
    GROUP BY
        SessionID, ReferralSource
)
SELECT
    ReferralSource, 
    SUM(saw_homepage) AS homepage_sessions,
    SUM(saw_product_page) AS product_page_sessions,
    SUM(saw_cart) AS cart_sessions,
    SUM(saw_checkout) AS checkout_sessions,
    SUM(saw_confirmation) AS confirmation_sessions
FROM
    SessionActions
GROUP BY
    ReferralSource;
```

**Query 4: Hypothesis 3 (Country)**

```sql
/*
-- Segmentation Query 3 (The "Why" - Part 3: Country)
*/
WITH SessionActions AS (
    SELECT
        SessionID,
        Country, 
        MAX(CASE WHEN PageType = 'home' THEN 1 ELSE 0 END) AS saw_homepage,
        MAX(CASE WHEN PageType = 'product_page' THEN 1 ELSE 0 END) AS saw_product_page,
        MAX(CASE WHEN PageType = 'cart' THEN 1 ELSE 0 END) AS saw_cart,
        MAX(CASE WHEN PageType = 'checkout' THEN 1 ELSE 0 END) AS saw_checkout,
        MAX(CASE WHEN PageType = 'confirmation' THEN 1 ELSE 0 END) AS saw_confirmation
    FROM
        event_log
    GROUP BY
        SessionID, Country
)
SELECT
    Country, 
    SUM(saw_homepage) AS homepage_sessions,
    SUM(saw_product_page) AS product_page_sessions,
    SUM(saw_cart) AS cart_sessions,
    SUM(saw_checkout) AS checkout_sessions,
    SUM(saw_confirmation) AS confirmation_sessions
FROM
    SessionActions
GROUP BY
    Country;
```

**Query 5: Hypothesis 4 (Time on Page)**

```sql
/*
-- Segmentation Query 4 (The "Why" - Part 4: TimeOnPage)
*/
WITH SessionStatus AS (
    SELECT
        SessionID,
        MAX(CASE WHEN PageType = 'cart' THEN 1 ELSE 0 END) AS eventually_added_to_cart
    FROM
        event_log
    GROUP BY
        SessionID
)
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
    e.PageType = 'product_page' 
GROUP BY
    user_group;
```

\</details\>

-----

## 5\. Insights & Final Recommendation

My analysis followed a process of hypothesis elimination, all of which are visible on the dashboard:

  * **Insight 1 (The "What"):** The funnel chart (`chart_1_funnel.png`) shows two major drop-offs: one at **Product Page -\> Cart** (the largest) and another at **Cart -\> Checkout**. The investigation focused on the first drop.

  * **Insight 2 (Hypothesis 1: FALSE):** The `Device` chart (`chart_2_device.png`) proves the problem is not technical. The drop-off pattern is identical across Mobile, Desktop, and Tablet.

  * **Insight 3 (Hypothesis 2: FALSE):** The `Referral Source` chart (`chart_3_referral.png`) proves the problem is not marketing "junk traffic". All sources (Google, Social, etc.) convert at the same poor rate.

  * **Insight 4 (Hypothesis 3: FALSE):** The `Country` chart (`chart_4_country.png`) proves the problem is not logistics (e.g., shipping costs). The drop-off is universal across all countries.

  * **Insight 5 (Hypothesis 4: FALSE):** The `Time on Page` chart (`chart_5_time.png`) proves the problem is not user confusion. Users who *don't* convert (95s) spend almost the same amount of time on the page as those who *do* (97s).

### Final Conclusion

I have scientifically proven that the problem is **NOT technical**, **NOT marketing**, **NOT logistics**, and **NOT clarity**. The problem is **UNIVERSAL and FUNDAMENTAL**.

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

Este dashboard resume toda la investigación. Los 5 gráficos cuentan la historia desde la identificación del problema hasta la causa raíz final.

-----

## 4\. El Motor (Consultas SQL)

En lugar de cargar datos crudos en Power BI, usé MySQL para pre-agregar y segmentar los datos. El análisis se realiza a nivel de **SessionID** (ID de Sesión) para rastrear con precisión los viajes individuales de los usuarios.

\<details\>
\<summary\>Haz clic para ver las 5 (Nuevas) Consultas SQL\</summary\>

**Consulta 1: Funnel General de 5 Pasos (El "Qué")**

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

```sql
/*
-- Segmentation Query 1 (The "Why" - Part 1: Device)
*/
WITH SessionActions AS (
    SELECT
        SessionID,
        DeviceType, 
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

```sql
/*
-- Segmentation Query 2 (The "Why" - Part 2: Referral)
*/
WITH SessionActions AS (
    SELECT
        SessionID,
        ReferralSource, 
        MAX(CASE WHEN PageType = 'home' THEN 1 ELSE 0 END) AS saw_homepage,
        MAX(CASE WHEN PageType = 'product_page' THEN 1 ELSE 0 END) AS saw_product_page,
        MAX(CASE WHEN PageType = 'cart' THEN 1 ELSE 0 END) AS saw_cart,
        MAX(CASE WHEN PageType = 'checkout' THEN 1 ELSE 0 END) AS saw_checkout,
        MAX(CASE WHEN PageType = 'confirmation' THEN 1 ELSE 0 END) AS saw_confirmation
    FROM
        event_log
    GROUP BY
        SessionID, ReferralSource
)
SELECT
    ReferralSource, 
    SUM(saw_homepage) AS homepage_sessions,
    SUM(saw_product_page) AS product_page_sessions,
    SUM(saw_cart) AS cart_sessions,
    SUM(saw_checkout) AS checkout_sessions,
    SUM(saw_confirmation) AS confirmation_sessions
FROM
    SessionActions
GROUP BY
    ReferralSource;
```

**Consulta 4: Hipótesis 3 (País)**

```sql
/*
-- Segmentation Query 3 (The "Why" - Part 3: Country)
*/
WITH SessionActions AS (
    SELECT
        SessionID,
        Country, 
        MAX(CASE WHEN PageType = 'home' THEN 1 ELSE 0 END) AS saw_homepage,
        MAX(CASE WHEN PageType = 'product_page' THEN 1 ELSE 0 END) AS saw_product_page,
        MAX(CASE WHEN PageType = 'cart' THEN 1 ELSE 0 END) AS saw_cart,
        MAX(CASE WHEN PageType = 'checkout' THEN 1 ELSE 0 END) AS saw_checkout,
        MAX(CASE WHEN PageType = 'confirmation' THEN 1 ELSE 0 END) AS saw_confirmation
    FROM
        event_log
    GROUP BY
        SessionID, Country
)
SELECT
    Country, 
    SUM(saw_homepage) AS homepage_sessions,
    SUM(saw_product_page) AS product_page_sessions,
    SUM(saw_cart) AS cart_sessions,
    SUM(saw_checkout) AS checkout_sessions,
    SUM(saw_confirmation) AS confirmation_sessions
FROM
    SessionActions
GROUP BY
    Country;
```

**Consulta 5: Hipótesis 4 (Tiempo en Página)**

```sql
/*
-- Segmentation Query 4 (The "Why" - Part 4: TimeOnPage)
*/
WITH SessionStatus AS (
    SELECT
        SessionID,
        MAX(CASE WHEN PageType = 'cart' THEN 1 ELSE 0 END) AS eventually_added_to_cart
    FROM
        event_log
    GROUP BY
        SessionID
)
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
    e.PageType = 'product_page' 
GROUP BY
    user_group;
```

\</details\>

-----

## 5\. Conclusiones y Recomendación Final

Mi análisis siguió un proceso de eliminación de hipótesis, todas visibles en el dashboard:

  * **Insight 1 (El "Qué"):** El gráfico de embudo (`chart_1_funnel.png`) muestra dos caídas principales: una en **Product Page -\> Cart** (la más grande) y otra en **Cart -\> Checkout**. La investigación se centró en la primera caída.

  * **Insight 2 (Hipótesis 1: FALSO):** El gráfico de `Dispositivo` (`chart_2_device.png`) prueba que el problema no es técnico. El patrón de caída es idéntico en Mobile, Desktop y Tablet.

  * **Insight 3 (Hipótesis 2: FALSO):** El gráfico de `Fuente de Tráfico` (`chart_3_referral.png`) prueba que el problema no es "tráfico basura" de marketing. Todas las fuentes (Google, Social, etc.) convierten igual de mal.

  * **Insight 4 (Hipótesis 3: FALSO):** El gráfico de `País` (`chart_4_country.png`) prueba que el problema no es de logística (ej. costos de envío). La caída es universal en todos los países.

  * **Insight 5 (Hipótesis 4: FALSO):** El gráfico de `Tiempo en Página` (`chart_5_time.png`) prueba que el problema no es de confusión. Los usuarios que *no* convierten (95s) pasan casi el mismo tiempo en la página que los que *sí* convierten (97s).

### Conclusión Final

He probado científicamente que el problema **NO es técnico**, **NO es de marketing**, **NO es de logística** y **NO es de claridad**. El problema es **UNIVERSAL Y FUNDAMENTAL**.

La caída es un "impuesto" que la Experiencia de Usuario (UX) de la página de producto está cobrando a *todos* los usuarios por igual.

### Recomendación de Negocio

El equipo de Producto (UX/UI) debe centrarse 100% en rediseñar la página de producto. Recomiendo hacer **Pruebas A/B (A/B Testing)** en los únicos elementos que ven todos los usuarios:

  * **El Precio** (Probar un descuento).
  * **El Botón de 'Añadir al Carrito'** (Probar un color/texto diferente).
  * **La Oferta** (Probar añadir un banner de 'Envío Gratis').

<!-- end list -->

```

Por cierto, para desbloquear la funcionalidad completa de todas las aplicaciones, habilita la [actividad en las aplicaciones de Gemini](https://myactivity.google.com/product/gemini).
```
