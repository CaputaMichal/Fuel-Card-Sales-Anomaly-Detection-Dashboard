import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt

# ===========================================================================
# 1. LOADING DATA / WCZYTYWANIE DANYCH
# ===========================================================================
# PL: Pobieranie danych z plików CSV.
# EN: Loading data from CSV files.

countries=pd.read_csv(r'C:\Users\Michal\Documents\SQL\countries.csv')
cards=pd.read_csv(r'C:\Users\Michal\Documents\SQL\cards.csv')
customers=pd.read_csv(r'C:\Users\Michal\Documents\SQL\customers.csv')
transactions=pd.read_csv(r'C:\Users\Michal\Documents\SQL\transactions.csv')


# ===========================================================================
# 2. DATA MERGING / ŁĄCZENIE DANYCH
# ===========================================================================
# PL: Łączenie tabel w jeden główny DataFrame.
# EN: Merging files into one main DataFrame.

df = pd.merge(transactions, cards, on='card_id', how='left')
df = pd.merge(df, customers, on='customer_id', how='left')
df = pd.merge(df, countries, left_on='station_country_code', right_on='country_code',how='left')
df = df.drop(columns=['country_code'])
df.info()


# ===========================================================================
# 3. DATE CONVERSION / KONWERSJA DAT
# ===========================================================================
# PL: Formatowanie kolumn z datami.
# EN: Converting columns to date format.

df['transaction_date'] = pd.to_datetime(df['transaction_date']).dt.date
df['expiry_date'] = pd.to_datetime(df['expiry_date'])
print(df.dtypes)


# ===========================================================================
# 4. PIE CHART / WYKRES KOŁOWY
# ===========================================================================
# PL: Udział produktów w całkowitym wolumenie.
# EN: Product share in total volume.

product_data=df.groupby('product_type')['volume'].sum()

plt.figure(figsize=(8, 8))
plt.pie(product_data, labels=product_data.index, autopct='%1.1f%%', startangle=140, colors=["#880b0bc0",'#66b3ff',"#248d24","#c47d36"])
plt.title('Product Share in Total Volume (L)')
plt.show()


# ===========================================================================
# 5. REVENUE BAR CHART / WYKRES SŁUPKOWY PRZYCHODU
# ===========================================================================
# PL: Przychód netto według kraju.
# EN: Net revenue by country.

df['revenue_eur'] = pd.to_numeric(df['net_amount_local']) * pd.to_numeric(df['exchange_rate_eur'])
revenue_per_country = df.groupby('station_country_code')['revenue_eur'].sum().sort_values(ascending=False).reset_index()

plt.figure(figsize=(12, 6))
sns.barplot(x='station_country_code', y='revenue_eur', data=revenue_per_country, palette='viridis')
plt.title('Total Net Revenue by Country (EUR)')
plt.ylabel('Revenue (EUR)')
plt.xlabel('Country Code')
plt.xticks(rotation=45)
plt.show()


# ===========================================================================
# 6. VOLUME BAR CHART / WYKRES SŁUPKOWY WOLUMENU
# ===========================================================================
# PL: Wolumen sprzedaży według kraju.
# EN: Sales volume by country.

volume_per_country = df.groupby('station_country_code')['volume'].sum().sort_values(ascending=False).reset_index()

plt.figure(figsize=(12, 6))
sns.barplot(x='station_country_code', y='volume', data=volume_per_country, palette='magma')
plt.title('Total Sales Volume by Country (L)')
plt.ylabel('Volume (L)')
plt.xlabel('Country Code')
plt.xticks(rotation=45)
plt.show()