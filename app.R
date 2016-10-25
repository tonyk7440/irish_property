library(shiny)
library(shinydashboard)
library(DT)
library(scales)

ui <- dashboardPage(
    dashboardHeader(title = "Explore Properties"),
    dashboardSidebar(
        sidebarMenu(
            menuItem("Pick Area", tabName = "Data", icon = icon("search")),
            uiOutput("menuItem"),
            menuItem("Plot", tabName = "Boxplot", icon = icon("area-chart"))
            )
    ),
    dashboardBody(
        tabItems(
        # include the UI for each tab
        source(file.path("ui", "tab1.R"),  local = TRUE)$value,
        source(file.path("ui", "tab2.R"),  local = TRUE)$value
        )
    )
)
server <- function(input, output, session) {
    # Include the logic (server) for each tab
    source(file.path("server", "tab1.R"),  local = TRUE)$value
    source(file.path("server", "tab2.R"),  local = TRUE)$value

    output$menuItem <- renderUI({
        return(selectizeInput(
            'pick_county', 'Location', choices = levels(data[["AddressSix"]]), multiple = TRUE))
    })
}

shinyApp(ui = ui, server = server)