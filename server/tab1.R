data <- read.csv("input/properties.csv", header = TRUE, stringsAsFactors = TRUE)
#data <- filter(data, AddressSix == input$area)


output$location <- renderUI({
    areas <- levels(data[["AddressSix"]])
    
    selectInput("area", "Location", choices = areas)
})

output$checkbox <- renderUI({
    if ( is.null(input$show_checkbox) ) { return(NULL) }
    if ( input$show_checkbox == 0 ) { return(NULL) }
    return(selectizeInput(
        'specy', 'Location', choices = levels(data[["AddressSix"]]), multiple = TRUE))
})

# Render the data table on tab 1
output$tbl <- renderDataTable(datatable({
    if ( is.null(input$specy) ) { return(data) }
    if ( length(input$specy) == 0 ) { return(data) }
    data[data[["AddressSix"]] == input$specy, ]
}))
    