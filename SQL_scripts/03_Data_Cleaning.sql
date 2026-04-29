/* 1. WERYFIKACJA WARTOŚCI BRAKUJĄCYCH / MISSING VALUES CHECK (NULLS)
PL: Sprawdzenie kompletności danych we wszystkich kluczowych tabelach. Identyfikacja rekordów z brakującymi polami, które mogłyby zaburzyć wyniki analizy.
EN: Checking data completeness across all key tables. Identifying records with missing fields that could skew analysis results.
*/

-- Sprawdzanie NULL w tabelach słownikowych i transakcyjnych
SELECT * FROM cards WHERE card_id IS NULL OR customer_id IS NULL OR card_number IS NULL OR expiry_date IS NULL OR is_active IS NULL;
SELECT * FROM countries WHERE country_code IS NULL OR country_name IS NULL OR currency IS NULL OR region IS NULL;
SELECT * FROM customers WHERE customer_id IS NULL OR company_name IS NULL OR home_country_code IS NULL OR vat_number IS NULL;
SELECT * FROM transactions WHERE transaction_id IS NULL OR card_id IS NULL OR station_country_code IS NULL OR product_type IS NULL OR volume IS NULL OR net_amount_local IS NULL;

---

/* 2. STANDARYZACJA DANYCH / DATA STANDARDIZATION
PL: Naprawa brakujących typów produktów oraz ujednolicenie formatowania tekstu (usunięcie zbędnych spacji, zamiana na wielkie litery). 
    Zapewnia to poprawne grupowanie produktów w raportach.
EN: Fixing missing product types and unifying text formatting (trimming whitespace, converting to uppercase). 
    This ensures correct product grouping in reports.
*/

UPDATE transactions SET product_type = 'UNKNOWN' WHERE product_type IS NULL;
UPDATE transactions SET product_type = UPPER(TRIM(product_type));

-- Weryfikacja unikalnych typów produktów po czyszczeniu
SELECT product_type, COUNT(*) FROM transactions GROUP BY product_type;

---

/* 3. INTEGRALNOŚĆ REFERENCYJNA / REFERENTIAL INTEGRITY CHECK
PL: Weryfikacja spójności między tabelami. Szukamy "osieroconych" transakcji (bez przypisanego kraju lub karty) 
    oraz usuwamy rekordy nieposiadające odniesienia w słownikach.
EN: Verifying consistency between tables. Searching for "orphan" transactions (without assigned country or card) 
    and removing records that lack references in master data.
*/

-- Usuwanie transakcji z nieistniejącymi kodami krajów
DELETE FROM transactions WHERE station_country_code NOT IN (SELECT country_code FROM countries);

---

/* 4. AUDYT JAKOŚCI DANYCH I WALIDACJA MATEMATYCZNA / DATA QUALITY AUDIT & MATH VALIDATION
PL: Tworzenie widoku audytowego, który kategoryzuje transakcje pod kątem błędów matematycznych, błędnych znaków (ujemny wolumen) 
    oraz identyfikuje noty kredytowe (zwroty).
EN: Creating an audit view that categorizes transactions based on mathematical errors, incorrect signs (negative volume), 
    and identifies credit notes (returns).
*/

CREATE OR REPLACE VIEW v_transaction_audited AS
SELECT *,
CASE 
    WHEN volume < 0 AND net_amount_local >= 0 THEN 'Error: Negative Volume'
    WHEN volume >= 0 AND net_amount_local < 0 THEN 'Error: Negative Net Amount'
    WHEN ABS((net_amount_local + vat_amount_local) - gross_amount_local) > 0.10 THEN 'Error: Math Mismatch'
    WHEN volume < 0 AND net_amount_local < 0 THEN 'Credit Note'
    ELSE 'OK' 
END AS quality_status
FROM transactions;

-- Podsumowanie statusu jakości danych
SELECT quality_status, COUNT(*) as quantity, SUM(gross_amount_local) as total_gross
FROM v_transaction_audited
GROUP BY quality_status
ORDER BY quantity DESC;

---

/* 5. ELIMINACJA DUPLIKATÓW / DE-DUPLICATION
PL: Identyfikacja i usuwanie powtarzających się rekordów (identyczna karta, data, wolumen i kwota). 
    Użycie funkcji ROW_NUMBER() pozwala na precyzyjne usunięcie nadmiarowych kopii przy zachowaniu oryginału.
EN: Identifying and removing duplicate records (same card, date, volume, and amount). 
    Using ROW_NUMBER() allows for precise removal of redundant copies while preserving the original record.
*/

DELETE FROM transactions
WHERE transaction_id IN (
    SELECT transaction_id FROM (
        SELECT transaction_id, 
        ROW_NUMBER() OVER (PARTITION BY card_id, transaction_date, volume, net_amount_local ORDER BY transaction_id) AS rn
        FROM transactions
    ) AS subquery
    WHERE rn > 1
);
