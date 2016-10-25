library(shiny)
library(ggplot2)
library(Cairo)
library(DT)

filtered_data <- reactive({
    if ( is.null(input$pick_county) ) { return(data) }
    return(filtered_data <- data[data[["AddressSix"]] %in% input$pick_county, ])
})

output$x_axis <- renderUI({
    cols <- names(filtered_data())
    
    selectInput("x_axis", "x-axis",  as.list(cols), selected = cols[7])
})

output$y_axis <- renderUI({
    cols <- names(filtered_data())
    
    selectInput("y_axis", "y-axis",  as.list(cols), selected = cols[6])
})

# Update changes in Title
observe({
    t <- levels(filtered_data()["AddressSix"])
    
    updateTextInput(session, inputId = "title", value = t)
})

# Observe change of selected x-xis
observe({
    x <- input$x_axis
    
    updateTextInput(session, inputId = "x_label", value = x)
})

# Observe change of selected y-axis
observe({
    y <- input$y_axis
    
    updateTextInput(session, inputId = "y_label", value = y)
})

# Add faceting option
output$facet_grid <- renderUI({
    cols <- names(filtered_data())
    
    selectInput("r_split", "Row split: ",  as.list(cols))
    selectInput("c_split", "Column split: ",  as.list(cols))
})

output$wrap_grid <- renderUI({
    cols <- names(filtered_data())
    
    selectInput("split_by", "Split by: ",  as.list(cols))
})
plotInput <- function(){
    numerics <- c("Photos", "Price", "Beds", "Baths")
    facts <- c("AddressFour", "AddressFive", "AddressSix", "Type", "agent")
    new_data <- filtered_data()
    if(input$x_axis == "agent" | input$y_axis == "agent") {
        new_data <- new_data %>% drop_na(agent)
    }
    if(((input$x_axis %in% numerics) & (input$y_axis %in% numerics)) |
       (input$x_axis %in% facts) & (input$y_axis %in% facts)) {
        pc <- ggplot(new_data, aes_string(input$x_axis, y=input$y_axis)) +
            geom_point() +
            labs(x=input$x_label,y=input$y_label) +
            ggtitle(input$title) +
            theme_bw()
    }
    else{
        pc <- ggplot(new_data, aes_string(input$x_axis, y=input$y_axis)) +
            geom_boxplot() +
            labs(x=input$x_label,y=input$y_label) +
            ggtitle(input$title) +
            theme_bw()
    }

    # log x
    if(input$log_x)
        pc <- pc + scale_x_log10(breaks = trans_breaks('log10', function(x) 10^x), labels = trans_format('log10', math_format(10^.x)))
    
    # log y
    if(input$log_y)
        pc <- pc + scale_y_log10(breaks = trans_breaks('log10', function(x) 10^x), labels = trans_format('log10', math_format(10^.x)))
    
    # Need to pass loess specs
    pc <- switch(input$loess_op,
                none = pc,
                loess = pc + stat_smooth(se = FALSE),
                loesssd = pc + stat_smooth()
    )
    
    pc
    
}

output$plotui <- renderUI({
    plotOutput("plot",
               click = "plot_click",
               dblclick = dblclickOpts(
                   id = "plot_dblclick"
               ),
               brush = brushOpts(
                   id = "plot_brush",
                   direction = input$brush_dir,
                   resetOnNew = input$brush_reset
               )
    )
})

output$plot <- renderPlot({
    plotInput()
})

output$downloadPlot <- downloadHandler(
    filename = function() { paste('image', '.png', sep='') },
    content = function(file) {
        ggsave(file, plot = plotInput(), device = "png")
    }
)

output$plot_clicked_points <- DT::renderDataTable({
    res <- nearPoints(filtered_data(), input$plot_click,
                      threshold = input$max_distance, maxpoints = input$max_points,
                      addDist = TRUE)
    
    res$dist_ <- round(res$dist_, 1)
    
    datatable(res)
})

output$plot_brushed_points <- DT::renderDataTable({
    res <- brushedPoints(filtered_data(), input$plot_brush)
    
    datatable(res)
})