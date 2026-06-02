# Server function
function(input, output, session) {
    # Data
    data_street_infra <- get_data_street_infra()
    data_mu_paths <- get_data_mu_paths()
    data_wards <- get_data_wards()
    
    data_modeshare <- get_data_modeshare()
    data_modeshare_subset <- reactiveVal(data_modeshare)
    data_modeshare_summary <- reactive({
        get_data_modeshare_summary(data_modeshare_subset())
    })
    
    filter_inputs <- reactiveValues(
        infra = NULL,
        other = NULL,
        uid = NULL,
        ward = NULL
    )
    
    north_arrow <- div(
        style = "display: flex; flex-direction: column; color: #777; margin-top: 1.4rem;",
        icon(
            "location-arrow",
            class = "fa-solid fa-2xl fa-rotate-by",
            style = "margin-right: 0; --fa-rotate-angle: -45deg;"
        ),
        span(
            style = "display: block; color: #777; font-family: Source Sans Pro; font-size: 2.4rem; font-weight: 700; line-height: 1.5; text-align: center; width: 100%;",
            "N"
        )
    )
    color_wards <- colorFactor(
        palette.colors(
            n = 9,
            palette = "Okabe-Ito"
        ),
        data_wards$WARD
    )
    initial_bounds <- st_bbox(data_wards)
    
    # Sidebar
    output$sidebarInputs <-
        renderUI({
            if (input$sidebarNav == "map" | input$sidebarNav == "chart") {
                tagList(
                    div(
                        p(
                            class = "shiny-input-container",
                            style = "font-size: 1.8rem;",
                            strong("Data subsets"),
                            actionLink(
                                style = "display: inline-block; margin-left: 1rem; font-size: 1.3rem;",
                                "actionFilterReset",
                                "Reset"
                            )
                        ),
                        selectInput(
                            "inputSelectBikeInfra",
                            "Bike infrastructure",
                            choices = get_choices_bikeinfra(),
                            selected = isolate(input$inputSelectBikeInfra)
                        ),
                        selectInput(
                            "inputSelectWard",
                            "City ward",
                            choices = get_choices_ward(),
                            selected = isolate(input$inputSelectWard)
                        ),
                        selectInput(
                            "inputSelectOther",
                            "Other subsets",
                            choices = get_choices_other(),
                            selected = isolate(input$inputSelectOther)
                        )
                    )
                )
            }
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
                        get_content_welcome(),
                        p(
                            style = "text-align: center;",
                            modalButton(
                                "Let's go"
                            )
                        )
                        
                    )
                )
            }
        },
        once = TRUE
    )
    
    # Initial map output
    output$mapMain <-
        renderLeaflet({
            leaflet() |>
                addProviderTiles(providers$CartoDB.Positron) |>
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
                    group = "baseWards",
                    data = data_wards,
                    stroke = TRUE,
                    weight = 2,
                    color = "#999",
                    opacity = 0.2,
                    fillColor = ~color_wards(WARD),
                    fillOpacity = 0.1,
                ) |>
                addPolylines(
                    group = "baseStreetLines",
                    data = data_street_infra,
                    weight = 2,
                    opacity = 0.3,
                    color = "#555"
                ) |>
                addPolylines(
                    group = "baseMUPaths",
                    data = data_mu_paths,
                    weight = 2,
                    opacity = 0.3,
                    color = "#555"
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
                fitBounds(
                    initial_bounds[["xmin"]],
                    initial_bounds[["ymin"]],
                    initial_bounds[["xmax"]],
                    initial_bounds[["ymax"]]
                ) |>
                setMaxBounds(
                    initial_bounds[["xmin"]],
                    initial_bounds[["ymin"]],
                    initial_bounds[["xmax"]],
                    initial_bounds[["ymax"]]
                )
        })
    
    # Handle changes to filter inputs
    observe({
        req(input$sidebarNav == "map" | input$sidebarNav == "chart")
        
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
    
    # Handle reset link
    observeEvent(input$actionFilterReset, {
        filter_inputs$uid <- NULL
        
        updateSelectInput(
            "inputSelectBikeInfra",
            selected = "all",
            session = session
        )
        updateSelectInput(
            "inputSelectWard",
            selected = "all",
            session = session
        )
        updateSelectInput(
            "inputSelectOther",
            selected = "none",
            session = session
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
                fillOpacity = 0.8,
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
            
            leafletProxy("mapMain") |>
                clearGroup("highlightStreetLines")
        } else {
            filter_inputs$infra <- input$inputSelectBikeInfra
            
            if (input$inputSelectBikeInfra == "Multi-Use Path") {
                data_infra_highlight <- data_mu_paths
            } else {
                data_infra_highlight <-
                    data_street_infra |>
                    filter(
                        BIKE_FAC == input$inputSelectBikeInfra
                    )
            }
            
            leafletProxy("mapMain") |>
                clearGroup("highlightStreetLines") |>
                addPolylines(
                    group = "highlightStreetLines",
                    data = data_infra_highlight,
                    weight = 2,
                    opacity = 0.7,
                    color = "darkred"
                )
        }
        filter_inputs$uid = NULL
    })
    
    # Handle ward filter input
    observeEvent(input$inputSelectWard, {
        if (input$inputSelectWard == "all") {
            filter_inputs$ward <- NULL
            
            leafletProxy("mapMain") |>
                clearGroup("highlightWards")
        } else {
            filter_inputs$ward <- input$inputSelectWard
            
            data_wards_highlight <-
                data_wards |>
                filter(
                    WARD == input$inputSelectWard
                )
            
            leafletProxy("mapMain") |>
                clearGroup("highlightWards") |>
                addPolygons(
                    group = "highlightWards",
                    data = data_wards_highlight,
                    stroke = TRUE,
                    weight = 2,
                    color = "#999",
                    opacity = 0.6,
                    dashArray = "4",
                    fillColor = ~color_wards(WARD),
                    fillOpacity = 0.35,
                )
        }
        filter_inputs$uid = NULL
    })
    
    # Handle "other" filter input
    observeEvent(input$inputSelectOther, {
        if (input$inputSelectOther == "none") {
            filter_inputs$other <- NULL
        } else {
            filter_inputs$other <- input$inputSelectOther
        }
        filter_inputs$uid = NULL
    })
    
    # Trips per hour
    output$valueBoxTotTrips <-
        renderValueBox({
            data <- data_modeshare_summary()
            
            valueBox(
                format(data$trip_count, big.mark = ","),
                "Trips counted per hour",
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
                xlim(0, maxpct_summary * 1.3) +
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
                        "Active trips counted per hour" = totAT_hr,
                        "Motor vehicle trips counted per hour" = totMV_hr,
                        "Walk Score" = walkscore,
                        "Bike Score" = bikescore
                    )
            } else {
                title <- sprintf(
                    "%s locations",
                    nrow(data)
                )
                data <-
                    data |>
                    summarize(
                        "Total active trips counted per hour" = sum(totAT_hr),
                        "Total motor vehicle trips counted per hour" = sum(totMV_hr),
                        "Average Walk Score" = round(mean(walkscore)),
                        "Average Bike Score" = round(mean(bikescore))
                    )
            }
            
            data[] <- lapply(data, function(x) format(x, big.mark = ","))
            
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
                    table.width = "100%",
                    table.font.names = c("Source Sans Pro", "sans-serif"),
                    table.font.size = 13,
                    heading.title.font.size = 16
                )
        })
    
    # Chart with customizable X and Y
    output$plotInteractiveChart <-
        renderPlotly({
            data <-
                data_modeshare_subset() |>
                rename_vars() |>
                mutate(
                    text = paste0(
                        "<span style='display: block; padding: 0.5rem; text-align: left;'>",
                        "Location: ", Location, "<br>",
                        input$inputSelectX, ": ", format(round(!!input$inputSelectX, 1), big.mark = ","), "<br>",
                        input$inputSelectY, ": ", format(round(!!input$inputSelectY, 1), big.mark = ","),
                        "</span>"
                    )
                )
            
            plot <-
                data |>
                ggplot(
                    aes(
                        x = !!input$inputSelectX,
                        y = !!input$inputSelectY
                    )
                ) +
                suppressWarnings(geom_point(
                    aes(
                        text = text
                    ),
                    shape = 21,
                    color = "#555",
                    fill = "darkorange",
                    size = 5,
                    alpha = 0.6
                ))
            
            if (!!input$inputCheckboxTrendLine) {
                smooth_method <- ifelse(nrow(data) < 10, "lm", "loess")
                
                plot <-    
                    plot +
                    geom_smooth(
                        formula = y ~ x,
                        method = smooth_method,
                        na.rm = TRUE,
                        se = FALSE,
                    )
            }
            
            plot <-
                plot +
                ylim(0, NA) +
                theme(
                    axis.title = element_text(
                        family = "Source Sans Pro",
                        size = 14
                    ),
                    axis.title.x = element_text(
                        margin = margin(t = 12)
                    ),
                    axis.title.y = element_text(
                        margin = margin(r = 12)
                    ),
                    axis.text = element_text(
                        family = "Source Sans Pro",
                        size = 12
                    )
                )
            
            ggplotly(
                plot,
                tooltip = "text"
            ) |>
                layout(
                    hoverlabel = list(
                        bgcolor = "white",
                        font = list(
                            size = 12,
                            color = "black"
                        )
                    )
                ) |>
                config(displayModeBar = F)
        })
}
