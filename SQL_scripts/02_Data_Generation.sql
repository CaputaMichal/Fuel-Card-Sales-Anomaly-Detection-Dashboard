/* 1. PRZYGOTOWANIE TABELI / TABLE PREPARATION
PL: Czyszczenie tabeli transakcji przed załadowaniem nowych danych testowych. Zapewnia to powtarzalność skryptu.
EN: Truncating the transactions table before loading new test data. This ensures script reusability.
*/

TRUNCATE TABLE transactions;

---

/* 2. AUTOMATYCZNE GENEROWANIE DANYCH (SEEDING) / AUTOMATED DATA SEEDING
PL: Zaawansowany generator 10 000 rekordów testowych. Skrypt wykorzystuje funkcje generowania serii oraz losowości, 
    aby symulować realne transakcje kartowe w różnych krajach i walutach.
EN: Advanced generator creating 10,000 test records. The script utilizes series generation and randomization 
    to simulate real-world card transactions across various countries and currencies.
*/

INSERT INTO transactions (
    card_id, transaction_date, station_country_code, product_type, 
    volume, net_amount_local, vat_amount_local, gross_amount_local, exchange_rate_eur
)
WITH raw_data AS (
    SELECT 
        s.id as row_id,
        (SELECT card_id FROM cards OFFSET (s.id % (SELECT count(*) FROM cards)) LIMIT 1) as c_id,
        (SELECT country_code FROM countries OFFSET (s.id % (SELECT count(*) FROM countries)) LIMIT 1) as c_code,
        (SELECT currency FROM countries OFFSET (s.id % (SELECT count(*) FROM countries)) LIMIT 1) as c_curr
    FROM generate_series(1, 10000) AS s(id)
)
SELECT 
    c_id,
    NOW() - (random() * INTERVAL '90 days'), -- Losowe daty z ostatnich 90 dni
    
    /* Symulacja błędnych danych (kod 'XX') dla 5% transakcji w celu przetestowania procesów czyszczenia */
    CASE WHEN row_id % 20 = 0 THEN 'XX' ELSE c_code END,
    
    /* Losowy wybór paliwa z celowo wprowadzonymi błędami wielkości liter do standaryzacji */
    (ARRAY['Diesel', 'LPG', 'AdBlue', 'PETROL', 'dIeSeL'])[floor(random() * 5) + 1],
    
    round((random() * 400 + 20)::numeric, 3), -- Losowy wolumen tankowania
    0, 0, 0, -- Kwoty inicjowane jako 0 przed przeliczeniem
    
    /* Realistyczna symulacja kursów wymiany walut względem EUR */
    CASE 
        WHEN c_curr = 'EUR' THEN 1.000000
        WHEN c_curr = 'PLN' THEN round((random() * (0.24 - 0.22) + 0.22)::numeric, 6)
        WHEN c_curr = 'CHF' THEN round((random() * (1.10 - 1.04) + 1.04)::numeric, 6)
        WHEN c_curr = 'GBP' THEN round((random() * (1.20 - 1.15) + 1.15)::numeric, 6)
        WHEN c_curr = 'CZK' THEN round((random() * (0.042 - 0.038) + 0.038)::numeric, 6)
        WHEN c_curr = 'HUF' THEN round((random() * (0.0027 - 0.0024) + 0.0024)::numeric, 6)
        ELSE 0.500000 
    END
FROM raw_data;

---

/* 3. KALKULACJA FINANSOWA / FINANCIAL CALCULATION
PL: Masowa aktualizacja wartości finansowych. Skrypt dynamicznie wylicza kwotę netto (na podstawie wolumenu), 
    podatek VAT (23%) oraz kwotę brutto, symulując kompletny proces księgowania transakcji.
EN: Bulk update of financial values. The script dynamically calculates net amount (based on volume), 
    VAT tax (23%), and gross amount, simulating a complete transaction accounting process.
*/

UPDATE transactions 
SET 
    net_amount_local = round((volume * (random() * 2 + 4))::numeric, 2),
    vat_amount_local = round(net_amount_local * 0.23, 2),
    gross_amount_local = round(net_amount_local * 1.23, 2);
