header <- dashboardHeader(disable = TRUE)

sidebar <- dashboardSidebar(
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
    useShinyjs(),
    extendShinyjs(
        script = "script.js",
        # Using the special init function so we don't need to list it here
        functions = c()
    ),
    # Putting this here since dashboardPage() doesn't take it
    tags$head(
        tags$style(HTML("
            body {
                font-size: 1.6rem;
            }
        ")),
        tags$link(
            rel = "stylesheet",
            type = "text/css",
            href = "style.css"
        )
    ),
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
                            height = "92vh",
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
                        style = "font-size: 1.3rem",
                        span(
                            style = "display: inline-block;",
                            "Dashboard by Corey McKrill",
                            a(
                                href = "https://github.com/coreymckrill/ATmodeshare",
                                target = "_blank",
                                img(
                                    src = "GitHub_Invertocat_Black.png",
                                    height = 13,
                                    alt = "Github logo",
                                    style = "vertical-align: center;"
                                )
                            )
                        ),
                        br(),
                        span(
                            style = "display: inline-block;",
                            "May, 2026."
                        )
                    ),
                    p(
                        style = "font-size: 1.3rem",
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
                            "City of Corvallis,"
                        ),
                        span(
                            style = "display: inline-block;",
                            "Walk Score."
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
                        plotlyOutput(
                            "plotInteractiveChart",
                            height = "92vh"
                        )
                    )
                ),
                column(
                    width = 4,
                    box(
                        solidHeader = TRUE,
                        width = NULL,
                        h2(
                            style = "margin-top: 0; font-size: 2rem;",
                            "Chart dimensions",
                            actionLink(
                                style = "display: inline-block; margin-left: 1rem; font-size: 1.3rem;",
                                "actionChartReset",
                                "Reset"
                            )
                        ),
                        varSelectInput(
                            "inputSelectX",
                            "Horizontal axis",
                            get_choices_axis(),
                            selected = "Motor vehicle trips counted per hour"
                        ),
                        varSelectInput(
                            "inputSelectY",
                            "Vertical axis",
                            get_choices_axis(),
                            selected = "Active trips mode share %"
                        ),
                        checkboxInput(
                            "inputCheckboxTrendLine",
                            "Show trend line",
                            value = TRUE
                        )
                    )
                )
            )
        ),
        # FAQ tab
        tabItem(tabName = "faq",
            fluidRow(
                column(
                    width = 8,
                    !!!get_content_faq()
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
