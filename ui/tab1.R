tabItem("Data",
        fluidRow(
            # A static infoBox
            infoBoxOutput("numberBox"),
            # Dynamic infoBoxes
            infoBoxOutput("averagePriceBox")
        ),
         sidebarLayout(
             sidebarPanel(
                 uiOutput("selectbox")
             ),
             mainPanel(
                 dataTableOutput('tbl')                 
             )
         )
)
