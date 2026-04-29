/* 1. USUWANIE ISTNIEJĄCYCH TABEL / CLEANUP
PL: Resetowanie struktury bazy danych. Usunięcie tabel w odpowiedniej kolejności (z uwzględnieniem kluczy obcych), 
    aby zapewnić czystą instalację projektu.
EN: Resetting the database structure. Dropping tables in the correct order (considering foreign keys) 
    to ensure a clean project installation.
*/

DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS cards;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS countries;

---

/* 2. DEFINICJA STRUKTURY (DDL) / SCHEMA DEFINITION
PL: Tworzenie szkieletu bazy danych kart paliwowych. Architektura obejmuje relacje między krajami, 
    klientami, kartami oraz samymi transakcjami.
EN: Creating the fuel card database skeleton. The architecture includes relationships between countries, 
    customers, cards, and the transactions themselves.
*/

-- Słownik krajów i walut / Countries and currencies dictionary
CREATE TABLE countries (
    country_code CHAR(2) PRIMARY KEY,
    country_name VARCHAR(50) NOT NULL,
    currency CHAR(3) NOT NULL,
    region VARCHAR(50)
);

-- Dane firm (Klientów) / Customer data
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    company_name VARCHAR(100) NOT NULL,
    home_country_code CHAR(2) REFERENCES countries(country_code),
    vat_number VARCHAR(20) UNIQUE
);

-- Zarządzanie kartami / Fuel card management
CREATE TABLE cards (
    card_id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(customer_id),
    card_number VARCHAR(30) UNIQUE,
    expiry_date DATE,
    is_active BOOLEAN DEFAULT TRUE
);

---

/* 3. REJESTR TRANSAKCJI / TRANSACTION LOG
PL: Główna tabela przechowująca dane o tankowaniach. 
    Uwaga: Pola 'station_country_code' oraz 'product_type' celowo nie posiadają restrykcyjnych więzów (REFERENCES/NOT NULL), 
    aby umożliwić symulację błędów systemowych i przeprowadzenie procesu Data Cleaning w dalszej części projektu.
EN: The main table storing fueling data. 
    Note: 'station_country_code' and 'product_type' fields intentionally lack restrictive constraints (REFERENCES/NOT NULL) 
    to allow for system error simulation and subsequent Data Cleaning processes.
*/

CREATE TABLE transactions (
    transaction_id SERIAL PRIMARY KEY,
    card_id INTEGER REFERENCES cards(card_id) NOT NULL,
    transaction_date TIMESTAMP NOT NULL,
    station_country_code CHAR(2), 
    product_type VARCHAR(30),
    volume DECIMAL(10,3) NOT NULL,
    net_amount_local DECIMAL(10,2) NOT NULL,
    vat_amount_local DECIMAL(10,2) NOT NULL,
    gross_amount_local DECIMAL(10,2) NOT NULL,
    exchange_rate_eur DECIMAL(10,6) NOT NULL
);
