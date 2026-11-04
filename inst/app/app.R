library(shiny)
library(bslib)
library(dplyr)
library(ggplot2)
library(nvdastocks)

nvda_colours <- c(
  page   = "#000000",
  card   = "#1A1A1A",
  green  = "#76B900",
  text   = "#FFFFFF",
  muted  = "#A6A6A6",
  down   = "#E5484D",
  orange = "#df720c"
)

nvidia_theme <- bs_theme(
  bg = nvda_colours[["page"]],
  fg = nvda_colours[["text"]],
  primary = nvda_colours[["green"]],
  secondary = nvda_colours[["muted"]],
  danger = nvda_colours[["down"]],
  "card-bg" = nvda_colours[["card"]]
)

theme_nvda_plots <- function(base_size = 15) {
  theme_minimal(base_size = base_size) +
    theme(
      plot.background = element_rect(fill = nvda_colours[["card"]], colour = NA),
      panel.background = element_rect(fill = nvda_colours[["card"]], colour = NA),
      panel.grid.major = element_line(colour = "#333333"),
      panel.grid.minor = element_blank(),
      text = element_text(colour = nvda_colours[["text"]]),
      axis.text = element_text(colour = nvda_colours[["muted"]]),
      legend.position = "bottom"
    )
}

ui <- page_sidebar(
  theme = nvidia_theme,
  title = span("What would investing in NVIDIA worth in the future ?",
               style = paste0("color: ", nvda_colours[["orange"]], "; font-weight: bold;")),
  sidebar = sidebar(
    bg = nvda_colours[["card"]],
    dateRangeInput(
      "period", "Choose an investment period",
      start = as.Date("2020-01-02"), end = max(nvda$date),
      min = min(nvda$date), max = max(nvda$date)
    ),
    numericInput("amount", "Amount invested (US$)", value = 1000, min = 1),
    checkboxInput("log_scale", "Compare growth in % (log scale)", FALSE),
    p("NVIDIA’s early prices were only cents, so on a normal chart those years look flat. Tick this to see how much they really rose and fell.", style = paste0("font-size: 0.85em; color: ", nvda_colours[["muted"]], ";")),
    conditionalPanel(condition = "input.main_tab == 'risk'",
    checkboxInput("show_sma", "Show 20- and 50-day averages", TRUE))
  ), navset_card_tab(
  id = "main_tab",
  nav_panel("How much would I have gained?", value = "gain",
          h3(textOutput("gain_headline", inline = TRUE)),
          p("The green line is what your investment was worth each day. Above the dashed line is a gain; below it is a loss."),
          plotly::plotlyOutput("gain_plot")),
  nav_panel("When did it fall, and how far?", value = "risk",
          h3(textOutput("risk_headline", inline = TRUE)),
          p("Top: the share price. Bottom: how far it was below its highest price so far. Drag across either chart to zoom both; double-click to reset."),
          plotly::plotlyOutput("price_drop_plot", height = "600px"))
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

  output$gain_plot <- plotly::renderPlotly({
    p <- ggplot(period_data(), aes(date, value)) +
      geom_hline(yintercept = input$amount, linetype = "dashed", colour = nvda_colours[["orange"]], linewidth = 0.8) +
      geom_line(aes(group = 1, text = paste0(format(date, "%d %b %Y"),
                                       "<br>Worth: ", scales::dollar(value))),
          colour = nvda_colours[["green"]]) +
      labs(x = NULL, y = "Value of investment (US$)") +
      theme_nvda_plots()
    if (input$log_scale) {
      p <- p + scale_y_log10(labels = scales::dollar)
    } else {
      p <- p + scale_y_continuous(labels = scales::dollar)
    }
    plotly::ggplotly(p, tooltip = "text")
  })

  output$price_drop_plot <- plotly::renderPlotly({
  df <- period_data()

  price <- ggplot(df, aes(date)) +
    geom_line(aes(y = close, colour = "Closing price", group = 1,
                  text = paste0(format(date, "%d %b %Y"),
                                "<br>Closing price: ", scales::dollar(close, accuracy = 0.01))))
  if (input$show_sma) {
    price <- price +
      geom_line(aes(y = sma_20, colour = "20-day average", group = 1,
                    text = paste0("20-day average: ", scales::dollar(sma_20, accuracy = 0.01))),
                na.rm = TRUE) +
      geom_line(aes(y = sma_50, colour = "50-day average", group = 1,
                    text = paste0("50-day average: ", scales::dollar(sma_50, accuracy = 0.01))),
                na.rm = TRUE)
  }
  price <- price +
    scale_colour_manual(values = c(
      "Closing price" = nvda_colours[["text"]],
      "20-day average" = nvda_colours[["green"]],
      "50-day average" = nvda_colours[["orange"]]
    )) +
    labs(x = NULL, y = "Share price (US$)", colour = NULL) +
    theme_nvda_plots()

  drop <- ggplot(df, aes(date, drawdown_pct)) +
    geom_area(fill = nvda_colours[["down"]], alpha = 0.4) +
    geom_line(aes(group = 1, text = paste0(format(date, "%d %b %Y"),
                                           "<br>Below its peak by: ", round(abs(drawdown_pct)), "%")),
              colour = nvda_colours[["down"]]) +
    labs(x = NULL, y = "Fall from peak") +
    theme_nvda_plots()

  plotly::subplot(
    plotly::ggplotly(price, tooltip = "text", dynamicTicks = TRUE),
    plotly::ggplotly(drop, tooltip = "text", dynamicTicks = TRUE),
    nrows = 2, shareX = TRUE, heights = c(0.6, 0.4), titleY = TRUE
  ) |>
    plotly::layout(
      showlegend = TRUE,
      legend = list(orientation = "h", y = 1.08),
      yaxis = list(tickprefix = "$", type = if (input$log_scale) "log" else "linear"),
      yaxis2 = list(ticksuffix = "%")
    )
})
}

shinyApp(ui, server)