/* 1. OGÓLNA WYDAJNOŚĆ RYNKOWA / GENERAL MARKET PERFORMANCE
PL: Zestawienie sprzedaży z podziałem na kraje. Kluczowe metryki to całkowity wolumen, obrót netto w EUR oraz średnia cena za litr. 
    Pozwala szybko zidentyfikować najbardziej dochodowe rynki i różnice w cenach paliw między krajami.
EN: Sales breakdown by country. It tracks total volume, net turnover in EUR, and average price per liter. 
    This view helps identify the most profitable markets and regional fuel price variances.
*/

SELECT 
    c.country_name,
    SUM(t.volume) AS Total_volume,
    SUM(t.net_amount_local * t.exchange_rate_eur) AS Total_net_amount_EUR, 
    SUM(t.net_amount_local * t.exchange_rate_eur) / NULLIF(SUM(t.volume), 0) AS AVG_price_per_liter
FROM transactions AS t
LEFT JOIN countries AS c ON c.country_code = t.station_country_code
GROUP BY c.country_name
ORDER BY Total_net_amount_EUR DESC, Total_volume DESC, c.country_name;

---

/* 2. TOP 5 KLIENTÓW (SEGMENTACJA) / TOP 5 CUSTOMERS (SEGMENTATION)
PL: Ranking pięciu największych klientów pod kątem wydatków. Dodatkowo monitorujemy liczbę aktywnych kart oraz średnią wartość 
    pojedynczego tankowania, co pomaga ocenić skalę floty i potencjał zakupowy danej firmy.
EN: A ranking of the top 5 customers by total spend. It also monitors the number of active cards and 
    average transaction value to assess fleet size and purchasing power.
*/

SELECT 
    cus.company_name,
    SUM(t.net_amount_local * t.exchange_rate_eur) AS Total_spend_EUR, 
    COUNT(DISTINCT c.card_id) AS Active_cards, 
    AVG(t.net_amount_local * t.exchange_rate_eur) AS AVG_transaction_amount
FROM transactions AS t
LEFT JOIN cards AS c ON c.card_id = t.card_id
LEFT JOIN customers AS cus ON cus.customer_id = c.customer_id
GROUP BY cus.company_name
ORDER BY Total_spend_EUR DESC
LIMIT 5;

---

/* 3. STRUKTURA SPRZEDAŻY PRODUKTÓW / PRODUCT MIX ANALYSIS
PL: Analiza udziału poszczególnych produktów w całkowitej sprzedaży. Użycie funkcji okna (OVER) pozwala na błyskawiczne 
    wyliczenie procentowego udziału każdego paliwa w całym wolumenie.
EN: Product sales distribution analysis. Using window functions (OVER), it calculates the percentage share 
    of each product type in the total volume, providing essential data for strategy planning.
*/

SELECT 
    product_type, 
    ROUND(SUM(volume), 2) AS Total_volume, 
    ROUND((SUM(volume) / SUM(SUM(volume)) OVER() * 100), 2) AS Product_volume_prc
FROM transactions
GROUP BY product_type
ORDER BY Total_volume DESC;

---

/* 4. WYKRYWANIE ANOMALII I NADUŻYĆ / ANOMALY & FRAUD DETECTION
PL: Zaawansowany raport identyfikujący podejrzane transakcje na podstawie indywidualnego zachowania każdej karty. 
    System flaguje tankowania drastycznie odbiegające od średniej, co pozwala wyłapać potencjalne kradzieże.
EN: Advanced report identifying suspicious transactions based on individual card behavior. 
    By flagging outliers, the system detects potential fraud, card cloning, or unauthorized vehicle fueling.
*/

WITH AvgCardVolume AS (
    SELECT 
        t.transaction_id,
        t.card_id,
        t.volume, 
        AVG(volume) OVER(PARTITION BY t.card_id) AS AVGCardVolume
    FROM transactions AS t
),
TrxStatus AS (
    SELECT *, 
        CASE 
            WHEN volume > AVGCardVolume * 2.5 THEN 'Critical_High_Volume'
            WHEN volume < AVGCardVolume * 0.3 THEN 'Suspicious: Low Volume'
            WHEN volume > AVGCardVolume * 1.5 THEN 'Warning: Above average'
            ELSE 'Normal'
        END AS anomaly_status
    FROM AvgCardVolume
    WHERE AVGCardVolume > 0
) 
SELECT * FROM TrxStatus
WHERE anomaly_status != 'Normal'
ORDER BY anomaly_status, volume;
