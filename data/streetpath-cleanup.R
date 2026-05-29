library(tidyverse)

data <- read_csv("data/modeshare_streetpath_raw.csv")

data <-
    data |>
    select(site_id, BIKE_FAC, MU_PATH) |>
    mutate(
        across(
            where(is.character),
            ~ na_if(., "")
        )
    ) |>
    mutate(
        BIKE_FAC = ifelse(is.na(BIKE_FAC), "None", BIKE_FAC),
        MU_PATH = ifelse(is.na(MU_PATH), NA, TRUE),
        trueval = TRUE,
    ) |>
    unique() |>
    pivot_wider(
        names_from = BIKE_FAC,
        values_from = trueval,
        values_fill = NA
    ) |>
    rename(
        "Multi-Use Path" = MU_PATH
    ) |>
    pivot_longer(
        cols = ! c(site_id),
        names_to = "bikeinfra",
        values_to = "trueval",
        values_drop_na = TRUE
    ) |>
    select(site_id, bikeinfra)


# Save to a new file
write.csv(
    data,
    "data/bikeinfra.csv",
    row.names = FALSE
)
