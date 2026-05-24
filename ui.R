
header <- dashboardHeader(
    title = "Active Transportation Mode Share in Corvallis, OR",
    titleWidth = 450
)

sidebar <- dashboardSidebar(
    selectInput(
        "inputSelectWard",
        "Filter by city ward",
        choices = choices_ward
    )
)

body <- dashboardBody(
    fluidRow(
        column(
            width = 9,
            box(
                solidHeader = TRUE,
                width = NULL,
                leafletOutput(
                    "mapMain",
                    height = "80vh",
                    width = "100%"
                )
            )
        ),
        column(
            width = 3,
            box(
                solidHeader = TRUE,
                width = NULL,
                div(
                    class = "small-box",
                    plotOutput(
                        "plotPctModeShare",
                        height = 100
                    ),
                ),
                div(
                    class = "small-box",
                    plotOutput(
                        "plotPctActiveModeShare",
                        height = 100
                    ),
                ),
                valueBoxOutput(
                    "valueBoxTotTrips",
                    width = "100%"
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
