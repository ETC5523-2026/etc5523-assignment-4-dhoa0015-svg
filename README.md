
<!-- README.md is generated from README.Rmd. Please edit that file -->

# nvdastocks

nvdastocks package is used to look at how much growth have changhed in
the investment in NVIDIA stocks over the period of 1999-2026, helps
someone thinking about investing in NVIDIA answer one question: **if I
had invested on this date then what would it be worth by this time, and
how far would it have fallen along the way?**

## Installation

``` r
remotes::install_github("ETC5523-2026/etc5523-assignment-4-dhoa0015-svg")
```

## Launch the app

``` r
library(nvdastocks)
run_app()
```

## What’s in the package

- `nvda`: daily NVIDIA share prices from 1999 to 2026, with moving
  averages and volatility
- `investment_path()`: the value of an investment, and its fall from
  peak, over any period
- `run_app()`: launches the Shiny app

## Data

Adapted from the Kaggle dataset “Nvidia Historical Stock Data” by
Muhammad Ibrahim Shahrukh
(<https://www.kaggle.com/datasets/muhammadishahrukh/nvidia-historical-stock-data?select=nvda_stock_clean.csv>),
licensed CC BY-SA 4.0. The `nvda` data in this package is shared under
the same licence.

## Website

<https://etc5523-2026.github.io/etc5523-assignment-4-dhoa0015-svg/>

## Generative AI declaration

I have used AI in this project to helps me naviagte between task, and
extensively apply the theme and color to the Shiny app dashboards. The
git commit show that extensive changes. - The link to the AI
conversation:
[Link](https://claude.ai/share/71bd9479-2474-46b5-9b6b-ea26c98511b9)
