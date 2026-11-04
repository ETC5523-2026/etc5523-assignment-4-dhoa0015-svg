library(shiny)
library(bslib)
library(dplyr)
library(ggplot2)
library(nvdastocks)

ui <- page_sidebar(
  title = "What would investing in NVIDIA worth in the future ?",
  sidebar = sidebar(
    dateRangeInput(
      "period", "Choose an investment period",
      start = as.Date("2020-01-02"), end = max(nvda$date),
      min = min(nvda$date), max = max(nvda$date)
    ),
    numericInput("amount", "Amount invested (US$)", value = 1000, min = 1),
    checkboxInput("log_scale", "Use a log scale", FALSE)
  ), plotOutput("gain_plot")
)

server <- function(input, output, session) {
  period_data <- reactive({
    req(input$period)
    validate(
      need(!is.na(input$amount) && input$amount > 0, "Enter an amount above $0."),
      need(input$period[1] < input$period[2], "The start date must be before the end date.")
    )
    df <- investment_path(nvda, input$period[1], input$period[2], input$amount)
    validate(need(nrow(df) >= 2, "This period has fewer than two trading days. Choose a longer period."))
    df
  })

  output$gain_plot <- renderPlot({
    p <- ggplot(period_data(), aes(date, value)) +
      geom_hline(yintercept = input$amount, linetype = "dashed") +
      geom_line() +
      labs(x = NULL, y = "Value of investment (US$)")
    if (input$log_scale) {
      p + scale_y_log10(labels = scales::dollar)
    } else {
      p + scale_y_continuous(labels = scales::dollar)
    }
  })
}

shinyApp(ui, server)