tabPanel("Data",
         sidebarLayout(
             sidebarPanel(
                 actionButton("show_checkbox", "Show Choices"),
                 uiOutput("checkbox")
             ),
             mainPanel(
                 dataTableOutput('tbl')                 
             )
         )
)
