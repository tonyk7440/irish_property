tabPanel("Data",
         sidebarLayout(
             sidebarPanel(
                 checkboxInput("smooth", "Use Example Dataset"),
                 conditionalPanel("input.smooth == true",
                     selectInput("example_ds", "Data set", choices = c("mtcars"))
                 ),
                 fileInput('file1', 'Choose CSV File',
                           accept=c('text/csv', 
                                    'text/comma-separated-values,text/plain', 
                                    '.csv')),
                 tags$hr(),
                 checkboxInput('header', 'Header', TRUE),
                 radioButtons('sep', 'Separator',
                              c(Comma=',',
                                Semicolon=';',
                                Tab='\t'),
                              ','),
                 radioButtons('quote', 'Quote',
                              c(None='',
                                'Double Quote'='"',
                                'Single Quote'="'"),
                              '"')
             ),
             mainPanel(
                 tableOutput('contents')                 
             )
         )
)
