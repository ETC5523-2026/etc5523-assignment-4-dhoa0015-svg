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
    checkboxInput("log_scale", "Compare growth in % terms (log scale)", FALSE),
    p("NVIDIA’s early prices were only cents, so on a normal chart those years look flat. Tick this to see how much they really rose and fell.", style = "font-size: 0.85em; color: grey;"),
    conditionalPanel(condition = "input.main_tab == 'price'",
    checkboxInput("show_sma", "Show 20- and 50-day averages", TRUE))
  ), navset_card_tab(
  id = "main_tab",
  nav_panel("How much would I have gained?", value = "gain",
          h3(textOutput("gain_headline", inline = TRUE)),
          p("The blue line is what your investment was worth each day. Above the dashed line is a gain; below it is a loss."),
          plotOutput("gain_plot")),
  nav_panel("How did the price move?", value = "price",
          h3(textOutput("price_headline", inline = TRUE)),
          p("The grey line is the daily closing price. The coloured lines average the last 20 and 50 days, which smooths out daily ups and downs."),
          plotOutput("price_plot")),
  nav_panel("How much did it drop thorughout the period?", value = "risk",
          h3(textOutput("risk_headline", inline = TRUE)),
          p("0% means the investment was at its highest value so far. The deeper the shaded area, the further it had fallen from that peak."),
          plotOutput("risk_plot"))
)
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

  output$price_plot <- renderPlot({
    p <- ggplot(period_data(), aes(date)) +
      geom_line(aes(y = close, colour = "Closing price"))
    if (input$show_sma) {
      p <- p +
        geom_line(aes(y = sma_20, colour = "20-day average"), na.rm = TRUE) +
        geom_line(aes(y = sma_50, colour = "50-day average"), na.rm = TRUE)
    }
    p <- p +
      scale_colour_manual(values = c(
        "Closing price" = "grey40",
        "20-day average" = "#006DAE",
        "50-day average" = "#D55E00"
      )) +
    labs(x = NULL, y = "Share price (US$)", colour = NULL)
    if (input$log_scale) {
      p + scale_y_log10(labels = scales::dollar)
    } else {
      p + scale_y_continuous(labels = scales::dollar)
  }
})

output$risk_plot <- renderPlot({
  ggplot(period_data(), aes(date, drawdown_pct)) +
    geom_area(fill = "#D55E00", alpha = 0.4) +
    geom_line(colour = "#D55E00") +
    labs(x = NULL, y = "Fall from highest value so far (%)")
})
}

shinyApp(ui, server)