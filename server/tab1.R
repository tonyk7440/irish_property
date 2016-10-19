myData <- reactive({
        if(input$smooth == TRUE){
            data <- switch(input$example_ds,
                           "mtcars" = mtcars) 
            data
        }
        else{
            inFile <- input$file1
            if (is.null(inFile)) return(NULL)
            data <- read.csv(inFile$datapath, header=input$header, sep=input$sep, 
                             quote=input$quote)
            data   
        }

})

# Render the data table on tab 1
output$contents <- renderTable({
    myData()
})