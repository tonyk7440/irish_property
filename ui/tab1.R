tabItem("Data",
        fluidRow(
            # A static infoBox
            infoBoxOutput("numberBox"),
            # Dynamic infoBoxes
            infoBoxOutput("averagePriceBox")
        ),
             mainPanel(
                 dataTableOutput('tbl')                 
             )
)
