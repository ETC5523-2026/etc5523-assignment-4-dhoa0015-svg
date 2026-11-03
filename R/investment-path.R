#' Follow an investment in NVIDIA shares over a chosen period
#'
#' Keeps the trading days between `start` and `end`, then calculates what an
#' amount invested at the first closing price in that period would be worth
#' on each day, and how far it had fallen from its highest value so far.
#'
#' @param prices A data frame of daily prices with `date` and `close`
#'   columns, such as [nvda].
#' @param start,end First and last dates of the period, as `Date` objects or
#'   `"YYYY-MM-DD"` strings.
#' @param amount Amount invested at the first closing price, in US dollars.
#' @return The rows of `prices` within the period, with three added columns:
#'   `value` (worth of the investment that day), `gain_pct` (percentage gain
#'   or loss since the start) and `drawdown_pct` (percentage fall from the
#'   highest closing price so far in the period; 0 at a new high). Returns
#'   zero rows when the period contains no trading days.
#' @importFrom dplyr arrange filter first mutate
#' @export
#' @examples
#' # $1,000 invested at the start of 2020
#' path <- investment_path(nvda, "2020-01-01", "2026-09-21", amount = 1000)
#' tail(path, 1)
#'
#' # The largest fall from a peak during 2022
#' min(investment_path(nvda, "2022-01-01", "2022-12-31")$drawdown_pct)
investment_path <- function(prices, start, end, amount = 1000) {
  if (!is.numeric(amount) || length(amount) != 1 || is.na(amount) || amount <= 0) {
    stop("`amount` must be a single positive number.")
  }

  prices |>
    filter(date >= as.Date(start), date <= as.Date(end)) |>
    arrange(date) |>
    mutate(
      value = amount * close / first(close),
      gain_pct = 100 * (close / first(close) - 1),
      # Compare each day with the highest close since the start of the period
      drawdown_pct = 100 * (close / cummax(close) - 1)
    )
}
