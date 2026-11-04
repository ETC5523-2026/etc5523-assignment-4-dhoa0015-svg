# Exploring NVIDIA's risk and return

``` r

library(nvdastocks)
```

## Who this is for

This guide is for anyone thinking about investing in NVIDIA who wants to
know what that investment would have looked like in the past. The app
answers the question: “If I had invested on a date I choose, how much
would it be worth now, and how far would it have fallen along the way?””

## Install and launch

``` r

remotes::install_github("ETC5523-2026/etc5523-assignment-4-dhoa0015-svg")

library(nvdastocks)
run_app()
```

The app opens in your browser, starts with a default of \$1,000
investment made on 2 January 2020 to 2026.

## Using the controls

All controls are on left sidebar:

- **Choose an investment period**: the day you invest and the day you
  check its value. Any dates from 22 January 1999 to 21 September 2026
  can be chosen.
- **Amount invested (US\$)**: how much you put in at the start.
- **Compare growth in % (log scale)**: NVIDIA’s early prices were only
  cents, so on a normal chart the early years look flat. Tick this when
  looking at long periods to see how much those years really rose and
  fell.
- **Show 20- and 50-day averages** (only shown in second tab only): adds
  lines that smooth out daily ups and downs, so the overall trend is
  easier to see.

## Reading the two tabs

### How much would I have gained?

The green line shows what your investment was worth on each day. The
dashed orange line is the amount you put in, showing anything above it
is a gain, and below it is a loss.

### When did it fall, and how far?

The top chart is NVIDIA’s share price. The red chart underneath shows
how far the price was below its highest point so far. At 0% the
investment was at a new high; the deeper the red area, the bigger the
fall.

## Using the function directly

The app is built on
[`investment_path()`](https://etc5523-2026.github.io/etc5523-assignment-4-dhoa0015-svg/reference/investment_path.md).
It returns one row per trading day with the investment’s value `value`,
the percentage gain `gain_pct` and the fall from its peak
`drawdown_pct`.

``` r

path <- investment_path(nvda, "2020-01-01", "2026-09-21", amount = 1000)

# The last three trading days
tail(path[, c("date", "close", "value", "gain_pct", "drawdown_pct")], 3)
#>            date  close    value gain_pct drawdown_pct
#> 1686 2026-09-17 219.34 36819.69 3581.969    -6.744147
#> 1687 2026-09-18 222.27 37311.54 3631.154    -5.498408
#> 1688 2026-09-21 227.38 38169.34 3716.934    -3.325811

# The largest fall from a peak during the period (%)
min(path$drawdown_pct)
#> [1] -66.33509
```

## Limitations

- Prices are adjusted for NVIDIA’s share splits, so early prices look
  like cents. They are not the prices people paid at the time.
- This is not the latest app since the data end on 21 September 2026. It
  could be made into one by using extensive feeding data tool.
- The data come from a Kaggle dataset (CC BY-SA 4.0); see
  [`?nvda`](https://etc5523-2026.github.io/etc5523-assignment-4-dhoa0015-svg/reference/nvda.md)
  for details.
