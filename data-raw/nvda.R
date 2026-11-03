## code to prepare `nvda` dataset goes here
nvda_raw <- utils::read.csv("data-raw/nvda_stock_clean.csv") |>
  dplyr::mutate(date = as.Date(date))

roll_mean <- function(x, n) {
  as.numeric(stats::filter(x, rep(1 / n, n), sides = 1))
}
 
roll_sd <- function(x, n) {
  sapply(seq_along(x), function(i) {
    if (i < n) NA_real_ else stats::sd(x[(i - n + 1):i])
  })
}
 
nvda <- nvda_raw |>
  dplyr::select(date, open, high, low, close, volume) |>
  dplyr::arrange(date) |>
  dplyr::mutate(
    daily_return_pct = 100 * (close / dplyr::lag(close) - 1),
    sma_20 = roll_mean(close, 20),
    sma_50 = roll_mean(close, 50),
    volatility_20_pct = 100 * roll_sd(log(close / dplyr::lag(close)), 20) * sqrt(252)
  )

usethis::use_data(nvda, overwrite = TRUE)
