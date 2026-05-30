library(tidyverse)

data <- read_csv("data/modeshare.csv")

# Fix incorrect wards
data[data$site_id == "602.1", "ward"] <- 6
data[data$site_id == "702", "ward"] <- NA

# Add 14th & Monroe to "Locations near OSU"
data[data$site_id == "212", "osu_city"] <- "osu"

# Offset 601.1 from 601 so they are both clickable
data[data$site_id == "602.1", "latitude"] <- 44.589177
data[data$site_id == "602.1", "longitude"] <- -123.247064

# Combine am and pm, calculate trips per hour
combined_counts <-
    data |>
    group_by(site_id) |>
    summarize(
        hours = sum(hours, na.rm = TRUE),
        moto = sum(moto, na.rm = TRUE),
        bus = sum(bus, na.rm = TRUE),
        workveh = sum(workveh, na.rm = TRUE),
        car = sum(car, na.rm = TRUE),
        truck = sum(truck, na.rm = TRUE),
        totMV = sum(totMV, na.rm = TRUE),
        bike = sum(bike, na.rm = TRUE),
        ebike = sum(ebike, na.rm = TRUE),
        totbike = sum(totbike, na.rm = TRUE),
        ped = sum(ped, na.rm = TRUE),
        escoot = sum(escoot, na.rm = TRUE),
        othermicro = sum(othermicro, na.rm = TRUE),
        tot_roll = sum(tot_roll, na.rm = TRUE),
        totAT = sum(totAT, na.rm = TRUE),
        tot_trips = sum(tot_trips, na.rm = TRUE),
    )
data <-
    data |>
    select(!ampm) |>
    select(site_id:latitude) |>
    unique() |>
    left_join(
        combined_counts,
        join_by(site_id)
    ) |>
    mutate(
        moto_hr = round(moto / hours),
        bus_hr = round(bus / hours),
        workveh_hr = round(workveh / hours),
        car_hr = round(car / hours),
        truck_hr = round(truck / hours),
        totMV_hr = round(totMV / hours),
        bike_hr = round(bike / hours),
        ebike_hr = round(ebike / hours),
        totbike_hr = round(totbike / hours),
        ped_hr = round(ped / hours),
        escoot_hr = round(escoot / hours),
        othermicro_hr = round(othermicro / hours),
        tot_roll_hr = round(tot_roll / hours),
        totAT_hr = round(totAT / hours),
        tot_trips_hr = round(tot_trips / hours),
    )
    

# Add walkscore data
walkscore <-
    read_csv("data/walkscore.csv") |>
    select(site_id, walkscore, bikescore) |>
    unique()
data <-
    data |>
    inner_join(
        walkscore,
        join_by(site_id)
    )


# Save to a new file
write.csv(
    data,
    "data/modeshare_plus.csv",
    row.names = FALSE
)
