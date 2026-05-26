# Server function
function(input, output, session) {
    # Sidebar
    output$sidebarInputs <-
        renderUI({
            if (input$sidebarNav == "map") {
                selectInput(
                    "inputSelectWard",
                    "Filter by city ward",
                    choices = get_choices_ward()
                )
            }
        })
    
    # Body
    data_wards <- get_data_wards()
    data_modeshare <- get_data_modeshare()
    data_modeshare_subset <- reactiveVal(data_modeshare)
    data_modeshare_summary <- reactive({
        get_data_modeshare_summary(data_modeshare_subset())
    })
    
    color_wards <- colorFactor("viridis", data_wards$WARD)
    
    # Initial map output
    output$mapMain <-
        renderLeaflet({
            leaflet() |>
                addProviderTiles(providers$Esri.WorldGrayCanvas) |>
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
                )
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
            subset <-
                data_modeshare |>
                get_data_modeshare_subset(
                    uid = marker_click$id
                )
            
            data_modeshare_subset(subset)
        } else {
            # Basemap was clicked
            subset <-
                data_modeshare |>
                get_data_modeshare_subset(
                    ward = isolate(input$inputSelectWard)
                )
            
            data_modeshare_subset(subset)
        }
    })
    
    # Handle inputs
    observe({
        if (
            ! is.null(input$inputSelectWard)
            && input$inputSelectWard != "all"
        ) {
            subset <-
                data_modeshare |>
                get_data_modeshare_subset(
                    ward = input$inputSelectWard
                )

            data_modeshare_subset(subset)
        } else {
            data_modeshare_subset(data_modeshare)
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
    
    #
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
