library(shiny)
library(bslib)
library(dplyr)
library(ggplot2)
library(nvdastocks)

ui <- page_fluid("My NVIDIA app")

server <- function(input, output, session) {
}

shinyApp(ui, server)