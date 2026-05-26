
header <- dashboardHeader(
    title = "Active Transportation Mode Share in Corvallis, OR",
    titleWidth = 450
)

sidebar <- dashboardSidebar(
    sidebarMenu(
        id = "sidebarNav",
        menuItem("About", tabName = "about", selected = TRUE),
        menuItem("Map", tabName = "map")
    ),
    uiOutput("sidebarInputs")
)

body <- dashboardBody(
    tabItems(
        tabItem(tabName = "about",
            fluidRow(
                box(
                    width = 8,
                    status = "primary",
                    get_content_about()
                )
            )
        ),
        tabItem(tabName = "map",
            fluidRow(
                column(
                    width = 8,
                    box(
                        solidHeader = TRUE,
                        width = NULL,
                        leafletOutput(
                            "mapMain",
                            height = "75vh",
                            width = "100%"
                        )
                    )
                ),
                column(
                    width = 4,
                    # Stats box
                    box(
                        solidHeader = TRUE,
                        width = NULL,
                        valueBoxOutput(
                            "valueBoxTotTrips",
                            width = "100%"
                        ),
                        hr(),
                        h4(
                            "Total Mode Share",
                            style = "margin-top: 0;"
                        ),
                        plotOutput(
                            "plotPctModeShare",
                            height = "10vh"
                        ),
                        hr(),
                        h4(
                            "Active Mode Share",
                            style = "margin-top: 0;"
                        ),
                        plotOutput(
                            "plotPctActiveModeShare",
                            height = "10vh"
                        ),
                    ),
                    # Info box
                    box(
                        solidHeader = TRUE,
                        width = NULL,
                        gt_output(
                            "tableDetails"
                        )
                    )
                )
            )
        )
    )
    
)

dashboardPage(
    header,
    sidebar,
    body
)
