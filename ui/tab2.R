tabItem("Boxplot",
        mainPanel(width = 12,
            uiOutput("plotui"),
            downloadButton('downloadPlot')
        ),
         fluidRow(
             column(width = 3,
                 uiOutput("x_axis"),
                 checkboxInput('log_x', 'Log(x)'),
                 textInput("x_label", "X-label")
             ),
             column(width = 3,
                    uiOutput("y_axis"),
                    checkboxInput('log_y', 'Log(y)'),
                    textInput("y_label", "Y-label")
             ),
             column(width = 3,
                    textInput("title", "Title"),
                    radioButtons("loess_op", "Loess",
                                 c("None" = "none",
                                   "Loess" = "loess",
                                   "Loess + SE" = "loesssd"))
                    ),
             column(width = 3,
                 radioButtons("facet", "Facet Type: ",
                              c("None" = "none",
                                "Grid" = "grid",
                                "Wrap" = "wrap")),
                 # Only show this panel if the plot type is a histogram
                 conditionalPanel(
                     condition = "input.facet == 'grid'",
                     uiOutput('facet_grid')),
                 
                 # Only show this panel if Custom is selected
                 conditionalPanel(
                     condition = "input.facet == 'wrap'",
                     uiOutput('wrap_grid')),
                 radioButtons("brush_dir", "Brush Direction(s)",
                              c("xy", "x", "y"), inline = TRUE),
                 checkboxInput("brush_reset", "Reset on new image")
             )
         ),
         fluidRow(
             column(width = 9,
                    wellPanel(width = 9,
                              h4("Points selected"),
                              DT::dataTableOutput("plot_brushed_points")
                    )
             )
         )
)