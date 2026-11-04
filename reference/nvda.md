# Daily NVIDIA stock prices

Daily prices and trading volume for NVIDIA Corporation stocks on Nasdaq,
with moving averages and volatility calculated from them.

## Usage

``` r
nvda
```

## Format

A data frame with 6,958 rows and 10 columns. Each row is one trading
day:

- date:

  Trading date

- open, high, low, close:

  Opening, highest, lowest and closing price in US dollars, adjusted for
  share splits

- volume:

  Number of shares traded, adjusted for share splits

- daily_return_pct:

  Percentage change in the closing price from the previous trading day;
  `NA` on the first day

- sma_20, sma_50:

  Average closing price over the last 20 and 50 trading days; `NA` until
  enough days are available

- volatility_20_pct:

  Annualised volatility (%): the standard deviation of the last 20 daily
  log returns multiplied by \\\sqrt{252}\\; `NA` for the first 20 days

## Source

Kaggle dataset "Nvidia Historical Stock Data" by Muhammad Ibrahim
Shahrukh,
<https://www.kaggle.com/datasets/muhammadishahrukh/nvidia-historical-stock-data?resource=download>,
licence CC BY-SA 4.0. Prices originally from Yahoo Finance.

## Details

Past prices are divided down to account for NVIDIA's share splits, so a
1999 price of \$0.04 equals about \$18 paid at the time. There are no
rows for weekends or US market holidays. The data run from 22 January
1999 to 21 September 2026.
