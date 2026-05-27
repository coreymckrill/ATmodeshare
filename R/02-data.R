# Download city wards data
get_data_wards <- memoise::memoise(function() {
    read_sf("https://services6.arcgis.com/NNPaUnXVoJt8FVVE/arcgis/rest/services/Wards/FeatureServer/0/query?outFields=*&where=1%3D1&f=geojson")
})

# Load modeshare data
get_data_modeshare <- memoise::memoise(function() {
    read_csv("data/modeshare_plus.csv") |>
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
    read_csv("data/modeshare_plus.csv")
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
    ward = NULL,
    uid = NULL
) {
    if (! is.null(ward)) {
        data <-
            data |>
            filter_by_ward(ward)
    }
    if (! is.null(uid)) {
        data <-
            data |>
            filter_by_uid(uid)
    }
    
    data
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
    data_wards <- get_data_wards()
    setNames(
        rev(append(rev(data_wards$WARD), "all")),
        c("All wards", "Ward 1", "Ward 2", "Ward 3", "Ward 4", "Ward 5", "Ward 6", "Ward 7", "Ward 8", "Ward 9")
    )
}
