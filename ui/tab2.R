tabPanel("Boxplot",
         sidebarLayout(
             sidebarPanel(
                 uiOutput("x_axis"),
                 uiOutput("y_axis"),
                 radioButtons("loess_op", "Loess",
                              c("None" = "none",
                                "Loess" = "loess",
                                "Loess + SE" = "loesssd"), inline = TRUE),
                 # Tidy before putting in
                 # selectInput("ggplot_scaletype", "Scale type",
                 #             c("normal" = "normal",
                 #               "reverse (scale_*_reverse())" = "reverse",
                 #               "log10 (scale_*_log10())" = "log10",
                 #               "log2 (scale_*_continuous( trans=log2_trans()))" = "log2",
                 #               "log10 (coord_trans())" = "log10_trans",
                 #               "log2 (coord_trans())" = "log2_trans",
                 #               "coord_cartesian()" = "coord_cartesian",
                 #               "coord_flip()" = "coord_flip",
                 #               "coord_polar() (doesn't work)" = "coord_polar",
                 #               "x factor" = "x_factor")
                 # ),
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