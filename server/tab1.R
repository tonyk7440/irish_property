myData <- reactive({
            data <- read.csv("input/properties.csv", header = TRUE, stringsAsFactors = TRUE)
            data
})

output$location <- renderUI({
    areas <- levels(myData()[["AddressSix"]])
    
    selectInput("area", "Location", choices = areas)
})

# Render the data table on tab 1
output$contents <- renderDataTable(
    datatable(myData(), options = list(pageLength = 25))
)