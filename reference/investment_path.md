# Follow an investment in NVIDIA shares over a chosen period

Keeps the trading days between `start` and `end`, then calculates what
an amount invested at the first closing price in that period would be
worth on each day, and how far it had fallen from its highest value so
far.

## Usage

``` r
investment_path(prices, start, end, amount = 1000)
```

## Arguments

- prices:

  A data frame of daily prices with `date` and `close` columns, such as
  [nvda](https://etc5523-2026.github.io/etc5523-assignment-4-dhoa0015-svg/reference/nvda.md).

- start, end:

  First and last dates of the period, as `Date` objects or
  `"YYYY-MM-DD"` strings.

- amount:

  Amount invested at the first closing price, in US dollars.

## Value

The rows of `prices` within the period, with three added columns:
`value` (worth of the investment that day), `gain_pct` (percentage gain
or loss since the start) and `drawdown_pct` (percentage fall from the
highest closing price so far in the period; 0 at a new high). Returns
zero rows when the period contains no trading days.

## Examples

``` r
# $1,000 invested at the start of 2020
path <- investment_path(nvda, "2020-01-01", "2026-09-21", amount = 1000)
tail(path, 1)
#>            date   open  high    low  close    volume daily_return_pct   sma_20
#> 1688 2026-09-21 222.94 228.5 221.56 227.38 109806100         2.299006 219.3635
#>        sma_50 volatility_20_pct    value gain_pct drawdown_pct
#> 1688 214.4001          46.18114 38169.34 3716.934    -3.325811

# The largest fall from a peak during 2022
min(investment_path(nvda, "2022-01-01", "2022-12-31")$drawdown_pct)
#> [1] -62.70168
```
