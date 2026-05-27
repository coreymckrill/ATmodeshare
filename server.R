# Server function
function(input, output, session) {
    # Data
    data_wards <- get_data_wards()
    data_modeshare <- get_data_modeshare()
    data_modeshare_subset <- reactiveVal(data_modeshare)
    data_modeshare_summary <- reactive({
        get_data_modeshare_summary(data_modeshare_subset())
    })
    
    filter_inputs <- reactiveValues(
        infra = NULL,
        uid = NULL,
        ward = NULL
    )
    
    north_arrow <- div(
        style = "margin-top: 0.5em;",
        icon(
            "location-arrow",
            class = "fa-solid fa-2xl fa-rotate-by",
            style = "margin-right: 0; --fa-rotate-angle: -45deg;"
        )
    )
    color_wards <- colorFactor("viridis", data_wards$WARD)
    initial_bounds <- st_bbox(data_wards)
    
    # Sidebar
    output$sidebarInputs <-
        renderUI({
            if (input$sidebarNav == "map") {
                tagList(
                    h4(
                        class = "shiny-input-container",
                        "Data subsets"
                    ),
                    selectInput(
                        "inputSelectWard",
                        "Filter by city ward",
                        choices = get_choices_ward()
                    ),
                    selectInput(
                        "inputSelectBikeInfra",
                        "Filter by bike infrastructure",
                        choices = get_choices_bikeinfra()
                    )
                )
            }
        })
    
    # Initial map output
    output$mapMain <-
        renderLeaflet({
            leaflet() |>
                addProviderTiles(providers$Esri.WorldGrayCanvas) |>
                addControl(
                    north_arrow,
                    position = "topright",
                    className = ""
                ) |>
                addScaleBar(
                    position = "bottomleft",
                    options = scaleBarOptions(
                        metric = FALSE
                    )
                ) |>
                addPolygons(
                    data = data_wards,
                    stroke = FALSE,
                    fillColor = ~color_wards(WARD),
                    fillOpacity = 0.3,
                ) |>
                addCircleMarkers(
                    group = "baseMarkers",
                    data = data_modeshare,
                    radius = 9,
                    weight = 1,
                    color = "#555",
                    fillColor = "#777",
                    layerId = ~uid,
                ) |>
                setMaxBounds(
                    initial_bounds[["xmin"]],
                    initial_bounds[["ymin"]],
                    initial_bounds[["xmax"]],
                    initial_bounds[["ymax"]]
                )
        })
    
    # Welcome modal
    observeEvent(
        input$sidebarNav,
        {
            if (input$sidebarNav == "map") {
                # Show welcome message
                showModal(
                    modalDialog(
                        title = NULL,
                        easyClose = TRUE,
                        size = "m",
                        footer = NULL,
                        p(
                            "
Welcome to the Corvallis Active Transportation Mode Share Explorer! Here you can peruse mode share data for Corvallis, Oregon, slice and dice it in different ways, and see a representative mode share for locations around the city.
                            "
                        ),
                        p(
                            style = "text-align: center;",
                            modalButton(
                                "Get started"
                            )
                        )
                        
                    )
                )
            }
        },
        once = TRUE
    )
    
    # Handle changes to filter inputs
    observe({
        req(input$sidebarNav == "map")
        
        inputs_list <- reactiveValuesToList(filter_inputs)
        
        # Allow map clicks on locations that are not highlighted
        if (! is.null(inputs_list$uid)) {
            args <- list(data_modeshare, uid = inputs_list$uid)
        } else {
            args <- c(list(data_modeshare), inputs_list)
        }
        
        subset <- do.call(get_data_modeshare_subset, args)
        
        data_modeshare_subset(subset)
    })
    
    # Update which markers are highlighted when the modeshare subset changes
    observeEvent(data_modeshare_subset(), {
        data <- data_modeshare_subset()

        leafletProxy("mapMain") |>
            clearGroup("highlightMarkers") |>
            addCircleMarkers(
                group = "highlightMarkers",
                data = data,
                radius = 9,
                weight = 1,
                color = "#555",
                opacity = 1,
                fillColor = "darkorange",
                fillOpacity = 1,
                # This layerId has to be different from the base markers
                layerId = ~uid_highlighted,
            )
    })
    
    # Handle map clicks
    # Inspired by https://medium.com/ibm-data-ai/capture-and-leverage-mouse-locations-and-clicks-on-leaflet-map-6d8601e466a5
    observeEvent(input$mapMain_click, {
        marker_click <-input$mapMain_marker_click
        map_click <- input$mapMain_click
        
        if (
            ! is.null(marker_click)
            && all(
                unlist(marker_click[c('lat','lng')]) ==
                    unlist(map_click[c('lat','lng')])
            )
        ) {
            # Marker was clicked
            filter_inputs$uid <- marker_click$id
        } else {
            # Basemap was clicked
            filter_inputs$uid <- NULL
        }
    })
    
    # Handle bike infrastructure filter input
    observeEvent(input$inputSelectBikeInfra, {
        if (input$inputSelectBikeInfra == "all") {
            filter_inputs$infra <- NULL
        } else {
            filter_inputs$infra <- input$inputSelectBikeInfra
        }
    })
    
    # Handle ward filter input
    observeEvent(input$inputSelectWard, {
        if (input$inputSelectWard == "all") {
            filter_inputs$ward <- NULL
        } else {
            filter_inputs$ward <- input$inputSelectWard
        }
    })
    
    # Trips per hour
    output$valueBoxTotTrips <-
        renderValueBox({
            data <- data_modeshare_summary()
            
            valueBox(
                format(data$trip_count, big.mark = ","),
                "Trips per hour",
                icon = icon("route")
            )
        })
    
    # Active vs Motor Vehicle mode share
    output$plotPctModeShare <-
        renderPlot({
            data <-
                data_modeshare_summary() |>
                select(active_pct, mv_pct) |>
                rename(
                    "Active trips" = active_pct,
                    "Motor vehicle trips" = mv_pct
                ) |>
                pivot_longer(
                    cols = everything(),
                    names_to = "Trips",
                    values_to = "Percent"
                ) |>
                mutate(
                    Trips = factor(
                        Trips,
                        levels = c("Motor vehicle trips", "Active trips")
                    )
                )
            data |>
                ggplot(
                    aes(
                        x = Percent,
                        y = factor(1),
                        fill = Trips,
                    )
                ) +
                geom_col() +
                geom_text_repel(
                    aes(
                        label = paste(
                            fill,
                            ": ",
                            round(after_stat(x), 1),
                            "%",
                            sep = ""
                        )
                    ),
                    seed = 1,
                    position = position_stacknudge(
                        vjust = 0.5,
                        x = c(5, -5),
                        y = c(0.9, -0.9),
                    ),
                    segment.curvature = -1e-20,
                    arrow = arrow(
                        length = unit(0.05, "npc"),
                        type = "closed"
                    )
                ) +
                xlab("") +
                ylab("") +
                theme_void() +
                theme(
                    legend.position = "none",
                    plot.margin = margin(b = 10)
                )
        })
    
    # Active modes split out
    output$plotPctActiveModeShare <-
        renderPlot({
            data <-
                data_modeshare_summary() |>
                select(bike_pct, ped_pct, roll_pct) |>
                rename(
                    "Bicycle" = bike_pct,
                    "Pedestrian" = ped_pct,
                    "Other" = roll_pct
                ) |>
                pivot_longer(
                    cols = everything(),
                    names_to = "Mode",
                    values_to = "Percent"
                ) |>
                mutate(
                    Mode = factor(
                        Mode,
                        levels = c("Other", "Pedestrian", "Bicycle")
                    )
                )
            
            maxpct_summary <- max(data$Percent)
            
            data |>
                ggplot(
                    aes(
                        x = Percent,
                        y = Mode
                    )
                ) +
                geom_col(
                    aes(
                        fill = Mode
                    )
                ) +
                geom_text(
                    aes(
                        label = paste(
                            round(after_stat(x), 1),
                            "%",
                            sep = ""
                        )
                    ),
                    hjust = -0.25
                ) +
                xlim(0, maxpct_summary * 1.1) +
                ylab("") +
                theme_void() +
                theme(
                    axis.text.y = element_text(
                        hjust = 1
                    ),
                    legend.position = "none",
                    plot.margin = margin(b = 10)
                )
                
        })
    
    # Data subset details
    output$tableDetails <-
        render_gt({
            data <-
                data_modeshare_subset() |>
                st_drop_geometry()
            
            if (nrow(data) == 1) {
                title <- data$site_desc
                data <-
                    data |>
                    summarize(
                        Walkscore = mean(walkscore),
                        Bikescore = mean(bikescore)
                    )
            } else {
                title <- sprintf(
                    "%s locations",
                    nrow(data)
                )
                data <-
                    data |>
                    summarize(
                        "Average Walkscore" = round(mean(walkscore)),
                        "Average Bikescore" = round(mean(bikescore))
                    )
            }
            
            data |>
                pivot_longer(
                    cols = everything(),
                    names_to = "Detail",
                    values_to = "Value"
                ) |>
                gt(
                    rowname_col = "Detail"
                ) |>
                tab_header(
                    title = title
                ) |>
                tab_options(
                    column_labels.hidden = TRUE,
                    table.width = "100%"
                )
        })
}
