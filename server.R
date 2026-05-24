# Server function
function(input, output, session) {
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
        if (input$inputSelectWard != "all") {
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
                    )
                ) +
                geom_bar(
                    aes(
                        fill = Trips,
                    ),
                    stat = "identity",
                    position = "fill"
                ) +
                xlab("") +
                ylab("") +
                guides(
                    fill = guide_legend(reverse = TRUE)
                ) +
                theme_void() +
                theme(
                    legend.title = element_blank(),
                    legend.position = "bottom",
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
                ylab("") +
                guides(
                    fill = guide_legend(reverse = TRUE)
                ) +
                theme_void() +
                theme(
                    legend.title = element_blank(),
                    legend.position = "bottom",
                )
                
        })
    
    # Total trips
    output$valueBoxTotTrips <-
        renderValueBox({
            data <- data_modeshare_summary()
            
            valueBox(
                format(data$trip_count, big.mark = ","),
                "Total trips",
            )
        })
}
