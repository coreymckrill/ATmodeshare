
header <- dashboardHeader(
    title = "Active Transportation Mode Share in Corvallis, OR",
    titleWidth = 450
)

sidebar <- dashboardSidebar(
    sidebarMenu(
        id = "sidebarNav",
        menuItem(
            "Map",
            tabName = "map",
            icon = icon(
                "map-location-dot",
                style = "margin-right: 1em;"
            ),
            selected = TRUE
        ),
        menuItem(
            "FAQ",
            tabName = "faq",
            icon = icon(
                "circle-info",
                style = "margin-right: 1em;"
            )
        )
    ),
    uiOutput("sidebarInputs")
)

body <- dashboardBody(
    tabItems(
        # Map tab
        tabItem(tabName = "map",
            fluidRow(
                column(
                    width = 8,
                    box(
                        solidHeader = TRUE,
                        width = NULL,
                        leafletOutput(
                            "mapMain",
                            height = "85vh",
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
                    ),
                    p(
                        span(
                            style = "display: inline-block;",
                            "Dashboard by Corey McKrill."
                        ),
                        span(
                            style = "display: inline-block;",
                            "May, 2026."
                        )
                    ),
                    p(
                        span(
                            style = "display: inline-block;",
                            "Data sources: "
                        ),
                        span(
                            style = "display: inline-block;",
                            "Corvallis Sustainability Coalition, "
                        ),
                        span(
                            style = "display: inline-block;",
                            "City of Corvallis."
                        )
                    )
                )
            )
        ),
        # FAQ tab
        tabItem(tabName = "faq",
            fluidRow(
                box(
                    width = 8,
                    status = "primary",
                    get_content_about()
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
