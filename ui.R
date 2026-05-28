header <- dashboardHeader(disable = TRUE)

sidebar <- dashboardSidebar(
    # Putting this here since dashboardPage() doesn't take it
    tags$head(
        tags$style(HTML("
            body {
                font-size: 1.6rem;
            }
        "))
    ),
    div(
        style = "margin-top: -50px; margin-bottom: 1.6rem; padding: 15px 15px 0;",
        h1(
            style = "margin: 0; font-size: 2rem; font-weight: 700;",
            "Active Transportation Mode Share"
        ),
        span(
            style = "display: block; font-size: 1.4rem;",
            "Corvallis, Oregon"
        )
    ),
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
            "Chart",
            tabName = "chart",
            icon = icon(
                "chart-line",
                style = "margin-right: 1em;"
            )
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
        # Chart tab
        tabItem(tabName = "chart",
            fluidRow(
                column(
                    width = 8,
                    box(
                        solidHeader = TRUE,
                        width = NULL,
                        plotOutput(
                            "plotInteractiveChart",
                            height = "85vh"
                        )
                    )
                ),
                column(
                    width = 4,
                    box(
                        solidHeader = TRUE,
                        width = NULL,
                        #uiOutput("chartInputs")
                        varSelectInput(
                            "inputSelectX",
                            "X axis",
                            get_choices_axis(),
                            selected = "Total trips per hour"
                        ),
                        varSelectInput(
                            "inputSelectY",
                            "Y axis",
                            get_choices_axis(),
                            selected = "Total active trips per hour"
                        ),
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
    title = "Active Transportation Mode Share, Corvallis, Oregon",
    skin = "blue",
    header,
    sidebar,
    body
)
