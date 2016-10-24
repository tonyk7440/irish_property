data <- read.csv("input/properties.csv", header = TRUE, stringsAsFactors = TRUE)

output$location <- renderUI({
    areas <- levels(data[["AddressSix"]])
    
    selectInput("area", "Location", choices = areas)
})

output$selectbox <- renderUI({
    # if ( is.null(input$show_checkbox) ) { return(NULL) }
    # if ( input$show_checkbox == 0 ) { return(NULL) }
    return(selectizeInput(
        'pick_county', 'Location', choices = levels(data[["AddressSix"]]), multiple = TRUE))
})

# Render the data table on tab 1
output$tbl <- DT::renderDataTable(datatable({
    if ( is.null(input$pick_county) ) { return(data) }
    if ( length(input$pick_county) == 0 ) { return(data) }
    data[data[["AddressSix"]] %in% input$pick_county, ]
}),
options = list(pageLength = 10, autoWidth = TRUE),rownames= FALSE)
    