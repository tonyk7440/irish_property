tabItem("Boxplot",
         sidebarLayout(
             sidebarPanel(
                 uiOutput("x_axis"),
                 uiOutput("y_axis"),
                 radioButtons("loess_op", "Loess",
                              c("None" = "none",
                                "Loess" = "loess",
                                "Loess + SE" = "loesssd"), inline = TRUE),

                 textInput("title", "Title"),
                 textInput("x_label", "X-label"),
                 textInput("y_label", "Y-label"),
                 div(class = "option-header", "Brush"),
                 radioButtons("brush_dir", "Direction(s)",
                              c("xy", "x", "y"), inline = TRUE),
                 checkboxInput("brush_reset", "Reset on new image")
             ),
             mainPanel(
                 uiOutput("plotui"),
                 downloadButton('downloadPlot')
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