# Download city wards data
get_data_wards <- memoise::memoise(function() {
    read_sf("https://services6.arcgis.com/NNPaUnXVoJt8FVVE/arcgis/rest/services/Wards/FeatureServer/0/query?outFields=*&where=1%3D1&f=geojson")
})

# Load modeshare data
get_data_modeshare <- memoise::memoise(function() {
    read_csv("data/modeshare_plus.csv") |>
        mutate(
            totMV_pct = totMV_hr / tot_trips_hr,
            totbike_pct = totbike_hr / tot_trips_hr,
            ped_pct = ped_hr / tot_trips_hr,
            tot_roll_pct = tot_roll_hr / tot_trips_hr,
            totAT_pct = totAT_hr / tot_trips_hr
        ) |>
        mutate(
            uid = site_id,
            uid_highlighted = paste0(site_id, "_highlighted"),
        ) |>
        st_as_sf(
            coords = c("longitude", "latitude"),
            crs = 4326 # Original data is in the WGS84 geographic coordinate system
        )
})

# Load bike infrastructure data
get_data_bikeinfra <- memoise::memoise(function() {
    read_csv("data/bikeinfra.csv")
})

# Generate summary data from a set of modeshare data
get_data_modeshare_summary <- function(data) {
    data |>
        st_drop_geometry() |>
        summarize(
            bike_count = sum(totbike_hr, na.rm = TRUE),
            ped_count = sum(ped_hr, na.rm = TRUE),
            roll_count = sum(tot_roll_hr, na.rm = TRUE),
            active_count = bike_count + ped_count + roll_count,
            mv_count = sum(totMV_hr, na.rm = TRUE),
            trip_count = sum(tot_trips_hr, na.rm = TRUE),
            bike_pct = (bike_count / trip_count) * 100,
            ped_pct = (ped_count / trip_count) * 100,
            roll_pct = (roll_count / trip_count) * 100,
            active_pct = (active_count / trip_count) * 100,
            mv_pct = (mv_count / trip_count) * 100,
        )
}

# Generate a subset of modeshare data
get_data_modeshare_subset <- function(
    data,
    infra = NULL,
    uid = NULL,
    ward = NULL
) {
    if (! is.null(infra)) {
        data <-
            data |>
            filter_by_infra(infra)
    }
    if (! is.null(uid)) {
        data <-
            data |>
            filter_by_uid(uid)
    }
    if (! is.null(ward)) {
        data <-
            data |>
            filter_by_ward(ward)
    }
    
    data
}

# Filter modeshare data by type of bike infrastructure
filter_by_infra <- function(data, infra) {
    data_infra <- get_data_bikeinfra()
    
    if (infra != "all") {
        data |>
            inner_join(
                data_infra,
                by = join_by(site_id)
            ) |>
            filter(
                bikeinfra == infra
            )
    } else {
        data
    }
}

# Filter modeshare data by the unique ID used on the map
filter_by_uid <- function(data, id) {
    # The layerID of the map marker might have a "_highlighted" suffix
    if (str_detect(id, "_highlighted")) {
        id <- unlist(strsplit(id, "_"))[1]
    }
    
    data |>
        filter(
            uid == id
        )
}

# Filter modeshare data by ward number
filter_by_ward <- function(data, wardId) {
    if (wardId != "all") {
        data |>
            filter(
                ward == wardId
            )
    } else {
        data
    }
}

# Options for the Filter by city ward input
get_choices_ward <- function() {
    data <- get_data_wards()
    setNames(
        rev(append(rev(data$WARD), "all")),
        c("All wards", "Ward 1", "Ward 2", "Ward 3", "Ward 4", "Ward 5", "Ward 6", "Ward 7", "Ward 8", "Ward 9")
    )
}

# Options for the Filter by bike infrastructure input
get_choices_bikeinfra <- function() {
    data <- get_data_bikeinfra()
    bikeinfra <- sort(unique(data$bikeinfra))
    setNames(
        rev(append(rev(bikeinfra), "all")),
        rev(append(rev(bikeinfra), "All infrastructure types"))
    )
}

# Choices for variables in X and Y on the interactive chart
get_choices_axis <- function() {
    data <-
        get_data_modeshare() |>
        st_drop_geometry() |>
        select(
            totAT_hr,
            totAT_pct,
            totbike_hr,
            totbike_pct,
            ped_hr,
            ped_pct,
            tot_roll_hr,
            tot_roll_pct,
            totMV_hr,
            totMV_pct,
            tot_trips_hr,
            walkscore,
            bikescore
        ) |>
        relocate(
            totAT_hr,
            totAT_pct,
            totbike_hr,
            totbike_pct,
            ped_hr,
            ped_pct,
            tot_roll_hr,
            tot_roll_pct,
            totMV_hr,
            totMV_pct,
            tot_trips_hr,
            walkscore,
            bikescore
        ) |>
        rename_vars()
        
    data
}

# Change column names to human-readable form
rename_vars <- function(modeshare_data) {
    labels <- c(
        "Total active trips per hour" = "totAT_hr",
        "Active trips mode share %" = "totAT_pct",
        "Bike trips per hour" = "totbike_hr",
        "Bike mode share %" = "totbike_pct",
        "Pedestrian trips per hour" = "ped_hr",
        "Pedestrian mode share %" = "ped_pct",
        "Other active trips per hour" = "tot_roll_hr",
        "Other active trips mode share %" = "tot_roll_pct",
        "Motor vehicle trips per hour" = "totMV_hr",
        "Motor vehicle mode share %" = "totMV_pct",
        "Total trips per hour" = "tot_trips_hr",
        "Walkscore" = "walkscore",
        "Bikescore" = "bikescore"
    )
    
    modeshare_data |>
        rename(any_of(labels))
}
