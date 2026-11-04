#' Launch the NVIDIA investment app
#'
#' Opens a Shiny app for exploring what an investment in NVIDIA stocks would have grown over a chosen period, and how far it fell along the way.
#' @return Called for its side effect of launching the app.
#' @export
#' @examples
#' if (interactive()) {
#'   run_app()
#' }
run_app <- function() {
  app_dir <- system.file("app", package = "nvdastocks")
  shiny::runApp(app_dir)
}