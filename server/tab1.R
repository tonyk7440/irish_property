data <- read.csv("input/properties.csv", header = TRUE, stringsAsFactors = TRUE)

createLink <- function(val) {
    sprintf('<a href="https://%s" target="_blank" class="btn btn-primary">Info</a>',val)
}

output$location <- renderUI({
    areas <- levels(data[["AddressSix"]])
    
    selectInput("area", "Location", choices = areas)
})

output$numberBox <- renderInfoBox({
    infoBox(
        "Properties", nrow(filtered_data()), icon = icon("home"),
        color = "purple"
    )
})
output$averagePriceBox <- renderInfoBox({
    df <- filtered_data()
    infoBox(
        "Average Price", prettyNum(paste("\u20ac",round(mean(df$Price))), big.mark = ","), icon = icon("money"),
        color = "green", width = 8
    )
})

output$selectbox <- renderUI({
    # if ( is.null(input$show_checkbox) ) { return(NULL) }
    # if ( input$show_checkbox == 0 ) { return(NULL) }
    return(selectizeInput(
        'pick_county', 'Location', choices = levels(data[["AddressSix"]]), multiple = TRUE))
})

# Render the data table on tab 1
output$tbl <- DT::renderDataTable(datatable({
    data$link <- createLink(data$url)
    if ( is.null(input$pick_county) ) { return(data) }
    if ( length(input$pick_county) == 0 ) { return(data) }
    return(data[data[["AddressSix"]] %in% input$pick_county, ])
}),
options = list(pageLength = 5, autoWidth = TRUE, columnDefs = list(list(visible=FALSE, targets=c(8)))),
escape = FALSE ,rownames= FALSE)
    